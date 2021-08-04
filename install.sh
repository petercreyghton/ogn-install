#!/bin/bash

# install.sh: installation of OGN receiver software

# first, set some variables
RemoteAdminUser="ogn-admin"
ExpandFilesystem="No"
# and remember where this script was started
RUNPATH=$(pwd)

# fail on errors, undefined variables and pipe errors
set -euo pipefail

# ------  Phase ONE: install OGN software and dependencies

# step 1: install prerequisites
# first, wait for internet connection
until ping -c1 -W2 1.1.1.1 &>/dev/null ; do  echo hoi; sleep 1; done
#  get the correct time
apt install -y ntpdate
until ntpdate -u pool.ntp.org &>/dev/null; do 
	echo "time not in sync"
	sleep 1
done
# write the date in the version file
sed -i "s/INSTALLDATE/$(date +%F)/" version 
# next, install required packages
apt update
apt install -y ntp libjpeg8 libconfig9 fftw3-dev procserv lynx telnet dos2unix

# step 2: populate the blacklist to prevent claiming of the USB stick by the kernel
cat >> /etc/modprobe.d/rtl-glidernet-blacklist.conf <<EOF
blacklist rtl2832
blacklist rtl2838
blacklist r820t
blacklist rtl2830
blacklist dvb_usb_rtl28xxu
EOF

# step 3: compile special rtlsdr driver for Bias Tee
TEMPDIR=$(mktemp -d)
cd $TEMPDIR
apt -y install git g++ gcc make cmake build-essential libconfig-dev libjpeg-dev libusb-1.0-0-dev
git clone https://github.com/rtlsdrblog/rtl-sdr-blog
cd rtl-sdr-blog
cp rtl-sdr.rules /etc/udev/rules.d/rtl-sdr.rules
mkdir build
cd build
cmake ../ -DINSTALL_UDEV_RULES=ON
make install
ldconfig

# get rid of the old libraries
apt -y remove --purge rtl-sdr
apt -y autoremove
cd $RUNPATH

