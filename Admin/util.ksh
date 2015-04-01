#!/usr/bin/ksh
########################################################
# Name:
# util.ksh
#
# Description:
# This script is to store a set of functions used in overall application.
#
# Created By:
# Siebel Expert Services
#
# Version : 0.1
#
# Update History:
#======================================================
#
#------------------------------------------------------#
. ./init.ksh
#------------------------------------------------------#

#Function that checks whether an array contains an element
containsElement () {
set -A arr
eval "arr=\"\${$2[@]}\""
checkNumber $1
ret_num=$?
for e in ${arr[@]}
do
if [[ "$ret_num" == 1 ]];
then 
	if [[ "$1" -eq "$e" ]];
        then
        j=1
        break;
        else
        j=0
        fi
else
	if [[ "$1" == "$e" ]];
        then
        j=1
        break;
        else
        j=0
        fi
fi
done
return $j
}

#Function that checks whether a variable is number
checkNumber()
{
n=1

if [[ ! -z $1 && `echo $* | tr -dc "[0-9]"` == "$1" ]];
then
n=1
else
n=0
fi
return $n
}

#Function returns the corresponding menu configuration file for the preferred language
check_menufile()
{
j=0;menufile="";
while [[ "$j" < "${#LANGS[*]}" ]];
do
	if [[ ! -z "$pref_lang" && "$pref_lang" == "${LANGS[$j]}" ]];
	then
	menufile=${MENUFILES[$j]}	
	break;
	else
		if [[ "$default_lang" == "${LANGS[$j]}" ]];
		then
		menufile=${MENUFILES[$j]}
		else	
			if [[ -z "$menufile" ]];
			then
			menufile="menu_config.xml" 
			fi
		fi
	fi 
j=$(($j+1))
done
echo "$menufile";
}

stop_all_gw_servers()
{
get_gwservers
get_gwhomedirs
get_gwusers
get_gwpasswords
host_server=$(hostname)
upper_host_server=$(echo $host_server|tr [a-z] [A-Z])
j=0;
while [[ "$j"<"${#GWSERVERS[$j]}" ]]; 
do
if [[ "${GWSERVERS[$j]}" != "$host_server" && "${GWSERVERS[$j]}" != "$upper_host_server" ]];
then
ssh -i $HOME/.ssh/id_dsa_siebel_ent_login.pub ${GWUSERS[$j]}@${GWSERVERS[$j]} '. ./gwserver_stop.ksh $j;exit'
else
. ./gwserver_stop.ksh $j 
fi
j=$(($j+1))
done
}

start_all_gw_servers()
{
get_gwservers
get_gwhomedirs
get_gwusers
get_gwpasswords
host_server=$(hostname)
upper_host_server=$(echo $host_server|tr [a-z] [A-Z])
j=0;
while [[ "$j"<"${#GWSERVERS[$j]}" ]];
do
if [[ "${GWSERVERS[$j]}" != "$host_server" && "${GWSERVERS[$j]}" != "$upper_host_server" ]];
then
ssh -i $HOME/.ssh/id_dsa_siebel_ent_login.pub ${GWUSERS[$j]}@${GWSERVERS[$j]} '. ./gwserver_start.ksh $j;exit'  
else
. ./gwserver_start.ksh $j
fi
j=$(($j+1))
done
}

