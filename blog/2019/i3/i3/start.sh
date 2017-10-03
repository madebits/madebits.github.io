#!/bin/bash

#compton -b &

xset dpms 0 0 0
xset -dpms
xset s off
#setterm -blank 0

eval $(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)
export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK

# https://superuser.com/questions/389397/ubuntu-and-privilege-elevation-in-i3wm
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1
