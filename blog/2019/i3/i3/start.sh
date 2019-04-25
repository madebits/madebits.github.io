#!/bin/bash

eval $(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)
export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] ; then
    eval $(dbus-launch --sh-syntax)
    echo "D-Bus per-session daemon address is: $DBUS_SESSION_BUS_ADDRESS"
fi

# https://superuser.com/questions/389397/ubuntu-and-privilege-elevation-in-i3wm
#/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &

# see comment in file, if this is enabled no logout is possible
sudo /usr/local/bin/gnome-kill

# left mouse
# leave touchpad unchanged
#for id in $(xinput list | grep 'Logitech USB Receiver' |  grep pointer | cut -d '=' -f 2 | cut -f 1); do xinput --set-button-map $id 3 2 1; done

~/.config/i3/battery.sh & disown

#/usr/bin/xinput set-button-map "$(/usr/bin/xinput list --name-only | grep -i touch)" 3 2 1 &
/usr/bin/xinput --disable "$(/usr/bin/xinput list --name-only | grep -i touch)"
