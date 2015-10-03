#Lubuntu on Lenovo u41-70

2016-11-13

<!--- tags: linux -->

I was looking for relatively portable and cheap laptop to use at home, and [Lenovo u41-70](https://filedownload.lenovo.com/supportdata/product.html?id=Laptops-and-netbooks/u-series/u41-70) with around 1.6 kg of weight, an i5 CPU, 8GB of RAM, and 256 GB SSD looked like a good match. It was relatively cheap (a bit over 450 euro) as b-ware returned over Amazon service. The price was somehow uncommon for such a machine despite being sold from Amazon ware deals. The reason it was cheap was obvious to me after I received it. The machine had no more the original Levono Windows installation and the recovery partition of both Lenovo and Windows were not present. After goggling a bit around, I found Ubuntu could run ok. Given my plan was to remove Windows anyway, it looked like a perfect deal.

<div id='toc'></div>

##Ubuntu Installation

I disabled UEFI and secure boot, and used the peculiar *novo* button to get the Lubuntu USB boot. Lubuntu install using a [bootable](https://www.ubuntu.com/download/desktop/create-a-usb-stick-on-windows) USB was fast. I fully removed the previous disk contents (but did not wipe the drive, just formated it, so the former owner *p0rn* may be still there :).

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

###Startup

I see some errors reported at startup:

```
$ dmesg | grep -iE "failed|error"
[    0.711376] acpi PNP0A08:00: _OSC failed (AE_ERROR); disabling ASPM
[    2.028037] ACPI Error: [\_SB_.PCI0.LPCB.H_EC.ECWT] Namespace lookup failure, AE_NOT_FOUND (20160422/psargs-359)
[    2.028044] ACPI Error: Method parse/execution failed [\_TZ.FN00._ON] (Node ffff8ce14e0f6a50), AE_NOT_FOUND (20160422/psparse-542)
[    2.028050] acpi PNP0C0B:00: Failed to change power state to D0
[    2.028073] ACPI Error: [\_SB_.PCI0.LPCB.H_EC.ECWT] Namespace lookup failure, AE_NOT_FOUND (20160422/psargs-359)
[    2.028075] ACPI Error: Method parse/execution failed [\_TZ.FN00._ON] (Node ffff8ce14e0f6a50), AE_NOT_FOUND (20160422/psparse-542)
[    2.028080] acpi PNP0C0B:00: Failed to set initial power state
[    2.051872] ACPI Error: [\_SB_.PCI0.LPCB.H_EC.ECRD] Namespace lookup failure, AE_NOT_FOUND (20160422/psargs-359)
[    2.051876] ACPI Error: Method parse/execution failed [\_TZ.TZ00._TMP] (Node ffff8ce14e0f6960), AE_NOT_FOUND (20160422/psparse-542)
[    2.051992] ACPI Error: [\_SB_.PCI0.LPCB.H_EC.ECRD] Namespace lookup failure, AE_NOT_FOUND (20160422/psargs-359)
[    2.051995] ACPI Error: Method parse/execution failed [\_TZ.TZ00._TMP] (Node ffff8ce14e0f6960), AE_NOT_FOUND (20160422/psparse-542)
[    2.052048] ACPI Error: [\_SB_.PCI0.LPCB.H_EC.ECRD] Namespace lookup failure, AE_NOT_FOUND (20160422/psargs-359)
[    2.052050] ACPI Error: Method parse/execution failed [\_TZ.TZ01._TMP] (Node ffff8ce14e0f62a8), AE_NOT_FOUND (20160422/psparse-542)
[    2.052135] ACPI Error: [\_SB_.PCI0.LPCB.H_EC.ECRD] Namespace lookup failure, AE_NOT_FOUND (20160422/psargs-359)
[    2.052137] ACPI Error: Method parse/execution failed [\_TZ.TZ01._TMP] (Node ffff8ce14e0f62a8), AE_NOT_FOUND (20160422/psparse-542)
[    2.313189] [drm:intel_dp_start_link_train [i915]] *ERROR* failed to train DP, aborting
[    2.360396] [drm:intel_dp_start_link_train [i915]] *ERROR* failed to train DP, aborting
```

It seems, [acpi](https://wiki.archlinux.org/index.php/ACPI_modules) information is [not](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1349740) correctly [supplied](http://askubuntu.com/questions/86499/error-about-acpi-osc-request-failed-ae-not-found) by BIOS. That does matter much in my case and this is not the first laptop to have this issue. Do not know what DP message is about, but external monitor (TV) over HDMI works fine.

###ZRam

8GB of RAM is more than enough for Lubuntu, but still I installed `zram-config` and enabled and started the its service (`sudo systemctl enable zram-config`). `zram` is lightweight for the i5 CPU and practically gives you 60% of more RAM for free (if you ever need it for virtual machines or so). I do not use any swap memory in Lubuntu, but have still to see the day I am using all of RAM.

network-manager network-manager-gnome network-manager-openvpn  network-manager-openvpn-gnome network-manager-pptp network-manager-vpnc  resolvconf ubuntu-minimal

##Bios

Bios can be reached either via the *novo* button, or via `Fn-F2`. Machine had an old BIOS version BDCN31WW. Lenovo already offers a newer version BDCN71WW. There is no BIOS updater provided for DOS, so I could not use FreeDOS (I already removed Windows :). I used [WinToUsb](http://www.easyuefi.com/wintousb/) to create a *Windows To Go* USB (Win10 64bit, MBR, VHD, 64GB) and used that to update the BIOS (there is no need to activate Windows if you use it only for this purpose). After the BIOS update, Bluetooth was not working:

```
[   19.677613] Bluetooth: hci0 sending Intel patch command (0xfc8e) failed (-110)
[   19.677676] Bluetooth: hci0 sending frame failed (-19)
[   21.693573] Bluetooth: hci0: Exiting manufacturer mode failed (-110)
```

Bluetooth has to be [activated](http://askubuntu.com/questions/437304/cannot-enable-bluetooth-anymore), because I did not reset BIOS to defaults before doing the update:

```
sudo apt install rfkill
sudo rfkill list all
0: ideapad_wlan: Wireless LAN
  Soft blocked: no
  Hard blocked: no
1: ideapad_bluetooth: Bluetooth
  Soft blocked: yes
  Hard blocked: no
3: phy0: Wireless LAN
  Soft blocked: no
  Hard blocked: no
sudo rfkill unblock 1 #id
```

`+` and `-` keys are not working to move USB devices up in the BIOS boot list, as the keyboard lacks a numeric pad. To be able to press those, I attached an external keyboard.

##Graphics

My u41-70 model comes with Intel HD Graphics 5500 (Broadwell) and an 1920x1080 TN screen.

###Screen

u41-70 has a full-hd [TN](https://www.quora.com/What-is-the-difference-between-an-IPS-screen-and-a-TFT-screen) [LCD](http://www.notebookcheck.net/Lenovo-U41-70-Notebook-Review.146824.0.html), which is ok for its kind. Black was not rendered as I expected and given, I am using [redshift](http://jonls.dk/redshift/), I configured gamma to be 0.8 for day and night. This improves the readability of black and gray text.

###GPU

I experienced some sporadic [tearing](https://wiki.archlinux.org/index.php/intel_graphics#Tips_and_tricks) with display while scrolling up and now in Chrome browser given its GPU usage. After several tests with various options, it [helps](https://www.reddit.com/r/archlinux/comments/4cojj9/it_is_probably_time_to_ditch_xf86videointel/) creating `/usr/share/X11/xorg.conf.d/20-intel.conf` [with](http://cynic.cc/blog/posts/sna_acceleration_vs_uxa/):

```
Section "Device"
   Identifier  "Intel Graphics"
   Driver      "intel"
   Option      "TearFree" "true"
   Option      "AccelMethod"  "uxa"
EndSection
```

There are some more hints to try [here](http://askubuntu.com/questions/766725/annoying-flickering-in-16-04-lts-chrome). 

###High DPI

16.10 seems to handle better high DPI and several Qt applications, such as, `vlc` and `virtualbox` do look much better in 16.10 than in 16.04.

I increased font size using default programs delivered with Lubuntu `lxappearance`, `obconf`, `lightdm-gtk-greeter-settings-pkexec`, and `pcmanfm --desktop-pref`.

High DPI is a problem with some [applications](https://wiki.archlinux.org/index.php/HiDPI#Applications). The Qt settings via `qtconfig` are better to be avoided as they may break font rendering. I still had to handle `firefox`, `thunderbird` (via `layout.css.devPixelsPerPx`), and `chromium-browser` manually. In `/etc/chromium-browser/default`, I tried ` --force-device-scale-factor=1.3`, but it seems to have issues in full screen video for current Chrome version. 

For Libreoffice, I used *Tools / Options / View | User Interface | Scaling* and of course `libreoffice-style-sifr` package theme for icons.

For SublimeText 3 sidebar font size, I had to [overwrite](http://stackoverflow.com/questions/18288870/sublime-text-3-how-to-change-the-font-size-of-the-file-sidebar) the theme.

##Battery

I installed [tlp](http://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html) via `sudo apt install tlp` and activated its service (`sudo systemctl enable tlp`). TLP [configuration](http://linrunner.de/en/tlp/docs/tlp-configuration.html) is in `/etc/default/tlp`. 

```
$ sudo tlp-stat -s
--- TLP 0.8 --------------------------------------------

+++ System Info
System         = LENOVO Lenovo U41-70 80JV
BIOS           = BDCN31WW
Release        = Ubuntu 16.10
Kernel         = 4.8.0-30-generic #32-Ubuntu SMP Son Nov 13 03:43:27 UTC 2016 x86_64
/proc/cmdline  = BOOT_IMAGE=/boot/vmlinuz-4.8.0-30-generic root=UUID=567c7acd-af49-415c-8ac1-4fedb6e962db ro quiet
Init system    = systemd

+++ System Status
TLP power save = enabled
power source   = battery

```

Battery lasts normally for around 2.5 hours, but if I reduce the screen brightness and only browse and read, I can get up to 3.5 hours - more than enough for my usage and I am usually always near a power source.

##Wireless

u41-70 makes use of [Intel](http://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/tree/) [Wireless 3160](https://wireless.wiki.kernel.org/en/users/Drivers/iwlwifi). It can [handle](https://forum.ubuntuusers.de/topic/kein-wlan-ohne-kernelupdate/#post-7996788) both 2.4 Ghz, 5.8 Ghz, and Bluetooth:

```
$ modinfo -F firmware iwlwifi | grep 3160
iwlwifi-3160-17.ucode

$ lspci -nnk | grep -i net -A2
02:00.0 Network controller [0280]: Intel Corporation Wireless 3160 [8086:08b4] (rev 93)
  Subsystem: Intel Corporation Dual Band Wireless AC 3160 [8086:8270]
  Kernel driver in use: iwlwifi

```

Card's reach is a bit weak on large distances. It has full speed in rooms near the router, but the quality (`watch -n1 iwconfig`) falls down three rooms away. This means at some locations at home WLAN is not stable. 

I tried [changing](https://wiki.archlinux.org/index.php/Wireless_network_configuration) [some](https://forum.ubuntuusers.de/topic/instabiles-wlan-mit-intel-ac-3160-in-neuem-tux/2/) of the properties, by appending to `/etc/modprobe.d/iwlwifi.conf`:

```
options iwlwifi bt_coex_active=0 11n_disable=8
```

Bluetooth and wireless could have [coexistence](https://wiki.archlinux.org/index.php/Wireless_network_configuration) issues, so I [tried](http://superuser.com/questions/924559/wifi-connection-troubles-solved-why-does-my-fix-work) `bt_coex_active=0`. To view all supported parameters use:

```
modinfo -F parm iwlwifi
```

To view current used parameters, try [any](http://serverfault.com/questions/62316/how-do-i-list-loaded-linux-module-parameter-values) of:

```
systool -vm iwlwifi # part of sysfsutils
grep '' /sys/module/iwlwifi*/parameters/*
```

I have a spare *Hama 300 Mbps WLAN USB* stick that runs ok under Ubuntu that I configured as a second wireless connection over NetworkManager manually for the same SSID and then selected as Device the Hamma WLan USB (via its MAC). I can plug the stick and select its WLAN connection (might give network [bonding](https://www.howtoforge.com/network_bonding_ubuntu_6.10) a try in the future. 

**Update**: Added a WLAN repeater, so now WLAN works much better in all places.

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
        <command>i3lock -i /home/user/bin/i3lock.png</command>
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

* Using `dbus-launch ~/.dropbox-dist/dropboxd` to [start](http://askubuntu.com/questions/732967/dropbox-icon-is-not-working-xubuntu-14-04-lts-64) Dropbox helps tray icon be visible.

* For Chromium, `pepperflashplugin-nonfree` is no more maintained - one has to use `adobe-flashplugin` now.

* [touchpad-indicator](https://launchpad.net/~atareao/+archive/ubuntu/atareao) helps disable touchpad when mouse is plugged in.

* I had to install `seahorse` and mark *Login* key ring as default, not to be asked for the password of shares by `pcmanfm` on every login. I also [installed](http://askubuntu.com/questions/666453/lubuntu-14-04-unlock-keyring-on-login) `sudo apt install libpam-gnome-keyring` and appended `auto_start` in `//etc/pam.d/common-password` to:
  ```
  password  optional  pam_gnome_keyring.so  auto_start
  ```   

* To enable my bluetooth headset, I [installed](http://askubuntu.com/questions/801404/bluetooth-connection-failed-blueman-bluez-errors-dbusfailederror-protocol-no):

  ```
  sudo apt-get install pulseaudio-module-bluetooth
  pactl load-module module-bluetooth-discover
  ```

 The module is added to `/etc/pulse/default.pa`. To autostart `blueman-manager` I added to `~/.config/lxsession/Lubuntu/autostart`:

  ```
  @blueman-applet
  ```

* LXDE *Keyboard and Mouse* settings are saved in `~/.config/.config/autostart/LXinput-setup.desktop`. I reversed my mouse buttons via UI (`lxinput`) and then manually modified the file to map *Caps* key to *Shift* and enable *Ctrl+Alt+Backspace* for x11 (`xset` below has defaults, rest are my modified values):

  ```
  [Desktop Entry]
  Type=Application
  Name=LXInput autostart
  Comment=Setup keyboard and mouse using settings done in LXInput
  NoDisplay=true
  Exec=sh -c 'xset m 20/10 10 r rate 500 30 b on;setxkbmap -option terminate:ctrl_alt_bksp;xmodmap -e "pointer = 3 2 1" -e "keycode 66 = Shift_L"'
  NotShowIn=GNOME;KDE;XFCE;
  ```

* Mandatory custom `/etc/hosts` entries:

  ```
  0.0.0.0 google-analytics.com
  0.0.0.0 www.google-analytics.com
  0.0.0.0 ssl.google-analytics.com
  0.0.0.0 client-s.gateway.messenger.live.com 
  ```

* I set a [Private](https://help.ubuntu.com/community/EncryptedPrivateDirectory) folder using:

  ```
  sudo apt-get install ecryptfs-utils
  ecryptfs-setup-private
  ```

##Final Thoughts

Finding an ultrabook-like machine that is powerful enough, runs Ubuntu without many hacks, and is not very expensive - can be a challenge. With u41-70, I had to be flexible on some areas, such as, TFT screen quality, battery life, and WLAN reach. I am happy that there was no obstacle big enough to make me return it. The machine is powerful enough for all my needs at home and light enough to carry around.


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-11-29-From-User-Stories-To-Code.md'>From User Stories To Code</a> <a rel='next' id='fnext' href='#blog/2016/2016-10-30-To-Rule-Your-City-Conquer-World.md'>To Rule Your City Conquer World</a></ins>