stop_all_ent_servers()
{
get_entservers "Running";
j=0;
host_server=$(hostname)
upper_host_server=$(echo $host_server|tr [a-z] [A-Z])
while [[ "$j"<"${#ENTSERVERS[$j]}" ]];
do
ENTHOSTNAME=${ENTSERVERS[$j]}
ENTHOSTNAME=${ENTHOSTNAME##*/}
if [[ "$ENTHOSTNAME" != "$host_server" && "$ENTHOSTNAME" != "$upper_host_server" ]];
then 
ssh -i $HOME/.ssh/id_dsa_siebel_ent_login.pub $ENTSERVERUSER@$ENTHOSTNAME '. ./entserver_stop.ksh $j;exit'
else
. ./entserver_stop.ksh $j
fi
j=$(($j+1))
done
}

start_all_ent_servers()
{
get_entservers;
j=0;
host_server=$(hostname)
upper_host_server=$(echo $host_server|tr [a-z] [A-Z])
while [[ "$j"<"${#ENTSERVERS[$j]}" ]];
do
ENTHOSTNAME=${ENTSERVERS[$j]}
ENTHOSTNAME=${ENTHOSTNAME##*/}
if [[ "$ENTHOSTNAME" != "$host_server" && "$ENTHOSTNAME" != "$upper_host_server" ]];
then
ssh -i $HOME/.ssh/id_dsa_siebel_ent_login.pub $ENTSERVERUSER@$ENTHOSTNAME '. ./entserver_start.ksh $j;exit'
else
. ./entserver_start.ksh $j
fi
j=$(($j+1))
done
}

#Menu function for backwards navigation to main menu from wizards
return_main()
{
if [[ -f menu_control.ksh ]]
then
. ./menu_control.ksh 0 $pref_lang
else
cd $BASE_DIR
. ./menu_control.ksh 0 $pref_lang
fi
exit
}


#Store the current Process ID, we don't want to kill the current executing process id

kill_all_child_procs()
{
CURPID=$$

# This is process id, parameter passed by user
ppid=$1

if [ -z $ppid ] ; then
   echo No PID given.
   exit;
fi

arraycounter=1
while true
do
        FORLOOP=FALSE
        # Get all the child process id
        for i in `ps -ef| awk '$3 == '$ppid' { print $2 }'`
        do
                if [ $i -ne $CURPID ] ; then
                        procid[$arraycounter]=$i
                        arraycounter=`expr $arraycounter + 1`
                        ppid=$i
                        FORLOOP=TRUE
                fi
        done
        if [ "$FORLOOP" = "FALSE" ] ; then
           arraycounter=`expr $arraycounter - 1`
           ## We want to kill child process id first and then parent id's
           while [ $arraycounter -ne 0 ]
           do
		 kill -9 "${procid[$arraycounter]}" >/dev/null
		 arraycounter=`expr $arraycounter - 1`
           done
	 kill -9 $$
         exit
        fi
done
}

get_list_columns()
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
set -A LIST_COLUMNS
shift 1
echo "\n Retrieving $* Configuration Info..."
$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "configure list $*" /o $SERVERINFO/list_$(echo $*|sed 's/ /_/g')_config_${ENTERPRISES[$j]}.txt
configfile=$SERVERINFO/list_$(echo $*|sed 's/ /_/g')_config_${ENTERPRISES[$j]}.txt
takeit=0
while read line
do

if [[ -z "$line" ]];
then
takeit=0
fi

if [[ "$takeit" -eq 1 && ! -z "$line" ]];
then
num=$(($k+1))
echo "\n $num""-""$line"
k=$(($k+1))
fi

commandavail=$(echo "$line"|grep "configure list")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi

done < "$configfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

set_list_config()
{
# Expressions below are added to display list configuration functionalities for the components
#1st parameter is enterprise, 2nd parameter is list type 
num_check=0
get_list_columns $1 "$2" > $SERVERINFO/list_config.tmp 2>&1
temp_list_conf_file=$SERVERINFO/list_config.tmp
firstcolavail=0
set -A validconfigcols "";
display_columns=$4
k=0
while read line
do
colavail=$(echo "$line"|grep ":")
if [[ ! -z "$colavail" ]];
then
line=${line#*-}
col=$(echo ${line%%\(*}|sed 's/*^ //')
validconfigcols[$k]=$(echo "$col")
k=$(($k+1))
fi
done < "$temp_list_conf_file"

until [[ "$num_check" -eq 1 && "$firstcolavail" -eq 1 ]];
do
cat $temp_list_conf_file
echo "\n Please select component group list column numbers to be displayed, putting \";\" in between such as 1;2;5 etc. (Please click \"CTRL+C\" to return to the server sub-menu): \c"
trap "display_server_submenu $1 $2" 2
read displaycolnums

OUT=$(echo $displaycolnums|sed 's/ //g'|tr ";" "\n")
j=0;
for x in $OUT
do
  display_column_set[$j]=$(echo "$x")
  j=$(($j+1))
done

for col in ${display_column_set[*]}
do
checkNumber $col
num_check=$?

        if [[ "$num_check" -eq 0 ]];
        then
        echo "\n There is a non-numerical value in the column list selection please provide a valid number!!!"
        sleep 3;
        break;
        fi

        if [[ "$col" -eq $3 ]];
        then
        firstcolavail=1
	else
	if [[ "$col" -eq ${#display_column_set[*]} && "$firstcolavail" -ne 1 ]]; 	
	then	
	echo "\n Column with id \"$3\" value is mandatory in the column list selection !!!"        
	sleep 3;	
	fi
	fi
done

j=0;dummy=0;
while [[ "$j" -lt "${#validconfigcols[*]}" ]];
do
dummy=$(($j+1))

for x in ${display_column_set[*]}
do
        if [[ "$dummy" == "$x" ]];
        then
        ret_val=1
        break;
        else
        ret_val=0
        fi
done

        if [[ "$ret_val" -eq 1 ]];
        then
                if [[ -z "$display_columns" ]];
                then
                display_columns=$display_columns" "${validconfigcols[$j]}
                else
                display_columns=$display_columns","${validconfigcols[$j]}
                fi
        fi
j=$(($j+1))
done

echo "COLUMNS="$display_columns > $SERVERINFO/list_display_config.tmp 2>&1
done

}

server_action()
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
echo "\n $3 Down Server..."

$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "$3 appserver $2" /o $SERVERINFO/$3server_${ENTERPRISES[$j]}_$2.txt

serverfile=$SERVERINFO/$3server_${ENTERPRISES[$j]}_$2.txt
clear;
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

commandavail=$(echo "$line"|grep "$3 appserver")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi


done < "$serverfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

comp_action()
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
action=$(echo $5|sed 's/_/ /g')
echo "\n $action Server Component..."

$SIEBEL_HOME/bin/srvrmgr /g ${GWSERVERS[$j]} /e ${ENTERPRISES[$j]} /u $SADMINUSER /p $SADMINPASS /c "$action component $3 for server $2" /o $SERVERINFO/$actioncomp_${ENTERPRISES[$j]}_$2_$4.txt

compfile=$SERVERINFO/$actioncomp_${ENTERPRISES[$j]}_$2_$4.txt
clear;
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

commandavail=$(echo "$line"|grep "$action component")
if [[ ! -z "$commandavail" ]];
then
takeit=1
fi


done < "$compfile"
#else
#echo "\n Siebel Management Agent Service is not up in this machine for ${ENTERPRISES[$j]} enterprise."
#fi
fi
j=$(($j+1))
done
cd $BASE_DIR
}

#Server Submenu function
display_server_submenu()
{
if [[ ! -z "$2" ]];
then
server_submenu=0
until [[ $server_submenu = @([1-9]) ]];
do
clear;
echo "################## SERVER $(echo $2|tr [a-z] [A-Z]) IN ENTERPRISE $(echo $1|tr [a-z] [A-Z]) ####################"
echo "===================================================================================================================="
echo "\n 1- List Server Component Groups"
echo "\n 2- List Server Components"
echo "\n 3- List Server Tasks"
echo "\n 4- List Sessions for Server"
echo "\n 5- Display Server Statistics"
echo "\n 6- Display Server State Values"
echo "\n 7- List Server Parameters"
echo "\n 8- Shutdown Enterprise Server"
echo "\n 9- Start Enterprise Server"
echo "\n Please select a submenu to proceed further details! (Please click \"CTRL+C\" to return to the main menu): \c"
trap "return_main" 2
read server_submenu
done

display_columns=""

case $server_submenu in
1)
get_comp_group_details $1 $2 $display_columns > $SERVERINFO/list_server_comp_group_$2.tmp 2>&1
temp_list_server_comp_group_file=$SERVERINFO/list_server_comp_group_$2.tmp
selected_comp_group=""
compgroupavail=0
reconfigured=0
set -A validcompgroups "";
k=0;
while read line
do
comp=$(echo $line|awk '{split($0,a," "); print a[2]}')
validcomps[$k]=$(echo "$comp")
k=$(($k+1))
done < "$temp_list_server_comp_group_file"

until [[ ! -z "$selected_comp_group" && "$compgroupavail" -eq 1 ]];
do
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_comp_group_details $1 $2 $display_columns > $SERVERINFO/list_server_comp_group_$2.tmp 2>&1
reconfigured=0
fi
cat $temp_list_server_comp_group_file
echo "\n Please select a server component group \"alias name\" to proceed further details! (Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the server sub-menu): \c"
trap "display_server_submenu $1 $2" 2
read selected_comp_group

# Expressions below are added to display list configuration functionalities for the components
if [[ "$selected_comp_group" == "config" ]];
then
mandatory_col_no=2
set_list_config $1 "component group" $mandatory_col_no $display_columns
reconfigured=1
fi

containsElement "$selected_comp_group" "validcompgroups"
compgroupavail=$?
done

selected_comp_group_name=$(cat $temp_list_server_comp_group_file|grep $selected_comp_group|awk '{split($0,a," "); print a[1]}')

#displays server components based on component group selection 
if [[ ! -z "$selected_comp_group" ]];
then
display_columns=""
get_server_comp_detailsbygroup $1 $selected_comp_group $display_columns > $SERVERINFO/list_server_comp_$selected_comp_group.tmp 2>&1
temp_list_server_comp_file=$SERVERINFO/list_server_comp_$selected_comp_group.tmp
selected_comp=""
compavail=0
reconfigured=0
set -A validcomps "";
k=0;
while read line
do
comp=$(echo $line|awk '{split($0,a," "); print a[2]}')
validcomps[$k]=$(echo "$comp")
k=$(($k+1))
done < "$temp_list_server_comp_file"


until [[ ! -z "$selected_comp" && "$compavail" -eq 1 ]];
do
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_server_comp_detailsbygroup $1 $selected_comp_group $display_columns > $SERVERINFO/list_server_comp_$selected_comp_group.tmp 2>&1
reconfigured=0
fi

cat $temp_list_server_comp_file

echo "\n Please select a server component \"alias name\" to proceed further details! (Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the server sub-menu): \c"
trap "display_server_submenu $1 $2" 2
read selected_comp

# Expressions below are added to display list configuration functionalities for the components
if [[ "$selected_comp" == "config" ]];
then
mandatory_col_no=2
set_list_config $1 "component" $mandatory_col_no $display_columns
reconfigured=1
fi

containsElement "$selected_comp" "validcomps"
compavail=$?
done

selected_comp_name=$(cat $temp_list_server_comp_file|grep $selected_comp|awk '{split($0,a," "); print a[3]}')

#displays server component submenu
display_comp_submenu $1 $2 $selected_comp $selected_comp_name
fi
;;
2)
get_server_comp_details $1 $2 $display_columns > $SERVERINFO/list_server_comp_$2.tmp 2>&1
temp_list_server_comp_file=$SERVERINFO/list_server_comp_$2.tmp
selected_comp=""
compavail=0
reconfigured=0
set -A validcomps "";
k=0;
while read line
do
comp=$(echo $line|awk '{split($0,a," "); print a[2]}')
validcomps[$k]=$(echo "$comp")
k=$(($k+1))
done < "$temp_list_server_comp_file"


until [[ ! -z "$selected_comp" && "$compavail" -eq 1 ]];
do
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_server_comp_details $1 $2 $display_columns > $SERVERINFO/list_server_comp_$2.tmp 2>&1
reconfigured=0
fi

cat $temp_list_server_comp_file

echo "\n Please select a server component \"alias name\" to proceed further details! (Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the server sub-menu): \c"
trap "display_server_submenu $1 $2" 2
read selected_comp

# Expressions below are added to display list configuration functionalities for the components
if [[ "$selected_comp" == "config" ]];
then
mandatory_col_no=2
set_list_config $1 "component" $mandatory_col_no $display_columns
reconfigured=1
fi

containsElement "$selected_comp" "validcomps"
compavail=$?
done

selected_comp_name=$(cat $temp_list_server_comp_file|grep $selected_comp|awk '{split($0,a," "); print a[3]}')

#displays server component submenu
display_comp_submenu $1 $2 $selected_comp $selected_comp_name
;;

3)
selected_task=""
reconfigured=0
get_server_task_details $1 $2 > $SERVERINFO/list_server_task_$2.tmp 2>&1
temp_list_server_task_file=$SERVERINFO/list_server_task_$2.tmp

while [[ 1 = 1 ]];
do
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_server_task_details $1 $2 $display_columns > $SERVERINFO/list_server_task_$2.tmp 2>&1
reconfigured=0
fi
cat $temp_list_server_task_file
echo "\n Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the server sub-menu !"
trap "display_server_submenu $1 $2" 2
read selected_task
# Expressions below are added to display list configuration functionalities for the components
if [[ "$selected_task" == "config" ]];
then
mandatory_col_no=3
set_list_config $1 "task" $mandatory_col_no $display_columns  
reconfigured=1
fi
done
;;
4)
session_submenu=0;

until [[ $session_submenu = @([1-3]) ]];
do
echo "\n 1- List Active Server Sessions"
echo "\n 2- List Hung Server Sessions"
echo "\n 3- List All Server Sessions"
echo "\n Please select a submenu to proceed further details! (Please click \"CTRL+C\" to return to the server sub-menu): \c"
trap "display_server_submenu $1 $2" 2
read session_submenu
done

session_type=""
case $session_submenu in
1)
session_type="active";;
2)
session_type="hung";;
3)
session_type="";;
esac

