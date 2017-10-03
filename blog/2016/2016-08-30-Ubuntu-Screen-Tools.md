#Ubuntu Screen Tools

2016-08-30

<!--- tags: linux -->

Several small useful tool for monitor and screen management in Ubuntu:

##Xrandr

(xrandr)[https://xorg-team.pages.debian.net/xorg/howto/use-xrandr.html] is the lowest most versatile command to configure displays. If you attach a new monitor and not want to restart X11 to detect it use first:

```
xrandr --auto
```

To get a list of all monitors use:

```
$ xrandr | grep -e "^\S"
Screen 0: minimum 320 x 200, current 3840 x 1080, maximum 8192 x 8192
eDP-1 connected primary 1920x1080+0+0 (normal left inverted right x axis y axis) 344mm x 194mm
HDMI-1 connected 1920x1080+1920+0 (normal left inverted right x axis y axis) 531mm x 299mm
DP-1 disconnected (normal left inverted right x axis y axis)
HDMI-2 disconnected (normal left inverted right x axis y axis)
```

To get a short list of monitors use (`xrandr --listactivemonitors` gives same result for me):

```
$ xrandr --listmonitors 
Monitors: 2
 0: +*eDP-1 1920/344x1080/194+0+0  eDP-1
 1: +HDMI-1 1920/531x1080/299+1920+0  HDMI-1
```

A useful GUI frontend to `xrandr` to setups displays is `sudo apt install arandr`. It can help generate something like this:

```
xrandr --output DP-1 --off --output HDMI-1 --mode 1920x1080 --pos 1920x0 --rotate normal --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-2 --off
```

##Disper

[disper](http://willem.engen.nl/projects/disper/) enables easy [dynamic](https://help.ubuntu.com/community/DynamicMultiMonitor) monitor switching. It is useful when connecting the HDMI cable (TV) after Ubuntu is started. `disper` is a command-line tool available via Ubuntu repositories (`sudo apt install disper`). Common [options](http://manpages.ubuntu.com/manpages/xenial/man1/disper.1.html) include:

* `disper -l` list all displays
* `disper -s` single (first) display
* `disper -c` clone displays
* `disper -e` extend displays
* `disper -d auto -e` extend all displays

`disper` is mainly for nVidia cards, but it works same good for `randr`. In Lubuntu, the `disper` commands can be mapped to keyboard using `openbox` configuration (`~/.config/openbox/lubuntu-rc.xml`). The following command cycles via different configurations:

```xml
...
    <keybind key="W-s">
      <action name="Execute">
        <command>disper --cycle-stages='-c:-e:-S:-s' --cycle</command>
      </action>
    </keybind>
```

##Redshift

[Redshift](http://jonls.dk/redshift/) is useful in the hope you can sleep well after using the laptop just before going to bed. It changes the screen color temperature to match the official sun times in your location detected based on your IP. It can be installed in Ubuntu via `sudo apt install redshift` (or if you want the tray applet, use `sudo apt install redshift-gtk`). The most useful command to know is `redshift -x` that resets (clears) `redshift` changes.

The automatic location detection works ok, but if your exit IP does not match you country of location, it is better you configure an approximate location in `~/.config/redshift.conf` (or via command-line `-l 50.1:8.6`):

```ini
[redshift]
location-provider=manual
temp-day=6500
temp-night=3700

gamma-day=0.8
gamma-night=0.6

; frankfurt
[manual]
lat=50.1
lon=8.6
```

In Lubuntu, `redshift` can be auto-started (if you do not use `redshift-gtk`), by adding an entry in `~/.config/lxsession/Lubuntu/autostart` (add any command-line arguments that you need to it) `@redshift`, or use `@redshift-gtk` for the UI. 6500K means no change. To monitor usage run `redshift -v`. To temporary disable / enable use `pkill -USR1 redshift`. 

`redshift` supports [hooks](http://jonls.dk/2015/01/redshift-1-10-released/) to notify if something changes: `$1` is the period event, `$2` is previous value, `$3` is new value. There is a [script](https://wiki.archlinux.org/index.php/Redshift#Use_real_screen_brightness) to change brightness based on that. The events are fired only when `redshift` runs (not when started) and brightness is also controlled by the power manager, so I found the hooks not useful in practice.

##xcalibr

`xcalib` is a command line tool obtained via `sudo apt install xcalib`. It can be used among others to [invert](https://bbs.archlinux.org/viewtopic.php?id=89218) colors back and forth. It is useful to map it to `openbox` configuration as:

```xml
    <keybind key="W-i">
      <action name="Execute">
        <command>xcalib -invert -alter</command>
      </action>
    </keybind>
```

If you play with the other options, such as `-co` for contrast, [append](https://bugzilla.redhat.com/show_bug.cgi?id=783562) `-a` in order for the command to work, for example, to set contrast 80% and then clear back the settings use:

```
xcalib -co 80 -a
xcalib -c
```

Both `xcalib` and the next tool `xgamma` may not work properly when `redshift` is active.

For an alternative tool to handle invert see: https://github.com/zoltanp/xrandr-invert-colors

##xgamma

`xgamma` comes with Ubuntu and can be used to configure [gamma](http://askubuntu.com/questions/9248/is-there-a-software-utility-to-adjust-screen-gamma-brightness-contrast) as a replacement for contrast if your screen is too bright. I have configured at startup at `~/.config/lxsession/Lubuntu/autostart` it as follows:

```
@xgamma -gamma 0.8
```

In my machine, this makes black text, in general, more readable. Similar effects can be achieved by modifying gamma via `redshift`. A useful script:

```
#!/bin/bash

if [ "$1" == "1" ]; then
  xgamma -gamma 1
  exit 0
fi

xgamma -gamma $(echo "$(xgamma 2>&1 | cut -d ' ' -f 4 | tr -d ',')${1}" | bc -l)
```

If saved as `gamma` this can used: `gamma +.1` or `gamma -.1` and combined with Openbox config keys:

```xml
<keybind key="W-g">
  <action name="Execute">
    <command>~/bin/gamma -0.1</command>
  </action>
</keybind>
<keybind key="W-S-g">
  <action name="Execute">
    <command>~/bin/gamma +0.1</command>
  </action>
</keybind>
<keybind key="W-A-g">
  <action name="Execute">
    <command>~/bin/gamma 1</command>
  </action>
</keybind>
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-10-02-xrandr-Panning-with-no-Tracking.md'>xrandr Panning with no Tracking</a> <a rel='next' id='fnext' href='#blog/2016/2016-08-02-Lubuntu-Closing-Chrome-Downloads-Bar.md'>Lubuntu Closing Chrome Downloads Bar</a></ins>
