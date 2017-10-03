#!/bin/bash

# csmap.sh

set -e

if [ $(id -u) != "0" ]; then
    (>&2 echo "! needs sudo")
    exit 1
fi

toolsDir="$(dirname $0)"
lastName=""
lastContainer=""
lastContainerTime=""
lastSecret=""
lastSecretTime=""

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
function umountContainer()
{
    local name=$(validName "$1")
    local mntDir1=$(mntDirRoot "$name")
    local mntDir2=$(mntDirUser "$name")
    
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
}

# name
function mountContainer()
{
    local name=$(validName "$1")
    local mntDir1=$(mntDirRoot "$name")
    local mntDir2=$(mntDirUser "$name")
    local user=${SUDO_USER:-$(whoami)}
    
    mkdir -p "$mntDir1"
    set +e
    mount "/dev/mapper/$name" "$mntDir1"
    if [ "$?" != "0" ]; then
        cryptsetup close "$name"
        rmdir "$mntDir1"
        resetTime
        exit 1
    fi
    set -e
    mkdir -p "$mntDir2"
    bindfs -u $(id -u "$user") -g $(id -g "$user") "$mntDir1" "$mntDir2"
    echo "Mounted ${device} at ${mntDir2}."
}

# name
function closeContainer()
{
    local name=$(validName "$1")
    echo "Closing ${name} ..."
    umountContainer "$name"
    cryptsetup close "$name"
    echo " Closed ${name} !"
}

# name secret container rest
function openContainer()
{
    local name=$(validName "$1")
    lastName="$name"
    local oName=${name:4}
    shift

    local secret="$1"
    checkArg "$secret" "secret"
    lastSecret="$secret"
    if [ -f "$secret" ]; then
        lastSecretTime=$(stat -c %z "$secret")
    fi
    shift

    local device="$1"
    checkArg "$device" "container"
    lastContainer="$device"
    if [ -f "$device" ]; then
        lastContainerTime=$(stat -c %z "$device")
    fi
    shift

    local user=${SUDO_USER:-$(whoami)}
    echo "Opening /dev/mapper/${name} ..."

    local key=$(sudo -E -u "$user" "${toolsDir}/cskey.sh" dec "$secret" | base64 -w 0)
    touchFile "$lastSecret" "$lastSecretTime"
    echo -n "$key" | base64 -d | cryptsetup --type plain -c aes-xts-plain64 -s 512 -h sha512 --shared "$@" open "$device" "$name" -
    echo
    cryptsetup status "/dev/mapper/$name"
    mountContainer "$name"
    echo "To close use:"
    echo "$0 close ${oName}"
    echo "$0 closeAll"    
}

# container bs count seek
function ddContainer()
{
    local container="$1"
    local bs="$2"
    local count="$3"
    local seek="$4"
    local user=${SUDO_USER:-$(whoami)}
    if [ -z "$seek" ]; then
        sudo -u "$user" dd iflag=fullblock if=/dev/urandom of="$container" bs="$bs" count="$count" status=progress
    else
        sudo -u "$user" dd iflag=fullblock if=/dev/urandom of="$container" bs="$bs" count="$count" seek="$seek" status=progress
    fi
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

    local sizeNum="${size:$length:-1}"
    local user=${SUDO_USER:-$(whoami)}

    echo "Creating ${container} with ${sizeNum}${size: -1} (/dev/mapper/${name}) ..."
    if [ "${size: -1}" == "G" ]; then
        ddContainer "$container" "1G" "$sizeNum"
    elif [ "${size: -1}" == "M" ]; then
        ddContainer "$container" "1M" "$sizeNum"
    else
        (>&2 echo "! size can be M or G")
        exit 1  
    fi
    sync

    echo "Creating ${secret} ..."
    sudo -E -u "$user" "${toolsDir}/cskey.sh" enc "$secret"
    echo "You will asked to re-enter password to open the container for the first time ..."
    local key=$(sudo -E -u "$user" "${toolsDir}/cskey.sh" dec "$secret" | base64 -w 0)
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
    if [ -f "$secret" ]; then
        lastSecretTime=$(stat -c %z "$secret")
    fi
    local user=${SUDO_USER:-$(whoami)}
    sudo -E -u "$user" "${toolsDir}/cskey.sh" chp "$secret"
    sleep 1
    touchFile "$secret" "$lastSecretTime"
}

function touchFile()
{
    local file="$1"
    local fileTime="$2"
    if [ -f "$file" ]; then
        #local user=${SUDO_USER:-$(whoami)}
sudo bash -s "$file" "$fileTime" <<'EOF'
    now=$(date +"%Y-%M-%d %T") && date -s "$2" > /dev/null && touch "$1"
    # && date -s "$now"
EOF
    fi
}

function resetTime()
{
    touchFile "$lastContainer" "$lastContainerTime"
    sleep 1
    touchFile "$lastSecret" "$lastSecretTime"
}

function cleanUp()
{
    closeContainer "$lastName"
    resetTime
    exit 0
}

function showChecksum()
{
    sha256sum "$0"
    sha256sum "${toolsDir}/cskey.sh"
    if [ -f "${toolsDir}/aes" ]; then
        sha256sum "${toolsDir}/aes"
    fi
}

# name
function resizeContainer()
{
    local name=$(validName "$1")
    cryptsetup resize "$name"
    resize2fs "/dev/mapper/$name"
}

# olny works for full G/M blocks
function increaseContainer()
{
    local name=$(validName "$1")
    shift
    local size="$1"
    checkArg "$size" "size"
    shift
    local sizeNum="${size:$length:-1}"

    container=$(cryptsetup status "$name" | grep loop: | cut -d ' ' -f 7)
    if [ ! -f "$container" ]; then
        (>&2 echo "! no such container file ${container}")
        exit 1
    fi
    local currentSize=$(stat -c "%s" "$container")
    if [ "${size: -1}" == "G" ]; then
        local sizeG=$(($currentSize / (1024 * 1024 * 1024)))
        if [ "$sizeG" = "0" ]; then # keep it simple
            (>&2 echo "! cannot determine current size in G")
            exit 1
        fi
        ddContainer "$container" "1G" "$sizeNum" "$sizeG"
    elif [ "${size: -1}" == "M" ]; then
        local sizeM=$(($currentSize / (1024 * 1024)))
        if [ "$sizeM" = "0" ]; then
            (>&2 echo "! cannot determine current size in M")
            exit 1
        fi
        ddContainer "$container" "1M" "$sizeNum" "$sizeM"
    else
        (>&2 echo "! size can be M or G")
        exit 1  
    fi
    resizeContainer "$name"
}

function showHelp()
{
    local bn=$(basename "$0")
    (>&2 echo "Usage:")
    (>&2 echo " $bn open secret device [ additional cryptsetup parameters ]")
    (>&2 echo " $bn openLive secret device [ additional cryptsetup parameters ]")
    (>&2 echo " $bn openNamed name secret device [ additional cryptsetup parameters ]")
    (>&2 echo " $bn close name")
    (>&2 echo " $bn closeAll")
    (>&2 echo " $bn mount name")
    (>&2 echo " $bn umount name")
    (>&2 echo " $bn create secret container size [ additional cryptsetup parameters ]")
    (>&2 echo "    size should end in M or G, secret and container files will be overwritten, use with care")
    (>&2 echo " $bn changePass secret")
    (>&2 echo " $bn resize name")
    (>&2 echo " $bn increase name size") 
    (>&2 echo "    size should end in M or G")
}

function main()
{
    showChecksum
    local mode="$1"
    shift

    case "$mode" in
        open|o)
            openContainer "-" "$@"
        ;;
        openNamed|openName|on)
            openContainer "$@"  
        ;;
        openLive|ol)
            openContainer "-" "$@"
            trap cleanUp SIGHUP SIGINT SIGTERM
            tput setaf 1
            read -p "Press Enter or Ctrl+C to close the container ..."
            tput sgr 0
            echo
            cleanUp
        ;;
        close|c)
            closeContainer "$@"
        ;;
        mount)
            mountContainer "$1"
        ;;
        umount)
            umountContainer "$1"
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
        resize|r)
            resizeContainer "$1"
        ;;
        increase|inc)
            increaseContainer "$@"
        ;;
        *)
            showHelp
            exit 1
        ;;
    esac
}

main "$@"
