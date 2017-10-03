#Installing Ubuntu 18.10

2019-01-23

<!--- tags: linux -->

I gave Ubuntu 18.10 a try in VirtualBox and 18.04 in a machine and here is a summary of some of the things I had to do, for own reference.

##Remove Swap Partition

Installer gave me errors when I tried to modify partitions of default encrypted disk setup (I guess they need to be modified by live CD before installer) and I ended up with using defaults. 

I wanted to remove the default swap partition that was created:

```bash
lsblk 
NAME                    MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda                       8:0    0    30G  0 disk  
+-sda1                    8:1    0   731M  0 part  /boot
+-sda2                    8:2    0     1K  0 part  
+-sda5                    8:5    0  29,3G  0 part  
  +-sda5_crypt          253:0    0  29,3G  0 crypt 
    +-ubuntu--vg-root   253:1    0  28,3G  0 lvm   /
    +-ubuntu--vg-swap_1 253:2    0   976M  0 lvm   # I do not want this
```

Fortunately, swap removal after installation is easy:

```bash
sudo swapoff -a
sudo vi /etc/fstab
# comment out /dev/mapper/ubuntu--vg-swap_1 line

sudo umount /dev/mapper/ubuntu--vg-swap_1
sudo lvremove ubuntu-vg/swap_1
sudo vgdisplay
# ...
# Free  PE / Size       253 / 1012,00 MiB

sudo lvextend -l +253  /dev/ubuntu-vg/root
sudo resize2fs /dev/ubuntu-vg/root 

sudo lvdisplay
```

Finally, I got:

```bash
lsblk
NAME                  MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda                     8:0    0    30G  0 disk  
+-sda1                  8:1    0   731M  0 part  /boot
+-sda2                  8:2    0     1K  0 part  
+-sda5                  8:5    0  29,3G  0 part  
  +-sda5_crypt        253:0    0  29,3G  0 crypt 
    +-ubuntu--vg-root 253:1    0  29,3G  0 lvm   /
```

I edited also `/etc/initramfs-tools/conf.d/resume` to set:

```
RESUME=none
```

And run `sudo update-initramfs -u`. Additionally, I claimed all disk space with: `sudo tune2fs -m 0 /dev/mapper/ubuntu--vg-root`.

###Encrypted Disk Layout Details

