#!/bin/bash

# csmap.sh

set -eu

if [ $(id -u) != "0" ]; then
    (>&2 echo "! needs sudo")
    exit 1
fi

user="${SUDO_USER:-$(whoami)}"
toolsDir="$(dirname $0)"
lastName=""
lastContainer=""
lastContainerTime=""
lastSecret=""
lastSecretTime=""
CSKEY_OPS="${CSKEY_OPS:-}"

currentScriptPid=$$
function failed()
{
    kill -9 "$currentScriptPid"
}

# error
function showError()
{
    (>&2 echo "! $1")
    failed
}

function newName()
{
    local newName=""
    while :
    do
        #a-zA-Z0-9
        newName=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 4 | head -n1)
        if [ ! -e "/dev/mapper/${newName}" ]; then
            break
        fi
    done
    echo "$newName"
}

# value valueName
function checkArg()
{
    local value=$1
    local key=$2
    if [ -z "$value" ]; then
        showError "${key} required"
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
    if [[ "$name" != csm-* ]]; then
        name="csm-${name}"
    fi
    echo ${name//[^a-zA-Z0-9-]/_}
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
    echo "$(mntDirRoot "$name")-user"
}

# file
function ownFile()
{
    local file="$1"
    if [ -f "$file" ]; then
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
    sleep 1
    umount "$mntDir2" && rmdir "$mntDir2"
    set +e
    fuser -km "$mntDir1"
    set -e
    sleep 1
    set +e
    umount "$mntDir1" && rmdir "$mntDir1"
    set -e
}

# name
function mountContainer()
{
    local name=$(validName "$1")
    local mntDir1=$(mntDirRoot "$name")
    local mntDir2=$(mntDirUser "$name")
    
    mkdir -p "$mntDir1"
    set +e
    mount "/dev/mapper/$name" "$mntDir1"
    if [ "$?" != "0" ]; then
        cryptsetup close "$name"
        rmdir "$mntDir1"
        resetTime
        echo " Closed ${name} !"
        failed
    fi
    set -e
    mkdir -p "$mntDir2"
    bindfs -u $(id -u "$user") -g $(id -g "$user") "$mntDir1" "$mntDir2"
    echo "Mounted ${name} at ${mntDir2}."
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

    local secret="${1:-}"
    checkArg "$secret" "secret"
    lastSecret="$secret"
    if [ -f "$secret" ]; then
        lastSecretTime=$(stat -c %z "$secret")
    fi
    shift

    local device="${1:-}"
    checkArg "$device" "container"
    lastContainer="$device"
    if [ -f "$device" ]; then
        lastContainerTime=$(stat -c %z "$device")
    fi
    shift

    echo "Opening /dev/mapper/${name} ..."

    local key=$(sudo -E "${toolsDir}/cskey.sh" dec "$secret" $CSKEY_OPS | base64 -w 0)
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
    local seek="${4:-}"
    
    if [ -z "$seek" ]; then
        sudo -u "$user" dd iflag=fullblock if=/dev/urandom of="$container" bs="$bs" count="$count" status=progress
    else
        sudo -u "$user" dd iflag=fullblock if=/dev/urandom of="$container" bs="$bs" count="$count" seek="$seek" status=progress
    fi
}

# size
function checkNumber()
{
    local re='^[0-9]+$'
    if ! [[ "$1" =~ $re ]] ; then
        showError "$1 not a number"
    fi
}

# secret
function createSecret()
{
    local secret="$1"
    echo "Creating ${secret} ..."
    sudo -E "${toolsDir}/cskey.sh" enc "$secret" $CSKEY_OPS
    ownFile "$secret"
}

# name secret container size rest
function createContainer()
{
    local name=$(validName "-")
    
    local secret="${1:-}"
    checkArg "$secret" "secret"
    shift

    local container="${1:-}"
    checkArg "$container" "container"
    if [ -f "$container" ]; then
        read -p "Overwrite container file ${container} [y | any key to exit]: " overwriteContainer
        if [ "$overwriteContainer" != "y" ]; then
            showError "nothing to do"
        fi
    fi
    shift

    local size="${1:-}"
    checkArg "$size" "size"
    shift

    local sizeNum="${size: : -1}"
    checkNumber "$sizeNum"

    echo "Creating ${container} with ${sizeNum}${size: -1} (/dev/mapper/${name}) ..."
    if [ "${size: -1}" = "G" ]; then
        ddContainer "$container" "1G" "$sizeNum"
    elif [ "${size: -1}" = "M" ]; then
        ddContainer "$container" "1M" "$sizeNum"
    else
        showError "size can be M or G"
    fi
    sync
    
    if [ -f "$secret" ]; then
        lastSecret="$secret"
        lastSecretTime=$(stat -c %z "$secret")
        read -p "Overwrite secret file $secret [y | any key to reuse]: " overwriteSecret
        case "$overwriteSecret" in
            y)
            createSecret "$secret"
            ;;
        esac
    else
        createSecret "$secret"
    fi
    
    echo "(Re-)enter password to open the container for the first time ..."
    local key=$(sudo -E "${toolsDir}/cskey.sh" dec "$secret" $CSKEY_OPS | base64 -w 0)
    echo
    touchFile "$lastSecret" "$lastSecretTime"
    echo -n "$key" | base64 -d | cryptsetup --type plain -c aes-xts-plain64 -s 512 -h sha512 "$@" open "$container" "$name" -

    echo "Creating filesystem in /dev/mapper/$name ..."
    mkfs -m 0 -t ext4 "/dev/mapper/$name"
    sync
    sleep 2
    cryptsetup close "$name"
    ownFile "$container"
    echo "Done! To open container use:"
    echo "$0 open ${secret} ${container}"
}

