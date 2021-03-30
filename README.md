# ogn-install

Install OGN software on a Raspberry Pi (all models). 

Note: this is the script i will use to create an updated generic OGN-pi image.

## Installation basics

- download latest RaspiOS from https://downloads.raspberrypi.org/raspios_lite_armhf/images/
- clone this repository:  `git clone https://github.com/petercreyghton/ogn-install`
- edit `/boot/ogn-install/OGN-receiver.conf` and set the required paramaters ReceiverName, Latitude, Longitude and piUserPassword

- mount the image and copy `/ogn-install` to `/boot/`
- for headless installation: edit `wpa_supplicant.conf`, copy it to `/boot` and create an empty `/boot/ssh` file
- flash the RaspiOS image to an SD card

- boot a Raspberry Pi with the flashed SD card
- log in as user pi and run these commands:

```
sudo -i
cd /boot/ogn-install
./install.sh
```

After installation, the Pi reboots. Log in to check the status of the receiver.

## Easy Access

This version of ogn-install includes easy access to the Pi via web console and ssh through a secure reverse tunnel.

Try `ssh pi@remotelysecu.re` to log in with SSH or browse to http://remotelysecu.re to access your Pi without an SSH program.

In short, Easy Access eliminates searching for the ip address of that headless receiver that's way up high near the antenna. Access is provided by a cloudserver which restricts Pi access to computers on your local network. So that's pretty secure, even without TLS.

# Screenshot 

Here's a screenshot of my test receiver:

![Screenshot RemotelySecu.re](https://github.com/petercreyghton/ogn-install/blob/master/Screenshot 2021-03-30 at 20.48.34.png)

# Plans

## Remote access

For a future release, plans are to implement remote access to the receiver with a public ssh key and a generated accountname based on the receiver's station name. This is still work in progress, as it should be more than remotely secure ;-)

## Remote Assistance

As with the OGN image from Sebastién Chaumontet, a remote admin account is created in preparation of a form of remote assistance. Actual remote assistance is not provided as of yet.
