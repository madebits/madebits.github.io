#!/bin/bash -

# csman.sh

PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
\export PATH
\unalias -a
hash -r
ulimit -H -c 0 --
IFS=$' \t\n'

set -eu -o pipefail

if [ $(id -u) != "0" ]; then
    (>&2 echo "! needs sudo")
    exit 1
fi

user="${SUDO_USER:-$(whoami)}"
toolsDir="$(dirname $0)"
csmkeyTool="${toolsDir}/cskey.sh"
lastName=""
lastContainer=""
lastContainerTime=""
lastSecret=""
lastSecretTime=""
csOptions=()
csiOptions=()
ckOptions=()
ckOptions2=()
csmCleanScreen="0"
csmName=""
csmLive="0"
mkfsOptions=()
csmChain="1"
csmMount="1"
cmsMountReadOnly="0"
csmListShowKey="0"
csmCreateOverwriteOnly="0"

########################################################################

currentScriptPid=$$
function failed()
{
    kill -9 "$currentScriptPid"
}

function logError()
{
    (>&2 echo "$@")
}

# error
function onFailed()
{
    logError "!" "$@"
    failed
}

# value valueName
function checkArg()
{
    if [ -z "$1" ]; then
        onFailed "required ${2:-}"
    fi
}

# size
function checkNumber()
{
    local re='^[0-9]+$'
    if ! [[ "$1" =~ $re ]] ; then
        onFailed "$1 not a number"
    fi
}

function clearScreen()
{
    if [ "$csmCleanScreen" = "1" ]; then
        tput reset
    fi
}

########################################################################

# file
function ownFile()
{
    if [ -f "${1:-}" ]; then
        chown $(id -un "$user"):$(id -gn "$user") -- "$1"
    fi
}

# fileOrDir
function touchDiskFile()
{
    file="${1:-}"
    checkArg "$file" "fileOrDir"
    local time="${2:-}"
    if [ -z "$time" ]; then
        time=$(stat -c %z "$file")
    fi
    echo "Setting file times to: $time"
    if [ -f "$file" ]; then
        ownFile "$file"
        touchFile "$file" "$time"
        stat "$file"
    elif [ -d "$file" ]; then
        find "$file" -type f | while IFS=$'\n' read -r f; do
            echo " $f"
            ownFile "$f"
            touchFile "$f" "$time"
        done
    else
        onFailed "not found: $file"
    fi
    echo "Done"
}

# file time
function touchFile()
{
    local file="$1"
    local fileTime="${2:-}"
    if [ -f "$file" ]; then
        if [ -z "${fileTime}" ]; then
            if [ -d "/usr" ]; then
                fileTime=$(stat -c %z "/usr")
            else
                fileTime=$(stat -c %z -- "$HOME")
            fi
        fi
        set +e
        #sudo bash -s "$file" "$fileTime" <<-'EOF'
            now=$(date +"%F %T.%N %z") && date -s "${fileTime}" > /dev/null && touch -- "$file" 2> /dev/null
            date -s "$now" > /dev/null
        #   EOF
        set -e
    fi
}

function resetTime()
{
    touchFile "$lastContainer" "$lastContainerTime"
    touchFile "$lastSecret" "$lastSecretTime"
}

########################################################################

function newName()
{
    local newName=""
    while :
    do
        #a-zA-Z0-9
        newName=$(cat /dev/urandom | tr -dc '[:lower:]' | fold -w 3 | head -n1)
        if [ ! -e "/dev/mapper/${newName}" ]; then
            break
        fi
    done
    echo "$newName"
}

# name
function validName()
{
    local name="${1:-}"
    checkArg "$name" "name"
    if [ "$name" = "-" ]; then
        name="$(newName)"
    fi
    if [[ "$name" != csm-* ]]; then
        name="csm-${name}"
    fi
    name="${name//[^[:lower:][:upper:][:digit:]-]/}"
    checkArg "$name" "name"
    echo "$name"
}

