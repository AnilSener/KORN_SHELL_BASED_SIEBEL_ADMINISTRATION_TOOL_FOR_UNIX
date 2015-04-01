#!/usr/bin/ksh
########################################################
# Name:
# script_run.ksh
#
# Description:
# This script is created to facilitate the control of menu scripts
#
# Created By:
# Siebel Expert Services
#
# Version : 0.1
#
# Update History:
#======================================================
#03/05/2013 Expert Services (v0.1)
#------------------------------------------------------
# Created
#======================================================

#------------------------------------------------------#
run_wizard()
{
SCRIPT=$(grep "$1 " script_library.cfg|awk 'BEGIN{FS="="} {print $2}'|sed 's/ //g')
echo "$SCRIPT"
}
