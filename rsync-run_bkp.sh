#!/bin/bash
#########################################################
## 2020/05/24 - DarS
## Script file to perform a configuration backup for RPi.
##
## If you want to do a 'system configuration backup' for your Raspberry Pi, 
##  place this script in your home directory.
## Then:
##   - change the BKPCLIENT to the name of your (THIS) machine
##   - change the NASSERVER to the FQDN name (or IP) of your OMV NAS.
##     Properly configured 'rsync' has to run in 'daemon access mode'
##     on your NAS. That 'rsync' will receive the backup data from your RPi.
##   - enter the list of directories to be backed up to DIR2BACKUP file 
##     (default file name: 'rsync-src_files.txt')
##     Please remember this script DOES NOT follow the (sym)links,
##     therefore you need to prepare your list of directories accordingly
##   - enter the list of files to be excluded to EXCLUDEFILE
##     (default file name 'rsync-exclude.txt')
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
