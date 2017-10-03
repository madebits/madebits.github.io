#!/bin/bash

# csman.sh

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
        chown $(id -un "$user"):$(id -gn "$user") "$1"
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
                fileTime=$(stat -c %z "$HOME")
            fi
        fi
        set +e
        #sudo bash -s "$file" "$fileTime" <<-'EOF'
            now=$(date +"%F %T.%N %z") && date -s "${fileTime}" > /dev/null && touch "$file"
            date -s "$now" > /dev/null
        #   EOF
        set -e
    fi
}

function resetTime()
{
    touchFile "$lastContainer" "$lastContainerTime"
    sleep 1
    touchFile "$lastSecret" "$lastSecretTime"
}

########################################################################

function newName()
{
    local newName=""
    while :
    do
        #a-zA-Z0-9
        newName=$(cat /dev/urandom | tr -dc '[:lower:]' | fold -w 4 | head -n1)
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
    mount ${ro} "$dev" "$mntDir1"
    if [ "$?" != "0" ]; then
        closeContainerByName "$name"
        rmdir "$mntDir1"
        resetTime
        failed
    fi
    set -e
    mkdir -p "$mntDir2"
    bindfs ${ro} --multithreaded -u $(id -u "$user") -g $(id -g "$user") "$mntDir1" "$mntDir2"
    echo "Mounted ${dev} at ${mntDir2}"
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
        local name=$(basename "$filename")
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
    local f="$(cryptsetup status "$name" | grep loop: | cut -d ' ' -f 7)"
    if [ -z "$f" ]; then
        f="$(cryptsetup status csm-dwpi | grep device: | cut -d ' ' -f 5)"
    fi
    echo "$f"
}

function listContainer()
{
    local name=$(validName "${1:-}")
    local oName=${name:4}
    echo -e "Name:\t$oName\t$name"
    local container="$(getContainerFile "$name")"
    local mode="$(cryptsetup status "$name" | grep mode: | cut -d ' ' -f 7)"
    if [ -z "$container" ]; then
        return
    fi
    local cipher=""
    echo -e "File:\t$container\t$mode"
    local dev="$(getDevice "$name" "0")"
    if [ -e "$dev" ]; then
        time=$(stat -c %z "$dev")
        echo -e "Open:\t${time}"
        cipher="$(cryptsetup status "$name" | grep cipher: | cut -d ' ' -f 5)"
        echo -e "Device:\t${dev}\t${cipher}"
        if [ "$csmListShowKey" = "1" ]; then
            local k=$(dmsetup table --target crypt --showkey "${dev}" | cut -d ' ' -f 5)
            echo -e "RawKey:\t$k"
        fi
    fi
    dev="$(getDevice "$name" "1")"
    if [ -e "$dev" ]; then
        cipher="$(cryptsetup status "$dev" | grep cipher: | cut -d ' ' -f 5)"
        echo -e "Device:\t${dev}\t${cipher}"
        if [ "$csmListShowKey" = "1" ]; then
            local k=$(dmsetup table --target crypt --showkey "${dev}" | cut -d ' ' -f 5)
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
        echo -e "Dir1:\t$mntDir1\t$m\troot"
    fi
    if [ -d "$mntDir2" ]; then
        local m="$(mount | grep "$mntDir2")"
        if [ -n "$m" ]; then
            m="mounted"
        fi
        echo -e "Dir2:\t$mntDir2\t$m\t${user}"
    fi
}

########################################################################

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
    if [ -f "$secret" ]; then
        lastSecretTime=$(stat -c %z "$secret")
    fi
    if [ ! -e "$secret" ]; then
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
    
    echo "Reading secret from: $secret"
    local key=$("${csmkeyTool}" dec "$secret" "${ckOptions[@]}" | base64 -w 0)
    if [ -z "$key" ]; then
        onFailed "cannot get key"
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
    echo "Creating ${secret} ..."
    "${csmkeyTool}" enc "$secret" "${ckOptions[@]}"
    ownFile "$secret"
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
        read -p "Overwrite? [y (overwrite) | e (erase) | Enter to exit]: " overwriteContainer
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
        echo "Size will be ingored for block devices"
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
    
    if [ "$writeContainer" = "1" ]; then
        if [ "$blockDevice" = "1" ]; then
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
    
    if [ -f "$secret" ]; then
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
        onFailed "cannot get key"
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
    resetTime
    #set +e
    #systemctl restart systemd-timesyncd
    #set -e
    exit 0
}

function showChecksum()
{
    (>&2 sha256sum "$0")
    (>&2 sha256sum "${csmkeyTool}")
    if [ -f "${toolsDir}/aes" ]; then
        (>&2 sha256sum "${toolsDir}/aes")
    fi
    if [ -f "${toolsDir}/argon2" ]; then
        (>&2 sha256sum "${toolsDir}/argon2")
    fi
    logError
}

function showHelp()
{
    local bn=$(basename -- "$0")
    local kn=$(basename -- "${csmkeyTool}")
    logError "Usage:"
    logError " $bn open|o device secret [ openCreateOptions ]"
    logError " $bn close|c name"
    logError " $bn closeAll|ca"
    logError " $bn list|l"
    logError " $bn mount|m name"
    logError " $bn umount|u name"
    logError " $bn create|n container secret size [ openCreateOptions ]"
    logError "    size should end in M or G"
    logError " $bn resize|r name"
    logError " $bn increase|i name bySize"
    logError "    bySize should end in M or G"
    logError " $bn touch|t fileOrDir [time]"
    logError "    if set, time has to be in format: \"$(date +"%F %T.%N %z")\""
    logError " $bn synctime|st"
    logError " $bn chp inFile [outFile] [ openCreateOptions ] : only -ck -cko are used"
    logError " $bn -k ... : invoke $kn ..."
    logError "Where [ openCreateOptions ]:"
    logError " -co cryptsetup options --- : outer encryption layer"
    logError " -ci cryptsetup options --- : inner encryption layer"
    logError " -ck $kn options ---"
    logError " -cko $kn options --- : only for use with chp output"
    logError " -cf mkfs ext4 options --- : (create)"
    logError " -l : (open) live"
    logError " -n name : (open) use csm-name"
    logError " -c : (open|create) clean screen after password entry"
    logError " -s : (open|create) use only one (outer) encryption layer"
    logError " -u : (open) do not mount on open"
    logError " -r : (open) mount user read-only"
    logError " -lk : (list) list raw keys"
    logError "Example:"
    logError " sudo csmap.sh open container.bin -l -ck -k -h -p 8 -m 14 -t 1000 -- ---"
}

function processOptions()
{
    while [ -n "${1:-}" ]; do
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
                trap cleanUp SIGHUP SIGINT SIGTERM
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