selected_session=""
reconfigured=0
get_server_session_details $1 $2 $session_type > $SERVERINFO/list_server_session_$2.tmp 2>&1
temp_list_server_session_file=$SERVERINFO/list_server_session_$2.tmp

while [[ 1 = 1 ]];
do
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_server_session_details $1 $2 $session_type $display_columns > $SERVERINFO/list_server_session_$2.tmp 2>&1
reconfigured=0
fi
cat $temp_list_server_session_file
echo "\n Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the server sub-menu ! \c"
trap "display_server_submenu $1 $2" 2
read selected_session
if [[ "$selected_session" == "config" ]];
then
mandatory_col_no=4
set_list_config $1 "session" $mandatory_col_no $display_columns
reconfigured=1
fi
done
;;
5)
selected_stat=""
reconfigured=0
get_server_statistics $1 $2 > $SERVERINFO/list_server_statistics_$2.tmp 2>&1
temp_list_server_statistics_file=$SERVERINFO/list_server_statistics_$2.tmp

while [[ 1 = 1 ]];
do
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_server_statistics $1 $2 $display_columns > $SERVERINFO/list_server_statistics_$2.tmp 2>&1
reconfigured=0
fi
cat $temp_list_server_statistics_file
echo "\n Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the server sub-menu ! \c"
trap "display_server_submenu $1 $2" 2
read selected_stat 
if [[ "$selected_stat" == "config" ]];
then
mandatory_col_no=2
set_list_config $1 "statistics" $mandatory_col_no $display_columns
reconfigured=1
fi
done
;;
6)
selected_state_value=""
reconfigured=0
get_server_state_values $1 $2 > $SERVERINFO/list_server_state_values_$2.tmp 2>&1
temp_list_server_state_values_file=$SERVERINFO/list_server_state_values_$2.tmp

