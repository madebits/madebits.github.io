# Using brightnessctl

2021-11-26

<!--- tags: linux -->

To be able to change the brightness of the laptop screen in a more fine grained way than via the keyboard `Fn` keys (that use `+/-5%` steps) install `brightnessctl`:

```bash
sudo apt install brightnessctl
```

Find the right device, for me `intel_backlight`:

```bash
sudo brightnessctl -l

Device 'intel_backlight' of class 'backlight':
	Current brightness: 150 (2%)
	Max brightness: 7500
...
```

Then use `brightnessctl` as in this script (for my monitor `%2` is good enough most of the time):

```bash
#!/bin/bash

if [ -n "$1" ]; then
    case "${1:-}" in
        min)
            brightnessctl -d intel_backlight set 1%
        ;;
        max)
            brightnessctl -d intel_backlight set 100%
        ;;
        up|+)
            brightnessctl -d intel_backlight set +1%
        ;;
        down|-)
            brightnessctl -d intel_backlight set 1%-
        ;;
        *)
            brightnessctl -d intel_backlight set "${1}%"
        ;;
    esac
else
    brightnessctl -d intel_backlight set 2%
fi
``` 

To be able to change the monitor brightness without `sudo`, get the *udev* rules file from [brightnessctl](https://github.com/Hummer12007/brightnessctl/blob/master/90-brightnessctl.rules) repository and copy them as *root* in `/etc/udev/rules.d/90-brightnessctl.rules`.

```udev
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="leds", RUN+="/bin/chgrp input /sys/class/leds/%k/brightness"
ACTION=="add", SUBSYSTEM=="leds", RUN+="/bin/chmod g+w /sys/class/leds/%k/brightness"
```

Then add your user name (`id -un`) to the mentioned `video` group and restart the machine:

```bash
sudo usermod -a -G video myUserName
```

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2021/2021-11-25-Feh-Start-Script.md'>Feh Start Script</a></ins>
