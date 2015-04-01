#!/usr/bin/ksh
########################################################
# Name:
# init.ksh
#
# Description:
# This script is to execute the initialization and the configuration of the Siebel Administration Tool for Solaris 
# Created By:
# Siebel Expert Services
#
# Version : 0.1
#
# Update History:
#======================================================
# 07/05/2013 Expert Services (v0.1)
#------------------------------------------------------
# Created
#======================================================
#
#------------------------------------------------------#
initfile="init_param.cfg"

if [[ $0 == "start.ksh" || $0 == "*./start.ksh" || $0 == ". ./start.ksh" || $0 == "ksh start.ksh" ]];
then
BASE_DIR=""

        BASE_DIR=`pwd`/`dirname $0`
        BASE_DIR=${BASE_DIR%/*}

REP_BASE_DIR=$(echo $BASE_DIR|sed 's/\//\\\//g')
if [[ -f $BASE_DIR/temp/init_param.tmp ]];
then
rm $BASE_DIR/temp/init_param.tmp
pref_lang=""
fi
while read line
do
echo $line|sed 's/<BASE DIRECTORY>/'$REP_BASE_DIR'/g' >> $BASE_DIR/temp/init_param.tmp
done < "$BASE_DIR/$initfile"
initfile=temp/init_param.tmp
else

initfile=temp/init_param.tmp
BASE_DIR=$(grep "Administration Application Base Directory" $initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g')

fi

set -A LANGS;
set -A MENUFILES;
need_lang_select=$(grep "Application Language Selection" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g')
default_lang=$(grep "Default Language" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g')
set -A ENTERPRISES;  

get_enterprises()
{
OUT=$(grep "Enterprises" $initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
  ENTERPRISES[$j]=$(echo "$x")
j=$(($j+1))
done
}

get_enterprises;
##get_entparams;
set -A DSNS;
SADMINUSER=$(grep "Siebel Administator Username" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g')
SADMINPASS=$(grep "Siebel Administrator Password" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g')
DBMS=$(grep "Siebel DBMS" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/^ *//'|sed 's/*^ //');
DBSID=$(grep "Siebel DB SID" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g')
TABLEOWNER=$(grep "Siebel DB Table Owner" $BASE_DIR/$initfile|grep -v "Siebel DB Table Owner Password"|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g')
TABLEOWNERPASS=$(grep "Siebel DB Table Owner Password" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g')
DEP_DIR=$(grep "Siebel Deployment Directory" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g')
REPOSITORY=$(grep "Siebel Repository Name" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/^ *//'|sed 's/*^ //');
set -A WEBSERVERS;
set -A WEBUSERS;
set -A WEBPASSWORDS;
set -A SWSEHOMEDIRS; 
set -A ENTSERVERS; 
ENTSERVERUSER=$(grep "Siebel Enterprise Server Username" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g');
ENTSERVERPASSWORD=$(grep "Siebel Enterprise Server Password" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g');
SIEBEL_HOME=$(grep "Siebel Enterprise Server Home Directory" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g');
set -A GWSERVERS;
set -A GWUSERS;
set -A GWPASSWORDS;
set -A GWHOMEDIRS;
DBSRVRHOMEDIR=$(grep "Siebel DB Server Home Directory" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g');
TEMP=$(grep "Temp Output Directory" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g');
SERVERINFO=$(grep "Server Info Output Directory" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g');
set -A SIEBLANGCODES;
set -A SIEBAPPCONFFILES;

 
get_languages()
{
OUT=$(grep "Application Languages" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
  LANGS[$j]=$(echo "$x")
j=$(($j+1))
done
}

get_menufiles()
{
OUT=$(grep "Menu Configuration" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
  MENUFILES[$j]=$(echo "$x")
j=$(($j+1))
done

}

get_dsns()
{
OUT=$(grep "Data Source Names" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
 DSNS[$j]=$(echo "$x")
j=$(($j+1))
done
}


get_webservers()
{
OUT=$(grep "Siebel Web Servers" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
 WEBSERVERS[$j]=$(echo "$x")
j=$(($j+1))
done
}

get_webusers()
{
OUT=$(grep "Siebel Web Server Usernames" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
 WEBUSERS[$j]=$(echo "$x")
j=$(($j+1))
done
}

get_webpasswords()
{
OUT=$(grep "Siebel Web Server Passwords" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
 WEBPASSWORDS[$j]=$(echo "$x")
j=$(($j+1))
done
}

get_swsehomedirs()
{
OUT=$(grep "SWSE Home Directories" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
 SWSEHOMEDIRS[$j]=$(echo "$x")
j=$(($j+1))
done
}

get_gwhomedirs()
{
OUT=$(grep "Siebel Gateway Server Home Directories" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
 GWHOMEDIRS[$j]=$(echo "$x")
j=$(($j+1))
done
}

get_gwservers()
{
OUT=$(grep "Siebel Gateway Server Names" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
 GWSERVERS[$j]=$(echo "$x")
j=$(($j+1))
done
}

get_gwusers()
{
OUT=$(grep "Siebel Gateway Server Usernames" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
 GWUSERS[$j]=$(echo "$x")
j=$(($j+1))
done
}

get_gwpasswords()
{
OUT=$(grep "Siebel Gateway Server Passwords" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
 GWPASSWORDS[$j]=$(echo "$x")
j=$(($j+1))
done
}

get_sieblangcode()
{
OUT=$(grep "Siebel Application Language Codes" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n");
j=0;
for x in $OUT
do
 SIEBLANGCODES[$j]=$(echo "$x") 
j=$(($j+1))
done
}

get_siebappconffile()
{
OUT=$(grep "Siebel Application Configuration Files" $BASE_DIR/$initfile|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g'|tr ";" "\n");
j=0;
for x in $OUT
do
SIEBAPPCONFFILES[$j]=$SIEBEL_HOME/bin/$(echo "$x")
j=$(($j+1))
done
}

get_entservers()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh 
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}") 
if [[ ! -z "$siebsvc" ]];
then 
echo "\n Retrieving Enterprise Server Info..."
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list servers show SBLSRVR_NAME,SBLSRVR_STATE" /o $SERVERINFO/listservernames_${ENTERPRISES[$j]}.txt 
entservernamesfile=$SERVERINFO/listservernames_${ENTERPRISES[$j]}.txt

takeit=0
while read line
do
if [[ -z "$line" ]];
then
takeit=0
fi

if [[ "$takeit" -eq 1 ]];
then
space_avail=$(echo "$line"|grep " ")
if [[ ! -z "$space_avail" ]];
then
server=${line% *}
status=${line##* }
else
server=$line
status=""
fi
if [[ ! -z "$1" && "$status" == "$1" || -z "$1" ]];
then
ENTSERVERS[$k]=${ENTERPRISES[$j]}/$(echo "$server")
k=$(($k+1))
fi

fi 

if [[ "$line" == *------------* ]];
then
takeit=1
fi

done < "$entservernamesfile"
else
echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
fi
j=$(($j+1))
done
cd $BASE_DIR
}


get_entparams()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list ent parameters" /o $SERVERINFO/listentparams_${ENTERPRISES[$j]}.txt
j=$(($j+1))
done
cd $BASE_DIR
}

get_entserver_details()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then 
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Enterprise Server Info..."
if [[ ! -z "$2" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list servers show $2" /o $SERVERINFO/listservers_${ENTERPRISES[$j]}.txt
else 
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list servers" /o $SERVERINFO/listservers_${ENTERPRISES[$j]}.txt
fi
entserversfile=$SERVERINFO/listservers_${ENTERPRISES[$j]}.txt
clear;
echo "################## ENTERPRISE SERVERS IN ${ENTERPRISES[$j]} ENTERPRISE ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list servers")  
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$entserversfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_server_comp_details()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Server Component Info..."
if [[ ! -z "$3" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list component for server $2 show $3" /o $SERVERINFO/listservercomps_${ENTERPRISES[$j]}_$2.txt
else
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list component for server $2" /o $SERVERINFO/listservercomps_${ENTERPRISES[$j]}_$2.txt
fi
servercompsfile=$SERVERINFO/listservercomps_${ENTERPRISES[$j]}_$2.txt
clear;
echo "################## SERVER COMPONENTS IN SERVER $2  ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list component")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$servercompsfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_server_comp_detailsbygroup()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Server Component Info..."
if [[ ! -z "$3" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list component for component group $2 show $3" /o $SERVERINFO/listservercomps_${ENTERPRISES[$j]}_$2.txt
else
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list component for component group $2" /o $SERVERINFO/listservercomps_${ENTERPRISES[$j]}_$2.txt
fi
servercompsfile=$SERVERINFO/listservercomps_${ENTERPRISES[$j]}_$2.txt
clear;
echo "################## SERVER COMPONENTS IN COMPONENT GROUP $2  ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list component")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$servercompsfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_comp_group_details()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Component Group Info..."
if [[ ! -z "$3" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list component group for server $2 show $3" /o $SERVERINFO/listservercompgroups_${ENTERPRISES[$j]}_$2.txt
else
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list component group for server $2" /o $SERVERINFO/listservercompgroups_${ENTERPRISES[$j]}_$2.txt
fi
compgroupsfile=$SERVERINFO/listservercompgroups_${ENTERPRISES[$j]}_$2.txt
clear;
echo "################## COMPONENT GROUPS IN SERVER $(echo $2|tr [a-z] [A-Z])  ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list component group")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$compgroupsfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_server_task_details()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Server Tasks Info..."
if [[ ! -z "$3" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list tasks for server $2 show $3" /o $SERVERINFO/listservertasks_${ENTERPRISES[$j]}_$2.txt
else
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list tasks for server $2" /o $SERVERINFO/listservertasks_${ENTERPRISES[$j]}_$2.txt
fi

servertasksfile=$SERVERINFO/listservertasks_${ENTERPRISES[$j]}_$2.txt
clear;
echo "################## SERVER TASKS IN SERVER $2  ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list tasks")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$servertasksfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_comp_task_details()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Server Component Tasks Info..."
if [[ ! -z "$5" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list tasks for component $3 server $2 show $5" /o $SERVERINFO/listcomptasks_${ENTERPRISES[$j]}_$2_$4.txt
else
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list tasks for component $3 server $2" /o $SERVERINFO/listcomptasks_${ENTERPRISES[$j]}_$2_$4.txt
fi

comptasksfile=$SERVERINFO/listcomptasks_${ENTERPRISES[$j]}_$2_$4.txt
clear;
echo "################## SERVER TASKS FOR COMPONENT $4 IN SERVER $2  ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list tasks")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$comptasksfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_server_session_details()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Server Sessions Info..."
if [[ ! -z "$4" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list $3 sessions for server $2 show $4" /o $SERVERINFO/listserver_$3_sessions_${ENTERPRISES[$j]}_$2.txt
else
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list $3 sessions for server $2" /o $SERVERINFO/listserver_$3_sessions_${ENTERPRISES[$j]}_$2.txt
fi
serversessionsfile=$SERVERINFO/listserver_$3_sessions_${ENTERPRISES[$j]}_$2.txt
clear;

echo "################## $(echo $3|tr [a-z] [A-Z]) SESSIONS IN SERVER $(echo $2|tr [a-z] [A-Z]) ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list $3 sessions")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$serversessionsfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_server_statistics()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Server Statistics Info..."
if [[ ! -z "$3" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list statistics for server $2 show $3" /o $SERVERINFO/listserverstatistics_${ENTERPRISES[$j]}_$2.txt
else
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list statistics for server $2" /o $SERVERINFO/listserverstatistics_${ENTERPRISES[$j]}_$2.txt
fi
serverstatisticsfile=$SERVERINFO/listserverstatistics_${ENTERPRISES[$j]}_$2.txt
clear;
echo "################## SERVER STATISTICS FOR SERVER $(echo $2|tr [a-z] [A-Z]) ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list statistics")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$serverstatisticsfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_comp_statistics()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Server Component Statistics Info..."
if [[ ! -z "$5" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list statistics for component $3 server $2 show $5" /o $SERVERINFO/listcompstatistics_${ENTERPRISES[$j]}_$2_$4.txt
else
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list statistics for component $3 server $2" /o $SERVERINFO/listcompstatistics_${ENTERPRISES[$j]}_$2_$4.txt
fi

compstatisticsfile=$SERVERINFO/listcompstatistics_${ENTERPRISES[$j]}_$2_$4.txt
clear;
echo "################## SERVER STATISTICS FOR COMPONENT $4 IN SERVER $2  ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list statistics")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$comptasksfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_server_state_values()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Server State Values Info..."
if [[ ! -z "$3" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list state values for server $2 show $3" /o $SERVERINFO/listserverstatevalues_${ENTERPRISES[$j]}_$2.txt
else
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list state values for server $2" /o $SERVERINFO/listserverstatevalues_${ENTERPRISES[$j]}_$2.txt
fi
serverstatevaluesfile=$SERVERINFO/listserverstatevalues_${ENTERPRISES[$j]}_$2.txt
clear;
echo "################## SERVER STATE VALUES FOR SERVER $2  ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list state values")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$serverstatevaluesfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_comp_state_values()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Server Component State Values Info..."
if [[ ! -z "$5" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list state values for component $3 server $2 show $5" /o $SERVERINFO/listcompstatevalues_${ENTERPRISES[$j]}_$2_$4.txt
else
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list state values for component $3 server $2" /o $SERVERINFO/listcompstatevalues_${ENTERPRISES[$j]}_$2_$4.txt
fi

compstatevaluesfile=$SERVERINFO/listcompstatevalues_${ENTERPRISES[$j]}_$2_$4.txt
clear;
echo "################## SERVER STATE VALUES FOR COMPONENT $4 IN SERVER $2  ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list state values")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$compstatevaluesfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_server_params()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Server Parameters Info..."
if [[ ! -z "$3" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list parameters for server $2 show $3" /o $SERVERINFO/listserverparams_${ENTERPRISES[$j]}_$2.txt
else
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list parameters for server $2" /o $SERVERINFO/listserverstateparams_${ENTERPRISES[$j]}_$2.txt
fi
serverparamsfile=$SERVERINFO/listserverparams_${ENTERPRISES[$j]}_$2.txt
clear;
echo "################## SERVER PARAMETERS FOR SERVER $2  ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list parameters")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi


done < "$serverparamsfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_comp_params()
{
get_enterprises
get_gwservers
cd $SIEBEL_HOME
. ./siebenv.sh
j=0;k=0;
while [[ "$j"<${#ENTERPRISES[*]} ]];
do
if [[ "${ENTERPRISES[$j]}" == "$1" ]];
then
#siebsvc=$(ps -ef|grep "$ENTSERVERUSER"|grep siebsvc|grep "\-e ${ENTERPRISES[$j]}")
#if [[ ! -z "$siebsvc" ]];
#then
echo "\n Retrieving Server Component Parameters Info..."
if [[ ! -z "$5" ]];
then
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list parameters for component $3 server $2 show $5" /o $SERVERINFO/listcompparams_${ENTERPRISES[$j]}_$2_$4.txt
else
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "list parameters for component $3 server $2" /o $SERVERINFO/listcompparams_${ENTERPRISES[$j]}_$2_$4.txt
fi

compparamsfile=$SERVERINFO/listcompparams_${ENTERPRISES[$j]}_$2_$4.txt
clear;
echo "################## SERVER PARAMETERS FOR COMPONENT $4 IN SERVER $2  ####################"
echo "==========================================================================================="
takeit=0
while read line
do
if [[ -z "$line" ]]
then
skipit=1
else
skipit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" && "$skipit" -eq 0 ]];
then
echo "$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "list parameters")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$compparamsfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

get_languages

if [[ $0 == "start.ksh" || $0 == "*./start.ksh" ]];
then
get_entservers 
#The part below is to generate keys
if [[ "${#ENTSERVERS[*]}" -ge 2 && ! -f $HOME/.ssh/id_dsa_siebel_ent_login.pub ]]
then
ssh-keygen -t dsa -f $HOME/.ssh/id_dsa_siebel_ent_login -N $ENTSERVERPASSWORD
fi

if [[ "${#ENTSERVERS[*]}" -ge 2 && -f $HOME/.ssh/id_dsa_siebel_ent_login.pub ]];
then
sh
i=0
while [[ "$i"<"${#ENTSERVERS[*]}" ]];
do
.  ./ssh-copy-id -i $HOME/.ssh/id_dsa_siebel_ent_login.pub $ENTSERVERUSER@${ENTSERVERS[$i]} 
j=$(($j+1))
done
ksh
fi
fi 
