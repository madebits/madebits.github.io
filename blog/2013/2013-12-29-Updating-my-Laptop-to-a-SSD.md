#Updating my Laptop to a SSD

2013-12-29

I switched my main laptop from a magnetic hard disk to a Samsung 250GB SSD. As the laptop can only handle one drive, I removed the original drive and put the SSD inside, and re-installed Windows and Lubuntu (on its own partition).

I took care that Windows 7 does not create any recovery partitions during the install, and disabled system recovery, page file, hibernation, volume shadow copy, and windows search. I have no use for these features and they just consume SSD space. I spend some time to install the correct set of hardware drivers. Then after installing the Service Pack 1 (it took only 10 minutes in the SSD) and all window updates, I ran the disk clean up wizard, which freed around of 6GB of data. I use Windows rarely at home (more often I use vpn and rdesktop at my Windows machine at work from Linux), but it is still good to have Windows around locally sometimes.

Lubuntu 13.10 64 bit install went smooth. In less than 5 minutes, I had Lubuntu installed and running. Of course, I spend then a day or so, to customize it as it fits to my needs - but that is part of the fun. I do not use multiple partitions as they just consume disk space, so I only created a root partition (and of course no swap, I have enough RAM).

Despite that I install Lubuntu in English, because of my German keyboard in laptop, Ubuntu sets some of locale settings in /etc/default/locale to German (de) ones, so I had to fix it manually.

The previous hard disk, I connected externally via a USB adapter. I copied all my data to a data NTFS partition. And after removing all the previous other partitions I extended the NTFS data partition to cover the whole disk space. Windows Drive Manager could not handle that, and neither could GParted, but I found some freeware by [EaseUs](http://www.partition-tool.com/personal.htm) that could extend the logical partition while leaving the primary unformatted one to only 1MB in size.

As I rarely move the laptop from my table, I will keep the external hard-disk always connected (the USB adapter turns if off if not in use), and it consumes only one USB port in my hub. I wanted to access the external hard disk from mediatomb service as root, so I mounted it via fstab (using `sudo blkid` to find the UUID). One can use [nobootwait](http://askubuntu.com/questions/120/how-do-i-avoid-the-s-to-skip-message-on-boot) in `/etc/fstab` so that even if the disk is not there I not to get any boot error messages:

```
UUID=36D22C00D22BC2CB	/media/extern	ntfs-3g auto,user,rw,nobootwait 0 0
```

To safely remove external USB devices on Lubuntu, first un-mount any mounted file system from the device, and then [use](http://askubuntu.com/questions/98784/safely-unmount-external-drive-on-lubuntu) (replace /dev/sdc with your own device):

```
udisks --detach /dev/sdc
```

Once I installed all Lubuntu software and used `bleachbit` to free the apt get space and the rest (I have to remember to remove also the older kernel version after the Software Update), I ran `sudo fstrim -v /` command to inform the SSD about the removed data.

I did not measure the speed of my internal hard disk before I put the SSD :(. But I measured the speeds of the SSD and the external hard disk connected via USB port, as well as some other external disks I own. I used an example of dd command from https://romanrm.net/dd-benchmark, with 512MB data file: `dd bs=1M count=512 if=/dev/zero of=test conv=fdatasync`. The shown disk model data are from running `sudo hdparm -I [device]`.

* Samsung SSD 840 EVO 250GB (ATA)
		536870912 bytes (537 MB) copied, 2.38861 s, 225 MB/s
* Samsung SSD 840 EVO 250GB (SATA III)
		536870912 bytes (537 MB) copied, 1.18932 s, 451 MB/s
* Samsung M3 Portable STSHX-M101TCB 1TB ST1000LM025 HN-M101ABB USB 3.0 => connected to USB 2.0 port
		536870912 bytes (537 MB) copied, 25.4847 s, 21.1 MB/s
* Samsung M2 Portable 1TB SAMSUNG HN-M101XBB (USB 2.0)
		536870912 bytes (537 MB) copied, 24.7446 s, 21.7 MB/s
* Seagate ST9320325AS 320GB => connected via SCSI Disk adapter to USB 2.0 (original laptop HD) (via USB 2.0 hub)
		536870912 bytes (537 MB) copied, 24.4285 s, 22.0 MB/s
* WDC WD5000YS-01MPB0 External 500GB (USB 2.0) (via USB 2.0 hub)
		536870912 bytes (537 MB) copied, 26.4048 s, 20.3 MB/s

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-12-31-Skype-Video-Flipped-Vertically-on-Asus-Laptop.md'>Skype Video Flipped Vertically on Asus Laptop</a> <a rel='next' id='fnext' href='#blog/2013/2013-12-27-A-Look-at-UEFI-Boot.md'>A Look at UEFI Boot</a></ins>
