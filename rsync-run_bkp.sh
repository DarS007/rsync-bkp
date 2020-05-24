#!/bin/bash
#########################################################
## 2020/05/24 - DarS
## Script file to do a configuration backup for RPi.
## Place it in home directory of RPi from where you want to backup its
## configuration. Then:
##   - change the BKPCLIENT to the name of THIS machine
##   - change the NASSERVER to the name FQDN (or IP) of your OMV NAS,
##     where runs properly configured 'rsync' in 'daemon access mode'
##   - enter the list of directories for backup to DIR2BACKUP file 
##     (default 'rsync-src_files.txt')
##     Please remember this script DOES NOT follow the (sym)links,
##     therefore you need to think of your list of directories accordingly
##   - enter the list of files to be excluded to EXCLUDEFILE
##     (default 'rsync-exclude.txt')
##   - properly configure the destination resource on NAS
##      - 'rsync' needs to be configured in 'daemon' mode with
##         BACKUP module created and enabled
##   - run this script with 'sudo' to make sure all /etc files are
##     accessible to the script
##
BKPCLIENT=YOUR.RPI.MACHINE.NAME
NASSERVER=FQDN.YOUR.OMV.NAS
DIR2BACKUP=rsync-src_files.txt
EXCLUDEFILE=rsync-exclude.txt
rsync -rvutb --recursive --files-from=$DIR2BACKUP --exclude-from=$EXCLUDEFILE / rsync://$NASSERVER/BACKUP/$BKPCLIENT
