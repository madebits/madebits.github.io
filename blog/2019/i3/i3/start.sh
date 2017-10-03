#!/bin/bash

xset dpms 0 0 0
xset -dpms
xset s off
#setterm -blank 0

eval $(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)
export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK


