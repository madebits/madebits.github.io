#German Umlauts on US Keyboard on Lubuntu

2013-11-13

<!--- tags: linux -->

I found a [blog entry](http://larsmichelsen.com/open-source/german-umlauts-on-us-keyboard-in-x-ubuntu-10-04/) how to map German umlauts on US keyboard in Ubuntu, using xmodmap.

To create a mapping, create a text file `~/.Xmodmap` with the mapping (I modified it to fit my needs):

```
! Map umlauts to RIGHT ALT + 
keycode 108 = Mode_switch
keysym 4 = 4 dollar EuroSign
keysym e = e E ediaeresis Ediaeresis
keysym c = c C ccedilla Ccedilla
keysym a = a A adiaeresis Adiaeresis
keysym o = o O odiaeresis Odiaeresis
keysym u = u U udiaeresis Udiaeresis
keysym s = s S ssharp
```
To disable the Ctrl key adding the following to the above worked for me:
```
keycode 66 = Shift_L
```
This maps the Caps Lock to be same left shift. I found the key codes using `xev` tool (to find only keys on a given window, use `xwininfo` to get the windowId, and then use `xev -id windowId`). To completely disable the caps lock, use: `keycode 66 = 0x0000`.

The file should be load directly using:
```
xmodmap ~/.Xmodmap
```

Location of `~/.Xmodmap` and its name seems not to play any role, as it is not loaded automatically in Lubuntu. No matter where you put xmodmap command it will not work at startup. It will be run, but then a later call from somewhere (lxpanel kb applet?) to `setxkbmap`, somehow undoes the xmodmap settings. I created a desktop shortcut `start-xmodmap.desktop` to easy access it:

```
[Desktop Entry]
Name=start-xmodmap
Exec=/usr/bin/xmodmap /home/user/.Xmodmap
Icon=accessories-character-map
Terminal=false
Type=Application
Encoding=UTF-8
```

**Update:** I managed to get `xmodmap` run on startup on Lubuntu by creating a shell script with a `sleep` delay in my home folder at `~/bin/xmod.sh`:
```
#!/bin/bash
sleep 3
/usr/bin/xmodmap /home/user/.Xmodmap
```
I made `xmod.sh` file executable and called it from `/home/user/.config/lxsession/Lubuntu/autostart` by adding:
```
@/home/user/bin/xmod.sh
```

If I use no sleep or sleep 1 in `xmod.sh` script it does not work for me. It starts working (for me) from `sleep 2` seconds and above, so I left it at 3 seconds to be sure.

The funny thing is, I had tried this before with like 5 seconds, but given it did not work I thought this is not the right way to do it and gave up. Now the only difference is I have switched to an SSD which is much faster than my previous hard disk. This means that this method with sleep delay works, but if sleep 3 does not work for you, increase the sleep seconds in the script and test until it works.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-11-14-Getting-Started-with-Qt-and-PySide-on-Ubuntu.md'>Getting Started with Qt and PySide on Ubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-11-06-Disabling-ZRAM-in-Lubuntu.md'>Disabling ZRAM in Lubuntu</a></ins>
