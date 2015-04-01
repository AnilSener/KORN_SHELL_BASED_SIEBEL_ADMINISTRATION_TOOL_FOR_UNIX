#!/usr/bin/ksh
########################################################
# Name:
# gwserver_start.ksh
#
# Description:
# This script is to execute gateway server start process 
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
ksh ${GWHOMEDIRS[$1]}/siebenv.sh
gw=$(${GWHOMEDIRS[$1]}/bin/list_ns)
host_server=$(hostname)
if [[ "$gw" == *stopped* ]];
then
${GWHOMEDIRS[$1]}/bin/start_ns
exit_status=$?
	if [[ "$exit_status" -eq 0 ]];
        then
        echo "\n GW Server with hostname ${GWSERVERS[$1]} is started."
        else
        echo "\n GW Server with hostname ${GWSERVERS[$1]} cannot be started"
        return 1;
        fi
else
echo "\n There is already a running GW Server Instance in server with hostname ${GWSERVERS[$1]}."
fi
if [[ "${#GWSERVERS[$1]}" != "$host_server" ]];
then
exit
fi
