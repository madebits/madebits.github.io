#Encrypted Containers with Cryptsetup

2013-09-07

<!--- tags: linux encryption -->

Summary of commands to set up an encrypted container in Ubuntu using `cryptsetup`. There are many places where to find these commands, listing them once more tested will not hurt :). The commands (most) should be run as root and data will be accessible as root only. Both LUKS and not LUKS commands are shown. LUKS is better in long term (to change keys etc), but its containers can be easy identified as such. Without LUKS it is safer, but it not easy change password, etc.

#1. Install cryptsetup

```
sudo apt-get install cryptsetup
```

#2. Creation

Create empty container (512MB container, see `dd` help for other sizes):
```
dd if=/dev/zero of=/root/test.bin count=1000k
```

Connect as loop device:
```
losetup -f
losetup /dev/loop0 /root/test.bin
```

Create partition:
```
fdisk /dev/loop0
```
Commands for fdisk session:
```
Command (m for help): n
Partition type:
  p  primary (0 primary, 0 extended, 4 free)
  e  extended
Select (default p): p
Partition number (1-4, default 1):
Using default value 1
First sector (2048-1023999, default 2048):
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-1023999, default 1023999):
Using default value 1023999

Command (m for help): w
The partition table has been altered!
```

###With LUKS
```
cryptsetup -v -y luksFormat /dev/loop0
cryptsetup luksOpen /dev/loop0 sometest
```
###Without LUKS
```
cryptsetup -v -y create /dev/loop0
```

##3. Format
```
mkfs -j -m 0 -t ext4 /dev/mapper/sometest
```

##4. Mount
```
mkdir /mnt/e1
mount /dev/mapper/sometest /mnt/e1
```
Use as root (or use `bindfs`).

##5. Disconnect
```
umount /mnt/e1
cryptsetup remove sometest
sudo losetup -d /dev/loop0
```
#6. Reconnect

To use:
```
losetup -f
losetup /dev/loop0 /root/test.bin
```

###With LUKS
```
cryptsetup luksOpen /dev/loop0 sometest
```

###Without LUKS
```
cryptsetup create /dev/loop0
```
Repeat Mount and Disconnect commands.

##Update (2018-12-16)

To create or open a plain (non-LUKS) container use (all shown commands need `sudo`):

```
# only on creation
dd iflag=fullblock if=/dev/urandom of=container.bin bs=1G count=30

# note adding some offset -o 111 for extra secrecy
cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain container.bin enc

# only on creation
mkfs -m 0 -t ext4 /dev/mapper/enc

mount /dev/mapper/enc /mnt/tmp
# re-mount to access as current user without sudo
bindfs -u $(id -u) -g $(id -g) /mnt/tmp $HOME/tmp
```

To specify password via some script above use (e.g.: via `sudo sh -c "..."`):

```
echo -n password | cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain /data2/temp/container.bin enc -
```

Given `--type plain` hashes password only once, the above is useful if you combine it with some command that hashes password more than once. For example, generate a long password and encrypt it using `scrypt`:

```
head -c 521 /dev/urandom | scrypt enc -t 60 -m 1000000 - secret.bin
# enter here the password
# keep secret.bin together with container.bin

# to use secret.bin
sudo sh -c "scrypt dec -t 60 -m 1000000 secret.bin | cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain /data2/temp/container.bin enc -"
#  enter here the password
```

To close the open container use:

```
umount $HOME/tmp
umount /mnt/tmp
cryptsetup remove enc
```

While a container is open, anyone (with `sudo` rights) can get its binary key using:

```
lsblk -p

NAME              MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
/dev/loop0          7:0    0    30G  0 loop  
└─/dev/mapper/enc 253:0    0    30G  0 crypt

dmsetup table --target crypt --showkey /dev/mapper/enc | cut -d ' ' -f 5 | xxd -r -p > key.bin

# and use that key.bin file later to reopen the container
cryptsetup --key-file=key.bin  -c aes-xts-plain64 -s 512 -o 111 open --type plain /data2/temp/container.bin enc
```


**References**

* http://www.linux.org/threads/encrypted-containers-without-truecrypt.4478/
* http://rkd.zgib.net/wiki/DebianNotes/EncryptedLoopback
* http://sleepyhead.de/howto/?href=cryptpart

* https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system#Loop_device
* https://lumit.it/how-to-get-a-tails-luks-master-key/


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-09-28-Tmux-on-Lubuntu.md'>Tmux on Lubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-08-20-Sort-Photos-By-EXIF-Date.md'>Sort Photos By EXIF Date</a></ins>
