# ogn-install

Install OGN software on a Raspberry Pi (all models). 

Note: this is the script i will use to create a new OGN-pi image.

## Installation basics

- download latest RaspiOS from https://downloads.raspberrypi.org/raspios_lite_armhf/images/
- clone this repository:  `git clone https://github.com/petercreyghton/ogn-install`
- edit `/boot/ogn-install/OGN-receiver.conf` and set the required paramaters ReceiverName, Latitude, Longitude and piUserPassword

- mount the image and copy `/ogn-install` to `/boot/`
- for headless installation: edit `wpa_supplicant.conf`, copy it to `/boot` and create an empty `/boot/ssh` file
- flash the RaspiOS image to an SD card

- boot a Raspberry Pi with the flashed SD card
- log in as user pi and run:

```
sudo -i
cd /boot/ogn-install
./install.sh
```

After installation, the Pi reboots. Log in to check the status of the receiver.

## Easy Access

This version of ogn-install includes a secure reverse tunnel that provides easy access to the Pi via web console and ssh.

Try `ssh pi@remotelysecu.re` to log in with SSH or browse to http://remotelysecu.re to access your Pi without an SSH program.

In short, never search for the ip address of that headless receiver anymore. Access is provided by a cloudserver which restricts Pi access to computers on your local network. So that's pretty secure, even without TLS. 

This version of ogn-install includes easy access to the Pi via web console and ssh through a secure reverse tunnel.

Try `ssh pi@remotelysecu.re` to log in with SSH or browse to `http://remotelysecu.re` to access your Pi without SSH software.

In short, Easy Access eliminates searching for the ip address of that headless receiver that's way up high near the antenna. Access is provided by a cloudserver which restricts Pi access to computers on your local network. So that's pretty secure, even without TLS.

# Future plans 

## Remote access

For a future release, it will be possible to access your receiver remotely with a public ssh key and a generated accountname based on the receiver's station name. This is still work in progress.

## Remote Assistance

As with the OGN image from Sebastién Chaumontet, a remote admin account is created in preparation of a form of remote assistance. Actual remote assistance is not provided as of yet.
