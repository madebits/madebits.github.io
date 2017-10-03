#Cryptsetup with Plain Mode

2018-12-16

<!--- tags: linux encryption -->

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

Given `--type plain` hashes password only once, the above is useful if you combine it with some command that hashes password more than once. For example, generate a long secret and encrypt it using `scrypt`. `scrypt `tool uses AES in CTR mode to encrypt data after hashing password via `scrypt`:

```
head -c 512 /dev/urandom | scrypt enc -t 60 -m 1000000 - secret.bin
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

* https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system#Loop_device
* https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#Encrypting_devices_with_plain_mode
* https://lumit.it/how-to-get-a-tails-luks-master-key/
* https://www.tarsnap.com/scrypt.html

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2018/2018-04-26-Lubuntu-18.04-Disable-initfsram-Resume.md'>Lubuntu 18.04 Disable initfsram Resume</a></ins>
