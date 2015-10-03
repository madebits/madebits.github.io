#Installing Lubuntu Alongside Windows

2013-07-25

<!--- tags: linux -->

It now more than one year I have become a regular Lubuntu user. I run Lubuntu in several machines. That was also the motivation for most of my blog posts - to serve mainly as a way to document to myself what I did, so that I can easy reference these steps if I need them later without googling much again.

Until now, I was running Lubuntu in one of my laptops via a 20 GB Wubi installation within Windows 7. Given my laptop had a hidden 20GB recovery partition for Windows, which I do not need (but was too lazy to remove before), I decided to recover that space and install Lubuntu on its own partition.

I used [EaseUS Partition Master](http://www.howtogeek.com/139710/remove-your-pc%E2%80%99s-recovery-partition-and-take-control-of-your-hdd/) - Home Edition, to first delete the recovery volume and move that space to the C: drive (+20GB).

Then I made C: volume 20 GB smaller, and shifted D: volume to that space, making D: also 10GB smaller. This left me with 30GB of free space in the end of the harddisk to use for Lubuntu. Given I plan to delete my Wubi install, it means I will still have 10Gb more on the D: volume than before doing these changes.

I prepared a [UNetbootin](http://unetbootin.sourceforge.net/) USB with Lubunut 13.04 64 bit ISO, and installed it. I created only a root ext4 partition (no swap, etc), as this fist better to my usage. I left the grub bootloader as machine bootloader.

With Wubi, the Windows D: data partition where I had Wubi was automatically mounted. This was no more the case with the separate install. So I mounted the NTFS partition in [fstab](http://www.howtogeek.com/howto/35807/how-to-harmonize-your-dual-boot-setup-for-windows-and-ubuntu/):
```
sudo blkid # to get the UUID
```
Created a mount point:
```
sudo mkdir /media/data
```
And then added a line to `/etc/fstab` and restarted that machine:
```
UUID=66E53AEC54455DB2 /media/data/    ntfs-3g        auto,user,rw 0 0
```
One more thing, that was remaining, was to access the old Wubi installation data from the new Lubuntu instance. Following the [askubuntu](http://askubuntu.com/questions/83690/mounting-wubi-part-from-another-linux-installation) advice:

```
sudo mkdir /media/wubi
sudo mount -o /media/data/ubuntu/disks/root.disk /media/wubi
```

I did not automount this in fstab as I plan to remove the Wubi installation once I have taken out all data I need from it.

Additionally, I installed `wine` and via `winetricks` .net:
```
rm -rf .wine
WINEARCH=win32 WINEPREFIX=~/.wine winecfg
winetricks dotnet20
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-07-26-Samsung-ML-1915-Printer-on-Lubuntu.md'>Samsung ML 1915 Printer on Lubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-07-17-Configuring-AMD-ATI-Radeon-on-Lubuntu.md'>Configuring AMD ATI Radeon on Lubuntu</a></ins>