# name
function innerName()
{
    echo "${1}_"
}

# name 1
function getDevice()
{
    local name="$1"
    # inner
    if [ "${2:-}" = "1" ]; then
        name="$(innerName "$name")"
    fi
    echo "/dev/mapper/$name"
}

function cleanMntDir()
{
    set +e
    rmdir "$HOME/mnt/tmpcsm" 2> /dev/null
    find "$HOME/mnt/" -maxdepth 1  -type d -name '?csm-*' -print0 | xargs -0 -r -n 1 -I {} rmdir {} 2> /dev/null
    set -e
}

# name
function mntDirRoot()
{
    echo "$HOME/mnt/${1}"
}

# name
function mntDirUser()
{
    echo "$HOME/mnt/u${1}"
}

########################################################################

# name
function umountContainer()
{
    local name=$(validName "${1:-}")
    local mntDir1=$(mntDirRoot "$name")
    local mntDir2=$(mntDirUser "$name")
    
    if [ -d "$mntDir2" ]; then
        set +e
        fuser -km "$mntDir2"
        set -e
        sleep 1
        umount "$mntDir2" && rmdir "$mntDir2"
    fi
    if [ -d "$mntDir1" ]; then
        set +e
        fuser -km "$mntDir1"
        set -e
        sleep 1
        set +e
        umount "$mntDir1" && rmdir "$mntDir1"
        set -e
    fi
}

# name
function mountContainer()
{
    local name=$(validName "${1:-}")
    local mntDir1=$(mntDirRoot "$name")
    local mntDir2=$(mntDirUser "$name")
    
    # check for inner one first
    local hasInner="1"
    local dev="$(getDevice "$name" "1")"
    if [ ! -e "$dev" ]; then
        hasInner="0"
        dev="$(getDevice "$name" "0")"
    fi
    if [ ! -e "$dev" ]; then
        onFailed "no mapper device: $name"
    fi
        
    local ro=""
    if [ "$cmsMountReadOnly" = "1" ]; then
        echo "# mounting read-only"
        ro="-o ro"
    fi
    
    mkdir -p "$mntDir1"
    set +e
    mount ${ro} -o users "$dev" "$mntDir1"
    if [ "$?" != "0" ]; then
        closeContainerByName "$name"
        rmdir "$mntDir1"
        failed
    fi
    set -e
    set +e
    chown $(id -un "$user"):$(id -gn "$user") "$mntDir1" 2> /dev/null
    set -e
    #mkdir -p "$mntDir2"
    #bindfs ${ro} --multithreaded -u $(id -u "$user") -g $(id -g "$user") "$mntDir1" "$mntDir2"
    #echo "Mounted ${dev} at ${mntDir2}"
    echo "Mounted ${dev} at ${mntDir1}"
}

function closeContainerByName()
{
    local name=$(validName "${1:-}")
    
    local dev="$(getDevice "$name" "1")"
    if [ -e "$dev" ]; then
        if [ -z "$lastContainer" ]; then
            set +e
            lastContainer="$(getContainerFile "$name")"
            set -e
        fi
        cryptsetup close "$(innerName "$name")"
    fi
    dev="$(getDevice "$name" "0")"
    if [ -e "$dev" ]; then
        cryptsetup close "$name"
    fi
    resetTime
    echo " Closed ${name} !"
}

# name
function closeContainer()
{
    local name=$(validName "${1:-}")
    echo "Closing ${name} ..."
    umountContainer "$name"
    closeContainerByName "$name"
}

