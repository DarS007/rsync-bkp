# rsync-bkp
Simple backup of config files from single-board computers (like Raspberry Pi)

### Table of contents
* [SOLUTION ARCHITECTURE](#SOLUTION-ARCHITECTURE)
* [OMV NAS SETUP](#OMV-NAS-SETUP)
* [RSYNC CLIENT SETUP](#RSYNC-CLIENT-SETUP)
* [INSTALLATION AND CONFIGURATION](INSTALLATION-AND-CONFIGURATION)
* [USAGE](USAGE)

(2020/05/23) Relative unreliability of single board controllers like Raspberry Pi (mainly due to SD card wear out) forced us to consider some forms of configuration backup for these little devices. So even if the SD card crashes, you can burn your new SD card, enter basic configuration (like network connection) and then restore remaining config files from the backup. Backup is not a rocket science, of course, but is often overlooked due to resource and time constraints associated with the initial implementation project. And then there is too late to remember about performing the backup... 

What needs to be backuped? The unique files that cannot be restored by flashing new OS on SD card:
 * */etc* configuration files
 * */home* directory
 * content of web page
 * your own code
 * etc

You are offered two files *rsync-src_files.txt* (defines what to backup) and *rsync-exclude.txt* (defines what NOT to backup) that you can tailor to suit your needs. Both files are pre-populated with defaults, by the way.

*Rsync* has been selected as the best candidate for syncing mechanism. It is:
  * extremely flexible
  * simple and cross-platform
  * high-performance and scalable

### SOLUTION ARCHITECTURE
rsync offers several modes of operation and dozens of configuration options. This is what has been selected here:
  * **OpenMediaVault (OMV) NAS storage** - storage resource to keep RPi backups
  * **rsync in 'daemon access mode'** running on OMV, with appropriate disk share to keep backups - this is the 'receiving side' (aka 'target') rsync instance. It receives the data from 'sending side' rsync installed on RPi (one or more)
  * **backup run script** - this Bash script is designed to run on each RPi in order to perform the configuration sync/backup.
  
###  OMV NAS SETUP

OMV NAS has to be pre-configured to became 'rsync' target. There are several ways to connect two machines via 'rsync'. One of it is 'daemon access mode' with plain rsync-to-rsync communication. This mode has been selected for this project (alternatives: mounting remote storage as local resource or using 'ssh' for machine-to-machine link). 

When using 'daemon access mode', you have to define so-called *modules* on the 'receiving side'. These 'modules' define the storage resource available for the tasks. 'Sending side' can then connect to such 'module' and send there the reguired files, without the need for detailed knowledge on target side directory structure. Simple and secure.

How to configure the 'module' in OMV? Log in to OMV web GUI. Then go to *Services → Rsync* menu and switch from default *Jobs* to *Server* (click *Server* tab). This will configure 'rsync' in daemon mode on the OMV target. Being there, click on *Modules* to define the module for RPi backup. 

![alt text](https://raw.githubusercontent.com/DarS007/rsync-bkp/master/OMV_rsync_setup.01.png "OMV setup for 'rsync' daemon")

Create there new *BACKUP* module which points to your disk share designated to RPi configuration storage. You can select *Use chroot* and enable *user authentication* for improved security.

Once done, switch to client machine and type there the following in the 'ssh' console to see whether *BACKUP* module is properly visible/accessible:
```
> sudo rsync rsync://YOUR.OMV.SERVER/
BACKUP          Resource for backing the configuration files from RPis
```

### RSYNC CLIENT SETUP

Once the 'rsync target' (receiving side on OMV) was configured, it was time to take care of 'rsync' on Raspberry Pi (sending) side. It's rsync binary is supposed to:
  *  make the connection to 'rsync' on OMV NAS
  *  open and read the local file with list of directories for backing up (and another file with exclude list)
  *  transfer the selected files from RPi to receiving side (OMV)

Several nice guides can help with proper configuration:
  *  [How to rsync only a specific list of files?](https://stackoverflow.com/questions/16647476/how-to-rsync-only-a-specific-list-of-files)
  *  [How to use rsync --list-only source to list all the files in that directory?](https://stackoverflow.com/questions/13414086/how-to-use-rsync-list-only-source-to-list-all-the-files-in-that-directory)

It was determined that **'rsync -rvut'** options are good enough for syncing RPi's config files to central storage. The '-rvut' options are usually used for FAT target (FAT does not support advanced file properties like ownership or access rights), and they fit for OMV setup as well (where 'rsync' is limited to certain user and to limited file attributes controlled by OMV).

Reference command for backing up the RPi configuration files:
```
> sudo rsync -rbvut --recursive --files-from=rsync-src_files.txt --exclude-from=rsync-exclude.txt / rsync://YOUR.OMV.SERVER/BACKUP/RPI_NAME
```
where:
 * 'rsync-src_files.txt' is prepared for each RPi individually and consist of list of directories to be backed up
 * 'rsync-exclude.txt' includes list of exclusions like 'passwd' and 'shadow' files.

The above command gives you the idea what and how is backed up. This command is executed by *rsync-run_bkp.sh* script.

### INSTALLATION AND CONFIGURATION
You can skip the first line (*install git*) if you already have this binary.
```
> sudo apt-get install git
> mkdir bin
> cd bin
> git clone https://github.com/DarS007/rsync-bkp.git
> cd rsync-bkp
  - configure *rsync-exclude.txt, rsync-run_bkp.sh* and *rsync-src_files.txt* files
> chmod +x rsync-run_bkp.sh
> sudo ./rsync-run_bkp.sh
```
If you prefer, you can install it manually. Just download these three files from this GitHub repository and place them for instance in your home directory:
```
 rsync-run_bkp.sh 
 rsync-exclude.txt
 rsync-src_files.txt
```
Edit *rsync-exclude.txt* and *rsync-src_files.txt* to suit your needs.

### USAGE
Run **./rsync-run_bkp.sh** from your home directory (*rsync-exclude.txt* and *rsync-src_files.txt* needs to be there) as 'sudo'.

Why 'sudo'? Because majority of RPi configuration files are in '/etc' directory, where the regular user has a limited access.
