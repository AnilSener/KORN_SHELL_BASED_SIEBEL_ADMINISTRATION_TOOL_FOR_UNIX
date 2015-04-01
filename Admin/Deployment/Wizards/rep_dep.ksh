#!/usr/bin/ksh
########################################################
# Name:
# rep_dep.ksh
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
# 07/05/2013 Expert Services (v0.1)
#------------------------------------------------------
# Created
#======================================================
#
. ./init.ksh
. ./util.ksh
#------------------------------------------------------#

pref_lang=$1;
condition=""
rep_dir=""
rep_file=""
get_dsns
get_gwhomedirs
exit_status=0;
import_pid=999999;
ddlsync_pid=999999;
until [[ "$condition" == "y" || "$condition" == "n" ]];  
do 

echo "\n The default directory location for the repository file to be imported is $DEP_DIR .(Please click "CTRL+C" to return to the main menu) Do you want to specify another directory? (Please select y/n) \c"
trap "return_main" 2
read condition 
done

if [[ "$condition" == "y" ]];
then
cd /
until [[ ! -z "$rep_dir" && -d "$rep_dir" ]];
do
echo "\n Please provide the directory location for the repository file to be imported (Please click "CTRL+C" to return to the main menu): \c"
trap "return_main" 2
read rep_dir
done
cd $BASE_DIR
else
rep_dir=$DEP_DIR
fi