# list
function closeAll()
{
    for filename in /dev/mapper/*; do
        [ -e "$filename" ] || continue
        local name=$(basename -- "$filename")
        [ "$name" != "control" ] || continue
        [[ "$name" == csm-* ]] || continue
        [ "${name: -1}" != "_" ] || continue
        case "${1:-}" in
            1)
            listContainer "$name"
            echo
            ;;
            2)
                if isSameContainerFile "$name" "${2:-}" ; then
                    csmIsContainerFileOpen="$name"
                    return
                fi
            ;;
            *)
            closeContainer "$name"
            ;;
        esac
    done
}

# file
csmIsContainerFileOpen=""
function isContainerFileOpen()
{
    csmIsContainerFileOpen=""
    closeAll 2 "$1"
}

# name file

function isSameContainerFile()
{
    local container="$(getContainerFile "$1")"
    if [ "$container" = "$2" ]; then
        return 0
    fi
    return 1
}

# name
function getContainerFile()
{
    local name=$(validName "${1:-}")
    #local f="$(cryptsetup status "$name" | grep loop: | cut -d ' ' -f 7)"
    set -- $(cryptsetup status "$name" | grep loop:)
    shift
    local f="$@"
    if [ -z "$f" ]; then
        #f="$(cryptsetup status csm-dwpi | grep device: | cut -d ' ' -f 5)"
        set -- $(cryptsetup status "$name" | grep device:)
        shift
        f="$@"
    fi
    echo "$f"
}

#dev
function getChipher()
{
    set -- $(cryptsetup status "$1" | grep cipher: )
    shift
    echo "$@"
}

function getMode()
{
    set -- $(cryptsetup status "$1" | grep mode:)
    shift
    echo "$@"
}

#dev
function getDmKey()
{
    #local k=$(dmsetup table --target crypt --showkey "${dev}" | cut -d ' ' -f 5)
    set -- $(dmsetup table --target crypt --showkey "$1")
    echo $5
}

function listContainer()
{
    local name=$(validName "${1:-}")
    local oName=${name:4}
    echo -e "Name:\t$oName\t$name"
    local container="$(getContainerFile "$name")"
    if [ -z "$container" ]; then
        return
    fi
    
    local mode="$(getMode "$name")"
    local cipher=""
    echo -e "File:\t$container\t$mode"
    local dev="$(getDevice "$name" "0")"
    local lastDev=""
    if [ -e "$dev" ]; then
        lastDev="$dev"
        time=$(stat -c %z "$dev")
        echo -e "Open:\t${time}"
        cipher="$(getChipher "$dev")"
        set +e
        local label="$(e2label "$dev" 2> /dev/null)"
        set -e
        echo -e "Device:\t${dev}\t${cipher}\t${label}"
        if [ "$csmListShowKey" = "1" ]; then
            local k=$(getDmKey "$dev")
            echo -e "RawKey:\t$k"
        fi
    fi
    dev="$(getDevice "$name" "1")"
    if [ -e "$dev" ]; then
        lastDev="$dev"
        cipher="$(getChipher "$dev")"
        set +e
        local label="$(e2label "$dev" 2> /dev/null)"
        set -e
        echo -e "Device:\t${dev}\t${cipher}\t${label}"
        if [ "$csmListShowKey" = "1" ]; then
            local k=$(getDmKey "$dev")
            echo -e "RawKey:\t$k"
        fi
    fi
    local mntDir1=$(mntDirRoot "$name")
    local mntDir2=$(mntDirUser "$name")
    if [ -d "$mntDir1" ]; then
        
        local m="$(mount | grep "$mntDir1")"
        if [ -n "$m" ]; then
            m="mounted"
        fi
        echo -e "Dir:\t$mntDir1\t$m\t$(stat -c "%U %G" "$mntDir1")"
    fi
    if [ -d "$mntDir2" ]; then
        local m="$(mount | grep "$mntDir2")"
        if [ -n "$m" ]; then
            m="mounted"
        fi
        echo -e "Dir:\t$mntDir2\t$m\t$(stat -c "%U %G" "$mntDir2")"
    fi
    if [ -n "$lastDev" ]; then
        set +e
        local df1=$(df --output=itotal,iused,iavail,ipcent "$lastDev" 2> /dev/null)
        local df2=$(df --output=size,used,avail,pcent -h "$lastDev" 2> /dev/null)
        set -e
        if [ -n "$df1" ] || [ -n "$df2" ]; then
            echo -e "Usage:\t$lastDev :"
            echo -e "$df1\n$df2" | column -t
        fi
    fi
}

########################################################################

function getVolumeDefaultLabel()
{
    if [ -f "${1:-}" ]; then
        echo -n "$(basename -- "$1")" | tr -s [:space:] | tr [:space:] '_'
    fi
}

function umountDevice()
{
    local device="$1"
    if [ -b "${device}" ]; then
        set +e
        ls ${device}?* 2>/dev/null | xargs -r -n 1 -I {} fuser -km {}
        ls ${device}?* 2>/dev/null | xargs -r -n 1 umount
        set -e
    fi
}

#key name device
function openContainerByName()
{
    local key="$1"
    local name="$2"
    local device="$3"
    
    umountDevice "${device}"
    
    local cro=""
    if [ "$cmsMountReadOnly" = "1" ]; then
        echo "# opening read-only"
        cro="--readonly"
    fi
    
    local dev="$(getDevice "$name" "0")"
    echo "Opening ${dev} ..."
    echo -n "$key" | base64 -d | cryptsetup --type plain -c aes-xts-plain64 -s 512 -h sha512 --shared $cro "${csOptions[@]}" open "${device}" "${name}" -
    cryptsetup status "${dev}"
    local lastDev="${dev}"
    
    if [ "$csmChain" = "1" ]; then
        local name1="$(innerName "$name")"
        local dev1="$(getDevice "$name" "1")"
        echo "Opening ${dev1} ..."
        set +e
        echo -n "${key}" | base64 -d | cat - <(echo -n "different key") | cryptsetup --type plain -c twofish-cbc-essiv:sha256 -s 256 -h sha512 $cro "${csiOptions[@]}" open "${dev}" "${name1}" -
        if [ "$?" != "0" ]; then
            closeContainerByName "$name"
            failed
        fi
        set -e
        cryptsetup status "${dev1}"
        lastDev="${dev1}"
    fi
    
    # set default label if volume has no label, may fail if no FS
    if [ -n "$lastDev" ]; then
        local label=""
        set +e
        label="$(e2label "$lastDev" 2> /dev/null)"
        set -e
        if [ -z "$label" ] && [ -f "$device" ]; then
            label=$(getVolumeDefaultLabel "$device")
            if [ -n "$label" ]; then
                set +e
                e2label "$lastDev" "$label" 2> /dev/null
                set -e
            fi
        fi
        set +e
        label="$(e2label "$lastDev" 2> /dev/null)"
        set -e
        if [ -n "$label" ]; then
            echo "# label: $label"
        fi
    fi
}

# name secret container rest
function openContainer()
{
    local name=$(validName "${1:-}")
    lastName="$name"
    local oName=${name:4}
    shift

    local device="${1:-}"
    checkArg "$device" "container"
    lastContainer="$device"
    if [ -f "$device" ]; then
        lastContainerTime=$(stat -c %z "$device")
    fi
    if [ ! -e "$device" ]; then
        resetTime
        onFailed "cannot open: $device"
    fi
    shift
    
    isContainerFileOpen "$device"
    if [ -n "$csmIsContainerFileOpen" ]; then
        listContainer ${csmIsContainerFileOpen}
        logError
        onFailed "${device} is already open (${csmIsContainerFileOpen})"
    fi
    
    local secret="${1:-}"
    checkArg "$secret" "secret"
    lastSecret="$secret"
    if [ -f "$secret" ] && [ "$secret" != "--" ]; then
        lastSecretTime=$(stat -c %z "$secret")
    fi
    if [ ! -e "$secret" ] && [ "$secret" != "--" ]; then
        resetTime
        onFailed "cannot open: $secret"
    fi
    shift
    
    processOptions "$@"
    
    if [ -n "$csmName" ]; then
        name=$(validName "${csmName}")
        lastName="$name"
        oName=${name:4}
    fi
    
    echo "Reading ${device} secret from ${secret} ($name)"
    local key=$("${csmkeyTool}" dec "$secret" "${ckOptions[@]}" | base64 -w 0)
    if [ -z "$key" ]; then
        onFailed "cannot get secret"
    fi
    touchFile "$lastSecret" "$lastSecretTime"
    clearScreen
    openContainerByName "$key" "$name" "$device"
    
    if [ "$csmMount" = "1" ]; then
        mountContainer "$name"
    fi
    echo "To close use:"
    echo "$0 close ${oName}"
    echo "$0 closeAll"    
}

########################################################################

function testRndDataSource()
{
    openssl enc -aes-256-ctr -pass pass:"test" -nosalt < <(echo -n "test") > /dev/null
}

function rndDataSource()
{
    # https://unix.stackexchange.com/questions/248235/always-error-writing-output-file-in-openssl
    testRndDataSource
    # https://wiki.archlinux.org/index.php/Securely_wipe_disk/Tips_and_tricks#dd_-_advanced_example
    local tpass=$(tr -cd '[:alnum:]' < /dev/urandom | head -c128)
    set +e
    openssl enc -aes-256-ctr -pass pass:"$tpass" -nosalt </dev/zero 2>/dev/null
    set -e
}

# container bs count seek
function ddContainer()
{
    local container="$1"
    local bs="$2"
    local count="$3"
    local seek="${4:-}"

    if [ -z "$seek" ]; then
        time rndDataSource | dd iflag=fullblock of="$container" bs="$bs" count="$count" status=progress
        #sudo -u "$user" dd iflag=fullblock if=/dev/urandom of="$container" bs="$bs" count="$count" status=progress
    else
        #sudo -u "$user" dd iflag=fullblock if=/dev/urandom of="$container" bs="$bs" count="$count" seek="$seek" status=progress
        time rndDataSource | dd iflag=fullblock of="$container" bs="$bs" count="$count" seek="$seek" status=progress
    fi
    sleep 1
    #sync -f "$container"
}

# secret
function createSecret()
{
    local secret="$1"
    if [ "${secret}" = "--" ]; then
        return
    fi
    echo "Creating ${secret} ..."
    "${csmkeyTool}" enc "$secret" "${ckOptions[@]}"
    ownFile "$secret"
}

function checkFreeSpace()
{
    local size="$1"
    local sizeNum="$2"
    local dir="$(dirname -- "$(realpath -- "${container}")")"
    local availMb=$(df --block-size=1 --output=avail "${dir}" | tail -n 1)
    availMb=$((availMb / 1024 / 1024))
    if [ "${size: -1}" = "G" ]; then
        availMb=$((availMb / 1024)) #gb
    fi
    if (( sizeNum > availMb )); then
        onFailed "${sizeNum}${size: -1} is bigger than free space ${availMb}${size: -1} in ${dir}"
    fi
}

# name secret container size rest
function createContainer()
{
    local name=$(validName "-")
        
    local container="${1:-}"
    checkArg "$container" "container"
    shift
    
    local blockDevice="0"
    local writeContainer="1"
    local overwriteContainer=""
    if [ -f "$container" ]; then
        echo "Container file exists: ${container}"
        read -p "Overwrite? [y (overwrite) | e (erase files) | Enter to exit]: " overwriteContainer
        if [ "$overwriteContainer" = "y" ]; then
            writeContainer="1"
        elif [ "$overwriteContainer" = "e" ]; then
            writeContainer="0"
        else
            onFailed "nothing to do"
        fi
    fi
    if [ -b "$container" ]; then
        blockDevice="1"
        echo "Are you sure encrypt block device: ${container}"
        read -p "Overwrite? [y (overwrite) | e (erase files) | Enter to exit]: " overwriteContainer
        if [ "$overwriteContainer" = "y" ]; then
            writeContainer="1"
        elif [ "$overwriteContainer" = "e" ]; then
            writeContainer="0"
        else
            onFailed "nothing to do"
        fi
        echo "Size will be ingored for block devices (must be 0)"
    fi
    
    local secret="${1:-}"
    checkArg "$secret" "secret"
    shift

    local size="${1:-}"
    checkArg "$size" "size"
    shift

    local sizeNum="${size: : -1}"
    checkNumber "$sizeNum"

    processOptions "$@"
    
    if [ "${csmCreateOverwriteOnly}" = "1" ]; then
        echo "# create container only"
    fi
    
    if [ "$writeContainer" = "1" ]; then
        if [ "$blockDevice" = "1" ]; then
            if [ "$sizeNum" -gt 0 ]; then
                onFailed "Invalid size: ${sizeNum} (must be set to 0 and will be ignored)"
            fi
            umountDevice "${container}"
            testRndDataSource
            echo "Overwriting block device: ${container} ..."
            #hmm, we have to ingore errors here
            echo "# script will go on in case of errors here, read the output and decide if all ok ..."
            echo "# when done, it is ok to see: dd: error writing '...': No space left on device"
            set +e
            time rndDataSource | dd iflag=fullblock of="$container" bs=1M status=progress
            set -e
            echo "# sync disk data, this may take a while if other write operations are running ..."
            sync
        else
            if [ "$sizeNum" -le 0 ]; then
                onFailed "Invalid size: ${sizeNum}"
            fi
            
            checkFreeSpace "${size}" "${sizeNum}"
    
            echo "Creating ${container} with ${sizeNum}${size: -1} ..."
            if [ "${size: -1}" = "G" ]; then
                ddContainer "$container" "1G" "$sizeNum"
            elif [ "${size: -1}" = "M" ]; then
                ddContainer "$container" "1M" "$sizeNum"
            else
                onFailed "size can be M or G"
            fi
            ownFile "$container"
        fi
    else
        echo "Reusing existing data (size $size is ingored): $container"
    fi
    
    if [ "${csmCreateOverwriteOnly}" = "1" ]; then
        echo "# create container only: done"
        return
    fi
    
    if [ -f "$secret" ] && [ "$secret" != "--" ]; then
        lastSecret="$secret"
        lastSecretTime=$(stat -c %z "$secret")
        read -p "Overwrite secret file $secret [y | Enter to reuse]: " overwriteSecret
        case "$overwriteSecret" in
            y)
            createSecret "$secret"
            ;;
        esac
    else
        createSecret "$secret"
    fi
    
    clearScreen
    
    echo "(Re-)enter password to open the container for formating (existing data, if any, will be lost) ..."
    local key=$("${csmkeyTool}" dec "$secret" "${ckOptions[@]}" | base64 -w 0)
    if [ -z "$key" ]; then
        onFailed "cannot get secret"
    fi

    clearScreen
    touchFile "$lastSecret" "$lastSecretTime"
    openContainerByName "$key" "$name" "$container"
    
    local dev="$(getDevice "$name" "1")"
    if [ ! -e "$dev" ]; then
        dev="$(getDevice "$name" "0")"
    fi
    if [ ! -e "$dev" ]; then
        onFailed "cannot find: $dev"
    fi

    echo "Creating filesystem in $dev ..."
    mkfs -t ext4 -m 0 "${mkfsOptions[@]}" "$dev"
    echo "Created file system."
    sleep 1
    closeContainerByName "$name"
    
    echo "Done! To open container use:"
    echo "$0 open ${container} ${secret}"
}


########################################################################

# name
function resizeContainer()
{
    local name=$(validName "${1:-}")
    local dev="$(getDevice "$name" "0")"
    local lastDev=""
    if [ -e "$dev" ]; then
        lastDev="$dev"
        cryptsetup resize "$name"
    fi
    dev="$(getDevice "$name" "1")"
    if [ -e "$dev" ]; then
        lastDev="$dev"
        local iName="$(innerName "$name")"
        cryptsetup resize "${iName}"
    fi
    
    if [ -n "$lastDev" ]; then
        resize2fs "$lastDev"
    fi
}

# only works for full G/M blocks
function increaseContainer()
{
    local name=$(validName "${1:-}")
    shift
    local size="${1:-}"
    checkArg "$size" "size"
    shift
    local sizeNum="${size: : -1}"
    checkNumber "$sizeNum"

    container="$(getContainerFile "$name")"
    if [ ! -f "$container" ]; then
        onFailed "no such container file ${container}"
    fi
    local currentSize=$(stat -c "%s" "$container")
    if [ "${size: -1}" = "G" ]; then
        local sizeG=$(($currentSize / (1024 * 1024 * 1024)))
        if [ "$sizeG" = "0" ]; then # keep it simple
            onFailed "cannot determine current size in G"
        fi
        ddContainer "$container" "1G" "$sizeNum" "$sizeG"
    elif [ "${size: -1}" = "M" ]; then
        local sizeM=$(($currentSize / (1024 * 1024)))
        if [ "$sizeM" = "0" ]; then
            onFailed "cannot determine current size in M"
        fi
        ddContainer "$container" "1M" "$sizeNum" "$sizeM"
    else
        onFailed "size can be M or G"
    fi
    resizeContainer "$name"
}

########################################################################

# infile [outfile]
function changePassword()
{
    local ifile="$1"
    shift
    local ofile="${1:-}"
    if [ -z "$ofile" ]; then
        ofile="$ifile"
    else
        shift
    fi
    processOptions "$@"
    echo "# Decoding ${ifile} ..."
    local secret=$("${csmkeyTool}" dec "${ifile}" "${ckOptions[@]}" | base64 -w 0)
    if (( ! ${#ckOptions2[@]} )); then
        echo "# using same options for encode"
        ckOptions2=( "${ckOptions[@]}" )
    fi
    "${csmkeyTool}" enc "${ofile}" -s <(echo -n "${secret}") "${ckOptions2[@]}"
}

########################################################################

function cleanUp()
{
    tput sgr 0
    echo
    closeContainer "$lastName"
    exit 0
}

function showChecksum()
{
    local how=56
    sha256sum "$0" | tail -c +$how
    sha256sum "${csmkeyTool}" | tail -c +$how
    if [ -f "${toolsDir}/aes" ]; then
        sha256sum "${toolsDir}/aes" | tail -c +$how
    fi
    if [ -f "${toolsDir}/argon2" ]; then
        sha256sum "${toolsDir}/argon2" | tail -c +$how
    fi
    echo
} >&2

function showHelp()
{
    local bn=$(basename -- "$0")
    local kn=$(basename -- "${csmkeyTool}")
    cat << EOF
Usage:
 $bn open|o device secret [ openCreateOptions ]
 $bn close|c name
 $bn closeAll|ca
 $bn list|l
 $bn mount|m name
 $bn umount|u name
 $bn create|n container secret size [ openCreateOptions ]
   size should end in M or G
 $bn resize|r name
 $bn increase|i name bySize
    bySize should end in M or G
 $bn touch|t fileOrDir [time]
    if set, time has to be in format: "$(date +"%F %T.%N %z")"
 $bn synctime|st
 $bn chp inFile [outFile] [ openCreateOptions ] : only -ck -cko are used
 $bn -k ... : invoke $kn ...
Where [ openCreateOptions ]:
 -co cryptsetup options --- : outer encryption layer
 -ci cryptsetup options --- : inner encryption layer
 -ck $kn options ---"
 -cko $kn options --- : only for use with chp output
 -cf mkfs ext4 options --- : (create)
 -l : (open) live
 -n name : (open) use csm-name
 -c : (open|create) clean screen after password entry
 -s : (open|create) use only one (outer) encryption layer
 -u : (open) do not mount on open
 -r : (open) mount user read-only
 -lk : (list) list raw keys
 -oo : (create) dd only
Example:
 sudo csmap.sh open container.bin -l -ck -k -h -p 8 -m 14 -t 1000 -- ---

EOF
} >&2

function processOptions()
{
    while (( $# > 0 )); do
        local current="${1:-}"
        case "$current" in
            -co)
                shift
                csOptions=()
                while [ "${1:-}" != "---" ]; do
                    csOptions+=( "${1:-}" )
                    shift
                done
            ;;
            -ci)
                shift
                csiOptions=()
                while [ "${1:-}" != "---" ]; do
                    csiOptions+=( "${1:-}" )
                    shift
                done
            ;;
            -ck)
                shift
                ckOptions=()
                while [ "${1:-}" != "---" ]; do
                    ckOptions+=( "${1:-}" )
                    shift
                done
            ;;
            -cko)
                shift
                ckOptions2=()
                while [ "${1:-}" != "---" ]; do
                    ckOptions2+=( "${1:-}" )
                    shift
                done
            ;;
            -cf)
                shift
                mkfsOptions=()
                while [ "${1:-}" != "---" ]; do
                    mkfsOptions+=( "${1:-}" )
                    shift
                done
            ;;
            -c|-cls)
                csmCleanScreen="1"
            ;;
            -n|-name)
                csmName="${2:-}"
                shift
            ;;
            -l)
                csmLive="1"
            ;;
            -s)
                csmChain="0"
            ;;
            -u)
                csmMount="0"
            ;;
            -r)
                cmsMountReadOnly="1"
            ;;
            -lk)
                csmListShowKey="1"
            ;;
            -oo)
                csmCreateOverwriteOnly="1"
            ;;
            *)
                onFailed "unknown option: $current"
            ;;
        esac
        shift
    done
}

function main()
{
    showChecksum
    local mode="${1:-}"
    if [ -z "$mode" ]; then
        showHelp
        exit 1
    fi
    shift

    case "$mode" in
        ol)
            csmLive="1"
            csmCleanScreen="1"
        ;&
        open|o)
            openContainer "-" "$@"
            if [ "$csmLive" = "1" ]; then
                trap cleanUp SIGHUP SIGINT SIGTERM ABRT QUIT
                tput setaf 1
                read -p "Press Enter twice or Ctrl+C to close the container ..."
                logError
                read -p "Press Enter once more or Ctrl+C to close the container ..."
                tput sgr 0
                logError
                cleanUp
            fi
        ;;
        #openNamed|openName|on)
        #    openContainer "$@"  
        #;;
        close|c)
            closeContainer "$1"
        ;;
        mount|m)
            mountContainer "$1"
        ;;
        umount|u)
            umountContainer "$1"
        ;;
        create|n)
            createContainer "$@"            
        ;;
        x)
            local tfs="$HOME/mnt/tmpcsm"
            if [ -d "${tfs}" ]; then
                set +e
                fuser -km "${tfs}"
                sleep 1
                umount "${tfs}" 2> /dev/null
                logError "# umount: ${tfs}"
                rmdir "${tfs}"
                set -e
            fi
        ;&
        closeAll|ca)
            closeAll
            cleanMntDir
        ;;
        list|l)
            processOptions "$@"
            closeAll "1"
        ;;
        resize|r)
            resizeContainer "$1"
        ;;
        increase|inc|i)
            increaseContainer "$@"
        ;;
        touch|t)
            touchDiskFile "$@"
        ;;
        synctime|st)
            systemctl restart systemd-timesyncd
            sleep 1
            date
        ;;
        chp)
            changePassword "$@"
        ;;
        -k)
            "${csmkeyTool}" "$@"
        ;;
        *)
            showHelp
        ;;
    esac
}

main "$@"
