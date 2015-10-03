#Connecting Acer Iconia One 7 on Lubuntu

2014-06-19

<!--- tags: linux -->

To connect Acer Iconia One 7 (B1-730HD) on Lubuntu, I followed the steps listed in [acer forum](http://www.acertabletforum.com/forum/acer-iconia-tab-a500-general-discussions/129-connecting-via-usb-linux-ubuntu.html), based on [xda forum](http://forum.xda-developers.com/showthread.php?t=981774).

I had to install first mtpfs (FUSE filesystem for Media Transfer Protocol (MTP) devices):

```
sudo apt-get install mtpfs
```

Using `lsusb`, I found the VendorID:
```
$ lsusb
...
Bus 002 Device 009: ID 0502:3657 Acer, Inc.
...
```

Then as recommended I added a UDEV rule to change the default file mode, so that all users can read and write:
```
sudo echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="0502", MODE="0666"' > /etc/udev/rules.d/51-android.rules
```
Created a mount point and gave ownership to my user to that:
```
sudo mkdir /media/iconia
sudo chown user:user /media/iconia
```

If not already done so, edit as root `/etc/fuse.conf` to un-comment `user_allow_other` and add your user name to group fuse (to be able to mount as non-root):
```
sudo useradd user fuse
```

Edit `/etc/fstab` to add the mount point as a new line as shown:
```
mtpfs     /media/iconia     fuse     user,noauto,allow_other      0      0
```

After a reboot, the mount point will show up in PCManFm and then when you connect the Iconia device, you can click on the mount point in PCManFm to have mounted (or unmounted).

Only folder whose names start in uppercase and have no special chars are show. I guess this has to do something with *Media Transfer Protocol* (MTP), but I would have to check that later.

I cannot create new top folders in the mounted Internal Storage. The device is simply disconnected if I try that. But I can create new sub-folders on existing ones. So I created a top folder from within Iconia with my name (it has to be in uppercase), using an Android file manager.

MTP is somehow not working properly. I can create files only by using echo with redirect from command-line, but not via PcManFm. `cp` command seems to succeed (gives no error), but it is not working.

**Update**: MTP is definitely not working. I installed a free [SSH server](http://arachnoid.com/android/SSHelper/) on the device and that seems to be the best way to access and copy files conveniently over the network (next to using the SD Card).

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-09-15-Msbuild-MsDeploy-Generated-SourceManifest.md'>Msbuild MsDeploy Generated SourceManifest</a> <a id='fnext' href='#blog/2014/2014-05-30-Making-dev-random-Temporary-Faster.md'>Making dev random Temporary Faster</a></ins>
