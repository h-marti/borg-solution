#!/bin/bash

info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM


category="${1}"
configroot='/backup'
config="${configroot}/backup_s.conf"
[ ! -f "${config}" ] && (echo "Configuration file ${config} not found)"; exit 2)
source "${config}"

export BORG_REPO
export BORG_PASSPHRASE

[ -z "${BACKUP_PREFIX}" ] && BACKUP_PREFIX="sn"

catconfig="${configroot}/backup_s.d/${category}.list"
catexclconfig="${configroot}/backup_s.d/${category}.exclude.list"
prescript="${configroot}/backup_s.d/${category}.sh"
postscript="${configroot}/backup_s.d/${category}.cleanup.sh"
[[ ! -f "${catconfig}" ]] && echo "Unknown category. (configuration file ${catconfig} not found)" && exit 3

[[ -f "${prescript}" ]] && info "Starting pre-backup script [${category}]" && "${prescript}"

info "Starting backup [${category}]"

function getExcludelist(){
  [[ ! -f "${catexclconfig}"  ]] && exit 1
  while read line; do
   echo "--exclude ${line} "
  done < "${catexclconfig}"

}

borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --stats                         \
    --show-rc                       \
    --compression zstd              \
    --exclude-caches                \
    --exclude '/home/*/.cache/*'    \
    --exclude '/var/tmp/*'          \
    $(getExcludelist)               \
                                    \
    ::"${BACKUP_PREFIX}"'-{hostname}-'"${category}"'-{now}' \
    $(< ${catconfig})

[[ -f "${postscript}" ]] && info "Starting post-backup script [${category}]" && "${postscript}"
