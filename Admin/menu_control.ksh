#!/usr/bin/ksh
########################################################
# Name:
# menu_control.ksh
#
# Description: 
# This script is to facilitate important Siebel Administrative tasks in Solaris/system information 
#
# Created By:
# Siebel Expert Services
#
# Version : 0.1
#
# Update History:
#======================================================
#22/04/2013 Expert Services (v0.1)
#------------------------------------------------------
# Created
#======================================================
. ./script_run.ksh
. ./util.ksh

#------------------------------------------------------#

set -A levels  
set -A ids 
set -A names 
set -A headers 
set -A levelids

active_level=0;
selected_id=0;
menu_address="";
exit_control=$1
pref_lang=$2
get_menufiles
menufile=$(check_menufile)
xml_parser ()

#------------------------------------------------------# 
{

OUT=$(egrep 'level|id|name|menuheader' $menufile|tr -d '\t'| sed 's/^<.*>\([^<].*\)<.*>$/\1/'|sed 's/ /_/g')
i=0;j=0
for tagvalue in ${OUT[@]} 
do

case $(($i%4)) in
0)
levels[$j]=$tagvalue;;
1)
ids[$j]=$tagvalue;;
2)
tagvalue=$(echo $tagvalue|sed -e 's/_/ /g')
names[$j]=$tagvalue;;
3)
tagvalue=$(echo $tagvalue|sed -e 's/_/ /g')
headers[$j]=$tagvalue
j=$(($j+1))
;;
esac

i=$(($i+1))

done
}
#------------------------------------------------------#


function header_line
#------------------------------------------------------#
{
 echo "#------------------------------------------------------#"
 echo "$*"
 echo "#------------------------------------------------------#\n"
} 
#------------------------------------------------------#

#------------------------------------------------------#
function menu_item
{
 echo "$*\n"
} 

function display_main
{
 
main_header=$(egrep 'mainheader' $menufile|tr -d '\t'| sed 's/^<.*>\([^<].*\)<.*>$/\1/')
clear;
header_line "\n "$main_header

xml_parser;
j=0;k=0;
while [[ "$j" < "${#names[*]}" ]];  
do
	if [[ "${levels[$j]}" -eq 1 ]];
	then
	menu_item "\n "${ids[$j]}"- "${names[$j]}
	levelids[$k]=${ids[$j]}
	k=$(($k+1))
	fi
j=$(($j+1))
done
active_level=1
menu_address="0"
} 


