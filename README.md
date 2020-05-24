# rsync-bkp
Simple backup of config files from single-board computers (like Raspberry Pi)

(2020/05/23) Relative unreliability of single board controllers like Raspberry Pi (mainly due to SD card wear out) forced us to consider some forms of configuration backup for these little devices. So even if the SD card crashes, you can burn your new SD card, enter basic configuration (like network connection) and then restore remaining config files from the backup. Backup is not a rocket science, of course, but is often overlooked due to resource and time constraints associated with the initial implementation project. And then there is too late to remember about performing the backup... 

Rsync has been selected as the best candidate:
  * extremely flexible
  * simple and cross-platform
  * high-performance and scalable

### SOLUTION ARCHITECTURE
rsync offers several modes of operation and dozens of configuration options. This is what has been selected here:
  * OpenMediaVault (OMV) NAS storage - storage resource to keep RPi backups
  * rsync in 'daemon access mode' running on OMV, with appropriate disk share to keep backups - this is the 'receiving side' (aka 'target') rsync instance. It receives the data from 'sending side' rsync installed on RPi (one or more)
  * runtime script - this Bash script is designed to run on each RPi in order to perform the configuration sync/backup.
  
###  OMV NAS SETUP

OMV NAS has to be pre-configured to became 'rsync' target. There are several ways to connect two machines via 'rsync'. One of it is 'daemon access mode' with plain rsync-to-rsync communication. This mode has been selected for this project (alternatives: mounting remote storage as local resource or using 'ssh' for machine-to-machine link). 

When using 'daemon access mode', you have to define so-called *modules* on the 'receiving side'. These 'modules' define the storage resource available for the tasks. 'Sending side' can then connect to such 'module' and send there the reguired files, without the need for detailed knowledge on target side directory structure. Simple and secure.

How to configure the 'module' in OMV? Log in to OMV web GUI. Then go to *Services → Rsync* menu and switch from default *Jobs* to *Server* (click *Server* tab). This will configure 'rsync' in daemon mode on the target. Being there, click on *Modules* to define the module for RPi backup. 

https://raw.githubusercontent.com/DarS007/rsync-bkp/master/OMV_rsync_setup.01.png
