#Configuring Wacom Bambo Pen on Lubuntu

2013-05-04

<!--- tags: linux -->

I tried a Wacom Bambo Pen graphics tablet on Lubuntu 13.04 with Gimp.

I was informed before buying it by reading around that since Linux kernel version 3.5, the 3rd generation of Wacom Bambo Pen is supported, so there was no need to install any additional driver modules. Indeed the tabled worked out of the box, even in Gimp despite the mode not set to Screen (but I set it to Screen anyway to be sure).

I wanted to see if there was anyway to configure the Wacom Bambo Pen settings via GUI in Lubuntu. The Wacom Tablet settings panel of GNOME is included in latest Lubuntu, but it shows nothing by default. To make it show in the Preferences menu, I edited `/usr/share/applications/gnome-wacom-panel.desktop` by commenting out the line that forces it to show only on GNome and Unity. Wacom Tablet settings panel kind of works. It detects the tablet, but I have the feeling the settings set there are somehow not applied.

The only way to configure Wacom Bambo Pen in Lubuntu is via `xsetwacom` command. It listed the following devices, of which my entry-level model has only the first:

```
$ xsetwacom list devices
Wacom Bamboo Connect Pen stylus 	id: 10	type: STYLUS    
Wacom Bamboo Connect Finger touch	id: 11	type: TOUCH     
Wacom Bamboo Connect Pen eraser 	id: 19	type: ERASER    
Wacom Bamboo Connect Finger pad 	id: 20	type: PAD
```

You have to type the full device name shown above in the rest of `xsetwacom` commands. I actually wanted to change only `PressureCurve`, as I had the feeling it was somehow not ok. First, I had a look at the current default settings:
```
$ xsetwacom -s get "Wacom Bamboo Connect Pen stylus" PressureCurve
xsetwacom set "Wacom Bamboo Connect Pen stylus" "PressureCurve" "0 0 100 100"
```

According to a [blog entry](http://linuxquirks.blogspot.de/2010/08/ubuntu-on-tablet-computer.html) several possible values (in Windows there is a Wacom GUI tool to manipulate the Beizer curve) are:

```
"PressureCurve" "0,75,25,100" # softest
"PressureCurve" "0,50,50,100"
"PressureCurve" "0,25,75,100"
"PressureCurve" "0,0,100,100 # linear (default)"
"PressureCurve" "25,0,100,75"
"PressureCurve" "50,0,100,50"
"PressureCurve" "75,0,100,25 # firmest"
```

The default delivered one `0,0,100,100` is unusable for me, so I tried the two limits and found `0,75,25,100` to match exactly my expectations how it should work (with Basic Dynamics):
```
xsetwacom set "Wacom Bamboo Connect Pen stylus" "PressureCurve" "0 75 25 100"
```
I verified it was set using get as above and tried it out in Gimp.

These settings are lost on next start up. A possible way to deal with it is to make a shell script with above set command - and may be also gimp-2.8, and start Gimp via it if you want to use Gimp together with the tablet.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-05-04-Using-Two-Monitors-on-Lubuntu.md'>Using Two Monitors on Lubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-03-21-Viewing-PDF-Documents-in-Chromium-Browser.md'>Viewing PDF Documents in Chromium Browser</a></ins>
