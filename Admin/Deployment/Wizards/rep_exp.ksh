#!/usr/bin/ksh
########################################################
# Name:
# rep_exp.ksh
#
# Description:
# This script is to execute a wizard functionality to enable repository export to a file.
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
rep_dir=""
rep_file=""
get_dsns
get_gwhomedirs
exit_status=0;

until [[ ! -z "$rep_dir" && -d "$rep_dir" ]];
do
echo "\n Please specify a \"directory location\" to export the repository file.(Please click \"CTRL+C\" to return to the main menu): \c"
trap "return_main" 2
read rep_dir
done

if [[ -d "$rep_dir" ]];
then

until [[ "$rep_file" == *.dat ]];
do
echo "\n Please provide the \"repository name (.dat file)\" to be exported from the list above (Please click \"CTRL+C\" to return to the main menu): \c"
trap "return_main" 2
read rep_file
done

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
until [[ "$exp_pref" -eq 1 || "$exp_pref" -eq 2 ]]; 
do
clear;
echo "\n 1- Interactive Mode" 
echo "\n 2- Background Mode"  
echo "\n Pease make your repository export preference (Please click \"CTRL+C\" to return to the main menu) : ""\c" 
trap "return_main" 2
read exp_pref
done
fi

cd $SIEBEL_HOME
. ./siebenv.sh
cd $BASE_DIR 
postfix=$(date '+_%d_%m_20%y_%H_%M_%S')
if [[ "$exp_pref" -eq 1 ]];
then
for dsn in ${DSNS[*]}
do
$SIEBEL_HOME/bin/repimexp /a e /c $dsn /u $SADMINUSER /p $SADMINPASS /d $TABLEOWNER /f "$rep_dir"/"$rep_file" /l $BASE_DIR/logs/repository_export"$postfix".log 
exit_status=$?
done
else
for dsn in ${DSNS[*]}
do
nohup $SIEBEL_HOME/bin/repimexp /a e /c $dsn /u $SADMINUSER /p $SADMINPASS /d $TABLEOWNER /f "$rep_dir"/"$rep_file" /l $BASE_DIR/logs/repository_export"$postfix".log &
exit_status=$?
done
fi


if [[ "$exit_status" -eq 0 ]];
then
echo "\n ## Repository Export is completed successfully. Please check $rep_dir/$rep_file ! ##"
else
echo "\n ## Repository Export cannot be completed successfully! ##"
fi

cd $BASE_DIR

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
