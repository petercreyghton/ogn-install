#!/bin/bash

# send the hostname of this client to the cloudserver providing reverse tunnel services
TUNNELHOST=$(grep -i server /etc/remotelysecure/server.conf|cut -d":" -f2)
PORT=60000

LOOP=0
MAXLOOP=15
while [ $LOOP -lt $MAXLOOP ]; do
	echo "hostname|nc -w1 $TUNNELHOST $PORT"
	hostname|nc -w1 $TUNNELHOST $PORT
	if [ $? -eq 0 ]; then echo "Hostname sent to tunnelhost"; break; fi
	sleep 1
	LOOP=$((LOOP+1))
done