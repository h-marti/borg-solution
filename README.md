# BORG SOLUTION

<!-- TOC tocDepth:2..3 chapterDepth:2..6 -->

- [Description](#description)
- [Prerequis](#prerequis)
    - [Serveur de sauvegarde](#serveur-de-sauvegarde)
    - [Machine principale](#machine-principale)
    - [Finalisation](#finalisation)

<!-- /TOC -->

## Description

Ce depot decris une procedure et un ensemble de script permettant de mettre en place borg backup dans une configuration `machine principale` <> `serveur de sauvegarde`

## Prerequis

### Serveur de sauvegarde

- Installer borgbackup
    - `apt install borgbackup`
- Creer un groupe pour les utilisateurs (robot) de sauvegarde.
    - `addgroup backup_users`
    - Permet d'identifier tous les utilisateurs dans les configurations qui suivent
- Editer le fichier `/etc/ssh/sshd_config` et ajouter la configuration dans le fichier `sshd.config`
- Recharger le service sshd avec `systemctl reload sshd`
- Creer le ficher `backup.sh` a l'endroit choisi. Exemple `/backup`
    - `/backup/backup.sh`
    - Ne pas oublier d'executer `chmod +x /backup/backup.sh` pour rendre le script executable

- Creer l'utilisateur de backup en utilisant le script `create_backup_user.sh`
    - `create_backup_user.sh <nom d'utilisateur de backup>`
    - ATTENTION : Bien noter la passphrase utilisee au moment de la configuration

### Machine principale

Dans le repertoire `/backup` :

- Creer le fichier `start-backup.sh`
- Penser a executer `chmod +x start-backup.sh`
- Creer le fichier `backup_s.conf` dans `/backup/config` : `/backup/config/backup_s.conf`
- Creer le repertoire `backup_s.d` dans `/backup/config` : `/backup/config/backup_s.d`
- Dans ce repertoire, creer un fichier pour chaque categorie de sauvegarde. Exemple : 
    - \<categorie>.list -> liste de fichiers ou de repertoires a sauvegarder (chemin complet a decrire)
    - \<categorie>.exclude.list -> liste de fichiers ou de repertoires a ne pas sauvegarder (chemin complet a decrire)
    - \<categorie>.sh -> script execute AVANT la sauvegarde
    - \<categorie>.cleanup.sh -> script execute APRES la sauvegarde
- Ne pas oublier de `chmod +x` les fichier .sh

### Finalisation

- Creer une cle ssh pour l'utilisateur `root` de la machine a sauvegarder
- Copier la cle publique obtenue dans le fichier `autorized_keys` de l'utilisateur cree precedemment sur le serveur de sauvegarde
- Creer une tache cron pour l'utilisateur `root` de la machine a sauvegarder afoin d'executer periodiquement la sauvegarde
    - Exemple : `0 4 * * 7 /backup/start-backup.sh <categorie>` => Lance une sauvegarde tous les dimanches a 4h du matin pour la categorie \<categorie>
    - ATTENTION : la premiere sauvegarde peut etre longue