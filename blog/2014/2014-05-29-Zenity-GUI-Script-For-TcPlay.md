#Zenity GUI Script For TcPlay

2014-05-29

<!--- tags: linux encryption -->

> I wrote a script for this, you can download from: [Linux-TcPlay](#r/linux-tcplay-ui.md)

[tcplay](https://github.com/bwalex/tc-play) is a command-line alternative for creating and using TrueCrypt volumes. It can be installed in Lubuntu via: `sudo apt-get install tcplay`.

Based on [ArchWiki](https://wiki.archlinux.org/index.php/Tcplay) documentation, given you have already a password protected TrueCrypt container, e.g., /data/truecrypt.tc, you can mount it using:

```
sudo losetup /dev/loop0 /data/truecrypt.tc
sudo tcplay -m foo -d /dev/loop0
# you will be asked here for the password
sudo mount -o nosuid,uid=1000,gid=1000 /dev/mapper/foo /home/user/test/
```

Here `loop0` was found using `losetup -f` command, the `/home/user/test/` folder must be created if it does not exist, and `uid=1000,gid=1000` are the current user id and current user group id. The mount options `-o uid=1000,gid=1000` are valid only for ntfs, or vfat. For ext4 to access the mounted volume as a normal user install first: `sudo apt-get install bindfs`, and re-mount to a new folder test1 as current user:

```
#ext4
sudo mount /dev/mapper/foo /home/user/test/
sudo bindfs -u $(id -u) -g $(id -g) /home/user/test /home/user/test1
```

To unmount the container when done use:
```
#for ext4:
# sudo umount /home/user/test1/
sudo umount /home/user/test/
sudo dmsetup remove foo
sudo losetup -d /dev/loop0
```

Other operations, not supported by the script:

Based on tcplay [man](http://leaf.dragonflybsd.org/cgi/web-man?command=tcplay&section=8) page to change the password of a password protected TrueCrypt container, you can use:

```
sudo losetup /dev/loop0 /data/truecrypt.tc
sudo tcplay --modify -d /dev/loop0
# you will be asked here for the old, and the new passwords
sudo losetup -d /dev/loop0
```

Creating a new container requires some more steps (see \# comments for details):

```
dd if=/dev/zero of=container1.tc bs=1 count=0 seek=1G
# slower and safer, but not really needed as tcplay does something similar in -c
# dd if=/dev/urandom of=container.tc bs=1M count=1024

sudo losetup /dev/loop0 container.tc
sudo tcplay -c -d /dev/loop0 -a RIPEMD160 -b AES-256-XTS
# enter password here, and wait for secure delete
# tcplay will use /dev/random to get header data
# to make it faster use the keyboard and mouse while tcplay is waiting

sudo tcplay -m foo -d /dev/loop0
# note -m 0 here to claim all space
sudo mkfs -j -m 0 -t ext4 /dev/mapper/foo
sudo mkdir -p /mnt/truecrypt/
sudo mount /dev/mapper/foo /mnt/truecrypt/

# here the /mnt/truecrypt/ can be used as root

# to unmount
sudo umount /mnt/truecrypt
sudo dmsetup remove foo
sudo losetup -d /dev/loop0
sudo rmdir /mnt/truecrypt/
```

Creation of new volumes happens rarely that many commands are ok. The mount / unmount happens more often and for that I wrote my script.

Another way to mount TrueCrypt containers from command-line is by using cryptsetup (`sudo apt-get install cryptsetup`):

```
# mount
sudo cryptsetup --type tcrypt open /data/truecrypt.tc foo
sudo mount -o nosuid,uid=1000,gid=1000 /dev/mapper/foo /home/user/test/

# unmount
sudo umount /home/user/test/
sudo cryptsetup remove foo
```
When used as shown cryptsetup will find and free the loop device on its own.

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-05-30-Making-dev-random-Temporary-Faster.md'>Making dev random Temporary Faster</a> <a id='fnext' href='#blog/2014/2014-05-27-Using-Dropbox-to-keep-EncFS-Configuration-File-Safe.md'>Using Dropbox to keep EncFS Configuration File Safe</a></ins>
