#!/usr/bin/ksh
########################################################
# Name:
# start.ksh
#
# Description:
# This script is to start the Siebel Administration Tool for Solaris
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
. ./init.ksh 
. ./util.ksh
#
#------------------------------------------------------#

if [[ "$need_lang_select" == "TRUE" ]];
then
containsElement "$pref_lang" "LANGS"
langavail=$?
until [[ "$langavail" -eq 1 && ! -z "$pref_lang" ]];
do 
clear;
echo "\n Siebel Administration Tool for Solaris"
echo "============================================"
set -A selectionlist;
i=1
for lang in ${LANGS[*]} 
do
echo "\n $i""- $lang" 
j=$(($i-1))
selectionlist[$j]=$i
i=$(($i+1))
done
echo "\n Please select the language that you are willing to use during your operations! Default Application language is \"$default_lang\".(Please click \"CTRL+C\" to retun to quit from the application): \c"
read pref_lang 

checkNumber $pref_lang
num_check=$?
if [[ "$num_check" -eq 1 ]] 
then
containsElement "$pref_lang" "selectionlist"
numavail=$?
j=$(($pref_lang-1))
pref_lang=${LANGS[$j]}
fi

containsElement "$pref_lang" "LANGS"
langavail=$?

done
else
pref_lang=$default_lang
fi

. ./menu_control.ksh 0 $pref_lang