#Menu drill-down function
drilldown()
{
j=$selected_id;k=0;headerfound=0;menufound=0;
next_header=0;first_header="";ret_script=""
while [[ "$j"<${#names[*]} ]];
do
	
	if [[ "$1" == "${ids[$j]}" && ${levels[$j]} = "$2" && "$headerfound" = 0  ]];
	then
	clear;
#	header_line "\n "${headers[$j]}
	if [[ "$2" -ge "$lev" ]];
	then
	menu_address=$menu_address"/"$selected_menu
	fi
	lev=$(($2+1))
	headerfound=1
	first_header=${headers[$j]}	
	fi

#checks the next equal level header id to restrict the menu items displayed in the limits of the selected id 
	if [[ "$headerfound" = 1 && "${levels[$j]}" = $2 && "$first_header" != ${headers[$j]} ]];
	then
	next_header=1
	fi	

#	if [[ "$headerfound" = 1 && "${levels[$j]}" == "$lev" && "$next_header" = 0 ]];
#	then
#	menu_item "\n "${ids[$j]}"- "${names[$j]}
#	levelids[$k]=${ids[$j]}
#	k=$(($k+1))
#	menufound=1
#	fi

#The condition below executes a script from script library in case there is not any sub-menu item available for the selected menu item

	return_val="ksh "$(run_wizard $menu_address)" "$pref_lang

	if [[ ! -z "$return_val" && ! -z "$(run_wizard $menu_address)" && "$headerfound" = 1 && "$menufound" = 0 ]];
	then
	eval $return_val 
	break;		
	fi

j=$(($j+1))

	if [[ "$headerfound" = 1 && "$menufound" = 1 && ${levels[$j]} < "$lev"  ]];
	then
	active_level=$lev
		
		if [[ ! -z "$selected_menu" ]];
		then
		pre_selected_menu=$selected_menu
		fi
	
	echo "\n Please enter your menu selection in number or click "CTRL+C" to return to the previous menu: \c"
	trap "return_back" 2 
	read selected_menu
	validate_selection
		if [[ ! -z "$selected_menu" ]];
       		then
			m=0;prev_menu=0	
			while [[ "$m"<${#names[*]} ]];
			do
		#The two conditions below searches the previously selected menu item id 
				if [[ "${levels[$m]}" == "$2" && "${ids[$m]}" == "$pre_selected_menu" ]];
				then
				prev_menu=1	
				fi	

				if [[ "${levels[$m]}" == "$2" && "${ids[$m]}" != "$pre_selected_menu" ]];
				then
				prev_menu=0
				fi	
	 #This condition selects the latest selected items array id to be used in the second drill down loop, it is very important to restrict starting point of the menu items
				if [[ "${levels[$m]}" == "$lev" && "${ids[$m]}" == "$selected_menu" && "$prev_menu" = 1 ]];	
				then	
				selected_id=$m
				fi	
			m=$(($m+1))	
			done		
		drilldown $selected_menu $(($2+1))
		break;
		fi	
	fi
done
}

#Menu function for backwards navigation
return_back()
{

if [[ "$active_level" -eq 1 ]]; 
then

	if [[ "$exit_control" -eq 0 ]];
	then
	echo "Application is terminated"
	fi
parent_process=$(ps -ef|grep " start.ksh"|awk '/:/ {print $2}')
if [[ ! -z "$parent_process" ]];
then
kill_all_child_procs $parent_process
fi
exit

fi
menu_address=${menu_address%/*}
echo $menu_address 
if [[ "$active_level" -eq 2 ]];
then
display_main
echo "\n Please enter your menu selection in number or click "CTRL+C" to quit from application:\c"
trap "return_back" 2
read selected_menu
validate_selection
selected_id=0
drilldown $selected_menu 1
else
selected_id=0

drilldown $pre_selected_menu $(($active_level-2))

fi

}

#Menu validation function for menu selection
validate_selection ()
{ 
proceed=1;
ret=1;
ret_num=1;

if [[ ! -z "$selected_menu" ]];
then
checkNumber $selected_menu
ret_num=$?
fi

if [[ ! -z "$selected_menu" && "$ret_num" -eq 1 ]];
then 
containsElement $selected_menu "levelids"
ret=$?
else
proceed=0
fi

while [[ "$proceed" -eq 0 || "$ret" -eq 0 ]];
do
echo "\n WARNING: Please provide an accurate menu selection!!!"

	if [[ "$active_level" -eq 1 ]];
	then
	display_main
	else
	drilldown $pre_selected_menu $(($active_level-1)) 
	fi

	if [[ ! -z "$selected_menu" ]];
	then
	checkNumber $selected_menu
	ret_num=$?
	fi

	if [[ ! -z "$selected_menu" && "$ret_num" -eq 1 ]];
	then
	pre_selected_menu=$selected_menu
	fi

	if [[ "$active_level" -eq 1 ]];
	then
	echo "\n Please enter your menu selection in number or click "CTRL+C" to quit from application: \c"
	else
	echo "\n Please enter your menu selection in number or click "CTRL+C" to return to the previous menu: \c"
	fi
	trap "return_back" 2
	read selected_menu
	if [[ ! -z "$selected_menu" ]];
	then
	checkNumber $selected_menu
	ret_num=$?
	fi

	if [[ ! -z "$selected_menu" && "$ret_num" -eq 1 ]];
	then
	containsElement $selected_menu "levelids"
	ret=$?

	if [[ "$ret" -eq 1 ]];
	then
	break;
	fi
	else
	proceed=0
	fi
done
}

#MAIN Administration Menu
display_main
echo "\n Please enter your menu selection in number or click "CTRL+C" to quit from application: \c"
trap "return_back" 2
read selected_menu
validate_selection

if [[ ! -z "$selected_menu" ]];
then
drilldown $selected_menu 1 
fi



