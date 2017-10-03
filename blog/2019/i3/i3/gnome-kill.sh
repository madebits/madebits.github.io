#!/bin/bash

# gnome-session still runs by gdm
# for this to run the script need sudo rights as follows

# sudo cp gnome-kill.sh /usr/local/bin/kill-gnome
# sudo visudo
# myUserName ALL=(ALL) ALL
# myUserName ALL=(root) NOPASSWD: /usr/local/bin/gnome-kill

pkill gnome-shell

# if you kill gnome-shell then logout will not work
