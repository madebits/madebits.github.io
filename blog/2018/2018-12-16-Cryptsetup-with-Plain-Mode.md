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

Let us create a bash helper script:

```bash
#!/bin/bash

# cs-key.sh

set -e

# none of values in this file is secret
# change argon2 params as it fits you here
at="${3:-1000}"
am="${4:-14}"
ap="${5:-8}"

# file pass key
function encodeKey()
{
    local file="$1"
    local pass="$2"
    local key="$3"
    local salt=$(head -c 32 /dev/urandom | base64 -w 0)
    hash=$(echo -n "$pass" | argon2 "$salt" -t $at -p $ap -m $am -l 128 -r)
    > "$file"
    echo -n "$salt" >> "$file"
    echo -n "$key" | ccrypt -e -f -k <(echo -n "$hash") | base64 -w 0 >> "$file"
}

# file pass
function decodeKey()
{
    local file="$1"
    local pass="$2"

    if [ -f "$file" ]; then
        local salt=$(head -c 44 "$file")
        local data=$(tail -c +45 "$file")
        local hash=$(echo -n "$pass" | argon2 "$salt" -t $at -p $ap -m $am -l 128 -r)
        echo -n "$data" | base64 -d | ccrypt -d -k <(echo -n "$hash")
    else
        (>&2 echo "! no such file: $file")
        exit 1
    fi
}

function readPass()
{
    read -p "New password: " -s pass
    echo
    if [ -t 0 ] ; then
        read -p "Renter new password: " -s pass2
        echo
        if [ "$pass" != "$pass2" ]; then
            (>&2 echo "! passwords do not match")
            exit 1
        fi
    fi
    if [ -z "$pass" ]; then
        (>&2 echo "! no password")
        exit 1
    fi
}

# mode file
function main()
{
    local mode="$1"
    local file="${2:-secret.bin}"
    case "$mode" in
        enc)
            readPass
            local key=$(head -c 512 /dev/urandom | base64 -w 0)
            encodeKey "$file" "$pass" "$key"
        ;;
        dec)
            read -p "Enter password: " -s pass
            decodeKey "$file" "$pass"
        ;;
        chp)
            read -p "Current password: " -s pass1
            echo
            key=$(decodeKey "$file" "$pass1")
            readPass
            encodeKey "$file" "$pass" "$key"
        ;;
        *)
            (>&2 echo "Usage: $0 [enc | dec | chp] file")
            (>&2 echo "file is overwritten by enc and chp, backup it as needed before")
            exit 1
        ;;
    esac
}

main $1 $2

```

Save it as `cs-key.sh` and make it executable.

We can use `cs-key.sh` to generate a secret file (we only need to do this once):

```bash
./cs-key.sh enc secret.bin
# enter password for container here
```

Now that we created *secret.bin* file (we need to store it together with the container), we can use that to open the container:

```bash
sudo sh -c "./cs-key.sh dec secret.bin | cryptsetup -v -c aes-xts-plain64 -s 512 -h sha512 -o 111 open --type plain container.bin enc -"
# enter password for container here
```

To change password of `secret.bin` (file is overwritten in place, so backup it before as needed) use:

```bash
./cs-key.sh chp secret.bin
# enter current pass
# enter new pass
```

With `cs-key.sh` ready, we can now automate open / close with a second script for convenience (it is not really needed), lets name it `cs-map.sh` (`cs-key.sh` should be in same folder):

```bash
#!/bin/bash

# cs-map.sh

set -e

toolsDir="$(dirname $0)"

function main()
{
    local mode="$1"
    local name="$2"
    local mntDir1="$HOME/mnt/${name}"
    local mntDir2="$HOME/mnt/${name}_user"
    
    case "$mode" in
        open)
            if [-z "$name" ]; then
                (>&2 echo "! name required")
                exit 1
            fi
            shift 
            shift

            local secret="$1"
            if [-z "$secret" ]; then
                (>&2 echo "! secret required")
                exit 1
            fi
            shift
            local device="$1"
            if [-z "$device" ]; then
                (>&2 echo "! device required")
                exit 1
            fi
            shift

            "${toolsDir}/cs-key.sh" dec "$secret" | cryptsetup --type plain -c aes-xts-plain64 -s 512 -h sha512 "$@" open "$device" "$name" -

            mkdir -p "$mntDir1"
            mount "/dev/mapper/$name" "$mntDir1"
            mkdir -p "$mntDir2"
            user=${SUDO_USER:-$(whoami)}
            bindfs -u $(id -u "$user") -g $(id -g "$user") "$mntDir1" "$mntDir2"
        ;;
        close)
            if [-z "$name" ]; then
                (>&2 echo "! name required")
                exit 1
            fi
            umount "$mntDir2"
            rmdir "$mntDir2"
            umount "$mntDir1"
            rmdir "$mntDir1"
            cryptsetup close "$name"
        ;;
        *)
            (>&2 echo "Usage:")
            (>&2 echo "Usage: $0 open name secret device [ additional cryptsetup parameters ]")
            (>&2 echo "Usage: $0 close name")
            exit 1
        ;;
    esac
}

main "$@"

```

It can be used as follows:

```bash
sudo ./cs-map open enc1 secret.bin container.bin

# mounted at $HOME/mnt/enc1_user
# and when done, to close it use

sudo ./cs-map close enc1
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

We can use `--offset (-o)` and `--size` option (both defined as number of 512 byte sectors) to have several non-overlapping encrypted containers on same binary file blob. We can even open several of them at once by adding `--shared` option to `cryptsetup open`:

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
