#/bin/bash
set -e

useradd -d <chemin vers le stockage de la sauvegarde>/"$1" --create-home "$1" --shell /backup/backup.sh
usermod -aG backup_users "$1"
sleep 1
su - "$1" -s /bin/bash -c "mkdir ~$1/.ssh ~$1/data"
su - "$1" -s /bin/bash -c "touch ~$1/.ssh/authorized_keys"
su - "$1" -s /bin/bash -c 'borg init -e repokey ~/data'