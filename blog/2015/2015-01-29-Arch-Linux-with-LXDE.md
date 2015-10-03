#Arch Linux with LXDE

2015-01-29

<!--- tags: linux -->

I often read Arch Linux [wiki](https://wiki.archlinux.org/) to figure out how to do things on Lubuntu, and at some point I decided to give Arch Linux a try in VirtualBox using (guess what) [LXDE](https://wiki.archlinux.org/index.php/LXDE) with it.

<div id='toc'></div>

##Basic Installation

I followed more or less the steps listed on an [XCFE](https://www.howtoforge.com/tutorial/arch-linux-installation-with-xfce-desktop/) article. I created a Arch VirtualBox machine, mounted the Arch Linux ISO, and started the VM with the live CD ISO. The detailed steps needed are listed in [Beginners' guide](https://wiki.archlinux.org/index.php/beginners'_guide).

Once booted on the live Arch Linux CD root# command-line prompt, prepare the VM hard disk manually. The steps are same as restoring any Linux system: identify the disk `/dev/sda`, create the needed partitions using you tool of choice such as `fdisk` or `gdisk` (I only use a single partition with no swap, if I need swap space, I like to add it later as swap file as this more flexible). Format the created partitions as needed (`mkfs.ext4 /dev/sda1`).

Edit `nano /etc/pacman.d/mirrorlist` on live CD and use some HTTPS mirrors from https://www.archlinux.org/mirrorlist/all/. Arch is generally less safe compared to other distributions (only core packages are signed), and by default some of repositories are over HTTP (not to mention you need AUR content to do anything meaningful), so run it in a VM instance with limited shared folders access.

Next `mount /dev/sda1 /mnt` (if you have other partitions do same within `/mnt`) and proceed with the base installation `pacstrap /mnt base base-devel`. The most recent packages will be downloaded and installed. Follow the steps in beginners' guide to generate `genfstab /mnt >> /mnt/etc/fstab` file. The next steps need to applied on the target disk, so `arch-chroot /mnt` to enter the chroot environment (the prompt will change). Edit again on the chroot `nano /etc/pacman.d/mirrorlist` on live CD and use some HTTPS mirrors from https://www.archlinux.org/mirrorlist/all/.

Set the system root `passwd`, get grub `pacman -S grub-bios`, install it with `grub-install /dev/sda`, and configure it with `grub-mkconfig -o /boot/grub/grub.cfg`. You may want to set `echo archbox > /etc/hostname` (use any host name in place of *archbox*). Then `exit` the chroot environment, `umount /mnt` and `reboot` removing the CD ISO. Once booted, login as `root` and activate `systemctl enable dhcpcd` and reboot again. For 64 bit systems you want to enable installing on 32 bit applications [too](https://wiki.archlinux.org/index.php/official_repositories#multilib), so edit `nano /etc/pacman.conf` and uncomment `[multilib]` and `Include = /etc/pacman.d/mirrorlist` lines. Update sources using `sudo pacman -Syy`. Then set the locale as shown in [Beginners' guide](https://wiki.archlinux.org/index.php/beginners'_guide).

Before adding a user, uncomment `%wheel ALL=(ALL) ALL` using `EDITOR=nano visudo`. Then add `useradd -m -g users -G adm,storage,power,wheel,systemd-journal -s /bin/bash "username"` and set its `passwd "username"`. To enable bash TAB completion install `pacman -S bash-completion`.

##Adding LXDE Desktop

To get [LXDE](http://www.archlinuxuser.com/2013/01/how-to-install-lxde-desktop-on-archlinux.html), install first X server: `pacman -S xorg-server xorg-xinit xorg-utils xorg-server-utils` and then the VirtualBox guest-additions `pacman -S virtualbox-guest-utils`. Then install `pacman -S lxde lxdm leafpad` and enable the GUI logins using `systemctl enable lxdm.service`. Reboot and you will be able to login as "username" in LXDM GUI. Add your created user to `usermod -a -G vboxsf "username"` for [automounting](https://wiki.archlinux.org/index.php/VirtualBox#Automounting) and [start](https://wiki.archlinux.org/index.php/VirtualBox#Load_the_Virtualbox_kernel_modules_2) `systemctl enable vboxservice`. Create also as root: `mkdir /media`.

If everything is ok, you will have a basic LXDE system that may look a bit ugly at first, if you have ever seen Lubuntu before. You have to customize it a bit, but before you do it, install [yaourt](https://wiki.archlinux.org/index.php/yaourt) that helps install packages for user repositories [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository#Installing_packages). I have written some command-line tools with cryptic options myself, so pacman looks familiar to me - check the `man` page or Arch Linux [wiki](https://wiki.archlinux.org/) to use it effectively. You may also decide to install some pacman [GUI](https://wiki.archlinux.org/index.php/Graphical_pacman_frontends), such as, `yaourt pamac-aur` or `yaourt octopi` (octopi looks better to me, but it somehow installs also some Qt development stuff that is not really needed). For `octopi`, I had to edit `sudo leafpad /usr/share/applications/octopi.desktop` and delete the `Path=` line there for the shortcut to work. Install also `sudo pacman -S gksu gnome-keyring` as it used by some of these tools.

##LXDE Customization

[box-theme](https://aur.archlinux.org/packages/box-theme/) did not work for me. I [zipped](blog/images/Lubuntu-default.tar.gz) `/usr/share/themes/Lubuntu-default` folder from my Lubuntu 14.04 installation and then copied and unzipped it on same location on the Arch installation. [http://lubuntublog.blogspot.de/p/artwork.html](Latest) Box theme can also be used. You need to install [GTK](https://wiki.archlinux.org/index.php/GTK%2B) theme engines `sudo pacman -S gtk-engines gtk-engine-murrine gtk-engine-unico`. Then I applied Lubuntu-default theme using `lxappearance`. Install `sudo pacman -S obconf` for extra OpenBox configuration. Install `pacman -S community/ttf-ubuntu-font-family` and apply the Ubuntu font using `lxappearance`. Install also at least `yaourt ttf-ms-fonts` and `xorg-fonts-100dpi` (also `ttf-vista-fonts` can be of use). Run `sudo fc-cache` when done to rebuild the fonts cache. For a web browser, install `yaourt firefox`. I installed also `chromium` and `chromium-pepper-flash-standalone` for flash support. I like to use [faenza-icon-theme](https://www.archlinux.org/packages/community/any/faenza-icon-theme/) with LXDE and my own LXDE menu icon ![inline](blog/images/menu.png). Install also `xscreensaver` and `file-roller` for a UI compression tool. For mouse cursors, you may use `xcursor-vanilla-dmz` package. Finally, get some nice Arch Linux wallpaper :). This configuration uses around 1.7 GB disk space (clean `/var/cache/pacman/pkg`). Based on [GTK+](https://wiki.archlinux.org/index.php/GTK%2B) entry I added the following in `~/.config/gtk-3.0/gtk.css` to get latest GTK3 kind of work with OpenBox (Update: GTK+ changes often, so this is not working anymore):

```
.window-frame {
  border-color: #808080;
  border-width: 1px;
  border-style: solid;
  /* border:none; */
  border-radius: 0;
  margin: 1px; /* resize cursor area */
}

.titlebar {
  border-radius: 0;
}
```

To set default theme for [Qt](https://wiki.archlinux.org/index.php/Uniform_Look_for_Qt_and_GTK_Applications#Styles_for_both_Qt_and_GTK.2B) applications (such as, `speedcrunch` or `vlc`), I used `qtconfig-qt4` with GTK+ theme, and added in `.bashrc` a line with ```export QT_STYLE_OVERRIDE=gtk```.

To install my custom PcManFm [actions](#r/linux-pcmanfm-actions.md), I download the .deb package and got out of it `data.tar.gz` and from that I copied all files of `opt` and `usr` folders as `sudo` on same locations on the arch system. Then I installed via `yaourt` two needed packages `extra/zenity` and `trash-cli`. After a logout and login the custom actions were there.

Add `export HISTCONTROL=ignoreboth' to `.bashrc`.

##Optional Services

To set up [zramswap](https://aur.archlinux.org/packages/zramswap/), use `yaourt zramswap` and then `sudo systemctl enable zramswap` and `systemctl start zramswap`. I installed also [NetworkManager](https://wiki.archlinux.org/index.php/NetworkManager), which I do not really needed in VirtualBox, but I wanted just to test it. The I ran `systemctl disable dhcpcd` and `systemctl enable NetworkManager.service` (and rebooted).

The process tree looks now like:

```
systemd
  ├─NetworkManager --no-daemon
  │   ├─dhclient -d -q -sf /usr/lib/networkmanager/nm-dhcp-helper -pf/var/run/
  │   ├─{NetworkManager}
  │   ├─{gdbus}
  │   └─{gmain}
  ├─VBoxClient --clipboard
  │   └─{SHCLIP}
  ├─VBoxClient --display
  │   └─{X11 monitor}
  ├─VBoxClient --seamless
  │   └─{Host events}
  ├─VBoxClient --draganddrop
  │   ├─{HGCM-NOTIFY}
  │   └─{X11-NOTIFY}
  ├─at-spi-bus-laun
  │   ├─dbus-daemon --config-file=/etc/at-spi2/accessibility.conf --nofork--pr
  │   ├─{dconf worker}
  │   ├─{gdbus}
  │   └─{gmain}
  ├─at-spi2-registr --use-gnome-session
  │   └─{gdbus}
  ├─dbus-daemon --system --address=systemd: --nofork --nopidfile--systemd-
  ├─dbus-daemon --fork --print-pid 5 --print-address 7 --session
  ├─dbus-launch --sh-syntax --exit-with-session
  ├─gconfd-2
  ├─gnome-keyring-d --daemonize --login
  │   └─{gmain}
  ├─gnome-keyring-d --daemonize --login
  │   └─{gmain}
  ├─lxdm-binary
  │   ├─Xorg.bin -background none :0 vt01 -nolisten tcp -novtswitch
  │   │   └─2*[{Xorg.bin}]
  │   └─lxdm-session
  │       └─lxsession -s LXDE -e LXDE
  │           ├─lxclipboard
  │           ├─lxpanel --profile LXDE
  │           │   ├─{gmain}
  │           │   └─{menu-cache-io}
  │           ├─lxpolkit
  │           │   └─{gdbus}
  │           ├─openbox --config-file /home/user/.config/openbox/lxde-rc.xml
  │           ├─pcmanfm --desktop --profile LXDE
  │           │   └─{gmain}
  │           ├─xscreensaver -no-splash
  │           ├─{gdbus}
  │           └─{gmain}
  ├─menu-cached /tmp/.menu-cached-:0-user
  │   └─{gmain}
  ├─nm-applet
  │   ├─{dconf worker}
  │   └─{gdbus}
  ├─octopi-notifier
  │   ├─{QInotifyFileSys}
  │   └─{QProcessManager}
  ├─polkitd --no-debug
  │   ├─{JS GC Helper}
  │   ├─{JS Sour~ Thread}
  │   ├─{gdbus}
  │   ├─{gmain}
  │   └─{runaway-killer-}
  ├─pulseaudio --start
  │   ├─gconf-helper
  │   ├─{alsa-sink-Intel}
  │   └─{alsa-source-Int}
  ├─rtkit-daemon
  │   └─2*[{rtkit-daemon}]
  ├─sublime_text
  │   ├─plugin_host 678
  │   │   ├─{process_status}
  │   │   ├─{shm_reader}
  │   │   └─{thread_queue}
  │   ├─{gdbus}
  │   ├─2*[{io_worker}]
  │   ├─{process_status}
  │   ├─{shm_reader}
  │   └─{thread_queue}
  ├─systemd --user
  │   └─(sd-pam)  
  ├─systemd-journal
  ├─systemd-logind
  └─systemd-udevd
```

Followed by `systemd-cgls` output (or use `systemctl status`):

```
├─1 /sbin/init
├─system.slice
│ ├─dbus.service
│ │ └─163 /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation
│ ├─lxdm.service
│ │ ├─184 /usr/sbin/lxdm-binary
│ │ └─211 /usr/bin/Xorg.bin -background none :0 vt01 -nolisten tcp -novtswitch
│ ├─systemd-journald.service
│ │ └─131 /usr/lib/systemd/systemd-journald
│ ├─udisks2.service
│ │ └─347 /usr/lib/udisks2/udisksd --no-debug
│ ├─systemd-logind.service
│ │ └─180 /usr/lib/systemd/systemd-logind
│ ├─systemd-udevd.service
│ │ └─152 /usr/lib/systemd/systemd-udevd
│ ├─polkit.service
│ │ └─222 /usr/lib/polkit-1/polkitd --no-debug
│ ├─NetworkManager.service
│ │ ├─179 /usr/bin/NetworkManager --no-daemon
│ │ └─232 /usr/bin/dhclient -d -q -sf /usr/lib/networkmanager/nm-dhcp-helper -pf /var/run/dhclient-enp0s3.pid -lf /var/lib/NetworkManager/dhclient-75caf6e1-b892-4a2f-9f09-c730aa013c35-enp0s3.lease -cf /var/lib/NetworkManager/dhclient-enp0s3.conf enp0s3
│ ├─vboxservice.service
│ │ └─192 /usr/bin/VBoxService -f
│ └─rtkit-daemon.service
│   └─401 /usr/lib/rtkit/rtkit-daemon
└─user.slice
  └─user-1000.slice
    ├─user@1000.service
    │ ├─286 /usr/lib/systemd/systemd --user
    │ └─287 (sd-pam)  
    └─session-c1.scope
      ├─285 /usr/lib/lxdm/lxdm-session
      ├─293 /usr/bin/lxsession -s LXDE -e LXDE
      ├─303 dbus-launch --sh-syntax --exit-with-session
      ├─304 /usr/bin/dbus-daemon --fork --print-pid 5 --print-address 7 --session
      ├─310 /usr/lib/gvfs/gvfsd
      ├─314 /usr/lib/gvfs/gvfsd-fuse /run/user/1000/gvfs -f -o big_writes
      ├─328 openbox --config-file /home/user/.config/openbox/lxde-rc.xml
      ├─330 lxpolkit
      ├─331 lxpanel --profile LXDE
      ├─333 pcmanfm --desktop --profile LXDE
      ├─334 xscreensaver -no-splash
      ├─336 lxclipboard
      ├─343 /usr/lib/gvfs/gvfs-udisks2-volume-monitor
      ├─355 nm-applet
      ├─363 /usr/bin/VBoxClient --clipboard
      ├─366 octopi-notifier
      ├─379 /usr/bin/VBoxClient --display
      ├─386 /usr/bin/VBoxClient --seamless
      ├─392 /usr/bin/VBoxClient --draganddrop
      ├─398 /usr/lib/at-spi2-core/at-spi-bus-launcher
      ├─399 /usr/bin/pulseaudio --start
      ├─406 /usr/bin/dbus-daemon --config-file=/etc/at-spi2/accessibility.conf --nofork --print-address 3
      ├─416 /usr/lib/at-spi2-core/at-spi2-registryd --use-gnome-session
      ├─417 /usr/lib/menu-cache/menu-cached /tmp/.menu-cached-:0-user
      ├─423 /usr/lib/gvfs/gvfsd-trash --spawner :1.1 /org/gtk/gvfs/exec_spaw/0
      ├─431 /usr/lib/GConf/gconfd-2
      ├─433 /usr/lib/pulse/gconf-helper
      ├─476 lxterminal
      ├─477 gnome-pty-helper
      ├─478 /bin/bash
      ├─593 /usr/lib/gvfs/gvfsd-metadata
      ├─647 /bin/bash
      └─649 systemd-cgls --no-pager -l
```


##Systemd Related Changes

It [seems](https://bugzilla.redhat.com/show_bug.cgi?id=905612) systemd people do not want to add a shorter alias to the `systemctl` command by default. If you want to add one on your own, append to `~/.bashrc` the [following](http://stackoverflow.com/questions/20032764/how-to-use-bash-completion-functions-that-are-defined-on-the-fly):
    
```bash
alias sc="systemctl"
_completion_loader systemctl
complete -F _systemctl systemctl sc
```
Now you can use `sc` in place of `systemctl`, e.g., to shutdown the machine use `sc po<TAB><ENTER>`.

One tip, I think could be useful, is to create a [rc.local](http://superuser.com/questions/278396/systemd-does-not-run-etc-rc-local) service [clone](http://notes.ponderworthy.com/rclocal-in-arch-linux-systemd). The `/etc/rc.local` (owned by root and executable):

```bash
#!/bin/sh -e
# add content here:

#do not remove
exit 0
```

And the systemd `/etc/systemd/system/rc-local.service` unit:

```
[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
```

systemd journal is persistent by default. To [change](http://www.freedesktop.org/software/systemd/man/journald.conf.html) that, edit `/etc/systemd/journald.conf` and set `Storage=volatile`. Then `sudo systemctl restart systemd-journald.service` and delete as root `/var/log/journal`.

To disable kernel code dumps, edit '/etc/systemd/coredump.conf' and set `Storage=none`.

##Temp Folder

I [remounted](https://wiki.archlinux.org/index.php/Tmpfs) some paths in `/etc/fstab`, to remove extra rights:

```
none /tmp tmpfs defaults,nodev,nosuid,noexec 0 0
none /var/tmp tmpfs defaults,nodev,nosuid,noexec 0 0
```

The `/tmp` one causes problems with some AUR `PKGBUILD` files that try to execute from `/tmp`. If you [run](https://bbs.archlinux.org/viewtopic.php?id=189625) into that, then temporary run (check result with `mount | column -t`):

```
sudo mount -o remount,exec tmpfs /tmp
#... install problematic package here
sudo mount -o remount,defaults,nodev,nosuid,noexec tmpfs /tmp
```

##Maintenance

Arch needs continuous maintenance to remain on the latest state (whole system is [updated](https://wiki.archlinux.org/index.php/Pacman#Upgrading_packages) using `pacman -Syu`, and AUR packages [using](https://wiki.archlinux.org/index.php/Yaourt) `yaourt -Syua`). To find whether some libraries in use have been deleted [use](http://unix.stackexchange.com/questions/75503/should-i-restart-after-a-pacman-upgrade) `sudo lsof +c 0 -d DEL | grep '.*lib'` (you have to install `lsof` before). The list of installed packages can be [obtained](https://wiki.archlinux.org/index.php/Pacman_tips) using `pacman -Qqe`.

Arch installed packages files are cached in `/var/cache/pacman/pkg`. Given Arch keeps only the latest version of a package in its official repositories the files in this folder can be used to [recover](https://wiki.archlinux.org/index.php/Downgrading_packages#Official_packages) your system if something goes wrong with a new update. If you clean up this folder to save space, you can use [ARM](https://wiki.archlinux.org/index.php/Arch_Rollback_Machine) to find and download older package files (use `pacman -U *.pkg.tar.gz` to downgrade a package from its file). To ignore these packages from updates edit `/etc/pacman.conf` and add them to `IgnorePkg=` line(s).

If you add [unofficial keys](https://wiki.archlinux.org/index.php/Pacman-key#Adding_unofficial_keys) custom keys in pacman keyring, as for example to install [infinality-bundle](https://wiki.archlinux.org/index.php/Infinality), you may get an error: `gpg: connecting dirmngr at '/root/.gnupg/S.dirmngr' failed:`. To [fix](https://bbs.archlinux.org/viewtopic.php?id=190380) it create the following folder if it does not exist: `sudo mkdir /root/.gnupg/`.

##More Packages to Install

* Install `ed` the only real line editor :), this is needed by some other packages.

* To receive desktop [notifications](http://askubuntu.com/questions/216726/what-is-the-application-that-displays-notifications-in-lubuntu-12-04-and-how-to), I installed `xfce4-notifyd`, and edited `/usr/share/applications/xfce4-notifyd-config.desktop` to remove `OnlyShowIn=XFCE;` line, so that the configuration application shows up on the Preferences menu.

* To enable a window composite manager, I installed [compton](https://wiki.archlinux.org/index.php/Compton) and added `@compton -b` in `~/.config/lxsession/LXDE/autostart` (to comment lines there prefix them with `!@`). It seems compton has some [issue](https://github.com/chjj/compton/issues/189) with some GTK3 application borders, such as, `file-roller`.

* To set [timezone](https://wiki.archlinux.org/index.php/Time#Time_zone) I used `timedatectl set-timezone Europe/Berlin` and [installed](https://wiki.archlinux.org/index.php/Network_Time_Protocol_daemon#Installation) `ntp`.

* I installed also `git` (and `tk` package for gitk) and Sublime Text 3, so now I can update this blog from the Arch installation too.

* `dnsutils` contains things like `dig` and `host`.

* `seahorse` to manage gnome-keyring and edit `~/.bashrc` to add `unset SSH_ASKPASS`.

* If not using IPv6, you can [disable](https://wiki.archlinux.org/index.php/IPv6#Disable_IPv6) it.

##Chromium Browser Flags

It seems Arch does not support [anymore](https://wiki.archlinux.org/index.php/Chromium_tweaks#Making_Flags_Persistent) `/etc/chromium/default`, but has replaced it by default with per user configuration in `$XDG_CONFIG_HOME/chromium-flags.conf` (one flag per line). These are some of the flags I use:

```
--disk-cache-dir=/dev/null
--disk-cache-size=1
--incognito 
--start-maximized 
--user-data-dir=/home/user/Encfs/Private/Chromium
--touch-devices=123
```

Last one is a [workaround](https://code.google.com/p/chromium/issues/detail?id=456222) for mouse support.

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-02-26-Useful-Browser-Extensions.md'>Useful Browser Extensions</a> <a id='fnext' href='#blog/2015/2015-01-15-Clustering-People.md'>Clustering People</a></ins>
