#Skippy-XD on Lubuntu

2013-08-05

<!--- tags: linux -->

Following instructions on [lubuntu blog](http://lubuntublog.blogspot.de/p/expos.html), I installed [Skippy-XD](https://code.google.com/p/skippy-xd/) open windows previewer, by using its [deb package](https://code.google.com/p/skippy-xd/downloads/list).

I downloaded also the sample [configuration](https://raw.github.com/richardgv/skippy-xd/master/skippy-xd.rc-default), and after played a bit around, in the end, I still left the defaults.

Editing `~/.config/openbox/lubuntu-rc.xml`, I added a key binding:

```
<keybind key="W-w">
<action name="Execute">
<command>skippy-xd</command>
</action>
</keybind>
```

And run `openbox --reconfigure`, to apply the changes.

Skippy-XD seems it can only preview normal windows, not minimized ones (I did not found a way to list them) - which in my opinion makes its pretty much useless - unless all your windows are maximized or fully overlapping. Additionally, while the windows are previewed the last focused window still receives key stokes.

There is a [fix](http://www.webupd8.org/2013/07/skippy-xd-expose-like-window-picker-for.html) to show also minimized windows. The `skippy-xd-fix` is a bit slower than `skippy-xd`:

```
sudo apt-get install xdotool
wget https://raw.github.com/hotice/webupd8/master/skippy-xd-fix -O /tmp/skippy-xd-fix
sudo install /tmp/skippy-xd-fix /usr/local/bin/
rm /tmp/skippy-xd-fix
```

If you use `skippy-xd-fix`, then change the `W-w`keybinding for openbox to:

```
<keybind key="W-w">
<action name="Execute">
<command>skippy-xd-fix</command>
</action>
</keybind>
```

[skippy-xd-fix](blog/images/skippy-xd-fix) script is cool. It finds the minimized windows, remembers them, maximizes them, calls `skippy-xd` to show them, then minimizes the remembered windows again - brute force at work :). It runs acceptably fast on my laptop.

<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-08-09-Reconnect-External-IP-for-Speeport-w504v.md'>Reconnect External IP for Speeport w504v</a> <a id='fnext' href='#blog/2013/2013-08-02-Pairing-Logitech-Touchpad-and-Mouse-on-Lubuntu.md'>Pairing Logitech Touchpad and Mouse on Lubuntu</a></ins>
