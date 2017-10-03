#!/bin/bash

# acpi_listen, sudo systemctl restart acpid.service

#actual_brightness  brightness  max_brightness

dir=/sys/class/backlight/intel_backlight
max=$dir/max_brightness
device=$dir/brightness

m=$(cat $max)
if (( $m <=0 ))
then
echo -
exit
fi
c=$(cat $device)

pc=$(( $c * 100 / $m ))

echo $pc
