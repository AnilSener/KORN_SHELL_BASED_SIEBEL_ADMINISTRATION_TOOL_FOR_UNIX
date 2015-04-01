#!/usr/bin/ksh
########################################################
# Name:
# srf_dep.ksh
#
# Description:
# This script is to execute a wizard functionality to enable repository deployment.
# Created By:
# Siebel Expert Services
#
# Version : 0.1
#
# Update History:
#======================================================
# 15/05/2013 Expert Services (v0.1)
#------------------------------------------------------
# Created
#======================================================
#
. ./init.ksh
. ./util.ksh
#------------------------------------------------------#

pref_lang=$1
condition=""
set -A srfdirs;
set -A srffiles;
get_sieblangcode;
get_siebappconffile;
set -A REQ_SRFFILENAMES;
set -A skippedlangs;
get_webservers;
get_webusers;
get_webpasswords;
get_swsehomedirs

i=0;m=0;
while [[ "$i"<"${#SIEBLANGCODES[*]}" ]];
do
condition=""
until [[ "$condition" == "y" || "$condition" == "n" || "$condition" == "skip" ]];
do

echo "\n The default directory location for the SRF compiled in ${SIEBLANGCODES[$i]} to be imported is $DEP_DIR/${SIEBLANGCODES[$i]} (Please enter \"skip\" to skip SRF deployment for ${SIEBLANGCODES[$i]} language or click \"CTRL+C\" to return to the main menu)(Please select y/n) : \c"
trap "return_main" 2
read condition
done



if [[ "$condition" == "y" ]];
then

cd /
srfavail=0
until [[ ! -z "${srfdirs[$i]}" && -d "${srfdirs[$i]}" && "$srfavail" -eq 1 ]];
do
echo "\n Please provide the directory location for the SRF compiled in ${SIEBLANGCODES[$i]} to be imported (Please click \"CTRL+C\" to return to the main menu): \c"
trap "return_main" 2
read srfdirs[$i]
cd ${srfdirs[$i]}
OUT=$(ls -l *.srf)
if [[ ! -z "$OUT" ]];
then
srfavail=1
else
srfavail=0
echo "\n There is not any .srf file located under the selected directory. Please provide another directory !!!"
fi
done

skippedlangs[$i]="n"
cd $BASE_DIR

else
srfdirs[$i]=$DEP_DIR/${SIEBLANGCODES[$i]}

if [[ "$condition" == "skip" ]];
then
skippedlangs[$i]="y"
echo "\n You have preffered to skip SRF deployment for ${SIEBLANGCODES[$i]} language !!!"
else
skippedlangs[$i]="n"
fi

fi

if [[ "${skippedlangs[$i]}" == "n" ]];
then

k=0;
while [[ "$k"<"${#SIEBAPPCONFFILES[*]}" ]];
do
conffilelang=${SIEBAPPCONFFILES[$k]}
conffilelang=${conffilelang%/*}
conffilelang=${conffilelang##*/}

