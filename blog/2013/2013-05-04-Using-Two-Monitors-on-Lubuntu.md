#Using Two Monitors on Lubuntu

2013-05-04

<!--- tags: linux -->

Monitor Settings tool (`lxrandr`) included in Lubuntu is limited to configure dual monitors. It can only clone the desktop using same size on both monitors. PcManFm also can only handle this mode 100% correctly.

Following a [tutorial](http://www.lubuntutips.com/2012/05/dual-monitors-in-lubuntu.html), I installed `sudo apt-get install arandr`, a gui front end for `xrand`.

Depending on the driver used, you may need to change the virtual screen size. For example, ATI Radeon closed source driver uses `xorg.conf` and you need to set there the virtual screen size. The free Radeon driver does not use `xorg.conf`, so the configuration of virtual screen size as shown next is not needed.

I had a look at [Xorg RandR 1.2](http://www.thinkwiki.org/wiki/Xorg_RandR_1.2) and it turned out the virtual screen size was not set in `/etc/X11/xorg.conf` (default is `1600 x 1600` pixels). So I edited my `xorg.conf` file adding `Virtual 2646 1600` inside `Screen Display` sub section, and restarted the system.

```
Section "Screen"
	...
	SubSection "Display"
		...
		Virtual     2646 1600
	EndSubSection
EndSection
```

Number `2646` is the sum of my laptops built-in screen width `1366` and the external monitor width `1280` (see also: [XConfigResolution](https://wiki.ubuntu.com/X/Config/Resolution)). Based on [Xorg RandR 1.2](http://www.thinkwiki.org/wiki/Xorg_RandR_1.2) documentation then, the command to activate the dual screens is in my case (the external monitor connected to VGA port is CRT1, can be found running `xrandr -q`):
```
xrandr --output LVDS --auto --output CRT1 --auto --right-of LVDS --output DFP1 --off
```
`arandr` generated the equivalent command:
```
xrandr --output LVDS --mode 1366x768 --pos 0x0 --rotate normal --output CRT1 --mode 1280x1024 --pos 1366x0 --rotate normal --output DFP1 --off
```
Somehow, I had never connected a second monitor before to Lubuntu, thought I had connected my TV via HDMI. The side-by-side setup shows up some limits of LXDE for handing monitors of different sizes. The bottom `lxpanel` is only half shown (in the bigger monitor only, in the smaller one it is outside of viewport). This can be fixed by arranging monitors to align bottom, using `arandr` (see also [lxlinux.com](http://lxlinux.com/)).

Based on the original [tutorial](http://www.lubuntutips.com/2012/05/dual-monitors-in-lubuntu.html) recommendation, I restarted `lxpanel` with `lxpanelctl restart` which brought back the `lxpanel` menu (this can be added to `arandr` generated scripts). An Ubuntu forums [suggestion](http://ubuntuforums.org/showthread.php?t=1984875) recommends resizing `lxplanel` to one monitor only and aligning that monitor only (right, left, or center).

Below are all side by side combinations of two monitors with different sizes. The lxpanel location shown in orange (or green). LXDE seems currently to also consider the red part as part of the desktop.

![](blog/images/lxde-screen.jpg)

1. This works, but the top desktop icons will not be visible (they will be in the red part), so in practice this is not usable.
1. This works ok, but for best results the lxpanel must be resized to first monitor only and 1. set to automatically hide (or configure openbox not use dock space).
1. This setup should work ok.
1. This setup should also work ok, but same as for 2, lxpanel needs to be customized.

Additionally, pcmanfm only manages the first desktop. The second one shows the openbox context menu. This seems to be the current pcmanfm behavior on extended monitors (update: this is improved in newer versions).

Bonus: To edit the Openbox context menu for second monitor get a copy of global one:
`cp /usr/share/lubuntu/openbox/menu.xml ~/.config/openbox/menu.xml`
Then edit `lubuntu-rc.xml` in `~/.config/openbox/` folder, replace:
```
<file>/usr/share/lubuntu/openbox/menu.xml</file>
```
With:
```
<file>$HOME/.config/openbox/menu.xml</file>
```
`lubuntu-rc.xml` is a copy of `/usr/share/lubuntu/openbox/rc.xml`. If it does not exist copy if from there.

In addition you can add the following key bindings to move windows from a monitor to the other in to `lubuntu-rc.xml` on Window key + Shift + Left or Right arrow key (more key tips here):
```
<keybind key="W-S-Left">  <action name="MoveResizeTo"><monitor>2</monitor></action></keybind>
<keybind key="W-S-Right"> <action name="MoveResizeTo"><monitor>1</monitor></action></keybind>
```
`W-S-Left`, `W-S-Right` are already defined to cycle windows in `lubuntu-rc.xml`. I changed those existing key bindings to `W-C-*` (for Control key) respectively.

Run in a terminal `openbox --reconfigure` for the changes made to local `menu.xml` or `lubuntu-rc.xml` file to be reflected.


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-05-11-Editing-LXDE-Desktop-Files-via-Context-Menu.md'>Editing LXDE Desktop Files via Context Menu</a> <a rel='next' id='fnext' href='#blog/2013/2013-05-04-Configuring-Wacom-Bambo-Pen-on-Lubuntu.md'>Configuring Wacom Bambo Pen on Lubuntu</a></ins>
