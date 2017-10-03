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
    if [ -z "${1:-}" ]; then
        onFailed "src required"
    fi
    if [ -z "${2:-}" ]; then
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

tcpUsePv="0"

# src dst
function tcp()
{
    checkSrcDst "$1" "$2"
    local s="$1"
    local d="$2"
    shift 2
    processOptions "$@"
    mkdir -p "$s"
    
    echo "Copying $s to $d ..."
        
    if [ "$tcpUsePv" = "1" ]; then
        time tar --ignore-failed-read -C "$s" -cf - . | pv | tar --ignore-failed-read -C "$d" -xf -
    else
        time tar --ignore-failed-read -C "$s" -cf - . | tar --ignore-failed-read -C "$d" -xf -
    fi
    echo "Done"
}

########################################################################

rcpBackupDir=""
rpcParallel="0"

function rcp()
{
    checkSrcDst "$1" "$2"
    local s="$1"
    local d="$2"
    shift 2
    processOptions "$@"
    mkdir -p "$s"
    
    if [ -n "${rcpBackupDir}" ]; then
        sameDir "$s" "${rcpBackupDir}"
        sameDir "$d" "${rcpBackupDir}"
        echo "Copying $s to $d (with backup in $3) ..."
        if (( rpcParallel > 0 )); then
            echo "# $rpcParallel instances"
            time find "$s" -maxdepth 1 -print0 | xargs -r -0 -n 1 -I {} -P "${rpcParallel}" rsync --info=none -aWS --delete "$s/"{} "$d/" --backup-dir="${rcpBackupDir}"
        else
            time rsync --info=progress2 -ahWS --delete --stats "$s/" "$d/" --backup-dir="${rcpBackupDir}"
        fi
    else
        echo "Copying $s to $d ..."
        if (( rpcParallel > 0 )); then
            echo "# $rpcParallel instances"
            time find "$s" -maxdepth 1 -print0 | xargs -r -0 -n 1 -I {} -P "${rpcParallel}" rsync --info=none -aWS --delete "$s/"{} "$d/"
        else
            time rsync --info=progress2 -ahWS --delete --stats "$s/" "$d/"
        fi
    fi
    echo "Done"
}

########################################################################

dcDir=""
dcStart=$(date +%s)
dcShowInfo=""1

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
    if [ "${dcShowInfo}" != "1" ]; then
        return
    fi
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

dcUseRnd="0"

function testRndDataSource()
{
    openssl enc -aes-256-ctr -pass pass:"test" -nosalt < <(echo -n "test") > /dev/null
}

function rndDataSource()
{
    if [ "$dcUseRnd" = "1" ]; then
        # https://unix.stackexchange.com/questions/248235/always-error-writing-output-file-in-openssl
        # https://wiki.archlinux.org/index.php/Securely_wipe_disk/Tips_and_tricks#dd_-_advanced_example
        local tpass=$(tr -cd '[:alnum:]' < /dev/urandom | head -c128)
        set +e
        openssl enc -aes-256-ctr -pass pass:"$tpass" -nosalt </dev/zero 2>/dev/null
        set -e
    else
        cat /dev/zero
    fi
}

function dc()
{
    local res=""
    if [ -z "${dcDir}" ]; then
        dcDir="$HOME/tmp"
    fi
    processOptions "$@"
    makeTmpDir
    trap cleanUp SIGHUP SIGINT SIGTERM ERR
    mkdir -p "${dcDir}"
    local partition=$(df -P "${dcDir}" | tail -1 | tr -s ' ' | cut -d ' ' -f 1)
    dcInfo "${partition}"
    dcStart=$(date +%s)
    echo -e "Using folder ${dcDir}\nOverwriting free partition space in ${partition} (may take some time):"

    if [ "$dcUseRnd" = "1" ]; then
        echo "# using random data for overwrite"
        testRndDataSource
    fi
   
    printAvailable
    while : ; do
        echo -n +
        set +e
        rndDataSource | dd iflag=fullblock count=1024 bs=1M conv=fdatasync >> "${dcDir}/zero.$RANDOM" 2>/dev/null
        res=$?
        set -e
        if [ $res -ne 0 ] ; then
            sync
            printAvailable
            break;
        fi
    done

    while : ; do
        set +e
        rndDataSource > "${dcDir}/zero.$RANDOM" 2>/dev/null
        res=$?
        set -e
        if [ $res -ne 0 ] ; then
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

function processOptions()
{
    while (( $# > 0 )); do
        local current="${1:-}"
        case "$current" in
            -tp)
                tcpUsePv="1"
            ;;
            -rb)
                rcpBackupDir="${2:?"! -rb backupDir"}"
                shift
            ;;
            -rp)
                rpcParallel="${2:?"! -rp instances"}" 
                shift
            ;;
            -dr)
                dcUseRnd="1"
            ;;
            -dd)
                dcDir="${2:?"! -dd tmpDir"}"
                shift
            ;;
            -dq)
                dcShowInfo="0"
            ;;
            *)
                onFailed "unknown option: $current"
            ;;
        esac
        shift
    done

}

########################################################################

function showHelp()
{
    local bn="$(basename -- $0)"
    cat <<EOF
Usage:

 $bn tcp srcDir dstDir [options]
 $bn rcp srcDir dstDir [options]
 $bn dc dir [options]

Where [options]:
 
 -tp : (tcp) use pv
 -rb backupDir : (rcp) rsync backup dir
 -rp instances : (rpc) use xargs -P instances
 -dr : (dc) use random data (default 0s)
 -dd tmpDir : (dc) temp dir to use, default $HOME/tmp
              csfile-$RANDOM folder is created within
 -dq : (dc) do not ask to confim (and no info)

Notes:

 tcp | rcp : copies content within srcDir to dstDir
    
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
            logError "unknown option: $runCmd"
            showHelp
            exit 1
        ;;
    esac
}

main "$@"