while [[ 1 = 1 ]];
do
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_server_state_values $1 $2 $display_columns > $SERVERINFO/list_server_state_values_$2.tmp 2>&1
reconfigured=0
fi
cat $temp_list_server_state_values_file
echo "\n Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the server sub-menu ! \c"
trap "display_server_submenu $1 $2" 2
read selected_state_value

if [[ "$selected_state_value" == "config" ]];
then
mandatory_col_no=2
set_list_config $1 "state value" $mandatory_col_no $display_columns
reconfigured=1
fi
done
;;
7)
selected_param=""
reconfigured=0
get_server_params $1 $2 > $SERVERINFO/list_server_params_$2.tmp 2>&1
temp_list_server_params_file=$SERVERINFO/list_server_params_$2.tmp

while [[ 1 = 1 ]];
do
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_server_params $1 $2 $display_columns > $SERVERINFO/list_server_params_$2.tmp 2>&1
reconfigured=0
fi
cat $temp_list_server_params_file
echo "\n Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the server sub-menu ! \c"
trap "display_server_submenu $1 $2" 2
read selected_param

if [[ "$selected_param" == "config" ]];
then
mandatory_col_no=1
set_list_config $1 "parameters" $mandatory_col_no $display_columns
reconfigured=1
fi
done
;;
8)
action="shutdown"
server_action $1 $2 $action > $SERVERINFO/$action_$2.tmp 2>&1
temp_server_action_file= $SERVERINFO/$action_$2.tmp
cat $temp_server_action_file 
display_server_submenu $1 $2
;;
9)
action="startup"
server_action $1 $2 $action> $SERVERINFO/$action_$2.tmp 2>&1
temp_server_action_file= $SERVERINFO/$action_$2.tmp
cat $temp_server_action_file
display_server_submenu $1 $2
;;
*)
;;
esac
fi
}