function closeAll()
{
    for filename in /dev/mapper/*; do
        [ -e "$filename" ] || continue
        local name=$(basename "$filename")
        [ "$name" != "control" ] || continue
        [[ "$name" == csm-* ]] || continue
        closeContainer "$name"
    done
}

function changePass()
{
    local secret="${1:-}"
    checkArg "$secret" "secret"
    if [ -f "$secret" ]; then
        lastSecretTime=$(stat -c %z "$secret")
    fi
    shift
    sudo -E "${toolsDir}/cskey.sh" chp "$secret" "$@"
    ownFile "$secret"
    sleep 1
    touchFile "$secret" "$lastSecretTime"
}

function touchDiskFile()
{
    if [ ! -f "$1" ]; then
        (>&2 echo "! no file $1")
        failed
    fi
    local time="${2:-}"
    if [ -z "$time" ]; then
        time=$(stat -c %z "$1")
    fi
    echo "Setting file times to: $time"
    touchFile "$1" "$time"
    stat "$1"
}

function touchFile()
{
    local file="$1"
    local fileTime="$2"
    if [ -f "$file" ]; then
sudo bash -s "$file" "$fileTime" <<'EOF'
    now=$(date +"%F %T.%N %z") && date -s "$2" > /dev/null && touch "$1"
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
    tput sgr 0
    echo
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

# only works for full G/M blocks
function increaseContainer()
{
    local name=$(validName "$1")
    shift
    local size="${1:-}"
    checkArg "$size" "size"
    shift
    local sizeNum="${size: : -1}"
    checkNumber "$sizeNum"

    container=$(cryptsetup status "$name" | grep loop: | cut -d ' ' -f 7)
    if [ ! -f "$container" ]; then
        showError "no such container file ${container}"
    fi
    local currentSize=$(stat -c "%s" "$container")
    if [ "${size: -1}" = "G" ]; then
        local sizeG=$(($currentSize / (1024 * 1024 * 1024)))
        if [ "$sizeG" = "0" ]; then # keep it simple
            showError "cannot determine current size in G"
        fi
        ddContainer "$container" "1G" "$sizeNum" "$sizeG"
    elif [ "${size: -1}" = "M" ]; then
        local sizeM=$(($currentSize / (1024 * 1024)))
        if [ "$sizeM" = "0" ]; then
            showError "cannot determine current size in M"
        fi
        ddContainer "$container" "1M" "$sizeNum" "$sizeM"
    else
        showError "size can be M or G"
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
    (>&2 echo "    size should end in M or G")
    (>&2 echo " $bn changePass secret [t m p]")
    (>&2 echo " $bn resize name")
    (>&2 echo " $bn increase name bySize") 
    (>&2 echo "    size should end in M or G")
    (>&2 echo " $bn touch file [time]")
    (>&2 echo "    if set, time has to be in format: \"$(date +"%F %T.%N %z")\"")
    (>&2 echo " To pass cskey.sh options in open/create use:")
    (>&2 echo "    CSKEY_OPS='-k -h -p 8 -m 14 -t 1000 --' sudo -E csmap.sh openLive container.bin")
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
            changePass "$@"
        ;;
        resize|r)
            resizeContainer "$1"
        ;;
        increase|inc)
            increaseContainer "$@"
        ;;
        touch)
            touchDiskFile "$@"
        ;;
        *)
            showHelp
        ;;
    esac
}

main "$@"
