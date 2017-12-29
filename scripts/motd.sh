#!/bin/bash
##
# Dynamic motd to be ran by ~/.profile.
# based on https://gist.github.com/cha55son/6042560
##

USER=`whoami`
HOSTNAME=`uname -n`
MEMORY=$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
SWAP=$(free -m | tail -n 1 | awk '{print $3}')
PSA=`ps -Afl | wc -l`

# Time of day.
HOUR=$(date +"%H")
if [ $HOUR -lt 12  -a $HOUR -ge 0 ]; then
  TIME="morning"
elif [ $HOUR -lt 17 -a $HOUR -ge 12 ]; then
  TIME="afternoon"
else
  TIME="evening"
fi

# System uptime.
uptime=`cat /proc/uptime | cut -f1 -d.`
upDays=$((uptime/60/60/24))
upHours=$((uptime/60/60%24))
upMins=$((uptime/60%60))
upSecs=$((uptime%60))

# System load.
LOAD1=`cat /proc/loadavg | awk {'print $1'}`
LOAD5=`cat /proc/loadavg | awk {'print $2'}`
LOAD15=`cat /proc/loadavg | awk {'print $3'}`

echo "
===========================================================================
 - Hostname............: $HOSTNAME
 - Release.............: `cat /etc/redhat-release`
 - Users...............: Currently `users | wc -w` user(s) logged on
===========================================================================
 - Current user........: $USER
 - CPU usage...........: $LOAD1, $LOAD5, $LOAD15 (1, 5, 15 min)
 - Memory usage........: $MEMORY
 - Swap in use.........: $SWAP MB
 - Processes...........: $PSA running
 - System uptime.......: $upDays days $upHours hours $upMins minutes $upSecs seconds
===========================================================================
"

# List failed systemd units.
# Based on CoreOS: /usr/share/baselayout/coreos-profile.sh.
FAILED=$(systemctl list-units --state=failed --no-legend)
if [[ ! -z "${FAILED}" ]]; then
  COUNT=$(wc -l <<<"${FAILED}")
  echo -e "Failed Units: \033[31m${COUNT}\033[39m"
  awk '{ print "  " $1 }' <<<"${FAILED}"
fi

echo "
Good $TIME $USER
"
