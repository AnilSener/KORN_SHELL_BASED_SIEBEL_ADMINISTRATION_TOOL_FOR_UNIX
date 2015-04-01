#!/usr/bin/ksh
########################################################
# Name:
# entserver_start.ksh
#
# Description:
# This script is to execute enterprise server start process 
# Created By:
# Siebel Expert Services
#
# Version : 0.1
#
# Update History:
#======================================================
# 15/05/2013 Expert Services (v0.1)
#------------------------------------------------------
. ./init.ksh
########################################################
cd $SIEBEL_HOME
. ./siebenv.sh
cd $BASE_DIR
as=$($SIEBEL_HOME/bin/list_server all)
host_server=$(hostname)
if [[ $as == *stopped* ]];
then
$SIEBEL_HOME/bin/start_server all
exit_status=$?
echo $exit_status
        if [[ "$exit_status" -eq 0 ]];
        then
        echo "\n Enterprise Server with hostname ${ENTSERVERS[$1]} is started."
        else
        echo "\n Enterprise Server with hostname ${ENTSERVERS[$1]} cannot be started."
        return 1;
        fi
else
echo "\n There is already a running Enterprise Server Instance in server with hostname ${ENTSERVERS[$j]}."
fi
if [[ "${#ENTSERVERS[$1]}" != "$host_server" ]];
then
exit
fi