#Server Submenu function
display_comp_submenu()
{
if [[ ! -z "$1" && ! -z "$2" && ! -z "$3" && ! -z "$4" ]];
then
comp_submenu=0
until [[ $comp_submenu = @([1-8]) ]];
do
clear;
echo "################## COMPONENT $4 IN SERVER $(echo $2|tr [a-z] [A-Z])  ####################"
echo "========================================================================================================================================"
echo "\n 1- List Server Component Tasks"
echo "\n 2- List Server Component Statistics"
echo "\n 3- List Server Component State Values"
echo "\n 4- List Server Component Parameters"
echo "\n 5- Shutdown Server Component"
echo "\n 6- Start Server Component"
echo "\n 7- Set Server Component to Auto Start"
echo "\n 8- Set Server Component to Manual Start"
echo "\n Please select a submenu to proceed further details! (Please click \"CTRL+C\" to return to the server sub-menu): \c"
trap "display_server_submenu $1 $2" 2

read comp_submenu
done
case $comp_submenu in
1)
selected_task=""
reconfigured=0
get_comp_task_details $1 $2 $3 $4 > $SERVERINFO/list_comp_task_$2_$4.tmp 2>&1
temp_list_comp_task_file=$SERVERINFO/list_comp_task_$2_$4.tmp

