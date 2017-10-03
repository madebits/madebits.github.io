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

# file
function ownFile()
{
    local file="$1"
    if [ -f "$file" ]; then
        local user=${SUDO_USER:-$(whoami)}
        chown $(id -un "$user"):$(id -gn "$user") "$file"
    fi
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
    umount "$mntDir2" && rmdir "$mntDir2"
    set +e
    fuser -km "$mntDir1"
    set -e
    sleep 2
    umount "$mntDir1" && rmdir "$mntDir1"
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
    local user=${SUDO_USER:-$(whoami)}
    echo "Opening /dev/mapper/${name} ..."

    local key=$(sudo -u "$user" "${toolsDir}/cs-key.sh" dec "$secret" | base64 -w 0)
    echo -n "$key" | base64 -d | cryptsetup --type plain -c aes-xts-plain64 -s 512 -h sha512 "$@" open "$device" "$name" -
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
        sudo -u "$user" dd iflag=fullblock if=/dev/urandom of="$container" bs=1G count="$sizeNum"
    elif [ "${size: -1}" == "M" ]; then
        sudo -u "$user" dd iflag=fullblock if=/dev/urandom of="$container" bs=1M count="$sizeNum"
    else
        (>&2 echo "! size can be M or G")
        exit 1  
    fi
    sync

    echo "Creating ${secret} ..."

    local user=${SUDO_USER:-$(whoami)}
    sudo -u "$user" "${toolsDir}/cs-key.sh" enc "$secret"
    echo "You will asked to re-enter password to open the container for the first time ..."
    local key=$(sudo -u "$user" "${toolsDir}/cs-key.sh" dec "$secret" | base64 -w 0)
    echo -n "$key" | base64 -d | cryptsetup --type plain -c aes-xts-plain64 -s 512 -h sha512 "$@" open "$container" "$name" -

    echo "Creating file system ..."
    mkfs -m 0 -t ext4 "/dev/mapper/$name"
    sync
    sleep 2
    cryptsetup close "$name"
    ownFile "$container"
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

function changePass()
{
    local secret="$1"
    checkArg "$secret" "secret"
    local user=${SUDO_USER:-$(whoami)}
    sudo -u "$user" "${toolsDir}/cs-key.sh" chp "$secret"
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
    (>&2 echo " $0 changePass secret")  
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
        changePass|chp)
            changePass "$1"
        ;;
        *)
            showHelp
            exit 1
        ;;
    esac
}

main "$@"
