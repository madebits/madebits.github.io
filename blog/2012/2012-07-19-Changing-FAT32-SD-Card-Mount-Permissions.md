#Changing FAT32 SD Card Mount Permissions

2012-07-19

<!--- tags: linux -->

My FAT32 micro SD-Card is automounted in Lubuntu (running in my *Asus EeePC X101*) by default allowing only current user to access folders there. This is a problem for me as I need several services have access to it. The [easiest](http://superuser.com/questions/134438/how-to-set-default-permissions-for-automounted-fat-drives-in-ubuntu-9-10) way to change the auto mount permissions is to create a permanent entry in `/etc/fstab` file.

To change the mount permissions I first added the following line to fstab file:
```
/dev/sdb1	/media/EXTRA16MB	vfat	user,exec,rw,nosuid,nodev,uid=1000,gid=1000,shortname=mixed,dmask=0022,utf8=1,showexec,flush	0	0
```
I found most of the options from using `mount -v` first. Then added user to enable automount and changed `dmask=0077` to `dmask=0022`. `fmask` is by default `133` so there is no need to change it.

Then unmounted it and created the directory:
```
sudo umount /media/EXTRA16MB
sudo mkdir /media/EXTRA16MB
```
At first, I mounted by UUID in `/etc/fstab` (using `blkid` to get it), but the mount point was listed twice in PCManFm. Based on details of [bug442130](https://bugs.launchpad.net/ubuntu/+source/gvfs/+bug/442130), I then changed `/etc/fstab` entry from UUID to the device path. The path is anyway same one all the time in *Asus Eee PC X101* and I use the SD-Card as permanent extra storage.


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2012/2012-07-21-Converting-Swap-Partition-to-a-Swap-File-in-Lubuntu.md'>Converting Swap Partition to a Swap File in Lubuntu</a> <a rel='next' id='fnext' href='#blog/2012/2012-06-17-Connecting-Lubuntu-and-Windows-Machines-at-Home-Network.md'>Connecting Lubuntu and Windows Machines at Home Network</a></ins>
