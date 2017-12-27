#!/bin/bash
##
# Send a message to slack.
##

# Failure is not an option.
set -e

# Get server vars.
source /etc/micloud-server.env

# Check for arg.
if [[ -z $1 ]]; then
  echo "Argument Required: message"
  echo "usage: $0 'message'"
  exit 1
fi
MESSAGE="$1"

# Check for pipe.
if [[ $MESSAGE == '-' ]]; then
  MESSAGE=$(cat /dev/stdin)
fi

# Send the message to slack. NOTE: Never save your hook url in git!
USERNAME="$(hostname)"
JSON="{\"username\": \"${USERNAME}\", \"text\": \"${MESSAGE}\"}"
curl --silent -S -X POST --data-urlencode "payload=$JSON" ${MICLOUD_SLACK_URL}
