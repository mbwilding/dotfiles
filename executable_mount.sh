#!/usr/bin/env bash

mkdir -p ~/mnt/{truenas/{common,security,mbwilding,josh,sara,apps},sara/{root,home}}

TRUENAS_BASE=~/mnt/truenas
NEXTCLOUD_BASE=~/mnt/nextcloud
CRED_PATH=~/.credentials

echo "Mounting CIFS shares..."
sudo mount.cifs //truenas/common              "$TRUENAS_BASE/common"           -o credentials=${CRED_PATH}/truenas-common,file_mode=0777,dir_mode=0777,uid=$(id -u),gid=$(id -g)
sudo mount.cifs //truenas/security            "$TRUENAS_BASE/security"         -o credentials=${CRED_PATH}/truenas-security,file_mode=0777,dir_mode=0777,uid=$(id -u),gid=$(id -g)
sudo mount.cifs //truenas/mbwilding           "$TRUENAS_BASE/mbwilding"        -o credentials=${CRED_PATH}/truenas-mbwilding,file_mode=0777,dir_mode=0777,uid=$(id -u),gid=$(id -g)
sudo mount.cifs //truenas/josh                "$TRUENAS_BASE/josh"             -o credentials=${CRED_PATH}/truenas-mbwilding,file_mode=0777,dir_mode=0777,uid=$(id -u),gid=$(id -g)
sudo mount.cifs //truenas/sara                "$TRUENAS_BASE/sara"             -o credentials=${CRED_PATH}/truenas-mbwilding,file_mode=0777,dir_mode=0777,uid=$(id -u),gid=$(id -g)
sudo mount.cifs //truenas/nextcloud-mbwilding "$NEXTCLOUD_BASE/home/mbwilding" -o credentials=${CRED_PATH}/truenas-mbwilding,file_mode=0777,dir_mode=0777,uid=$(id -u),gid=$(id -g)

# echo "Mounting S3..."
# s3fs

echo "Mounting SSHFS shares..."
sshfs root@truenas:/mnt/.ix-apps    "$TRUENAS_BASE/apps"      -o allow_other,IdentityFile=~/.ssh/personal
# sshfs root@sara:/                   ~/mnt/sara/root           -o allow_other,IdentityFile=~/.ssh/personal
# sshfs sara@sara:/home/sara          ~/mnt/sara/home           -o allow_other,IdentityFile=~/.ssh/personal