while [[ 1 = 1 ]];
do
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_comp_task_details $1 $2 $3 $4 $display_columns > $SERVERINFO/list_comp_task_$2_$4.tmp 2>&1
reconfigured=0
fi
cat $temp_list_comp_task_file
echo "\n Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the server component sub-menu ! \c"
trap "display_comp_submenu $1 $2 $3 $4" 2
read selected_task
# Expressions below are added to display list configuration functionalities for the components
if [[ "$selected_task" == "config" ]];
then
mandatory_col_no=3
set_list_config $1 "task" $mandatory_col_no $display_columns
reconfigured=1
fi
done
;;
2)
selected_stat=""
reconfigured=0
get_comp_statistics $1 $2 $3 $4 > $SERVERINFO/list_comp_statistics_$2_$4.tmp 2>&1
temp_list_comp_statistics_file=$SERVERINFO/list_comp_statistics_$2_$4.tmp

while [[ 1 = 1 ]];
do
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_comp_statistics $1 $2 $3 $4 $display_columns > $SERVERINFO/list_comp_statistics_$2_$4.tmp 2>&1
reconfigured=0
fi

cat $temp_list_comp_statistics_file
echo "\n Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the server component sub-menu ! \c"
trap "display_comp_submenu $1 $2 $3 $4" 2
read selected_stat
if [[ "$selected_stat" == "config" ]];
then
mandatory_col_no=2
set_list_config $1 "statistics" $mandatory_col_no $display_columns
reconfigured=1
fi
done
;;
3)
selected_state_value=""
reconfigured=0
get_comp_state_values $1 $2 $3 $4 > $SERVERINFO/list_comp_statevalues_$2_$4.tmp 2>&1
temp_list_comp_statevalues_file=$SERVERINFO/list_comp_statevalues_$2_$4.tmp

