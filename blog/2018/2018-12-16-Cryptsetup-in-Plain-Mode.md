#Cryptsetup in Plain Mode

2018-12-16

<!--- tags: linux encryption -->

`cryptsetup` in *plain* mode is a very versatile tool to create encrypted containers.

<div id='toc'></div>

##Using Encrypted Containers

To create or open a plain (non-LUKS) container use (all shown commands need `sudo`):

```bash
# only on creation
dd iflag=fullblock if=/dev/urandom of=container.bin bs=1G count=30

# note adding some offset -o 111 for extra secrecy, we can use --size too
cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain container.bin enc

# only on creation, other options can include -N inodes
mkfs -m 0 -t ext4 /dev/mapper/enc
# to set a label use either -L label with mkfs or later:
# sudo e2label /dev/mapper/enc label

mount /dev/mapper/enc /mnt/tmp
# re-mount to access as current user without sudo
bindfs -u $(id -u) -g $(id -g) /mnt/tmp $HOME/tmp
```

To close the open container use:

```bash
umount $HOME/tmp
umount /mnt/tmp
cryptsetup close enc
```

##Resizing Containers

Container size can be incremented either when container is mounted or not, whereas to decrease size container needs to be open, but not mounted.

###Increasing Size

To increase size of the container file, we can use use again `dd` with *seek* parameter to skip it size in *bs* size blocks:

```bash
# resize container from 30G to 40G (i.e., +10G)
dd iflag=fullblock if=/dev/urandom of=container.bin bs=1G count=10 seek=30
```

The command above will work for both open, mounted, and closed containers.

If the container is not open, you can `cryptsetup open` it and run:

```bash
sudo e2fsck -f /dev/mapper/enc
sudo resize2fs /dev/mapper/enc
```

If the container was already open and mounted before `dd`, to resize it live run:

```bash
sudo cryptsetup resize enc
sudo resize2fs /dev/mapper/enc
```
###Decreasing Size

To shrink a container file `cryptsetup open` it, but do not mount:

```bash
# e.g shrink to 20G total size
sudo e2fsck -f /dev/mapper/enc
sudo resize2fs /dev/mapper/enc 20G
truncate -s 20G container.bin
```

##Better Passwords

Given `--type plain` hashes password only once, plain mode is safe only if combined with some tool that hashes password more than once. 

We can specify a password via some script to `cryptsetup open` by using (e.g.: via `sudo sh -c "..."`):

```bash
echo -n "password" | cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain container.bin enc -
```

The idea is to generate a long random secret and encrypt it using `scrypt`. `scrypt` tool uses AES in CTR mode to encrypt data after better hashing password:

```bash
# only once
head -c 512 /dev/urandom | scrypt enc -t 60 -m 1000000 - secret.bin
# enter here the password you will need to open the container

# keep secret.bin together with container.bin

# use secret.bin to open container
sudo sh -c "scrypt dec -t 60 -m 1000000 secret.bin | cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain container.bin enc -"
#  enter here the password to open the container
```

While `scrypt` is the easiest tool to use, you may also consider combining `argon2` and `ccrypt` (uses AES in CFB mode) tools to achieve same, as shown in next section.

##Using Argon2 and Ccrypt

We need the following helper bash scripts (ideally copy them as root in `/usr/local/bin`):

* [cskey.sh](blog/2018/csm/cskey.sh)
* [csman.sh](blog/2018/csm/csman.sh)
* [csfile.sh](blog/2018/csm/csfile.sh) (optional)

These scripts use the following helper tools:

```bash
sudo apt install cryptsetup bindfs argon2 ccrypt
```

###Key Generation

`cskey.sh` bash script helps manage key contents. It uses `ccrypt` to save container key, or if present in same folder, it uses my [aes](#r/cpp-aes-tool.md) tool. The benefit of my `aes` tool is that it (same as *dm-crypt*) always decrypts the data even if the password is wrong, while `ccrypt` is designed to give an error, which I consider unsafe. We can use `cskey.sh` to generate a secret file (we only need to do this once):

```bash
./cskey.sh enc secret.bin
# enter password for container here
```

Now that we created *secret.bin* file (we need to store it together with the container), we can use that to open the container:

```bash
sudo sh -c "./cskey.sh dec secret.bin | cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain container.bin enc -"
# enter password for container here
```

Use `history -r` or `kill -9 $$` to prevent `bash` from storing command history.

###Container Management

With `cskey.sh` ready, we can now automate for convenience open / close with a second script `csman.sh` (`cskey.sh` should be in same folder). The `csman.sh` script can be used as follows:

```bash
sudo ./csman open container.bin secret.bin

# mounted at $HOME/mnt/csm_XXXX_user
# and when done, to close it use

sudo ./csman close XXXX
sudo ./csman closeAll
```

We may also use the script create a new container file (size can be either in M or G):

```bash
sudo $HOME/bin/csman.sh create container.bin secret.bin 30M
```

##Finding Container Key 

While a container is open, anyone with `sudo` rights can get its binary key using:

```bash
lsblk -p

NAME              MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
/dev/loop0          7:0    0    30G  0 loop  
└─/dev/mapper/enc 253:0    0    30G  0 crypt

dmsetup table --target crypt --showkey /dev/mapper/enc | cut -d ' ' -f 5 | xxd -r -p > key.bin

# and use that key.bin file later to reopen the container
cryptsetup --key-file=key.bin -c aes-xts-plain64 -s 512 -o 111 open --type plain container.bin enc
```

##Plain Mode Goodies

[Arch Wiki](https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#Encrypting_devices_with_plain_mode) has two interesting uses of plain mode.

###Encryption Chaining

We can nest multiple `cryptsetup open` calls with a previous `/dev/mapper/*` device. This enables multiple layers of encryption:

```bash
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

We can use `--offset (-o)` and `--size` option (both defined as number of 512 byte sectors) to have several *non-overlapping* encrypted containers on same binary file blob. We can even open several of them at once by adding `--shared` option to `cryptsetup open`:

```bash
cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 open --type plain -o 100 --size 1000 container.bin container1
cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 open --type plain -o 1100 --size 1000 --shared container.bin container2
```

Related to `--offset` and `--size` is `--skip`, that tells `cryptsetup` the first sector number to use for *IV* calculation (by default `0` is used in all parts). I am not sure why that info is exposed to the user, very likely to enable using a different *IV seed* for each part.

**References**

* https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_a_non-root_file_system#Loop_device
* https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#Encrypting_devices_with_plain_mode
* https://lumit.it/how-to-get-a-tails-luks-master-key/
* https://www.tarsnap.com/scrypt.html
* https://en.wikipedia.org/wiki/Argon2
* https://github.com/P-H-C/phc-winner-argon2
* https://www.gnu.org/software/bash/manual/bashref.html
* http://www.gnu.org/software/coreutils/manual/coreutils.html
* https://unix.stackexchange.com/questions/10922/temporarily-suspend-bash-history-on-a-given-shell
* https://www.digitalocean.com/community/tutorials/how-to-partition-and-format-storage-devices-in-linux

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2019/2019-01-23-Installing-Ubuntu-18.10.md'>Installing Ubuntu 18.10</a> <a rel='next' id='fnext' href='#blog/2018/2018-04-26-Lubuntu-18.04-Disable-initfsram-Resume.md'>Lubuntu 18.04 Disable initfsram Resume</a></ins>
