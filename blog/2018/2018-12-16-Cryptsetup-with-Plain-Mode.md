#Cryptsetup with Plain Mode

2018-12-16

<!--- tags: linux encryption -->

`cryptsetup` in *plain* mode is a very versatile tool create encrypted containers.

##Creating and Using Encrypted Containers

To create or open a plain (non-LUKS) container use (all shown commands need `sudo`):

```
# only on creation
dd iflag=fullblock if=/dev/urandom of=container.bin bs=1G count=30

# note adding some offset -o 111 for extra secrecy, we can use --size bytes too
cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain container.bin enc

# only on creation
mkfs -m 0 -t ext4 /dev/mapper/enc

mount /dev/mapper/enc /mnt/tmp
# re-mount to access as current user without sudo
bindfs -u $(id -u) -g $(id -g) /mnt/tmp $HOME/tmp
```

To close the open container use:

```
umount $HOME/tmp
umount /mnt/tmp
cryptsetup close enc
```

##Better Plain Mode Passwords

Given `--type plain` hashes password only once, the above is useful if we combine it with some command that hashes password more than once. First, note that we can specify a password via some script to `cryptsetup` open by using (e.g.: via `sudo sh -c "..."`):

```
echo -n "password" | cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain container.bin enc -
```

We can generate a long random secret and encrypt it using `scrypt`. `scrypt` tool uses AES in CTR mode to encrypt data after better hashing password:

```
head -c 512 /dev/urandom | scrypt enc -t 60 -m 1000000 - secret.bin
# enter here the password you will need to open the container

# keep secret.bin together with container.bin

# to use secret.bin
sudo sh -c "scrypt dec -t 60 -m 1000000 secret.bin | cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain container.bin enc -"
#  enter here the password to open the container
```

While `scrypt` is the easiest tool to use, you may also consider combining `argon2` and `ccrypt` tools to achieve same.

##Finding Container Key 

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

##Other Plain Mode Goodies

[Arch Wiki](https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#Encrypting_devices_with_plain_mode) has two interesting uses of plain mode.

###Chain Encryption

We can nest multiple `cryptsetup open` calls with over a previous `/dev/mapper/*` device. This enables using multiple layers of encryption:

```
# first layer, we open a file or a losetup device, created /dev/mapper/layer1
cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 open --type plain container.bin layer1

# second layer, we reopen /dev/mapper/layer1 as /dev/mapper/layer2
cryptsetup -v -c twofish-xts-plain64 -s 512 -h sha512 open --type plain /dev/mapper/layer1 layer2

# we can create the file system and mount /dev/mapper/layer2

# when done
cryptsetup close layer2
cryptsetup close layer1
```

### Shared Blob

We can use `--offset (-o)` and `--size` option (both in number of 512 byte sectors) to have several encrypted containers on same binary file. We can even open several of the at once by adding `--shared` option to `cryptsetup open`.

```
cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 open --type plain -o 100 --size 1000 container.bin container1
cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 open --type plain -o 1100 --size 1000 --shared container.bin container2
```

Related to `--offset` and `--size` is `--skip`, that tells `cryptsetup` the first sector number to use for *IV* calculation (by default `0` is used in all parts). I am not sure why that info is exposed to the user, very likely to enable using a different *IV seed* for each part.

**References**

* https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system#Loop_device
* https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#Encrypting_devices_with_plain_mode
* https://lumit.it/how-to-get-a-tails-luks-master-key/
* https://www.tarsnap.com/scrypt.html

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2018/2018-04-26-Lubuntu-18.04-Disable-initfsram-Resume.md'>Lubuntu 18.04 Disable initfsram Resume</a></ins>
