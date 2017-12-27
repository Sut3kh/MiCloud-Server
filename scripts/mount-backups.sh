#!/bin/bash
##
# Decrypt and mount backups drive.
##

sudo cryptsetup luksOpen /dev/sdc securebackups
sudo systemctl start backups.mount
