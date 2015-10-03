#Lubuntu on Lenovo u41-70

2016-11-13

<!--- tags: linux -->

I was looking for relatively portable laptop to use in the evening at home, and [Lenovo u41-70](https://filedownload.lenovo.com/supportdata/product.html?id=Laptops-and-netbooks/u-series/u41-70) with around 1.6 kg of weight, an i5 CPU, 8GB of RAM, and 256 GB SSD looked like a good match. It was relatively cheap (a bit over 450 euro) as b-ware returned over Amazon service. The price was somehow uncommon for such a machine despite being sold from Amazon ware deals. The reason it was cheap was obvious to me after I received it. The machine had no more the original Levono Windows installation and the recovery partition of both Lenovo and Windows were not present. After goggling a bit around, I found Ubuntu could run ok. Given my plan was to remove Windows anyway, it looked like a perfect deal.

##Ubuntu Installation

I disabled UEFI and secure boot, and used the peculiar *novo* button to get the Lubuntu USB boot. Lubuntu install using a [bootable](https://www.ubuntu.com/download/desktop/create-a-usb-stick-on-windows) UBS was fast. I fully removed the previous disk contents (but did not wipe the drive, just formated it, so the former owner *p0rn* may be still there :).

###Lubuntu 16.04

Lubuntu 16.04 (kernel 4.4) run ok on Lenovo u41-70, but I decided to upgrade to 16.10 (kernenl 4.8) given some sporadic [freezes](http://askubuntu.com/questions/761706/ubuntu-15-10-and-16-04-keep-freezing-randomly) related to Lenovo models seem to have been fixed in 4.7+ kernels.

###Lubuntu 16.10

Lubuntu 16.10 [update](https://wiki.ubuntu.com/YakketyYak/ReleaseNotes) went ok. 16.10 seems to work better and there are no freezes. I was affected by a [dns bug](https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/1633912) and commented out `#dns=dnsmasq` in `/etc/NetworkManager/NetworkManager.conf`. DNS is handled now by `systemd-resolve`.

###Grub

Lubuntu starts very fast on SSD machines, but as of personal preference disabling `plymouth` makes startup even faster, so I [edited](http://askubuntu.com/questions/265010/how-do-i-edit-grub-menu) `/etc/default/grub` removing *splash* option:

```
#GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
```

and run `sudo update-grub` to update grub.

###ZRam

My u41-70 model has 8GB of RAM, more than enough for Lubuntu, but still I installed `zram-config` and enabled and started the its service (`sudo systemctl enable zram-config`). `zram` is lightweight for the i5 CPU and practically gives you 60% of more RAM for free (if you ever need it for virtual machines or so). I do not use any swap memory in Lubuntu, but have still to see the day I am using all of RAM.

##Graphics

My u41-70 model comes with Intel HD Graphics 5500 and a 1920x1080 TFT screen.

###Screen

u41-70 comes with a full-hd [TFT](https://www.quora.com/What-is-the-difference-between-an-IPS-screen-and-a-TFT-screen) LCD, which is ok for its kind. Black was not rendered as I expected and given, I am using [redshift](http://jonls.dk/redshift/), I configured gamma to be 0.8 for day and night. This improves the readability of black and gray text.

###GPU

I experienced some sporadic [tearing](https://wiki.archlinux.org/index.php/intel_graphics#Tips_and_tricks) with display. Tearing was up and now in Chrome browser given its GPU usage, but also in sometimes VLC given it also uses hardware acceleration for video. It seems creating `/usr/share/X11/xorg.conf.d/20-intel.conf` with (ArchWiki writes that `TearFree` option should not be needed with DRI3 enabled, but I can confirm that this works for me):

```
Section "Device"
   Identifier  "Intel Graphics"
   Driver      "intel"
   Option      "AccelMethod"  "sna"
   Option      "TearFree"    "true"
   Option      "DRI"    "3"
EndSection
```

There are some more hints to try [here](http://askubuntu.com/questions/766725/annoying-flickering-in-16-04-lts-chrome). For Chrome I also tried force-enabling GPU rasterization for all layers, via `chrome://flags/#enable-gpu-rasterization`. 

###High DPI

16.10 seems to handle better high DPI and several Qt applications, such as, `vlc` and `virtualbox` do look much better in 16.10 than in 16.04.

I increased font size using default programs delivered with Lubuntu `lxappearance`, `obconf`, `lightdm-gtk-greeter-settings-pkexec`, and `pcmanfm --desktop-pref`.

High DPI is a problem with some [applications](https://wiki.archlinux.org/index.php/HiDPI#Applications). The Qt settings via `qtconfig` are better to be avoided as they may break font rendering. I still had to handle `firefox`, `thunderbird` (via `layout.css.devPixelsPerPx`), and `chromium-browser` manually. In `/etc/chromium-browser/default`, I appended ` --force-device-scale-factor=1.3` to the browser parameters. 

For Libreoffice, I used *Tools / Options / View | User Interface | Scaling* and of course `libreoffice-style-sifr` package theme for icons.

For SublimeText 3 sidebar font size, I had to [overwrite](http://stackoverflow.com/questions/18288870/sublime-text-3-how-to-change-the-font-size-of-the-file-sidebar) the theme.

##Battery

I installed [tlp](http://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html) via `sudo apt install tlp` and activated its service (`sudo systemctl enable tlp`). The battery lasts normally for around 2.5 hours, but if I reduce the brightness and only browse and read, I can get up to 4 hours - more than enough for my usage and I am usually always near a power source.

##Wireless

u41-70 makes use of [Intel Wireless 3160](https://wireless.wiki.kernel.org/en/users/Drivers/iwlwifi). It can handle both 2.4 Ghz, 5.8 Ghz, and bluetooth. The card reach is a bit weak on large distances. It has full speed in rooms near the router, but the quality (`watch -n1 iwconfig`) falls down three rooms away. This means at some locations at home the wlan is not very usable. 

I tried to [disable](https://wiki.archlinux.org/index.php/Wireless_network_configuration) some of the [properties](http://askubuntu.com/questions/640178/no-connection-sporatic-connection-with-intel-3160-wireless-lenovo-y50-ubuntu), by appending to `/etc/modprobe.d/iwlwifi.conf`:

```
options iwlwifi bt_coex_active=0 11n_disable=1
```

Bluetooth and wireless may have [coexistence](https://wiki.archlinux.org/index.php/Wireless_network_configuration) issues, so I [tried](http://superuser.com/questions/924559/wifi-connection-troubles-solved-why-does-my-fix-work) `bt_coex_active=0`.

I have a spare *Hama 300 Mbps WLAN USB* stick that runs ok under Ubuntu. I configured a second wireless connection over NetworkManager manually for the same SSID and then selected as Device the Hamma WLan USB (via its MAC). I can plug the stick and select its WLAN connection. I might give network [bonding](https://www.howtoforge.com/network_bonding_ubuntu_6.10) a try in the future. **Update**: I added a WLAN repeater.

##Openbox Configurarion

My usual custom `openbox` configuration in `~/.config/openbox/lubuntu-rc.xml`:

```xml
    <keybind key="W-s">
      <action name="Execute">
        <command>disper --cycle-stages='-c:-e:-S:-s' --cycle</command>
      </action>
    </keybind>
    <keybind key="W-b">
      <action name="Execute">
        <command>/usr/bin/chromium-browser</command>
      </action>
    </keybind>
    <keybind key="W-m">
      <action name="Execute">
        <command>lxpanelctl menu</command>
      </action>
    </keybind>
    <keybind key="W-x">
      <action name="Execute">
        <command>lubuntu-logout</command>
      </action>
    </keybind>
    <keybind key="W-space">
      <action name="ToggleMaximize"/>
    </keybind>
    <keybind key="W-t">
      <action name="Execute">
        <command>lxsession-default-terminal</command>
      </action>
    </keybind>
    <keybind key="W-l">
      <action name="Execute">
        <command>i3lock -i /home/u7/bin/i3lock.png</command>
      </action>
    </keybind>
    <keybind key="W-i">
      <action name="Execute">
        <command>xcalib -invert -alter</command>
      </action>
    </keybind>
```

I installed `pavucontrol` and `pulseaudio`, I so had to modify the commands mapped for keyboard [sound](http://askubuntu.com/questions/97936/terminal-command-to-set-audio-volume) keys:

```xml
    <keybind key="XF86AudioRaiseVolume">
      <action name="Execute">
        <command>amixer -D pulse sset Master 5%+ unmute</command>
      </action>
    </keybind>
    <keybind key="XF86AudioLowerVolume">
      <action name="Execute">
        <command>amixer -D pulse sset Master 5%- unmute</command>
      </action>
    </keybind>
    <keybind key="XF86AudioMute">
      <action name="Execute">
        <command>amixer -D pulse sset Master toggle</command>
      </action>
    </keybind>
```

##Other Applications

Using `dbus-launch ~/.dropbox-dist/dropboxd` to [start](http://askubuntu.com/questions/732967/dropbox-icon-is-not-working-xubuntu-14-04-lts-64) Dropbox helps tray icon be visible.

For Chromium, `pepperflashplugin-nonfree` is no more maintained - one has to use `adobe-flashplugin` now.

[touchpad-indicator](https://launchpad.net/~atareao/+archive/ubuntu/atareao) helps disable touchpad when mouse is plugged in.

I had to install `seahorse` and mark *Login* key ring as default, not to be asked for the password of shares by `pcmanfm` on every login.

To enable my bluetooth headset, I [installed](http://askubuntu.com/questions/801404/bluetooth-connection-failed-blueman-bluez-errors-dbusfailederror-protocol-no):

```
sudo apt-get install pulseaudio-module-bluetooth
pactl load-module module-bluetooth-discover
```

The module is added to `/etc/pulse/default.pa`. To autostart `blueman-manager` I added to `/home/u7/.config/lxsession/Lubuntu/autostart`:

```
@blueman-applet
```

##Final Thoughts

Finding an ultrabook-like machine that is powerful enough, runs Ubuntu without many hacks, and is not very expensive - can be a challenge. With u41-70, I had to be flexible on some areas, such as, TFT screen quality, battery life, and WLAN reach. I am happy there was no obstacle big enough to make me return it. The machine is powerful enough for all my needs at home and light enough to carry around.


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-11-29-From-User-Stories-To-Code.md'>From User Stories To Code</a> <a rel='next' id='fnext' href='#blog/2016/2016-10-30-To-Rule-Your-City-Conquer-World.md'>To Rule Your City Conquer World</a></ins>