#!/bin/bash

# set up an autoreverse tunnel at port 22 for a cloudserver
LOGFILE=/var/log/remotelysecure-client.log
HUB=$(grep -i server /etc/remotelysecure/server.conf|cut -d":" -f2)
HIGHPORT=61522
AUTOLOGINUSER=pi

echo "$( date +%F_%T) Initiating reverse tunnel to $HUB" >>$LOGFILE
autossh -M 0 -o "ServerAliveInterval=30" -o "ServerAliveCountMax=3" -NTR 0:localhost:22 $AUTOLOGINUSER@$HUB -p $HIGHPORT