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
sudo apt install synaptic
sudo apt install gnome-tweaks
sudo apt install gnome-system-tools
sudo apt install menulibre
sudo apt install faenza-icon-theme # I am used to those icons, rest confuses me
sudo apt install chromium-browser
# --incognito --enable-dom-distiller
```

I can go on with rest of my specific configuration.

##Summary

Apart of GNOME taskbar, which I really do not like, as it consumes the limited vertical space on screen:

* you cannot move it right or left; 
* auto-hide is not so easy to use within VirtualBox;
* if you are used with free vertical space from other environments, it is hard to accept lack of that option;

I think with minor tweaks, Ubuntu 18.10 UI is usable, without having to install some other desktop variant. The overall UI direction looks ok, I can imagine using next LTS release as default desktop.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2019/2019-01-24-Docker-s-Blackhole-Like-Behavior.md'>Docker s Blackhole Like Behavior</a> <a rel='next' id='fnext' href='#blog/2018/2018-12-16-Cryptsetup-in-Plain-Mode.md'>Cryptsetup in Plain Mode</a></ins>
