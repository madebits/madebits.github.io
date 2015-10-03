#Archivemount in Lubuntu

2013-11-01

<!--- tags: linux -->

[ArchiveMount](http://manpages.ubuntu.com/manpages/raring/man1/archivemount.1.html) can be used to mount archive files via fuse user driver. To install `archivemount` in Lubuntu use:
```
sudo apt-get install archivemount
```
Mounting as Root

By default, fuse mounted folders are mounted and are accessible as root. To allow non-root users access the mounted files, edit (as root) `/etc/fuse.conf` and uncomment:
```
# uncomment
user_allow_other
```

There is no need to restart. Then create a folder where to mount the archive, it can be in your home folder:
```
mkdir -p ~/mount/archive
```

Finally, mount an archive file of choice to that directory:
```
sudo archivemount -o allow_other -o readonly /media/data/Test.rar mount/archive
```

I am using the fuse option `-o allow_other` to be able to access the mounted folder data `~/mount/archive` also as normal non root user. I am also using `-o readonly` option, which is a good idea as `archivemount` supports most of archives as readonly. If you do not use `-o readonly` you may end up with corrupted archive files, thought `archivemount` preserves the original archive as `*.orig`, even if it creates a changed copy.

Now you can access the mounted archive files by browsing the `~/mount/archive` folder. When done, to unmount make sure no open program is accessing anymore the mount folder and use:
```
sudo umount ~/mount/archive
```

##Mount as Non-Root User

To be able to mount fuse volumes as non-root add your `user` name to group `fuse`:
```
sudo useradd user fuse
```
A restart is needed after this. Then you can mount and umnount as your own user:
```
archivemount -o allow_other -o readonly /media/data/Test.rar mount/archive
fusermount -u mount/archive
```

##Integrating ArchiveMount in PCManFM

This is a partial solution to integrate Archivemount in PCManFM that kind of works. At the moment, I can only mount once archive at a time.

I created first a shell script in my home `~/bin/amount.sh` with this content (and made it executable):

```
#!/bin/bash

#add -z option to fusermoun to allow lazy unmounts for files in use
fusermount -u ~/mount/archive
if [ -n "$1" ]; then
	archivemount -o allow_other -o readonly "$1" ~/mount/archive
	# remove this if you do not want to open a new pcmanfm window
	pcmanfm ~/mount/archive
fi
```

This script can be used manually as follows:

```
#mount
amount.sh /media/data/Test.rar
#unmount
amount.sh
```

I thought first being a bit fancy and using `basename` to create the mount point automatically per archive, but then I had to delete those folders somehow after unmount, and I cannot do this easy automatically from `pcmanfm`. So I decided to leave the script for the moment as simple as shown above. It will mount only one archive at a time at the same given location `~/mount/archive` (which must be created once before).

Then I cloned "Archive Manager" system shortcut:
```
sudo cp /usr/share/applications/file-roller.desktop  ArchiveMount.desktop
```

And edited as root the new `ArchiveMount.desktop` file to look as follows (note I am using absolute path for my script above /home/user/bin/amount.sh):

```
[Desktop Entry]
Name=Mount Archive
Comment=Mount Archive
Keywords=zip;tar;extract;unpack;
TryExec=file-roller
Exec=/home/user/bin/amount.sh %f
Type=Application
Icon=applications-other
Categories=GTK;GNOME;Utility;Archiving;Compression;
MimeType=application/x-7z-compressed;application/x-7z-compressed-tar;application/x-ace;application/x-alz;application/x-ar;application/x-arj;application/x-bzip;application/x-bzip-compressed-tar;application/x-bzip1;application/x-bzip1-compressed-tar;application/x-cabinet;application/x-cbr;application/x-cbz;application/x-cd-image;application/x-compress;application/x-compressed-tar;application/x-cpio;application/x-deb;application/x-ear;application/x-ms-dos-executable;application/x-gtar;application/x-gzip;application/x-gzpostscript;application/x-java-archive;application/x-lha;application/x-lhz;application/x-lrzip;application/x-lrzip-compressed-tar;application/x-lzip;application/x-lzip-compressed-tar;application/x-lzma;application/x-lzma-compressed-tar;application/x-lzop;application/x-lzop-compressed-tar;application/x-ms-wim;application/x-rar;application/x-rar-compressed;application/x-rpm;application/x-rzip;application/x-rzip-compressed-tar;application/x-tar;application/x-tarz;application/x-stuffit;application/x-war;application/x-xz;application/x-xz-compressed-tar;application/x-zip;application/x-zip-compressed;application/x-zoo;application/zip;application/x-archive;application/vnd.ms-cab-compressed;
Encoding=UTF-8
Name[en_US]=Mount Archive
Comment[en_US]=Mount Archive
```
I changed the name, icon and exec entries. After doing this, when I right-click on an archive file, I have "Mount Archive" as menu option. If I select it the archive is mounted in `~/mount/archive` and it is shown as mounted in pcmanfm.

Unfortunately unmount via `pcmanfm` does not work as it uses `umount`, so to unmount I make sure the mounted contents are not in use by any open applications (use lsof if unsure), and then I ran in a terminal (or using Alt+F2) `amount.sh`, or I simply leave the archive mounted, till I mount another one.

`archivemount` kind of works. For some files inside `rar` archives, I get read errors, for example:
```
read[0] 131072 bytes from 0 flags: 0x8000
   unique: 707, error: -25 (Inappropriate ioctl for device), outsize: 16
```

This is not directly related to the archive entry file size, but I do not know the exact reason for this.

<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-11-02-LibreOffice-Preview-Thumbnails-in-PCManFM.md'>LibreOffice Preview Thumbnails in PCManFM</a> <a id='fnext' href='#blog/2013/2013-10-28-Starting-VirtualBox-VM-Directly.md'>Starting VirtualBox VM Directly</a></ins>
