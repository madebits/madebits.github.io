#!/bin/bash

#actual_brightness  brightness  max_brightness

dir=/sys/class/backlight/intel_backlight
max=$dir/max_brightness
device=$dir/brightness

step=$(( $(cat $max) / 20 ))
if (( $step <= 0 ))
then
    exit 0
fi

next=$(( $(cat $device) - $step ))
if (( $next < $step ))
then
    next=$step
fi

echo $next | sudo tee $device
