#Converting Swap Partition to a Swap File in Lubuntu

2012-07-21

<!--- tags: linux -->

I used default settings when I installed Lubuntu on my *Asus EeePC X101*. This created a swap partition of `1012MiB`, corresponding the size of system RAM. Given the disk space is small on the machine, I wanted to experiment a bit with swap size to make it smaller, or even remove it. Such experiments are hard to do with a swap partition, so I decided to convert to using a swap file instead of a swap partition.

To create a swap file I followed the steps in Ubuntu [SwapFaqs](https://help.ubuntu.com/community/SwapFaq/):
```
sudo fallocate -l 512m /mnt/512MiB.swap
sudo chmod 600 /mnt/512MiB.swap
sudo mkswap /mnt/512MiB.swap
sudo swapon /mnt/512MiB.swap
```
In this process I also cut in half of the original the swap size (I had checked up and now the system using free command and noticed that the swap space was not used on the machine - and I do not use hibernate, etc - I have disabled hibernate in `/usr/share/polkit-1/actions/org.freedesktop.upower.policy`). Then I added the swap file to /etc/fstab, and commented the original swap partition mount entry line from there:

```
/mnt/512MiB.swap  none  swap  sw  0 0
```
I did a system restart to verify (using `free` command) that it worked. After that, I rebooted using the same live Lubuntu USB created with [UNetbootin](http://unetbootin.sourceforge.net/) that I used to install Lubuntu on the machine (any other live USB will do), in order to be able to use GParted to remove the swap partition.

After starting GParted from the live Lubuntu USB, I removed first the swap flag from the swap volume, and deleted it and the extended volume that contained it. Then I re-sized the main partition to occupy the full freed space. After applying the changes, I restarted the system to the machine installed Lubuntu instance and verified that the disk space was really increased using `df -h` command.

I did not win much free disk space at the moment doing this, but I have now the flexibility to experiment with the swap file, turn swap off, or make it smaller or bigger as needed, and even try to move it to an external SD-Card.

Update1: I experimented moving swap file to the external mini SD-Card (vfat) I use. See my previous post on setting SD-Card mount options so that all user can access it. I additionally changed fstab mount line for SD-Card by adding `fmask=0111` in options so that all users can read and write to it. Then I used `fallocate` to create a file on the main harddisk (it did not work with SD-Card location) and moved it to SD-Card.

```
sudo fallocate -l 1024m /mnt/1024MiB.swap
mkdir /media/EXTRA16MB/mnt/
mv /mnt/1024MiB.swap /media/EXTRA16MB/mnt/1024MiB.swap
```
Then I ran same commands as above:
```
sudo mkswap /media/EXTRA16MB/mnt/1024MiB.swap
sudo swapon /media/EXTRA16MB/mnt/1024MiB.swap
sudo swapoff /mnt/512MiB.swap
```
I deleted old `/mnt/512MiB.swap` file and did a restart. Verified swap space with `free` and `cat /proc/swaps` and the disk free space with `df -h`. I have now 1GB more free space in the main hard disk.
```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       7.5G  2.6G  4.6G  36% /
/dev/sdb1        15G  8.4G  6.5G  57% /media/EXTRA16MB
```
I never remove the mini SD-Card from machine, but if I ever need to remove it, I can either to do it when the machine is off, or I must run first `sudo swapoff /media/EXTRA16MB/mnt/1024MiB.swap` (and `umount`) before remove, then s`wapon on` same file path once I insert the card back.

<ins class='nfooter'><a id='fprev' href='#blog/2012/2012-08-01-Change-Wallpaper-at-Startup-in-Lubuntu.md'>Change Wallpaper at Startup in Lubuntu</a> <a id='fnext' href='#blog/2012/2012-07-19-Changing-FAT32-SD-Card-Mount-Permissions.md'>Changing FAT32 SD Card Mount Permissions</a></ins>