Above, [sda2](https://askubuntu.com/questions/950307/why-guided-partitioning-create-a-sda2-of-1-kb) is the extended partition. What is shown as *1K* is the [unaligned](https://unix.stackexchange.com/questions/128290/what-is-this-1k-logical-partition) area in it.

`/boot` is not encrypted by default. Rather that deal with effort to [encrypt](https://dustymabe.com/2015/07/06/encrypting-more-boot-joins-the-party/) it (`grub` will still be unencrypted and you have to take extra care during kernel / grub / distribution updates), an additional BIOS disk password (or VM disk encryption password) maybe better.

For [reference](https://vitobotta.com/2018/01/11/ubuntu-full-disk-encryption-manual-partitioning-uefi/), if we need to login as root in grub and fix something:

```
sudo mkdir /mnt/root
sudo cryptsetup luksOpen /dev/sda3 sda3_crypt
sudo mount /dev/mapper/system-root /mnt/root
sudo mount --bind /dev /mnt/root/dev
sudo mount --bind /run /mnt/root/run
sudo chroot /mnt/root
umount /boot
mkdir /boot
mount /dev/sda2 /boot
mount /dev/sda1 /boot/efi
mount --types=proc proc /proc
mount --types=sysfs sys /sys
...
exit
reboot
```

To change [password](https://askubuntu.com/questions/109898/how-to-change-the-password-of-an-encrypted-lvm-system-done-with-the-alternate-i), either use `sudo gnome-disks` or:

```
# find device
cat /etc/crypttab
# find used slots
sudo cryptsetup luksDump /dev/sda3
# change or add new slot
sudo cryptsetup luksAddKey /dev/sda3 -S 0
# sudo cryptsetup luksRemoveKey /dev/sda3
```

##GNOME

I have still to find someone that can use GNOME as it is out of the box. So first things first:

```bash
sudo apt-get update
sudo apt install chrome-gnome-shell
```

On Firefox, installed [GNOME Shell Integration](https://addons.mozilla.org/en-US/firefox/addon/gnome-shell-integration/). Next, I installed a minimum set of [GNOME extensions](https://extensions.gnome.org/local/).

###Minimal Selection of GNome Extensions

I can live with this one only:

* Dash to Panel https://extensions.gnome.org/extension/1160/dash-to-panel/

I added also some CPU load indicator (first one I found that looked ok):

* SysPeek-GS https://extensions.gnome.org/extension/1409/syspeek-gs/

A well-done menu:

* Gno-Menu https://extensions.gnome.org/extension/608/gnomenu/

To move notifications to corner:

* Panel-OSD https://extensions.gnome.org/extension/708/panel-osd/

Not having used GNOME in a while, I had to remind myself of *Windows+A* [shortcut](https://wiki.gnome.org/Design/OS/KeyboardShortcuts) to open applications.

Some `nautilus` shortcuts:

*  Ctrl+Shift+N new folder
*  Ctrl+L edit address bar
*  Ctrl+T new tab
*  Ctrl+Q or Ctrl+W close (tab)
*  Ctrl+R of F5 refresh
*  Ctrl+F find, Ctrl+S select, Ctrl+A select all
*  `touch ~/Templates/New.txt` templates

###Hacks

* GEdit and other GNOME programs was showing *'Preferences'* menu only if run with *sudo*. I had to [run](https://askubuntu.com/questions/375049/where-are-gedits-preferences/671398#671398):

    ```
    gsettings set org.gnome.settings-daemon.plugins.xsettings overrides '@a{sv} {"Gtk/ShellShowsAppMenu": <int32 0>}'
    ```

* `gedit` fails to show [last](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=826278) lines sometimes (cannot scroll to end of file). Will use `geany` for [text](https://askubuntu.com/questions/13447/how-do-i-change-the-default-text-editor) edits.

* VirtualBox mouse was freezing. I found a [solution](https://ubuntuforums.org/showthread.php?t=2395969) that seems to work: *Go into the preferences of your VirtualBox Manager. Click on "Input" and make sure that "Auto Capture Keyboard" is not selected for "VirtualBox Manager" and "Virtual Machine".*

* `gthumb` had a dark theme, ignoring system theme. I had to edit its [desktop](https://askubuntu.com/questions/1017886/gthumb-version-3-4-3-with-light-background-colors-in-menus-and-browser-like) file: 

```
Exec=env GTK_THEME=Ambiance:light gthumb %U
```

* The frequent apps list is in `~/.local/share/gnome-shell/application_state`.

* If GNOME shell [freezes](https://wiki.archlinux.org/index.php/GNOME/Troubleshooting#Shell_freezes), type `Ctrl+Alt+F3`, login and run `pkill -HUP gnome-shell`.

* I copied *ttf* [fonts](https://askubuntu.com/questions/3697/how-do-i-install-fonts) from a Windows VM to `~/.local/share/fonts`.

* Graphical `update-manager` was closing after update check. I had to clean all files in `/var/lib/apt/lists` and run `sudo apt update` to fix the issue.

##First Tools

I did a minimal Ubuntu install. I am so happy they offer that, as in the past I had to un-install most of things. I installed some initial set of tools to get started:

```bash
sudo apt remove --purge ubuntu-report 
sudo apt remove --purge popularity-contest

sudo apt install synaptic
sudo apt install gnome-tweaks
sudo apt install dconf-editor
sudo apt install gnome-system-tools
sudo apt install menulibre
sudo apt install faenza-icon-theme # I am used to those icons, rest confuses me
sudo apt install chromium-browser
# with flags
# --incognito --disk-cache-dir=/dev/null --disk-cache-size=1 -start-maximized --enable-dom-distiller
```

##Snap

[snap](https://snapcraft.io/) gives a whole class of users choice, and it is in the core strategy behind Ubuntu Core. There seems to be a [decision](https://askubuntu.com/questions/1039968/why-have-canonical-installed-core-gnome-apps-as-snaps-by-default) to deliver parts of desktop as snaps by default to update them cleaner in the future. `snap` is already active for GNOME parts:

```bash
$ df -h -T | grep loop
/dev/loop0                  squashfs   13M   13M     0 100% /snap/gnome-characters/124
/dev/loop1                  squashfs   88M   88M     0 100% /snap/core/5662
/dev/loop2                  squashfs  2,3M  2,3M     0 100% /snap/gnome-calculator/238
/dev/loop4                  squashfs  3,8M  3,8M     0 100% /snap/gnome-system-monitor/57
/dev/loop3                  squashfs   43M   43M     0 100% /snap/gtk-common-themes/701
/dev/loop5                  squashfs   15M   15M     0 100% /snap/gnome-logs/45
/dev/loop6                  squashfs  141M  141M     0 100% /snap/gnome-3-26-1604/70
/dev/loop7                  squashfs   90M   90M     0 100% /snap/core/6130
/dev/loop8                  squashfs   13M   13M     0 100% /snap/gnome-characters/139
/dev/loop9                  squashfs  2,3M  2,3M     0 100% /snap/gnome-calculator/260
/dev/loop10                 squashfs   35M   35M     0 100% /snap/gtk-common-themes/818
/dev/loop11                 squashfs  141M  141M     0 100% /snap/gnome-3-26-1604/74

```

Someone designed `snap` to use `squashfs` and now each *snap* needs a `loop` device. In place of fixing the root of problem and come up with something better, Ubuntu developers are starting to [modify](https://bugs.launchpad.net/ubuntu/+source/gnome-disk-utility/+bug/1637984) GNOME desktop UI tools now, such as `gnome-disks`, not to list snap `loop` devices.

Useful `.bash_aliases` alias:

```
alias dfh='df -h -T -x tmpfs -x devtmpfs -x squashfs'
```

###Getting Rid of Snaps

Ubuntu desktop may not function properly if you do any of these. This info is listed here for completeness only.

To [remove](https://askubuntu.com/questions/1035915/how-to-remove-snap-store-from-ubuntu) `snap` one can use:

```bash
sudo apt autoremove --purge snapd
# to remove snaps appearing in gnome-software only
sudo apt remove --purge gnome-software-plugin-snap
```

To [remove](https://www.reddit.com/r/Ubuntu/comments/8krkam/system_monitor_on_1804_is_a_snap_by_default/) specific pre-installed snaps:

```bash
sudo snap remove gnome-system-monitor
sudo apt install gnome-system-monitor
```

###Final Steps

* Obligatory `/etc/hosts` entries:

```
0.0.0.0 google-analytics.com
0.0.0.0 www.google-analytics.com
0.0.0.0 ssl.google-analytics.com

0.0.0.0 daisy.ubuntu.com
0.0.0.0 metrics.ubuntu.com
0.0.0.0 popcon.ubuntu.com
0.0.0.0 motd.ubuntu.com
```

* Installed `sudo apt install tlp zram-config` and enabled and started their services.

* Installed `openvpn`. Added client configuration in `/etc/openvpn/client/my-client.conf` and enabled and started its service `sudo systemctl start openvpn-client@my-client`. For firewall, had to install `sudo apt install netfilter-persistent`.

* `veracrypt` needs `sudo apt install libcanberra-gtk-module libcanberra-gtk3-module`.

* Useful software: `sudo apt install mpv vlc speedcrunch speedcrunch keepassxc baobab`.

* `mpv` config (`~/.config/mpv/`) (using also [nextfile](https://github.com/donmaiq/mpv-nextfile) [script](https://github.com/mpv-player/mpv/wiki/User-Scripts)):

```
#input.conf

- quit
x quit
s quit
S quit
ctrl+s quit
Alt+s quit
ESC quit
LEFT playlist-prev force
RIGHT playlist-next force
WHEEL_UP playlist-prev
WHEEL_DOWN playlist-next
ctrl+LEFT script-binding previousfile
ctrl+RIGHT script-binding nextfile

# mpv.conf

fs
image-display-duration=3
```

##Summary

Ubuntu 18.10 UI is usable with minor tweaks without having to install some other desktop variant. GNOME is still full of bugs, but the overall UI is acceptable. I can imagine using next LTS release UI as default desktop. Expect to see more things like `snap` and `ubuntu-report` being added there by default.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2019/2019-01-24-Docker-s-Blackhole-Like-Behavior.md'>Docker s Blackhole Like Behavior</a> <a rel='next' id='fnext' href='#blog/2018/2018-12-16-Cryptsetup-in-Plain-Mode.md'>Cryptsetup in Plain Mode</a></ins>
