# ogn-install

Install OGN software on a Raspberry Pi (all models). 

Note: The generic OGN-pi image i created with this script can be found [here](https://drive.google.com/file/d/1P4IT78_i_FIv2Rtl5RsL8F1aWtVRKXJF/view?usp=sharing)

## Installation basics

- flash the lastest Raspberry Pi OS via Pi imager https://www.raspberrypi.org/software/
- clone this repository:  `git clone https://github.com/petercreyghton/ogn-install`
- edit `/boot/ogn-install/OGN-receiver.conf` and set the required paramaters ReceiverName, Latitude, Longitude and piUserPassword

- copy `/ogn-install` to `/boot/` (Note: this is the default partition "drive" on Windows on the above flashed SD card)
- for headless installation: edit `wpa_supplicant.conf` and copy it to `/boot`
- create an empty `/boot/ssh` file to enable SSH access
- for pi zero only: `add over_voltage=6` and `force_turbo=1` to the already existing config.txt file on the sd card (this prevents the pi zero from freezing in idle mode)

- boot a Raspberry Pi with the flashed SD card
- log in as user "pi" with the default password: "raspberry" (the new password in the OGN-receiver.conf will be set after the install.sh script has been run) and run these commands:

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

If you don't want to access the Pi via Easy Access you can disable it by entering:

```
systemctl disable --now remotelysecure-client.service

```

Additionally you can disable the remote admin user in OGN-receiver.conf (RemoteAdminEnabled="NO")


# Screenshot 

Here's a screenshot of my test receiver:

![Screenshot RemotelySecu.re](https://github.com/petercreyghton/ogn-install/blob/master/Screenshot%202021-03-30%20at%2020.48.34.png)
Yep! That's a screenshot of the Easy Access webpage, available only from the same network the Pi is attached to. 

# Plans

## Remote access

For a future release, plans are to implement remote access to the receiver with a public ssh key and a generated accountname based on the receiver's station name. This is still work in progress, as it should be more than remotely secure ;-)

## Remote Assistance

As with the OGN image from Sebastién Chaumontet, a remote admin account is created in preparation of a form of remote assistance. Actual remote assistance is not provided as of yet.
