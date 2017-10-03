#Cryptsetup in Plain Mode

2018-12-16

<!--- tags: linux encryption -->

`cryptsetup` in *plain* mode is a very versatile tool to create encrypted containers.

<div id='toc'></div>

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

##Resizing a Container

To increase size of the container file, we can use use again `dd` with *seek* parameter to skip it size in *bs* size blocks:

```bash
# resize container from 30G to 40G (i.e., +10G)
dd iflag=fullblock if=/dev/urandom of=container.bin bs=1G count=10 seek=30
```

Now `cryptsetup open` container, but do not mount it:

```bash
sudo e2fsck -f /dev/mapper/enc
sudo resize2fs /dev/mapper/enc
sudo e2fsck -f /dev/mapper/enc
```

To shrink, after resize use `truncate` tool on container file.

##Better Plain Mode Passwords

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

Let us create a bash helper script `cs-key.sh` to manage key contents. It uses `ccrypt` to save container key, or if found it uses my [aes](#r/cpp-aes-tool.md) tool. The only benefit of my `aes` tool is that it (same as *dm-crypt*) always decrypts the data even if the password is wrong, while `ccrypt` is designed to give an error, which I consider unsafe.

```bash
#!/bin/bash

# cs-key.sh

set -e

# none of values in this file is secret
# change argon2 params as it fits you here
at="${3:-1000}"
am="${4:-14}"
ap="${5:-8}"

# set to 1 to use my aes tool, 0 uses ccrypt
toolsDir="$(dirname $0)"
useAes=0
if [ -f "${toolsDir}/aes" ]; then
    useAes=1
fi

function encryptedKeyLength()
{
    if [ "$useAes" = "1" ]; then
        echo 560
    else
        echo 544
    fi
}

function encryptAes()
{
    local pass=$1
    if [ "$useAes" = "1" ]; then
        "${toolsDir}/aes" -r /dev/urandom -e -f <(echo -n "$pass")
    else
        ccrypt -e -f -k <(echo -n "$pass")
    fi
}

function decryptAes()
{
    local pass=$1
    if [ "$useAes" = "1" ]; then
        "${toolsDir}/aes" -d -f <(echo -n "$pass")
    else
        ccrypt -d -k <(echo -n "$pass")
    fi
}

# file pass key
function encodeKey()
{
    local file="$1"
    local pass="$2"
    local key="$3"
    local salt=$(head -c 32 /dev/urandom | base64 -w 0)
    hash=$(echo -n "$pass" | argon2 "$salt" -t $at -p $ap -m $am -l 128 -r)
    
    if [ "$file" = "-" ]; then
        file="/dev/stdout"
    fi
    
    > "$file"
    echo -n "$salt" | base64 -d >> "$file"
    echo -n "$key" | base64 -d | encryptAes "$hash" >> "$file"
    # random file size
    local r=$((1 + RANDOM % 512))
    head -c "$r" /dev/urandom >> "$file"
}

# file pass
function decodeKey()
{
    local file="$1"
    local pass="$2"
    local keyLength=$(encryptedKeyLength)
    
    if [ -e "$file" ] || [ "$file" = "-" ]; then
        local fileData=$(head -c 600 "$file" | base64 -w 0)
        local salt=$(echo -n "$fileData" | base64 -d | head -c 32 | base64 -w 0)
        local data=$(echo -n "$fileData" | base64 -d | tail -c +33 | head -c "$keyLength" | base64 -w 0)
        local hash=$(echo -n "$pass" | argon2 "$salt" -t $at -p $ap -m $am -l 128 -r)
        echo -n "$data" | base64 -d | decryptAes "$hash"
    else
        (>&2 echo "! no such file: $file")
        exit 1
    fi
}

function readPass()
{
    read -p "New password: " -s pass
    (>&2 echo)
    if [ -t 0 ] ; then
        read -p "Renter password: " -s pass2
        (>&2 echo)
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
            #echo $key | base64 -d > out.txt
            encodeKey "$file" "$pass" "$key"
        ;;
        dec)
            read -p "Enter password: " -s pass
            decodeKey "$file" "$pass"
        ;;
        chp)
            read -p "Current password: " -s pass1
            (>&2 echo)
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

Save it as `cs-key.sh` and make it executable. We can use `cs-key.sh` to generate a secret file (we only need to do this once):

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

With `cs-key.sh` ready, we can now automate for convenience open / close with a second script `cs-map.sh` (`cs-key.sh` should be in same folder):

```bash
#!/bin/bash

# cs-map.sh

set -e

if [ $(id -u) != "0" ]; then
    (>&2 echo "! needs sudo")
    exit 1
fi

toolsDir="$(dirname $0)"

function newName()
{
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n1
}

# value valueName
function checkArg()
{
    local value=$1
    local key=$2
    if [ -z "$value" ]; then
        (>&2 echo "! ${key} required")
        exit 1
    fi
}

# name
function validName()
{
    local name="$1"
    checkArg "$name" "name"
    if [ "$name" = "-" ]; then
        name="$(newName)"
    fi
    if [[ "$name" != csm_* ]]; then
        name="csm_${name}"
    fi
    echo ${name//[^a-zA-Z0-9]/_}
}

# name
function mntDirRoot()
{
    local name=$1
    echo "$HOME/mnt/${name}"
}

# name
function mntDirUser()
{
    local name=$1
    echo "$(mntDirRoot "$name")_user"
}

# name
function closeContainer()
{
    local name=$(validName "$1")
    local mntDir1=$(mntDirRoot "$name")
    local mntDir2=$(mntDirUser "$name")

    echo "Closing ${name} ..."

    set +e
    fuser -km "$mntDir2"
    set -e
    sleep 2
    umount "$mntDir2"
    rmdir "$mntDir2"
    set +e
    fuser -km "$mntDir1"
    set -e
    sleep 2
    umount "$mntDir1"
    rmdir "$mntDir1"
    cryptsetup close "$name"
    echo " Closed ${name}!"
}

# name secret container rest
function openContainer()
{
    local name=$(validName "$1")
    local oName=${name:4}
    shift

    local secret="$1"
    checkArg "$secret" "secret"
    shift

    local device="$1"
    checkArg "$device" "container"

    shift

    local mntDir1=$(mntDirRoot "$name")
    local mntDir2=$(mntDirUser "$name")

    echo "Opening /dev/mapper/${name} ..."

    "${toolsDir}/cs-key.sh" dec "$secret" | cryptsetup --type plain -c aes-xts-plain64 -s 512 -h sha512 "$@" open "$device" "$name" -
    echo
    mkdir -p "$mntDir1"
    set +e
    mount "/dev/mapper/$name" "$mntDir1"
    if [ "$?" != "0" ]; then
        cryptsetup close "$name"
        exit 1
    fi
    set -e
    mkdir -p "$mntDir2"
    user=${SUDO_USER:-$(whoami)}
    bindfs -u $(id -u "$user") -g $(id -g "$user") "$mntDir1" "$mntDir2"
    echo "Mounted ${device} at ${mntDir2}. To close use:"
    echo "$0 close ${oName}"
    echo "$0 closeAll"    
}

# name secret container size rest
function createContainer()
{
    local name=$(validName "-")

    local secret="$1"
    checkArg "$secret" "secret"
    shift

    local container="$1"
    checkArg "$container" "container"
    shift

    local size="$1"
    checkArg "$size" "size"
    shift

    sizeNum="${size:$length:-1}"

    echo "Creating ${container} with ${sizeNum}${size: -1} (/dev/mapper/${name}) ..."

    if [ "${size: -1}" == "G" ]; then
        dd iflag=fullblock if=/dev/urandom of="$container" bs=1G count="$sizeNum"
    elif [ "${size: -1}" == "M" ]; then
        dd iflag=fullblock if=/dev/urandom of="$container" bs=1M count="$sizeNum"
    else
        (>&2 echo "! size can be M or G")
        exit 1  
    fi
    sync

    echo "Creating ${secret} ..."

    "${toolsDir}/cs-key.sh" enc "$secret"
    echo "You will asked to re-enter password to open the container for the first time ..."
    "${toolsDir}/cs-key.sh" dec "$secret" | cryptsetup --type plain -c aes-xts-plain64 -s 512 -h sha512 "$@" open "$container" "$name" -

    echo "Creating file system ..."
    mkfs -m 0 -t ext4 "/dev/mapper/$name"
    sync
    sleep 2
    cryptsetup close "$name"
    echo "Done! Container is closed. To open container use:"
    echo "$0 open ${secret} ${container}"
}

function closeAll()
{
    for filename in /dev/mapper/*; do
        [ -e "$filename" ] || continue
        local name=$(basename "$filename")
        [ "$name" != "control" ] || continue
        [[ "$name" == csm_* ]] || continue
        closeContainer "$name"
    done
}

function showHelp()
{
    (>&2 echo "Usage:")
    (>&2 echo " $0 open secret device [ additional cryptsetup parameters ]")
    (>&2 echo " $0 openNamed name secret device [ additional cryptsetup parameters ]")
    (>&2 echo " $0 close name")
    (>&2 echo " $0 closeAll")
    (>&2 echo " $0 create secret container size [ additional cryptsetup parameters ]")
    (>&2 echo "    size should end in M or G, secret and container files will be overwritten, use with care")   
}

function main()
{
    local mode="$1"
    shift

    case "$mode" in
        open|o)
            openContainer "-" "$@"
        ;;
        openNamed|openName|openN|open2|o2)
            openContainer "$@"  
        ;;
        close|c)
            closeContainer "$@"
        ;;
        create)
            createContainer "$@"            
        ;;
        closeAll|ca|x)
            closeAll
        ;;
        *)
            showHelp
            exit 1
        ;;
    esac
}

main "$@"

```

The `cs-map.sh` script can be used as follows:

```bash
sudo ./cs-map open secret.bin container.bin

# mounted at $HOME/mnt/cms_XXXX_user
# and when done, to close it use

sudo ./cs-map close XXX
```

We may also use the script create a new container file (size can be either in M or G):

```bash
sudo ./cs-map.sh create secret.bin container.bin 30M
```

These scripts use the following helper tools:

```bash
sudo apt install cryptsetup bindfs argon2 ccrypt
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
* https://www.gnu.org/software/bash/manual/bashref.html

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2018/2018-04-26-Lubuntu-18.04-Disable-initfsram-Resume.md'>Lubuntu 18.04 Disable initfsram Resume</a></ins>
