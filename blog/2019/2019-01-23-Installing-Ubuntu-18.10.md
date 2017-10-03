#Installing Ubuntu 18.10

2019-01-23

<!--- tags: linux -->

I gave [Ubuntu](https://blog.ubuntu.com/) 18.10 a try in VirtualBox and 18.04 in a machine and here is a summary of some of the things I had to do, for own reference.

<div id='toc'></div>

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

##Encrypted Disk Layout Details

The [/dev/sda2](https://askubuntu.com/questions/950307/why-guided-partitioning-create-a-sda2-of-1-kb) is the extended partition. What is shown as *1K* is the [unaligned](https://unix.stackexchange.com/questions/128290/what-is-this-1k-logical-partition) area in it.

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

###Changing LUKS Password

To change disk [password](https://askubuntu.com/questions/109898/how-to-change-the-password-of-an-encrypted-lvm-system-done-with-the-alternate-i), either use `sudo gnome-disks` or:

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

I have still to find someone that can use [GNOME](https://wiki.archlinux.org/index.php/GNOME) as it is out of the box. So first things first:

```bash
sudo apt-get update
sudo apt install chrome-gnome-shell
```

On Firefox, installed [GNOME Shell Integration](https://addons.mozilla.org/en-US/firefox/addon/gnome-shell-integration/). Next, I installed a minimum set of [GNOME extensions](https://extensions.gnome.org/local/).

Not having used GNOME in a while, I had to remind myself of *Windows+A* [shortcut](https://wiki.gnome.org/Design/OS/KeyboardShortcuts) to open applications.

###Minimal Selection of GNOME Extensions

* Dash to Panel https://extensions.gnome.org/extension/1160/dash-to-panel/
    I can live with this one only

* SysPeek-GS https://extensions.gnome.org/extension/1409/syspeek-gs/

    This extension expects in its source code that there is an application `gnome-system-monitor.desktop` which is not there due to being installed as snap, so I had to do the following: 

    ```
    sudo cp /var/lib/snapd/desktop/applications/gnome-system-monitor_gnome-system-monitor.desktop /usr/share/applications/gnome-system-monitor.desktop
    ```

* Gno-Menu https://extensions.gnome.org/extension/608/gnomenu/

* Panel-OSD https://extensions.gnome.org/extension/708/panel-osd/
    After working on first run, its state is ERROR now

* AlternateTab https://extensions.gnome.org/extension/15/alternatetab/

###GNOME Files

Some [nautilus](https://wiki.archlinux.org/index.php/GNOME/Files) shortcuts:

*  Ctrl+Shift+N new folder
*  Ctrl+L edit address bar
*  Ctrl+T new tab
*  Ctrl+Q or Ctrl+W close (tab)
*  Ctrl+R of F5 refresh
*  Ctrl+F find, Ctrl+S select, Ctrl+A select all
*  Ctrl+H toggle hidden files

Extra setup:

*  `touch ~/Templates/New.txt` for text file templates
* [folder-color](http://foldercolor.tuxfamily.org/) `sudo apt install folder-color`
* `nautilus -q` to quit instances
* To have `nautilus` generate video [thumbnails](https://askubuntu.com/questions/2608/nautilus-video-thumbnails-without-totem), I installed `sudo apt install ffmpegthumbnailer` (though [mpv](https://github.com/mpv-player/mpv/issues/3735) can also be used). It created `/usr/share/thumbnailers/ffmpegthumbnailer.thumbnailer` file with the following content:

    ```
    [Thumbnailer Entry]
    TryExec=ffmpegthumbnailer
    Exec=ffmpegthumbnailer -i %i -o %o -s %s -f
    MimeType=video/jpeg;video/mp4;video/mpeg;video/quicktime;video/x-ms-asf;video/x-ms-wm;video/x-ms-wmv;video/x-msvideo;video/x-flv;video/x-matroska;video/webm;video/mp2t;
    ```
* https://github.com/flozz/nautilus-terminal
* User [scripts](https://wiki.ubuntuusers.de/Nautilus/Skripte/) can be put in `~/.local/share/nautilus/scripts/` folder.

###Hacks

* GEdit and other GNOME programs was showing *'Preferences'* menu only if run with *sudo*. I had to [run](https://askubuntu.com/questions/375049/where-are-gedits-preferences/671398#671398):

    ```
    gsettings set org.gnome.settings-daemon.plugins.xsettings overrides '@a{sv} {"Gtk/ShellShowsAppMenu": <int32 0>}'
    ```

* `gedit` fails to show [last](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=826278) lines sometimes (cannot scroll to end of file). Will use `geany -i` for [text](https://askubuntu.com/questions/13447/how-do-i-change-the-default-text-editor) edits.
    - *[workaround](https://gitlab.gnome.org/GNOME/gedit/issues/42) is to unmaximize and then maximize the window again*
    - [geany-themes](https://github.com/codebrainz/geany-themes)

* VirtualBox mouse was freezing. I found a [solution](https://ubuntuforums.org/showthread.php?t=2395969) that seems to work: *Go into the preferences of your VirtualBox Manager. Click on "Input" and make sure that "Auto Capture Keyboard" is not selected for "VirtualBox Manager" and "Virtual Machine".*

* `gthumb` had a dark theme, ignoring system theme. I had to edit its [desktop](https://askubuntu.com/questions/1017886/gthumb-version-3-4-3-with-light-background-colors-in-menus-and-browser-like) file: 

    ```
    Exec=env GTK_THEME=Ambiance:light gthumb %U
    ```

* The frequent apps list is in `~/.local/share/gnome-shell/application_state`.

* If GNOME shell [freezes](https://wiki.archlinux.org/index.php/GNOME/Troubleshooting#Shell_freezes), type `Ctrl+Alt+F3`, login and run `pkill -HUP gnome-shell`.

* I copied *ttf* [fonts](https://askubuntu.com/questions/3697/how-do-i-install-fonts) from a Windows VM to `~/.local/share/fonts`.

* Graphical `update-manager` was closing after update check. I had to clean all files in `/var/lib/apt/lists` and run `sudo apt update` to fix the issue.

* `eog` is not ok for me as mouse wheel does not work as I would like to. I `sudo apt install feh`, and create a `$HOME/bin/feh.sh` file:

    ```bash
    #!/bin/bash -

    cmd="feh -F -B white --no-recursive --auto-rotate --draw-filename --hide-pointer --auto-zoom"
    path="${1:-.}"
    if [ -d "$path" ]; then
        exec $cmd "$path"
    elif [ -e "$path" ]; then
        file=$(realpath -- "$path")
        dir=$(dirname -- "$file")

        exec $cmd "$dir" --start-at "$file"
    fi
    ```

    The above was my first try. However, `feh` in Ubuntu repos is a bit old and does not support numeric sorting. I got a [newer](https://debian.pkgs.org/10/debian-main-amd64/feh_3.1.1-1_amd64.deb.html) copy and then my script looked as follows:

    ```bash
    #!/bin/bash -

    cmd="$HOME/bin/feh/feh -C $HOME/.local/share/fonts/ -e arial/10 -M arial/10 -F -B white --no-recursive --auto-rotate --draw-filename --hide-pointer --auto-zoom --sort name --version-sort"
    path="${1:-.}"
    if [ -d "$path" ]; then
        exec $cmd "$path"
    elif [ -e "$path" ]; then
        file=$(realpath -- "$path")
        dir=$(dirname -- "$file")

        $cmd "$dir" --start-at "$file"
    fi
    ```
    
    And added `HOME/.local/share/applications/feh.desktop` file:

    ```
    [Desktop Entry]
    Value=1.0
    Encoding=UTF-8
    Terminal=0
    TryExec=/home/user/bin/feh.sh
    Exec=/home/user/bin/feh.sh %F
    Icon=/home/user/bin/feh/feh.png
    Type=Application
    Categories=Graphics;
    StartupNotify=false
    Name=Feh
    GenericName=XnViewMP
    MimeType=image/bmp;image/jpeg;image/png;image/tiff;image/gif;
    ```

    Then in GNome Files, I made it default for images (using *Properties* menu).

##First Tools

I did a minimal Ubuntu install. I am happy they offer that, as in the past I had to un-install most of things. I installed some initial set of tools to get started:

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

Got an error from `synaptic` (*W: Download is performed unsandboxed as root as file '/root/.synaptic/tmp//tmp_sh' couldn't be accessed by user '_apt'.*) and had to [run](https://bugs.launchpad.net/ubuntu/+source/aptitude/+bug/1543280):

```
adduser --force-badname --system --home /nonexistent \
--no-create-home --quiet _apt || true

if dpkg --compare-versions "$2" lt-nl 1.1~exp10~; then
usermod --home /nonexistent _apt
fi
```

*Update*: I think, that warning come because, I run `synaptic` via `sudo` once. To [fix](https://askubuntu.com/questions/908800/what-does-this-synaptic-error-message-mean) it, I had also to run `sudo chmod -Rv 755 /root/.synaptic/tmp`.

##Snap

There seems to be a [decision](https://askubuntu.com/questions/1039968/why-have-canonical-installed-core-gnome-apps-as-snaps-by-default) to deliver parts of desktop as [snaps](https://snapcraft.io/) by default to update them cleaner in the future. `snap` is already active for GNOME parts:

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

Someone [designed](https://docs.snapcraft.io/) `snap` to use `squashfs` and now each *snap* needs a `loop` device. Ubuntu developers are starting to [modify](https://bugs.launchpad.net/ubuntu/+source/gnome-disk-utility/+bug/1637984) GNOME desktop UI tools now, such as `gnome-disks`, not to list snap `loop` devices. `HOME/snap` is the [folder](https://askubuntu.com/questions/882562/how-can-i-change-or-hide-the-snap-directory) where snaps are mapped.

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

##Final Steps

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

* Useful software: `sudo apt install mpv vlc audacious speedcrunch keepassxc baobab`.

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

##GNOME Eating CPU

Even without doing anything `gnome-shell` [eats](https://bugs.launchpad.net/ubuntu/+source/gnome-shell/+bug/1773959) some small percent of CPU, doing something with some socket:

```
$ sudo strace -c -p $(pgrep gnome-shell$)
strace: Process 2252 attached
strace: [ Process PID=2252 runs in x32 mode. ]
strace: [ Process PID=2252 runs in 64 bit mode. ]
^Cstrace: Process 2252 detached
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 41.11    0.033921           2     22549     21055 recvmsg
 40.60    0.033497           6      6015           poll
  9.28    0.007655           5      1535           writev
  5.86    0.004835           3      1466           write
  2.31    0.001906           2       771           read
  0.30    0.000249           1       287           getpid
  0.19    0.000155           0       550           mprotect
  0.19    0.000155          26         6           shmdt
  0.07    0.000061           0       131           futex
  0.04    0.000037           2        17         8 openat
  0.01    0.000010           0        66        33 recvfrom
  0.01    0.000006           0        15           fstat
  0.01    0.000005           1         6           getrusage
  0.00    0.000004           1         8           close
  0.00    0.000002           0        12           shmctl
  0.00    0.000002           2         1           clone
  0.00    0.000002           0         7           uname
  0.00    0.000002           0         7           fcntl
  0.00    0.000001           0         6           shmat
  0.00    0.000001           1         1           fchmod
  0.00    0.000001           1         1           fchown
  0.00    0.000000           0       270       240 stat
  0.00    0.000000           0         7           mmap
  0.00    0.000000           0         6           shmget
------ ----------- ----------- --------- --------- ----------------
100.00    0.082507                 33740     21336 total

```

This does not help with battery life. 

###i3wm

I decided to co-install `sudo apt install i3`. It is not [first](#blog/2014/2014-02-04-Using-i3wm-on-Lubuntu.md) time I use [i3](https://plus.google.com/communities/112960345026405927743) and I do not really [like](http://xahlee.info/linux/why_tiling_window_manager_sucks.html) it, but it is very low resource and for that purpose ideal if battery life is important.

####i3

* [$HOME/.config/i3/config](./blog/2019/i3/i3/config)
* [$HOME/.config/i3/start.sh](./blog/2019/i3/i3/start.sh)
* [$HOME/.config/i3/battery.sh](./blog/2019/i3/i3/battery.sh)
* * [$HOME/.config/i3/gnome-kill.sh](./blog/2019/i3/i3/gnome-kill.sh)
* [$HOME/.config/i3/rofi_custom.sh](./blog/2019/i3/i3/rofi_custom.sh)
* [$HOME/.config/i3/term.sh](./blog/2019/i3/i3/term.sh)
* [$HOME/.config/i3/.Xresources](./blog/2019/i3/i3/.Xresources) - this is more or less same as in [here](https://github.com/briancaffey/.i3)
* [$HOME/.config/i3status/config](./blog/2019/i3/i3status/config)

####GTK

* [$HOME/.gtkrc-2.0](./blog/2019/i3/gtk/.gtkrc-2.0)
* [$HOME/.config/gtk-3.0/settings.ini](./blog/2019/i3/gtk/settings.ini)

####Tools

* [$HOME/.config/ranger/rc.conf](./blog/2019/i3/ranger/rc.conf)
* [$HOME/.config/ranger/rifle.conf](./blog/2019/i3/ranger/rifle.conf)
* [$HOME/.config/ranger/scope.sh](./blog/2019/i3/ranger/scope.sh)
* [$HOME/.config/rofi/config](./blog/2019/i3/rofi/config)

####Notifications

* [$HOME/.config/dunst/dunstrc](./blog/2019/i3/dunst/dunstrc)

####Screen Brightness

I learned something about [brightness](https://unix.stackexchange.com/questions/322814/xf86monbrightnessup-xf86monbrightnessdown-special-keys-not-working) handling for Intel:

* [/etc/acpi/actions/bl-down.sh](./blog/2019/i3/acpi/actions/bl-down.sh)
* [/etc/acpi/actions/bl-up.sh](./blog/2019/i3/acpi/actions/bl-up.sh)
* [/etc/acpi/actions/bl-status.sh](./blog/2019/i3/acpi/actions/bl-status.sh)
* [/etc/acpi/events/bl-down](./blog/2019/i3/acpi/events/bl-down)
* [/etc/acpi/events/bl-up](./blog/2019/i3/acpi/events/bl-up)

####Other

* [/etc/polkit-1/localauthority/50-local.d/com.ubuntu.disable-suspend.pkla](./blog/2019/i3/com.ubuntu.disable-suspend.pkla) - disable [suspend](https://askubuntu.com/questions/972114/ubuntu-17-10-cant-disable-suspend-with-systemd-hybrid-sleep)
* `HOME/.bashrc` changes:

    ```
    export TERMINAL=xterm
    # show current command in title https://unix.stackexchange.com/questions/104018/set-dynamic-window-title-based-on-command-input
    trap 'echo -ne "\033]0;$BASH_COMMAND\007"' DEBUG
    if [ "$XDG_SESSION_DESKTOP" = "i3" ]; then
        export PAGER="w3m"
    else
        export PAGER="most"
    fi
    ```

    `w3m` works for mouse scroll within `man` in `urxvt`. Within `w3m` the *m* key activates mouse selection to copy text (or pressing *Shift* in `urxvt` allows direct mouse selection in [any](http://nion.modprobe.de/blog/archives/634-copy-paste-in-text-mode-applications.html) console application). *Shift+q* exits `w3m` without confirmation.

* [$HOME/.w3m/keymap](./blog/2019/i3/w3m/keymap)
* To set mouse cursor theme, I [used](https://askubuntu.com/questions/126491/how-do-i-change-the-cursor-and-its-size): `sudo update-alternatives --config x-cursor-theme`.

##Summary

Ubuntu 18.10 UI is usable with minor tweaks without having to install some other desktop variant. GNOME is still full of bugs and consumes more battery than LXDE, but the overall UI is tolerable. I can imagine using next LTS release UI as default desktop. Expect to see more things like `snap` and `ubuntu-report` being added there by default.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2019/2019-01-24-Docker-s-Blackhole-Like-Behavior.md'>Docker s Blackhole Like Behavior</a> <a rel='next' id='fnext' href='#blog/2018/2018-12-16-Cryptsetup-in-Plain-Mode.md'>Cryptsetup in Plain Mode</a></ins>