if [[ "$conffilelang" == "${SIEBLANGCODES[$i]}" ]];
then
REQ_SRFFILENAMES[$m]=${SIEBLANGCODES[$i]}/$(grep "RepositoryFile" ${SIEBAPPCONFFILES[$k]}|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
m=$(($m+1))
fi
k=$(($k+1))
done

set -A validsrfs;
p=0;k=0
while [[ "$p"<"${#REQ_SRFFILENAMES[*]}" ]];
do
if [[ "${REQ_SRFFILENAMES[$p]}" == ${SIEBLANGCODES[$p]}* ]];
then
srf=${REQ_SRFFILENAMES[$p]}
srf=${srf##*/}
set -A REQ_SRFFILENAMES ""

validsrfs[$k]=$srf
k=$(($k+1))

fi
p=$(($p+1))
done

cd ${srfdirs[$i]}
OUT=$(ls -l *.srf|awk '/:/ {print $9}')
set -A srffileslist
n=0;
for x in $OUT
do
srffileslist[$n]=$(echo "$x")
n=$(($n+1))
done

selected_file=${srffiles[$i]}
containsElement "$selected_file" "srffileslist"
ret_val=$?
proceed=1;

while [[ "$proceed" -eq 0 || "$ret_val" -eq 0 ]];
do
echo "\n .srf files located in ${srfdirs[$i]} directory:"
echo "#----------------------------------------------------#" 
for valids in ${validsrfs[*]}
do
ls -l *.srf|awk '/:/ {print $9,$7,$6,$8}'|grep $valids
done
srfname="siebel_sia.srf"
echo "\n Please provide the SRF name (.srf file) compiled in ${SIEBLANGCODES[$i]} (.srf file) to be imported from the list above(Please click "CTRL+C" to return to the main menu): \c"
trap "return_main" 2
read  srffiles[$i] 

selected_file=${srffiles[$i]}
containsElement "$selected_file" "srffileslist"
ret_val=$?

containsElement "$selected_file" "validsrfs"
ret_val=$?
set -A validsrfs ""

if [[ "$ret_val" -eq 0 ]];
then
echo "\n An srf file with \"$selected_file\" name doesn't exist in actively used Application Configuration files for this language. Please select another file!"    
fi
done

fi

i=$(($i+1))
done

#Below is the piece of code where all Enterprise Servers are stopped."
cd $BASE_DIR

containsElement "n" "skippedlangs"
langavail=$?

if [[ "$langavail" -eq 1 ]];
then
autostop_option=""
until [[ "$autostop_option" == "y" || "$autostop_option" == "n" ]];
do
	clear;
	echo "\n ATTENTION!!!: All enterprise servers should be shutdown before starting SRF deployment, would you like them to be shutdown automatically (y/n)?
(Please click "CTRL+C" to return to the main menu): \c"
trap "return_main" 2
	read autostop_option
done

if [[ "$autostop_option" == "y" ]];
then
stop_all_ent_servers;
exit_status=$?
	if [[ "$exit_status" -eq 0 ]];
	then
	echo "\n All Enterprise Servers are down."
	fi
fi
fi

get_entservers "Running";
if [[ -z "${ENTSERVERS[*]}" && "$exit_status" -eq 0 && "$langavail" -eq 1 ]];
then

host_server=$(hostname);
upper_host_server=$(echo $host_server|tr [a-z] [A-Z])
postfix=$(date '+_%d_%m_20%y_%H_%M_%S')

clear;
echo "\n #------------------------------------------------------#"
echo "\n Below is the srf deployment plan to the enterprise servers:"

start_answer=""
until [[ "$start_answer" == "y" ]];  
do
clear;
echo "\n #------------------------------------------------------#"
i=0;
while [[ "$i"<"${#SIEBLANGCODES[*]}" ]];
do
if [[ "${skippedlangs[$i]}" == "n" ]];
then
echo "\n BACKUP $SIEBEL_HOME/objects/${SIEBLANGCODES[$i]}/${srffiles[$i]} AS $SIEBEL_HOME/objects/${SIEBLANGCODES[$i]}/${srffiles[$i]}$postfix"
echo "\n COPY ${srfdirs[$i]}/${srffiles[$i]} TO $SIEBEL_HOME/objects/${SIEBLANGCODES[$i]}/${srffiles[$i]}"
fi
i=$(($i+1))
done

echo "\n #------------------------------------------------------#"
echo "\n If you are willing to copy files according to settings above please enter \"y\", otherwise please click \"CTRL+C\" to return to the main menu: \c" 
trap "return_main" 2
read start_answer
done


echo "\n #------------------------------------------------------#"
echo "\n Starting to copy srf files..."

get_entservers;

i=0
while [[ "$i"<"${#SIEBLANGCODES[*]}" ]];
do

if [[ "${skippedlangs[$i]}" == "n" ]];
then

j=0
while [[ "$j"<"${#ENTSERVERS[*]}" ]];
do

ENTHOSTNAME=${ENTSERVERS[$j]}
ENTHOSTNAME=${ENTHOSTNAME##*/}

if [[ "$ENTHOSTNAME" != "$host_server" && "$ENTHOSTNAME" != "$upper_host_server" ]];
then

ftp -n -i -v $ENTHOSTNAME
user $ENTSERVERUSER $ENTSERVERPASSWORD 
bin
cd $SIEBEL_HOME/objects/${SIEBLANGCODES[$i]} 
rename ${srffiles[$i]} ${srffiles[$i]}$postfix
lcd ${srfdirs[$i]}
put ${srffiles[$i]}
bye  
exit_status=$?

else
cp $SIEBEL_HOME/objects/${SIEBLANGCODES[$i]}/${srffiles[$i]} $SIEBEL_HOME/objects/${SIEBLANGCODES[$i]}/${srffiles[$i]}$postfix 
cp ${srfdirs[$i]}/${srffiles[$i]} $SIEBEL_HOME/objects/${SIEBLANGCODES[$i]}/${srffiles[$i]}
exit_status=$?
fi

j=$(($j+1))
done
fi
i=$(($i+1))
done
fi

if [[ "$langavail" -eq 1 ]];
then

i=0;
while [[ "$i"<"${#SIEBLANGCODES[*]}" ]];
do
if [[ "$exit_status" -eq 0 && -f $SIEBEL_HOME/objects/${SIEBLANGCODES[$i]}/${srffiles[$i]} && "${skippedlangs[$i]}" == "n" ]];
then
echo "\n SRF files for ${SIEBLANGCODES[$i]} language are copied successfully!"
fi
i=$(($i+1))
done

bs_answer=""
until [[ "$bs_answer" == "y" || "$bs_answer" == "n" ]];
do
if [[ "$exit_status" -eq 0 ]];
then
clear;
echo "\n Would you like to generate Browser Scripts for the deployed srf files (y/n)? (Please click "CTRL+C" to return to the main menu): \c"
trap "return_main" 2
read bs_answer
fi
done

autostart_option=""
if [[ "$bs_answer" == "y" ]];
then
cd $SIEBEL_HOME
. ./siebenv.sh
cd $BASE_DIR
i=0;
while [[ "$i"<"${#SIEBLANGCODES[*]}" ]];
do
if [[ "${skippedlangs[$i]}" == "n" ]];
then
scriptgen_conffile="";
k=0;
while [[ "$k"<"${#SIEBAPPCONFFILES[*]}" ]];
do
conffilelang=${SIEBAPPCONFFILES[$k]}
conffilelang=${conffilelang%/*}
conffilelang=${conffilelang##*/}

if [[ "$conffilelang" == "${SIEBLANGCODES[$i]}" ]];
then
srf=${SIEBLANGCODES[$i]}/$(grep "RepositoryFile" ${SIEBAPPCONFFILES[$k]}|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
srf=${srf##*/}

if [[ "$srf" == "${srffiles[$i]}" ]]; 
then
scriptgen_conffile=${SIEBAPPCONFFILES[$k]}
fi
m=$(($m+1))
fi
k=$(($k+1))
done

if [[ ! -z "$scriptgen_conffile" ]];
then
upper_langcode=$(echo ${SIEBLANGCODES[$i]}|tr [a-z] [A-Z])
$SIEBEL_HOME/bin/genbscript $SIEBEL_HOME/bin/$scriptgen_conffile $SIEBEL_HOME/webmaster upper_langcode 
exit_status=$?
fi

if [[ "$exit_status" -eq 0 ]];
then
cd $SIEBEL_HOME/webmaster
browserscript=$(ls -ltr|tail -1|awk '/:/ {print $9}');
echo "\n Browser Scripts in folder $browserscript for ${SIEBLANGCODES[$i]} language are generated."

w=0;
while [[ "$w"<"${#WEBSERVERS[*]}" ]];
do
ftp -n -i -v ${WEBSERVERS[$w]}
user ${WEBSERVERUSERS[$w]} ${WEBSERVERPASSWORDS[$w]}
ascii
cd ${SWSEHOMEDIRS[$i]}
mkdir $browserscript
cd $browserscript 
lcd $SIEBEL_HOME/webmaster/$browserscript 
mput * 
bye
exit_status=$?

bs_completed=0
if [[ "$exit_status" -eq 0 ]];
then
echo "\n Browser Scripts in folder $browserscript which is in ${SIEBLANGCODES[$i]} language are copied to ${SWSEHOMEDIRS[$i]}." 
bs_completed=1
else
echo "\n Browser Scripts in folder $browserscript which is in ${SIEBLANGCODES[$i]} language cannot be copied to ${SWSEHOMEDIRS[$i]}."
bs_completed=0
fi
w=$(($w+1))
done 

cd $BASE_DIR
fi
fi
i=$(($i+1))
done

sleep 5
until [[ "$autostart_option" == "y" || "$autostart_option" == "n" ]];
do
clear;
echo "\n All Enterprise Servers can be opened after SRF deployment, would you like them to be started automatically (y/n)? (Please click "CTRL+C" to return to the main menu): \c"
trap "return_main" 2
read autostart_option
done

else

sleep 5
until [[ "$autostart_option" == "y" || "$autostart_option" == "n" ]];
do
clear;
echo "\n All Enterprise Servers can be opened after repository deployment, would you like them to
be started automatically (y/n)? (Please click "CTRL+C" to return to the main menu): \c"
trap "return_main" 2
read autostart_option
done

fi

if [[ "$autostart_option" == "y" ]];
then
start_all_ent_servers;
exit_status=$?
        if [[ "$exit_status" -eq 0 ]];
        then
        echo "\n All Enterprise Servers are up. Please restart the Web Application Servers manually!!!"
        fi
fi
fi

sleep 5;
answer=""
until [[ "$answer" == "exit" ]];
do
clear;
echo "\n  Please click "CTRL+C" to retun to the main menu or type \"exit\" to terminate the application: \c"
trap "return_main" 2
read answer
done
echo "\n Application is terminated"
exit
