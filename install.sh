#!/bin/bash
#
# Description: Installation script for displayboard
#

# Check we are root
if [ $LOGNAME != "root" ]
then
    echo "ERROR: Execution of $0 stopped as not run by user root!"
    exit 1
fi

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#echo "Changing default password"
#passwd pi

# Set the timezone
#dpkg-reconfigure tzdata

# Set Hostname to displayboard
#raspi-config nonint do_hostname "displayboard"

#  Wait for Network at Boot
raspi-config nonint do_boot_wait 1

# Disable Overscan
raspi-config nonint do_overscan 1

# Give the GPU the most memory possible (256MB)
raspi-config nonint do_memory_split 256

# Install the bits we need
apt install -y matchbox x11-xserver-utils xinit ttf-mscorefonts-installer unattended-upgrades unclutter firefox-esr cec-utils

# Setup rc.local
if test -f /etc/rc.local; then
    rm /etc/rc.local
fi
cp $SCRIPTDIR/src/rc.local /etc/rc.local
chmod +x /etc/rc.local

# Setup .xinitrc
if test -f /home/pi/.xinitrc; then
    rm /home/pi/.xinitrc
fi
sudo -u pi cp $SCRIPTDIR/src/xinitrc /home/pi/.xinitrc

# Allow anyone to start an Xserver
sed -i 's/allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config

# Enable Automatic upgrades to keep the box secure
if test -f /etc/apt/apt.conf.d/50unattended-upgrades; then
    rm /etc/apt/apt.conf.d/50unattended-upgrades
fi
cp $SCRIPTDIR/src/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades

if test -f /etc/apt/apt.conf.d/20auto-upgrades; then
    rm /etc/apt/apt.conf.d/20auto-upgrades
fi
cp $SCRIPTDIR/src/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades

sudo cat $SCRIPTDIR/bashrc.template >> /home/pi/.bashrc