cd $rep_dir
OUT=$(ls -l *.dat|awk '/:/ {print $9}')
set -A datfiles
j=0;
for x in $OUT
do
datfiles[$j]=$(echo "$x")
j=$(($j+1))
done
containsElement "$rep_file" "datfiles"
ret_val=$?
proceed=1;
repfilein_masterimprep=$(grep "Repository File Name" $SIEBEL_HOME/bin/master_imprep.ucf|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g')
repfilein_masterddlsync=$(grep "Repository File Name" $SIEBEL_HOME/bin/master_ddlsync.ucf|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g')
while [[ "$proceed" -eq 0 || "$ret_val" -eq 0 ]];
do
echo "\n .dat files located in $rep_dir directory:"
echo "-----------------------------------------------"
ls -l *.dat|awk '/:/ {print $9,$7,$6,$8}' 
echo "\n Please provide the repository name (.dat file) to be imported from the list above(Please click "CTRL+C" to return to the main menu): \c"
trap "return_main" 2
read rep_file
containsElement "$rep_file" "datfiles"
ret_val=$?

if [[ "$ret_val" -eq 1 && "$repfilein_masterimprep" != "$DBSRVRHOMEDIR"/common/"$rep_file" ]];
then
ret_val=0
echo "\n Repository File Name available in $SIEBEL_HOME/bin/master_imprep.ucf is not matching your preferences!!!"
fi

if [[ "$ret_val" -eq 1 && "$repfilein_masterddlsync" != "$DBSRVRHOMEDIR"/common/"$rep_file" ]];
then
ret_val=0
echo "\n Repository File Name available in $SIEBEL_HOME/bin/master_ddlsynch.ucf is not matching your preferences!!!"
fi

done

cd $BASE_DIR

autostop_option=""
until [[ "$autostop_option" == "y" || "$autostop_option" == "n" ]];
do
clear;
echo "\n ATTENTION!!!: All Enterprise Servers and Gateway Servers should be shutdown before starting repository deployment, would you like them to be shutdown automatically (y/n)? (Please click "CTRL+C" to return to the main menu): \c"
trap "return_main" 2
read autostop_option
done

if [[ "$autostop_option" == "y" ]];
then
stop_all_ent_servers;
exit_status=$?

if [[ "$exit_status" -eq 0 ]];
then
echo "\n All Enterprise Servers are down. Stopping GW Servers..."
stop_all_gw_servers;
exit_status=$?

if [[ "$exit_status" -eq 0 ]];
then
echo "\n All GW Servers are down."
fi
fi
fi 

get_entservers "Running";
if [[ -z "${ENTSERVERS[*]}" && -f "$DBSRVRHOMEDIR"/common/"$rep_file" ]];
then
postfix=$(date '+_%d_%m_20%y_%H_%M_%S')
sleep 5
clear;
echo "\n Backuping $DBSRVRHOMEDIR/common/$rep_file as $DBSRVRHOMEDIR/common/$rep_file$postfix ..." 
mv $DBSRVRHOMEDIR/common/$rep_file $DBSRVRHOMEDIR/common/$rep_file$postfix 
exit_status=$?
fi

if [[ "$exit_status" -eq 0 ]];
then
echo "\n Copying $rep_dir/$rep_file to $DBSRVRHOMEDIR/common/$rep_file ..."
cp $rep_dir/$rep_file $DBSRVRHOMEDIR/common/$rep_file
exit_status=$?
fi

if [[ "$exit_status" -eq 0 ]];
then
echo "\n Repository file under $rep_dir named as $rep_file is copied under directory $DBSRVRHOMEDIR/common/"
sleep 5 
if [[ "$DBMS" == Oracle* && ! -z "$DBSID" && -f $ORACLE_HOME/bin/tnsping ]];
then
postfix=$(date '+_%d_%m_20%y_%H_%M_%S')

###The Script below is used to backup Repository file record in Database
tnspingresult=$(tnsping $DBSID|grep $DBSID|sed 's/Attempting to contact //g')

sqlplus -s /nolog<<ENDOFSQL
connect $TABLEOWNER/$TABLEOWNERPASS@$tnspingresult
UPDATE S_REPOSITORY SET NAME = '$REPOSITORY$postfix' WHERE NAME='$REPOSITORY';
exit
ENDOFSQL
exit_status=$?

if [[ "$exit_status" -eq 0 ]];
then
echo "\n Repository file name is updated in S_REPOSITORY table with $DBSID SID as Siebel Repository$postfix ."
sleep 5 
else
echo "\n Repository file name cannot be updated in S_REPOSITORY table with $DBSID SID as Siebel Repository$postfix . Please check DB connectivity or Siebel Table Owner access rights. Please click "CTRL+C" to return to the main menu or system will exit autamatically in 30 seconds."
trap "return_main" 2
sleep 30
exit;
fi

fi

fi


#set senvironmental variables

if [[ -f /"$SIEBEL_HOME"/siebenv.sh && "$exit_status" -eq 0 ]];
then 
cd $SIEBEL_HOME
. ./siebenv.sh
cd $BASE_DIR 
exit_status=$?
if [[ "$exit_status" -eq 1 ]];
then
echo "Siebel Enviornmental variables cannot be set please check the availability of siebenv.sh script." 
fi
fi

if [[ "$exit_status" -eq 0 ]];
then
dep_pref=0;
until [[ "$dep_pref" -eq 1 || "$dep_pref" -eq 2 || "$dep_pref" -eq 3 || "$dep_pref" -eq 4 ]]; 
do
clear;
echo "\n 1- Interactive Mode" 
echo "\n 2- Background Mode (Automatically start DDL Synchronization and DB check sequentially when the repository import process finishes successfully)"  
echo "\n 3- Background Mode (Prompt for DDL Synchronization  and DB check when the repository import process finishes successfully)"
echo "\n 4- Skip Repository Import"
echo "\n Pease make your repository deployment preference (Please click \"CTRL+C\" to return to the main menu) : ""\c" 
trap "return_main" 2
read dep_pref
done
fi

cd $SIEBEL_HOME
. ./siebenv.sh
cd $BASE_DIR 
postfix=$(date '+_%d_%m_20%y_%H_%M_%S')
if [[ "$dep_pref" -eq 1 ]];
then
$SIEBEL_HOME/bin/srvrupgwiz /m $SIEBEL_HOME/bin/master_imprep.ucf > $BASE_DIR/logs/repository_import"$postfix".log 2>&1
exit_status=$?
echo $exit_status
else
if [[ "$dep_pref" -eq 2 || "$dep_pref" -eq 3 ]];
then
nohup $SIEBEL_HOME/bin/srvrupgwiz /m $SIEBEL_HOME/bin/master_imprep.ucf > $BASE_DIR/logs/repository_import"$postfix".log 2>&1&
exit_status=$?
import_pid=$!
echo "exit status" $exit_status
echo "last background process" $import_pid
program_pid=$$
echo "program_id" $program_pid
fi
fi

if [[ -f $BASE_DIR/logs/repository_import"$postfix".log ]];
then
chmod 777 "$BASE_DIR/logs/repository_import"$postfix".log" 
fi

if [[ "$exit_status" -eq 0 && "$dep_pref" -ne 4 ]];
then
echo "\n ## Repository Import Phase is completed successfully! ##"
fi

if [[ "$exit_status" -eq 1 ]];
then
echo "\n ## Repository Import Phase cannot be completed successfully! ##"
fi

cd $BASE_DIR

import_pid_avail=$(ps -ef|egrep '$import_pid|master_imprep.ucf'|grep -v "egrep")
if [[ ! -z "$import_pid_avail" && "$dep_pref" -eq 4 ]];
then
echo "There is a running instance of ddl synchronization with process id $ddlsync_pid_avail , therefore DB check cannot be run"
fi

if [[ -z "$import_pid_avail" && "$exit_status" -eq 0 || -z "$import_pid_avail" && "$dep_pref" -eq 4 ]];
then

if [[ "$dep_pref" -eq 1 || "$dep_pref" -eq 3  || "$dep_pref" -eq 4 ]];
then

#ddl synchronization prompt menu is below
ddlsynch_pref=0;
until [[ "$ddlsynch_pref" -eq 1 || "$ddlsynch_pref" -eq 2 || "$ddlsynch_pref" -eq 3 ]];
do
sleep 5
clear;
echo "\n 1- Interactive Mode"
echo "\n 2- Background Mode"
echo "\n 3- Skip DDL Sychronization"
echo "\n Pease make your ddl synchronization preference (Please click \"CTRL+C\" to return to the main menu): ""\c"
trap "return_main" 2
read ddlsynch_pref
done

cd $SIEBEL_HOME
. ./siebenv.sh
cd $BASE_DIR 
postfix=$(date '+_%d_%m_20%y_%H_%M_%S')
if [[ "$exit_status" -eq 0 && "$ddlsynch_pref" -eq 1 ]];
then 
$SIEBEL_HOME/bin/srvrupgwiz /m $SIEBEL_HOME/bin/master_ddlsync.ucf > $BASE_DIR/logs/repository_ddlsynch"$postfix".log 2>&1
exit_status=$?
else
	if [[ "$ddlsynch_pref" -eq 2 ]];
	then	
	nohup $SIEBEL_HOME/bin/srvrupgwiz /m $SIEBEL_HOME/bin/master_ddlsync.ucf > $BASE_DIR/logs/repository_ddlsynch"$postfix".log 2>&1&
	exit_status=$?
	ddlsync_pid=$!
	echo "exit status" $exit_status
	echo "last background process" $ddlsync_pid
	program_pid=$$
	echo "program_id" $program_pid	
	fi
fi

else
nohup $SIEBEL_HOME/bin/srvrupgwiz /m $SIEBEL_HOME/bin/master_ddlsync.ucf > $BASE_DIR/logs/repository_ddlsynch"$postfix".log 2>&1&
exit_status=$?
ddlsync_pid=$!
echo "exit status" $exit_status
echo "last background process" $ddlsync_pid
program_pid=$$
echo "program_id" $program_pid
fi

if [[ -f $BASE_DIR/logs/repository_ddlsynch"$postfix".log ]];
then
chmod 777 $BASE_DIR/logs/repository_ddlsynch"$postfix".log
fi

if [[ "$exit_status" -eq 0 && "$ddlsynch_pref" -ne 3 ]];
then
echo "\n ## DDL Synchronization Phase is completed successfully! ##"
fi

if [[ "$exit_status" -eq 1 ]];
then
echo "\n ## DDL Synchronization Phase cannot be completed successfully! ##"
fi

fi
cd $BASE_DIR

#DB check is processed below
ddlsync_pid_avail=$(ps -ef|egrep '$ddlsync_pid|master_ddlsync.ucf'|grep -v "egrep")
if [[ ! -z "$ddlsync_pid_avail" && "$ddlsynch_pref" -eq 3 ]];
then
echo "There is a running instance of ddl synchronization with process id $ddlsync_pid_avail , therefore DB check cannot be run"  
fi

if [[ -z "$import_pid_avail" && -z "$ddlsync_pid_avail" && "$exit_status" -eq 0 || -z "$import_pid_avail" && -z "$ddlsync_pid_avail" && "$ddlsynch_pref" -eq 3 ]];
then

if [[ "$dep_pref" -eq 1 || "$dep_pref" -eq 3 || "$dep_pref" -eq 4 || "$ddlsynch_pref" -eq 3 ]];
then
dbcheck_pref=0;
until [[ "$dbcheck_pref" -eq 1 || "$dbcheck_pref" -eq 2 ]];
do
sleep 5;
clear;
echo "\n 1- Interactive Mode"
echo "\n 2- Background Mode"
echo "\n 3- Skip DB Check"
echo "\n Pease make your db check  preference (Please click \"CTRL+C\" to return to the main menu) : \c"
trap "return_main" 2
read dbcheck_pref 
done

postfix=$(date '+_%d_%m_20%y_%H_%M_%S')
j=0
for dsn in ${DSNS[*]}
do
j=$(($j+1))

cd $SIEBEL_HOME
. ./siebenv.sh
cd $BASE_DIR 

if [[ "$dbcheck_pref" -eq 1 ]];
then
dbchck /s $dsn /u $SADMINUSER /p $SADMINPASS /t $TABLEOWNER /a /d /r "$REPOSITORY" > $BASE_DIR/logs/dbchck"$postfix"_"$j".log 2>&1
exit_status=$?
echo "exit status" $exit_status
echo "\n Please check the results in $BASE_DIR/logs/dbchck"$postfix"_"$j".log file later."
else
if [[ "$dbcheck_pref" -eq 2 ]];
then
nohup dbchck /s $dsn /u $SADMINUSER /p $SADMINPASS /t $TABLEOWNER /a /d /r "$REPOSITORY" > $BASE_DIR/logs/dbchck"$postfix"_"$j".log 2>&1&
exit_status=$?
dbcheck_pid=$!
echo "\n The DB Check Process will run in the background, you can close this command line connection and check the results in $BASE_DIR/logs/dbchck"$postfix"_"$j".log file later."
echo "exit status" $exit_status
echo "last background process" $dbcheck_pid
program_pid=$$
echo "program_id" $program_pid
fi
fi

if [[ -f $BASE_DIR/logs/dbchck"$postfix"_$j.log ]];
then
chmod 777 $BASE_DIR/logs/dbchck"$postfix"_$j.log
fi
done

else

j=0
for dsn in ${DSNS[*]}
do
j=$(($j+1))
nohup dbchck /s $dsn /u $SADMINUSER /p $SADMINPASS /t $TABLEOWNER /a /d /r "$REPOSITORY" > $BASE_DIR/logs/dbchck"$postfix"_$j.log 2>&1&
exit_status=$?
dbcheck_pid=$!
echo "\n The DB Check Process will run in the background, you can close this command line connection and check the results in $BASE_DIR/logs/dbchck"$postfix"_"$j".log file later."
echo "exit status" $exit_status
echo "last background process" $dbcheck_pid
program_pid=$$
echo "program_id" $program_pid

if [[ -f $BASE_DIR/logs/dbchck"$postfix"_"$j".log ]];
then
chmod 777 $BASE_DIR/logs/dbchck"$postfix"_"$j".log
fi
done
fi

fi

cd $BASE_DIR

if [[ "$exit_status" -eq 0 && "$dbcheck_pref" -ne 3 ]];
then
echo "\n ## DB Check Phase is completed successfully! ##"
else
echo "\n ## DB Check Phase cannot be completed successfully! ##"
fi

if [[ "$dbcheck_pref" -eq 3 && "$ddlsynch_pref" -eq 3 && "$dep_pref" -eq 4 ]];
then
echo "\n ## Repository Deployment Process is skipped. ##"
else
if [[ "$exit_status" -eq 0 ]];
then
echo "\n ## Repository Deployment Process is completed successfully! ##"
fi
fi

if [[ "$exit_status" -eq 0 ]];
then
sleep 5 
autostart_option=""
until [[ "$autostart_option" == "y" || "$autostart_option" == "n" ]];
do
clear;
echo "\n All Gateway Servers and Enterprise Servers can be opened after repository deployment, would you like them to be started automatically (y/n)? (Please click \"CTRL+C\" to return to the main menu) : \c" 
trap "return_main" 2
read autostart_option
done

if [[ "$autostart_option" == "y" ]];
then
start_all_gw_servers;
exit_status=$?

if [[ "$exit_status" -eq 0 ]];
then
echo "\n All GW Servers are up. Starting GW Servers..."
start_all_ent_servers;
exit_status=$?

if [[ "$exit_status" -eq 0 ]];
then
echo "\n All Enterprise Servers are up."
fi
fi
fi
fi

sleep 5;
answer=""
until [[ "$answer" == "exit" ]];
do
clear;
echo "\n  Please click \"CTRL+C\" to retun to the main menu or type \"exit\" to terminate the application: \c" 
trap "return_main" 2
read answer
done
echo "\n Application is terminated"
exit
