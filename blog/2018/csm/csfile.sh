#!/bin/bash -

# csfile.sh

PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
\export PATH
\unalias -a
hash -r
ulimit -H -c 0 --
IFS=$' \t\n'

set -eu -o pipefail

########################################################################

currentScriptPid=$$
function failed()
{
    kill -9 "$currentScriptPid"
}

function logError()
{
    echo "$@"
} >&2

function onFailed()
{
    logError "!" "$@"
    failed
}

function checkSrcDst()
{
    if [ -z "$1" ]; then
        onFailed "src required"
    fi
    if [ -z "$2" ]; then
        onFailed "dst required"
    fi
    
    sameDir "$1" "$2"
}

function sameDir()
{
    local s="$(realpath -- "$1")"
    local d="$(realpath -- "$2")"
    if [ "$s" = "$d" ]; then
        onFailed "same folder $s"
    fi 
}

########################################################################

# src dst
function tcp()
{
    checkSrcDst "$1" "$2"
    mkdir -p "$2"
    
    echo "Copying $1 to $2 ..."
        
    if [ -e "/usr/bin/pv" ]; then
        time tar --ignore-failed-read -C "$1" -cf - . | pv | tar --ignore-failed-read -C "$2" -xf -
    else
        time tar --ignore-failed-read -C "$1" -cf - . | tar --ignore-failed-read -C "$2" -xf -
    fi
    echo "Done"
}

function rcp()
{
    checkSrcDst "$1" "$2"
    mkdir -p "$2"
    
    if [ -n "${3:-}" ]; then
        sameDir "$1" "$3"
        sameDir "$2" "$3"
        echo "Copying $1 to $2 (with backup in $3) ..."
        time rsync --progress -ahWSD --delete --stats "$1/" "$2" --backup-dir="$3"
    else
        echo "Copying $1 to $2 ..."
        time rsync --progress -ahWSD --delete --stats "$1/" "$2"
    fi
    echo "Done"
}

########################################################################

dcDir=""
dcStart=$(date +%s)

function cleanUp {
    if [ -d "${dcDir}" ]; then
        echo -e "\nRemoving: ${dcDir}"
        rm -rf "${dcDir}"
    fi
    end=$(date +%s)
    runtime=$((end-dcStart))
    echo "Done: ${runtime} seconds"
    exit
}

function printAvailable {
    available=$(df -Ph "${dcDir}" | tail -1 | tr -s ' ' | cut -d ' ' -f 4)
    echo -n "$available"
}

function dcInfo()
{
    cat <<EOF
# Info: Before running dc tool, call once manually on your partition:

  sudo tune2fs -m 0 $1
  sudo tune2fs -l $1 | grep 'Reserved block count'

# Info: Last command should return 0
EOF
    read -p "Press Enter to continue or Ctrl+C to exit: "
    echo
} >&2

function makeTmpDir()
{
    local tmp="${dcDir}/csfile-$RANDOM"
    while [ -d "$tmp" ]; do
        tmp="${dcDir}/csfile-$RANDOM"
    done
    dcDir="${tmp}"
}

function dc()
{
    dcDir="${1:-$HOME/tmp}"
    makeTmpDir
    trap cleanUp SIGHUP SIGINT SIGTERM
    mkdir -p "${dcDir}"
    local partition=$(df -P "${dcDir}" | tail -1 | tr -s ' ' | cut -d ' ' -f 1)
    dcInfo "${partition}"
    dcStart=$(date +%s)
    echo -e "Using folder ${dcDir}\nOverwriting free partition space in ${partition} (may take some time):"
   
    printAvailable
    while : ; do
        echo -n .
        dd if=/dev/zero count=1024 bs=1M >> "${dcDir}/zero.$RANDOM" 2>/dev/null
        if [ $? -ne 0 ] ; then
            sync
            printAvailable
            break;
        fi
    done

    while : ; do
        cat /dev/zero > "${dcDir}/zero.$RANDOM" 2>/dev/null
        if [ $? -ne 0 ] ; then
            sync
            available=$(df -P "${dcDir}" | tail -1 | tr -s ' ' | cut -d ' ' -f 4)
            echo -n "$available"
            echo -n .
            if [[ $available -lt 5 ]] ; then
                break;
            fi
        fi
    done
    sleep 1 ; sync
    cleanUp
}

########################################################################

showHelp()
{
    local bn="$(basename -- $0)"
    cat <<EOF
Usage:

$bn tcp srcDir dstDir
$bn rcp srcDir dstDir [backupDir]
$bn dc [dir]

Notes:

    (tcp | rcp ) : copy content within srcDir to dstDir
    (dc) : default dir is $HOME/tmp, a csfile-$RANDOM folder is created within
    
EOF

} >&2

########################################################################

function main()
{
    local runCmd="${1:-}"
    if [ -z "$runCmd" ]; then
        showHelp
        exit 1
    fi
    shift
    
    case "$runCmd" in
        tcp)
            tcp "$@"
        ;;
        rcp)
            rcp "$@"
        ;;
        dc)
            dc "$@"
        ;;
        *)
            showHelp
            exit 1
        ;;
    esac
}

main "$@"
