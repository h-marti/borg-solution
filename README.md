# BORG SOLUTION

<!-- TOC tocDepth:2..3 chapterDepth:2..6 -->

- [Description](#description)
- [Setup](#setup)
    - [Backup Server](#backup-server)
    - [Main Machine](#main-machine)
    - [Finalization](#finalization)

<!-- /TOC -->

## Description

This repository describes a procedure and a set of scripts to set up borg backup in a `main machine` <> `backup server` configuration.

## Setup

### Backup Server

- Install borgbackup
    - `apt install borgbackup`
- Create a group for backup users (robot).
    - `addgroup backup_users`
    - Allows all backup users to be identified in the following configurations
- Edit `/etc/ssh/sshd_config` and add the configuration provided in [`sshd.config`](exemple/server/sshd.config)
- Reload the sshd service with `systemctl reload sshd`
- Create a [`backup.sh`](exemple/server/backup/backup.sh) file at the chosen location
    - Example `/backup/backup.sh`
    - Don't forget to execute `chmod +x /backup/backup.sh` to make the script executable

- Create a backup user and its associated borg repo using the script [`create_backup_user.sh`](exemple/server/create_backup_user.sh)
    - `create_backup_user.sh <backup user>`
    - WARNING: Be sure to note the passphrase used when initialising the borg repo

### Main Machine

In the directory `/backup` :

- Create a [`start-backup.sh`](exemple/client/backup/start-backup.sh) file
    - Don't forget to execute `chmod +x start-backup.sh` to make the script executable
- Create a [`backup_s.conf`](exemple/client/backup/config/backup_s.conf) file in `/backup/config`
    - `/backup/config/backup_s.conf`
- Create a `backup_s.d` directory in `/backup/config`
    - `/backup/config/backup_s.d`
- In this directory, create the configurations for each backup category
    - Example : 
        - \<category>.list -> list of files or directories to be backed up (full path to be described)
        - \<category>.exclude.list -> list of files or directories not to be backed up (full path to be described)
        - \<category>.sh -> script executed BEFORE the backup
        - \<category>.cleanup.sh -> script executed AFTER the backup
- Don't forget to execute `chmod +x` .sh files

### Finalization

- Create an ssh key for the `root` user of the **machine to be backed up**
- Copy the public key obtained into the `autorized_keys` file of the user previously created on the **backup server**
- Create a cron job for the `root` user of the machine to be backed up in order to run the backup periodically
    - Example : `0 4 * * 7 /backup/start-backup.sh <category>` => Run a backup every Sunday at 4am for the category `<category>`
    - WARNING: the first backup may take a long time