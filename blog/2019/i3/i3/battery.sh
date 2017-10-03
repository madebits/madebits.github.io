#!/bin/bash

#https://faq.i3wm.org/question/1730/warning-popup-when-battery-very-low.1.html

function alert() 
{
    BATTINFO=$(acpi -b)
    if [[ $(echo $BATTINFO | grep Discharging) && $(echo $BATTINFO | cut -f 5 -d " ") < 00:30:00 ]] ; then
        DISPLAY=:0.0 /usr/bin/notify-send -u critical "Battery low" "$BATTINFO"
    fi
}

while : ; do
    alert
    sleep 10m
done
