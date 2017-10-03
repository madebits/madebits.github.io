#Cryptsetup with Plain Mode

2018-12-16

<!--- tags: linux encryption -->

`cryptsetup` in *plain* mode is a very versatile tool to create encrypted containers.

##Creating and Using Encrypted Containers

To create or open a plain (non-LUKS) container use (all shown commands need `sudo`):

```bash
# only on creation
dd iflag=fullblock if=/dev/urandom of=container.bin bs=1G count=30

# note adding some offset -o 111 for extra secrecy, we can use --size too
cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain container.bin enc

# only on creation
mkfs -m 0 -t ext4 /dev/mapper/enc

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

##Better Plain Mode Passwords

Given `--type plain` hashes password only once, the above is safe only if combined with some tool that hashes password more than once. 

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

Let us create a quick bash helper file:

```bash
#!/bin/bash

set -e
mode=$1

# none of values in this file is secret
# change argon2 params as it fit you here
at=1000
ap=8
am=14

if [ "$mode" = "enc" ]; then
    read -p "Enter password: " -s pass
    if [ -t 0 ] ; then
        read -p "Re-Enter password: " -s pass2
        if [ "$pass" != "$pass2" ]; then
            (>&2 echo "Passwords do not match")
            exit 1
        fi
    fi
    
    file="${2:-secret.bin}"
    > "$file"

    salt=$(head -c 32 /dev/urandom | base64 -w 0)
    echo -n "$salt" >> "$file"
    hash=$(echo -n "$pass" | argon2 "$salt" -t $at -p $ap -m $am -l 128 -r)
    retVal=$?
    if [ $retVal -ne 0 ]; then
        (>&2 echo "argon2 failed")
    fi

    head -c 512 /dev/urandom | base64 -w 0 | ccrypt -e -f -k <(echo -n "$hash") | base64 -w 0 >> "$file"
    
elif [ "$mode" = "dec" ]; then
    read -p "Enter password: " -s pass
    file="$2"
    if [ -f "$file" ]; then
        salt=$(head -c 44 "$file")
        data=$(tail -c +45 "$file")
        hash=$(echo -n "$pass" | argon2 "$salt" -t $at -p $ap -m $am -l 128 -r)
        echo -n "$data" | base64 -d | ccrypt -d -k <(echo -n "$hash")
    else
        (>&2 echo "no such file: $file")
        exit 1
    fi
    
else
    (>&2 echo "$0 enc secret.bin | $0 dec secret.bin")
    exit 1
fi
```

Save it as `helper.sh` and make it executable.

We can use helper script to generate a secret file (we only need to do this once):

```bash
./helper.sh enc secret.bin
# enter password for container here
```

Now that we created *secret.bin* file (we need to store it together with the container), we can use that to open the container:

```bash
sudo sh -c "./helper.sh dec secret.bin | cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain container.bin enc -"
# enter password for container here
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

##Other Plain Mode Goodies

[Arch Wiki](https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#Encrypting_devices_with_plain_mode) has two interesting uses of plain mode.

###Chain Encryption

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

We can use `--offset (-o)` and `--size` option (both defined as number of 512 byte sectors) to have several encrypted containers on same binary file. We can even open several of the at once by adding `--shared` option to `cryptsetup open`:

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

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2018/2018-04-26-Lubuntu-18.04-Disable-initfsram-Resume.md'>Lubuntu 18.04 Disable initfsram Resume</a></ins>