while [[ 1 = 1 ]];
do
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_comp_state_values $1 $2 $3 $4 $display_columns > $SERVERINFO/list_comp_statevalues_$2_$4.tmp 2>&1
reconfigured=0
fi

cat $temp_list_comp_statevalues_file
echo "\n Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the server component sub-menu ! \c"
trap "display_comp_submenu $1 $2 $3 $4" 2
read selected_state_value

if [[ "$selected_state_value" == "config" ]];
then
mandatory_col_no=2
set_list_config $1 "state value" $mandatory_col_no $display_columns
reconfigured=1
fi
done
;;
4)
selected_param=""
reconfigured=0
get_comp_params $1 $2 $3 $4 > $SERVERINFO/list_comp_param_$2_$4.tmp 2>&1
temp_list_comp_param_file=$SERVERINFO/list_comp_param_$2_$4.tmp

while [[ 1 = 1 ]];
do
if [[ "$reconfigured" -eq 1 ]];
then
display_columns=$(grep "COLUMNS=" $SERVERINFO/list_display_config.tmp|awk 'BEGIN{FS="="} {print $2}')
get_comp_params $1 $2 $3 $4 $display_columns > $SERVERINFO/list_comp_param_$2_$4.tmp 2>&1
reconfigured=0
fi

cat $temp_list_comp_param_file
echo "\n Please enter \"config\" to change columns displayed or click \"CTRL+C\" to return to the server component sub-menu ! \c"
read selected_param

if [[ "$selected_param" == "config" ]];
then
mandatory_col_no=1
set_list_config $1 "parameters" $mandatory_col_no $display_columns
reconfigured=1
fi
done
;;
5)
action="shutdown"
comp_action $1 $2 $3 $4 $action > $SERVERINFO/$action_$2_$4.tmp 2>&1
temp_component_action_file= $SERVERINFO/$action_$2_$4.tmp
cat $temp_component_action_file 
display_comp_submenu $1 $2 $3 $4
;;
6)
action="startup"
comp_action $1 $2 $3 $4 $action > $SERVERINFO/$action_$2_$4.tmp 2>&1
temp_component_action_file= $SERVERINFO/$action_$2_$4.tmp
cat $temp_component_action_file
display_comp_submenu $1 $2 $3 $4
;;
7)
action="auto_start"
comp_action $1 $2 $3 $4 $action > $SERVERINFO/$action_$2_$4.tmp 2>&1
temp_component_action_file= $SERVERINFO/$action_$2_$4.tmp
cat $temp_component_action_file
display_comp_submenu $1 $2 $3 $4
;;
8)
action="manual_start"
comp_action $1 $2 $3 $4 $action > $SERVERINFO/$action_$2_$4.tmp 2>&1
temp_component_action_file= $SERVERINFO/$action_$2_$4.tmp
cat $temp_component_action_file
display_comp_submenu $1 $2 $3 $4
;;
*)
;;
esac
fi
} 
