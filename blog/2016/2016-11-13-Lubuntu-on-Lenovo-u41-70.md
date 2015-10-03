#Lubuntu on Lenovo u41-70

2016-11-13

<!--- tags: linux -->

I was looking for relatively portable laptop to use in the evening at home, and [Lenovo u41-70](http://support.lenovo.com/us/en/products/laptops-and-netbooks/u-series/u41-70) with around 1.6 kg of weight, an i5 CPU, 8GB of RAM, and 256 GB SSD looked like a good match. I bought it relatively cheap (a bit over 400 euro) as b-ware returned over Amazon service. The price was somehow uncommon for such a machine despite being sold from Amazon ware deals. The reason it was cheap was obvious to me after I received it. The machine had no more the original Levono Windows installation and the recovery partition of both Lenovo and Windows were not present. I goggled a bit around before I bough it, and found Ubuntu could run ok. Given my plan was to remove Windows anyway, it looked like a perfect deal.

##Lubuntu 16.04

I installed first Lubuntu 16.04 (kernel 4.4) on Lenovo u41-70, but decided to upgrade to 16.10 (kernenl 4.8) given some sporadic [freezes](http://askubuntu.com/questions/761706/ubuntu-15-10-and-16-04-keep-freezing-randomly) related to Lenovo models seem to have been fixed in 4.7+ kernels.

I disabled UEFI and secure boot, and used the strange *novo* button to get the UBS boot. Lubuntu install over a [bootable](https://www.ubuntu.com/download/desktop/create-a-usb-stick-on-windows) UBS was fast and I fully removed the previous disk contents (I did not wipe the drive, just formated it, so former owner *p0rn* may still be there :).

##Lubuntu 16.10

Lubuntu 16.10 [update](https://wiki.ubuntu.com/YakketyYak/ReleaseNotes) went ok. For the u41-70 machine, 16.10 seems to work better and there no freezes. 

I was affected by a [dns bug](https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/1633912) and commented out `#dns=dnsmasq` in `/etc/NetworkManager/NetworkManager.conf`. DNS is handled now by `systemd-resolve`.

##High DPI

16.10 seems to handle better high DPI and several Qt applications, such as, `vlc` and `virtualbox` do look much better in 16.10 than in 16.04.

I increased font size using default programms delivered with Lubuntu `lxappearance`, `obconf`, `lightdm-gtk-greeter-settings-pkexec`, and `pcmanfm --desktop-pref`.

High DPI is a problem with some [application](https://wiki.archlinux.org/index.php/HiDPI#Applications). The Qt settings via qtconfig are better to be avoided as they may break font rendering. I still had to handle `firefox`, `thunderbird`, and `chromium-browser` manually. For Libreoffice, I used *Tools / Options / View | User Interface | Scaling* and of course `libreoffice-style-sifr` package theme for icons.

For SublimeText 3, sidebar font size, I had to (overwrite)[http://stackoverflow.com/questions/18288870/sublime-text-3-how-to-change-the-font-size-of-the-file-sidebar] the theme.

##Monitor Screen

u41-70 comes with a full-hd [TFT](https://www.quora.com/What-is-the-difference-between-an-IPS-screen-and-a-TFT-screen) LCD, which is ok for its kind. I found black was not properly rendered as I expected. Given, I am using [redshift](http://jonls.dk/redshift/), I configured gamma to be 0.8 for day and 0.6 for night. This improves the readability of black and gray text.

##Openbox Configurarion

I extended `openbox` configuration in `~/.config/openbox/lubuntu-rc.xml` with the usual stuff I am used to:

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

##Grub

Lubuntu starts very fast on SSD machines, but as of personal preference disabling `plymouth` makes startup even faster, so I [edited](http://askubuntu.com/questions/265010/how-do-i-edit-grub-menu) `/etc/default/grub` removing *splash* option:

```
#GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
```

and run `sudo update-grub` to update grub.

##ZRam

My u41-70 model has 8GB of RAM, more than enough for Lubuntu, but still I installed `zram-config` and enabled and started the its service (`sudo systemctl enable zram-config`). `zram` is lightweight for the i5 CPU and practically gives you 60% of more RAM for free (if you ever need it). I do not use any swap memory in Lubuntu, so RAM is all I have, but have still to see the day, I am using all of it.

##Battery

I installed [tlp](http://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html) via `sudo apt install tlp` and activated its service (`sudo systemctl enable tlp`). The battery lasts normally for around 2.5 hours, but if I reduce the brightness and only browse and read, I can get up to 4 hours - more than enough for my usage. Anyway, I am always near a power source.

##Wireless

u41-70 comes with [Intel Wireless 3160](https://wireless.wiki.kernel.org/en/users/Drivers/iwlwifi). It can handle both 2.4 Ghz and 5.8 Ghz and bluetooth. I found the card reach is a bit weak on large distances. It has full speed in rooms near the router, but the quality (`watch -n1 iwconfig`) falls down four rooms away. This means at some locations at home, the wlan is not very usable.

Fortunately, I have a spare *Hama 300 Mbps WLAN USB* stick that runs ok under Ubuntu. The trick is to configure a second wireless connection over NetworkManager manually for the same SSID and then select as Device the Hamma WLan USB (via its MAC). When I am in a room far away, I can plug the stick (via a short UBS cable to the machine for better signal reception and that it is convenient to move around freely) and then I just select that other WLAN connection.

##Other Applications

I had to use `dbus-launch ~/.dropbox-dist/dropboxd` to [start](http://askubuntu.com/questions/732967/dropbox-icon-is-not-working-xubuntu-14-04-lts-64) Dropbox, so that icon is visible.

For Chromium, `pepperflashplugin-nonfree` is no more maintained, one has to use `adobe-flashplugin` now.

I am not a big user of touchpad, so I use [touchpad-indicator](https://launchpad.net/~atareao/+archive/ubuntu/atareao) to disable it when mouse in plugged in.

##Final Thoughts

Finding an ultrabook-like machine that is powerful enough, runs Ubuntu without many hacks, and is not very expensive - can be a challenge. With u41-70, I had to be flexible on some areas, such as, TFT screen quality, battery life, and wlan reach. I am happy there was no obstacle big enough to make me return it. The machine in powerful enough for all my needs at home for the near future and light enough to carry around.


<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2016/2016-10-30-To-Rule-Your-City-Conquer-World.md'>To Rule Your City Conquer World</a></ins>
