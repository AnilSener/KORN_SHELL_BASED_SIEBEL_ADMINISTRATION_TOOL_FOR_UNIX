#!/usr/bin/ksh
########################################################
# Name:
# bs_dep.ksh
#
# Description:
# This script is to execute a wizard functionality to enable browser script deployment.
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

pref_lang=$1;
condition="";
set -A bsdirs;
set -A bsfiles;
get_sieblangcode;
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

echo "\n The default directory location for the Browser Script Directory in ${SIEBLANGCODES[$i]} to be imported is $DEP_DIR/${SIEBLANGCODES[$i]} (Please enter \"skip\" to skip SRF deployment for ${SIEBLANGCODES[$i]} language or click \"CTRL+C\" to return to the main menu)(Please select y/n) : \c"
trap "return_main" 2
read condition

if [[ "$condition" == "n" ]];
then
cd $DEP_DIR/${SIEBLANGCODES[$i]} 
OUT=$(ls -l | egrep '^d')
if [[ ! -z "$OUT" ]];
then
bsavail=1
else
bsavail=0
echo "\n There is not any directory located under the selected directory. Please provide another directory !!!"
fi
fi

done



if [[ "$condition" == "y" ]];
then

cd /
bsavail=0
until [[ ! -z "${bsdirs[$i]}" && -d "${bsdirs[$i]}" && "$bsavail" -eq 1 ]];
do
echo "\n Please provide the directory location for the generated Browser Script Directory in ${SIEBLANGCODES[$i]} to be imported (Please click \"CTRL+C\" to return to the main menu): \c"
trap "return_main" 2
read bsdirs[$i]
cd ${bsdirs[$i]}
OUT=$(ls -l | egrep '^d')
if [[ ! -z "$OUT" ]];
then
bsavail=1
else
bsavail=0
echo "\n There is not any directory located under the selected directory. Please provide another directory !!!"
fi
done

skippedlangs[$i]="n"
cd $BASE_DIR

else
bsdirs[$i]=$DEP_DIR/${SIEBLANGCODES[$i]}

if [[ "$condition" == "skip" ]];
then
skippedlangs[$i]="y"
echo "\n You have preffered to skip Browser Script deployment for ${SIEBLANGCODES[$i]} language !!!"
else
skippedlangs[$i]="n"
fi

fi

if [[ "${skippedlangs[$i]}" == "n" ]];
then

cd ${bsdirs[$i]}
OUT=$(ls -l | egrep '^d'|awk '/:/ {print $9}')
set -A bsfileslist
n=0;
for x in $OUT
do
bsfileslist[$n]=$(echo "$x")
n=$(($n+1))
done

selected_file=${bsfiles[$i]}
containsElement "$selected_file" "bsfileslist"
ret_val=$?
proceed=1;

while [[ "$proceed" -eq 0 || "$ret_val" -eq 0 ]];
do
echo "\n Directories located in ${bsdirs[$i]} directory:"
echo "#----------------------------------------------------#"
ls -l | egrep '^d'|awk '/:/ {print $9,$7,$6,$8}'
echo "\n Please provide the Browser Script directory name generated in ${SIEBLANGCODES[$i]} to be copied to the Web Servers from the list above(Please click "CTRL+C" to return to the main menu): \c"
trap "return_main" 2
read bsfiles[$i]
selected_file=${bsfiles[$i]}
containsElement "$selected_file" "bsfileslist"
ret_val=$?
done
fi
i=$(($i+1))
done

containsElement "n" "skippedlangs"
langavail=$?

# The code below states the verification fo the copy directories of Browser Scripts to Web Servers
if [[ "$langavail" -eq 1 ]];
then
start_answer=""
until [[ "$bs_answer" == "y" ]];
do
clear;
echo "\n #------------------------------------------------------#"
i=0;
while [[ "$i"<"${#SIEBLANGCODES[*]}" ]];
do
if [[ "${skippedlangs[$i]}" == "n" ]];
then
echo "\n COPY ${bsdirs[$i]}/${bsfiles[$i]} TO ${SWSEHOMEDIRS[$i]} in webserver/s."
fi
i=$(($i+1))
done

echo "\n #------------------------------------------------------#"
echo "\n If you are willing to copy BS directory/directories  to all webservers according to settings above please enter \"y\", otherwise please click \"CTRL+C\" to return to the main menu: \c"
trap "return_main" 2
read bs_answer
done
fi


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

w=0;
while [[ "$w"<"${#WEBSERVERS[*]}" ]];
do
ftp -n -i -v ${WEBSERVERS[$w]}
user ${WEBSERVERUSERS[$w]} ${WEBSERVERPASSWORDS[$w]}
ascii
cd ${SWSEHOMEDIRS[$i]}
mkdir ${bsfiles[$i]}
cd ${bsfiles[$i]}
lcd ${bsdirs[$i]}/${bsfiles[$i]}
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

fi
i=$(($i+1))
done
fi

if [[ "$exit_status" -eq 0 ]];
then
echo "\n Please restart the Web Application Servers manually!!!"
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
