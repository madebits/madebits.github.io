#Installing Ubuntu 18.10

2019-01-23

<!--- tags: linux -->

I gave Ubuntu 18.10 a try in VirtualBox and here is a summary of some of the things I had to do, for own reference.

##Remove Swap Partition

Installer gave me errors when I tried to modify partitions of default encrypted disk setup. I am not really sure how much control installer offers to fine-tune that, and I ended up with using defaults. 

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

Fortunately, removal after installation is easy:

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
resize2fs /dev/ubuntu-vg/root 

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

##GNOME

I have still to find someone that can use GNome as it is out of the box. So first things first:

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

Not having used GNOME in a while, I had to remind myself of *Windows+A* [shortcut](https://wiki.gnome.org/Design/OS/KeyboardShortcuts) to open applications.

##Other Useful Tools

I did a minimal Ubuntu install. I am so happy they offer that, as in the past I had to un-install most of things. I installed some initial set of tools to get started:

```bash
sudo apt remove --purge ubuntu-report 
# please fire the dev that stored configuration in ~/.cache ($XDG_CONFIG_HOME ?)
# was the new intern in the team the only one that agreed to implement ubuntu-report?

sudo apt install synaptic
sudo apt install gnome-tweaks
sudo apt install gnome-system-tools
sudo apt install menulibre
sudo apt install faenza-icon-theme # I am used to those icons, rest confuses me
sudo apt install chromium-browser
# with flags
# --incognito --disk-cache-dir=/dev/null --disk-cache-size=1 -start-maximized --enable-dom-distiller
```

I can go on with the rest of my system specific configuration.

##Ah, Snap :(

I have nothing against [snap](https://snapcraft.io/). I think it gives a whole class of users choice. I have a problem, when that choice is not there. Here I am, with a newly installed Ubuntu and I have not installed anything using `snap` on my own. Just what was there and software from official repositories (`deb` packages). What I see is `snap` already taking over:

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

My expectation would be there is nothing using `snap` in a fresh system using only software from official repositories.

There is one more very disturbing thing to complain. Someone designs `snap` to use `squashfs` and now each *snap* needs a `loop` device. Suddenly, people end up seeing a lot of `loop` devices in system, even those that do not use `snap` like me. This is real nuisance for something that is expected to take world over.

And what do they do? In place of fixing the root of problem and come with something better, they are starting to [modify](https://bugs.launchpad.net/ubuntu/+source/gnome-disk-utility/+bug/1637984) GNOME desktop UI tools now, such `gnome-disks` not to list snap `loop` devices. An initial bad decision, is followed by even more bad decisions to cover up the initial bad one. What about *GNU coreutils*, will they hack them too? What about all third party software (e.g. *VeraCrypt*)? Oh, they compiled its code in GNOME too, next one in the list?

##Summary

Apart of GNOME taskbar, which I really do not like, as it consumes the limited vertical space on screen:

* you cannot move it right or left; 
* auto-hide is not so easy to use within VirtualBox;
* if you are used with free vertical space from other environments, it is hard to accept lack of that option;

I think with minor tweaks, Ubuntu 18.10 UI is usable, without having to install some other desktop variant. The overall UI direction looks ok, I can imagine using next LTS release UI as default desktop. Thought, I expect to see more crap like `snap` and `ubuntu-report` being added there by default.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2019/2019-01-24-Docker-s-Blackhole-Like-Behavior.md'>Docker s Blackhole Like Behavior</a> <a rel='next' id='fnext' href='#blog/2018/2018-12-16-Cryptsetup-in-Plain-Mode.md'>Cryptsetup in Plain Mode</a></ins>