# step 4: get OGN executables for Pi 3B+ and earlier, and for Pi$ and up 
# get arm binaries
mkdir /home/pi/arm
cd /home/pi/arm
curl -O http://download.glidernet.org/arm/rtlsdr-ogn-bin-ARM-latest.tgz
tar -xf rtlsdr-ogn-bin-ARM-latest.tgz --no-same-owner
cd rtlsdr-ogn
chown root ogn-rf ogn-decode gsm_scan
chmod a+s ogn-rf ogn-decode gsm_scan
# get GPU binaries
mkdir /home/pi/gpu
cd /home/pi/gpu
curl -O http://download.glidernet.org/rpi-gpu/rtlsdr-ogn-bin-RPI-GPU-latest.tgz
tar -xf rtlsdr-ogn-bin-RPI-GPU-latest.tgz --no-same-owner
cd rtlsdr-ogn
chown root ogn-rf ogn-decode gsm_scan
chmod a+s ogn-rf ogn-decode gsm_scan
# copy binaries to Pi user home
cp -r /home/pi/arm/* /home/pi/
chown pi:pi /home/pi/rtlsdr-ogn
cd /home/pi/rtlsdr-ogn
# note: remove the binaries, these are copied in by rtlsdr-ogn on service start
#       which will fail if root-owned non-writeable binaries are present 
rm -f gsm_scan ogn-rf ogn-decode
cd $RUNPATH

# step 5: prepare executables and node for GPU
# move custom files to pi home
cp OGN-receiver-config-manager2 rtlsdr-ogn /home/pi/rtlsdr-ogn/
sed -i "s/REMOTEADMINUSER/$RemoteAdminUser/g" /home/pi/rtlsdr-ogn/OGN-receiver-config-manager2
# configure ogn executables and GPU node file
cd /home/pi/rtlsdr-ogn
if [ ! -e gpu_dev ]; then mknod gpu_dev c 100 0; fi
chmod a+x OGN-receiver-config-manager2 rtlsdr-ogn
cd $RUNPATH

# step 6: get WW15MGH.DAC for conversion between the Height-above-Elipsoid to Height-above-Geoid thus above MSL
# Note: Temporarily disabled, the file has moved and this break the installation
# wget --no-check-certificate https://earth-info.nga.mil/GandG/wgs84/gravitymod/egm96/binary/WW15MGH.DAC
# Provisionally copy a static version 
cp WW15MGH.DAC /home/pi/rtlsdr-ogn

# step 7: move configuration file to FAT32 partition in /boot for editing in any OS
cp OGN-receiver.conf /boot
sed -i "s/REMOTEADMINUSER/$RemoteAdminUser/g" /boot/OGN-receiver.conf

# step 8: install service
cd /home/pi/rtlsdr-ogn
cp -v rtlsdr-ogn /etc/init.d/rtlsdr-ogn
sed -i 's/Template/\/etc\/ogn/g' rtlsdr-ogn.conf
cp -v rtlsdr-ogn.conf /etc/rtlsdr-ogn.conf
update-rc.d rtlsdr-ogn defaults
cd -



# ------  Phase TWO: install additional tooling and configuration

# step 1: add a nightly reboot at 0:42 local time
# scheduled reboot is deprecated in this version
#echo "42 0 * * * root reboot" >> /etc/crontab

# step 2: set global aliases
cat > /etc/profile.d/aliases-global.sh <<-EOF
alias ll='ls -l'
EOF

# step 3: configure watchdog
echo "RuntimeWatchdogSec=10s" >> /etc/systemd/system.conf
echo "ShutdownWatchdogSec=4min" >> /etc/systemd/system.conf

# step 4: disable swap
set +e
systemctl stop dphys-swapfile
systemctl disable dphys-swapfile
apt purge -y dphys-swapfile
apt autoremove -y
set -e

# step 5: disable fake hwclock
update-rc.d fake-hwclock disable

# step 6: make the filesystem readonly to protect the SDcard from wear
cd /sbin
wget https://github.com/ppisa/rpi-utils/raw/master/init-overlay/sbin/init-overlay
wget https://github.com/ppisa/rpi-utils/raw/master/init-overlay/sbin/overlayctl
chmod +x init-overlay overlayctl
mkdir -p /overlay
overlayctl install
cd -
overlayctl enable

# step 7: create user account for remote Admin access
# NOTE: Only required if you want remote assistence setting up and troubleshooting your 
#       receiver installation. The account is enabled or disabled at boot time by 
#       the setting of 'RemoteAdminEnabled' in /boot/OGN-receiver.conf 
#
#       Remove this step if your not comfortable with remote access. This will NOT
#       disable the cloudservice for easy local access.
#
# create useraccount without password
adduser --disabled-password --gecos "" $RemoteAdminUser
usermod -aG sudo $RemoteAdminUser
# make sure the remote admin user can sudo without password, because there's none set
echo  "$RemoteAdminUser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# create key pair (and create ~/.ssh)
su - $RemoteAdminUser -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa"
# store a public key in ogn-admin
cat ogn-admin.pub >> /home/$RemoteAdminUser/.ssh/authorized_keys 
# set the correct permissions and owner
chmod 600 /home/$RemoteAdminUser/.ssh/authorized_keys
chown $RemoteAdminUser:$RemoteAdminUser /home/$RemoteAdminUser/.ssh/authorized_keys

# step 8: show receiver status on login
cp version /home/pi/rtlsdr-ogn
cp ogn-receiver-status.sh /etc/profile.d/

# step 9: setup a reverse tunnel to remotelysecu.re
# NOTE: this step enables easy access to your Pi from your local network and is
#       required if you want the benefits of secure remote login to your Pi.
HUB=remotelysecu.re
HIGHPORT=61522
# install required packages
apt -y install autossh
# create config file
mkdir -p /etc/remotelysecure
cat > /etc/remotelysecure/server.conf <<-EOF
server:$HUB
EOF
# install script
cp remotelysecure-client.sh /usr/local/bin
cp send-hostname.sh /usr/local/bin
# install the service
cp remotelysecure-client.service /lib/systemd/system/
# get hostkey of remotelysecure server
mkdir ~/.ssh
ssh-keyscan -p $HIGHPORT -t rsa $HUB >> ~/.ssh/known_hosts
# enable the service 
systemctl daemon-reload
systemctl enable --now remotelysecure-client

# step 10: enable Wifi on all platforms
for filename in /var/lib/systemd/rfkill/*:wlan ; do
  echo 0 > $filename
done

echo
echo "OGN receiver will now reboot to complete installation."
echo

# Final step: optionally auto expand image to SDcard size
if [ -n "$ExpandFilesystem" ]; then
  ENABLED=$(echo ${ExpandFilesystem^}|cut -c1)
  if [ "$ENABLED" == "Y" ]; then 
    # expand the filesystem to the size of the SD card
    # Note: defaults to "NO" to save installation time
    /usr/lib/raspi-config/init_resize.sh
  fi
fi
# reboot to activate read-only filesystem
if [ -e /boot/pix ]; then
  touch /boot/pix/reboot
else
  reboot
fi
