#!/bin/bash
##
# Check the age of the Lastpass backup and warn if too old.
#
# Lastpass does not support automated backups...
##

# Failure is not an option.
set -e

# Get server vars.
source /etc/micloud-server.env
FILEPATH=/backups/lastpass.csv

# Check the lastpass file exists.
if [ ! -f "$FILEPATH" ]; then
  MESSAGE="The lastpass backup does not exist ($FILEPATH)!"
else
  # Check the age of the backup.
  FILE_TIME=$(date -r "$FILEPATH" +%s)
  TOO_OLD="$(eval $MICLOUD_LASTPASS_TOO_OLD_CMD)"
  if ((FILE_TIME <= TOO_OLD)); then
    MESSAGE="The lastpass backup is too old! Please update it ($FILEPATH)."
  fi
fi

# Alert the message if there is one.
if [ ! -z "$MESSAGE" ]; then
  echo "$MESSAGE" 1>&2;
  bash "$MICLOUD_PATH/scripts/alert.sh '$MESSAGE'"
fi

# NOTE: Always exit cleanly so the alert-on-failure unit is not also triggered.
exit 0
