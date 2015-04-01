#!/usr/bin/ksh
########################################################
# Name:
# ent_srv_man.ksh
#
# Description:
# This script is to execute a wizard functionality to monitor Enterprise Servers and their components.
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
get_enterprises;

if [[ "${#ENTERPRISES[*]}" -ne 0 ]];
then
containsElement "$pref_ent" "ENTERPRISES"
entavail=$?
until [[ "$entavail" -eq 1 && ! -z "$pref_ent" ]];
do
clear;
echo "\n Siebel Enterprise Server Management"
echo "============================================"
set -A selectionlist;
i=1
for ent in ${ENTERPRISES[*]}
do
echo "\n $i""- $ent"
j=$(($i-1))
selectionlist[$j]=$i
i=$(($i+1))
done
echo "\n Please select the Enterprise where you are willing to display Enterprise Servers! (Please click \"CTRL+C\" to return to the main menu): \c"
trap "return_main" 2
read pref_ent

checkNumber $pref_ent
num_check=$?
if [[ "$num_check" -eq 1 ]]
then
containsElement "$pref_ent" "selectionlist"
numavail=$?
j=$(($pref_ent-1))
pref_ent=${ENTERPRISES[$j]}
fi

containsElement "$pref_ent" "ENTERPRISES"
entavail=$?

done
fi

#if [[ -f "$SERVERINFO/list_server_display_config.tmp" ]];
#then
#display_server_columns=$(grep "SERVER_COLUMNS=" $SERVERINFO/list_server_display_config.tmp|awk 'BEGIN{FS="="} {print $2}') 
#else
display_columns=""
#fi
get_entserver_details $pref_ent $display_columns > $SERVERINFO/entserver_details.tmp 2>&1 
temp_entserver_file=$SERVERINFO/entserver_details.tmp
selected_server=""
entserveravail=0
reconfigured=0
set -A validentservers;
k=0;
while read line
do
server=${line%% *}
validentservers[$k]=$(echo "$server")
k=$(($k+1))
done < "$temp_entserver_file" 

until [[ ! -z "$selected_server" && "$entserveravail" -eq 1 ]];
do  
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_entserver_details $pref_ent $display_columns > $SERVERINFO/entserver_details.tmp 2>&1
reconfigured=0
fi

cat $SERVERINFO/entserver_details.tmp
echo "\n Please select a server name to proceed further details! (Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the main menu): \c"
trap "return_main" 2
read selected_server

# Expressions below are added to display list configuration functionalities for the servers
if [[ "$selected_server" == "config" ]];
then
mandatory_col_no=1
set_list_config $pref_ent "server" $mandatory_col_no $display_columns
reconfigured=1
fi

containsElement "$selected_server" "validentservers"
entserveravail=$?
done

#Displays server submenu for the selected server
display_server_submenu $pref_ent $selected_server





