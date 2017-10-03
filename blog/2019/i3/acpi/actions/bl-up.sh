#!/bin/bash

#actual_brightness  brightness  max_brightness

dir=/sys/class/backlight/intel_backlight
max=$dir/max_brightness
device=$dir/brightness

m=$(cat $max)
step=$(( $m / 20 ))
if (( $step <= 0 ))
then
    exit 0
fi

next=$(( $(cat $device) + $step ))
if (( $next > $m ))
then
    next=$m
fi

echo $next | sudo tee $device
