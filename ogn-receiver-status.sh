#!/bin/bash

# get parameters
source /dev/stdin < <(dos2unix < /boot/OGN-receiver.conf)
source /home/pi/rtlsdr-ogn/version


# check internet access
INTERNETSTATUS=$(ping -c1 1.1.1.1 &>/dev/null; if [ $? -eq 0 ]; then echo "OK"; else echo "NOT CONNECTED"; fi)
# check glidernet access
OGNSTATUS=$(nc -w1 aprs.glidernet.org 14580 &>/dev/null; if [ $? -eq 0 ]; then echo "OK"; else echo "NOT REACHABLE"; fi)
# check service status
SERVICESTATUS=$(systemctl is-active rtlsdr-ogn &>/dev/null; if [ $? -eq 0 ]; then echo "OK"; else echo "NOT RUNNING (try 'sudo reboot')"; fi)
# check usb stick status
USBSTICKSTATUS=$(if [ $(lsusb|grep -ie "dvb-t" -e "rtl" -e "820" &>/dev/null; echo $?) -eq 1 ]; then echo "No USB stick detected"; else echo "OK"; fi)
# check receiver status
RECEIVERSTATUS=$(sudo netstat -tlpn|grep 50010 &>/dev/null; if [ $? -eq 0 ]; then echo "OK"; else echo "NOT CONNECTED (try 'sudo reboot')"; fi)
# check web console status
TUNNELSERVICE=$(systemctl is-active remotelysecure-client &>/dev/null; if [ $? -eq 0 ]; then echo "active"; else echo "disabled"; fi)
# check web console status
WEBCONSOLESTATUS=$(curl remotelysecu.re &>/dev/null; if [ $? -eq 0 ]; then echo "active"; else echo "unreachable"; fi)
# get overlay status

if [ $(overlayctl status|grep " active" &>/dev/null; echo $?) -eq 0 ]; then 
    FSMODE="read-only"
else 
    FSMODE="read-write"
fi
# check RemoteAdminUser status
if [ "$(sudo chage -l $RemoteAdminUser|grep 'Account expires'|cut -d':' -f2|sed 's/ //')" == "never" ]; then REMOTEADMIN="active"; else REMOTEADMIN="disabled"; fi


# show the status page
GREEN='\033[0;32m'
YELLOW='\033[1;33'
RED='\033[0;31m'
NC='\033[0m'
echo -n -e "${GREEN}"
echo "     ____  _______   __                       _                  "
echo "    / __ \/ ____/ | / /  ________  ________  (_)   _____  _____  "
echo "   / / / / / __/  |/ /  / ___/ _ \/ ___/ _ \/ / | / / _ \/ ___/  "
echo "  / /_/ / /_/ / /|  /  / /  /  __/ /__/  __/ /| |/ /  __/ /      "
echo "  \____/\____/_/ |_/  /_/   \___/\___/\___/_/ |___/\___/_/       "
echo -n -e "${NC}"
echo
# show receiver name or config message
if [ -z $ReceiverName ]; then
    echo "      ERROR: NO CONFIGURATION FOUND"
    echo
    echo "      Type 'sudo vi /boot/OGN-receiver.conf' and enter"
    echo "      Station, lat, lon and pi password"
    echo
else
    echo "        Station:               $ReceiverName"
    echo
    echo "        Image version:         $ImageVersion"
    echo "        RaspiOS:               $RaspiOSversion"
    echo "        OGN sw:                $OGNversion"
    echo
    echo "        Internet status:       $INTERNETSTATUS"
    echo "        Glidernet status:      $OGNSTATUS"
    echo "        rtlsdr-ogn service:    $SERVICESTATUS"
    echo "        USB stick status:      $USBSTICKSTATUS"
    echo "        Receiver status:       $RECEIVERSTATUS"
    echo
    echo "        Tunnel service:        $TUNNELSERVICE"
    echo "        Web console status     $WEBCONSOLESTATUS"
    echo "        Remote admin user:     $REMOTEADMIN"
    echo
    echo "        Filesystem:            $FSMODE"
    echo
    if [ "$INTERNETSTATUS" == "OK" ]; then
      if [ "$OGNSTATUS" == "OK" ]; then
        if [ "$USBSTICKSTATUS" == "OK" ]; then
          if [ "$SERVICESTATUS" == "OK" ]; then
            if [ "$RECEIVERSTATUS" == "OK" ]; then
              if [ "$FSMODE" == "read-only" ]; then
                  echo -e "${GREEN}       Receiver is fully operational${NC}"
              else
                echo -e "${YELLOW}        Receiver is operational. Type 'sudo overlayctl enable' and reboot"
                echo -e "        for maximal lifespan of your SDcard${NC}"
              fi
            else
              echo -e "${RED}        Receiver not operational, port 50010 not active. Did you reboot after install?${NC}"
            fi
          else
            echo -e "${RED}        Service rtlsdr-ogn not started. Did you reboot after install?${NC}"
          fi
        else
          echo -e "${RED}        No USB stick detected, is the USB receiver dongle connected and supported?${NC}"
        fi
      else
        echo -e "${RED}        aprs.glidernet.org not responding.${NC}"
      fi
    else
      echo -e "${RED}        No internet connection.${NC}"
    fi
    echo
fi

# finished
