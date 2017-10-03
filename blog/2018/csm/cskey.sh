#!/bin/bash

# cskey.sh

set -eu

# none of values in this file is secret
# change default argon2 params in cskHashToolOptions as it fits you here
# https://crypto.stackexchange.com/questions/37137/what-is-the-recommended-number-of-iterations-for-argon2

#state
cskFile=""
cskFile2=""
cskDebug="0"
cskInputMode="0"
cskBackup="0"
cskHashToolOptions=( "-p" "8" "-m" "14" "-t" "1000" )
cskHashToolOptions2=( "${cskHashToolOptions[@]}" )
cskSamePass="0"
cskSameKeyFiles="0"
cskSameHashToolOptions="0"
cskPassFile=""
cskPassFile2=""
csmKeyFiles=()
csmKeyFiles2=()
csmNoKeyFiles="0"
csmNoKeyFiles2="0"

currentScriptPid=$$
toolsDir="$(dirname $0)"
useAes=0
if [ -f "${toolsDir}/aes" ]; then
	useAes=1
fi

function dumpError()
{
	(>&2 echo "$@")
}

function onFailed()
{
	dumpError "! " "$@"
	kill -9 "${currentScriptPid}"
}

# file
function touchFile()
{
	local file="$1"
	if [ -f "$file" ]; then
		local md=$(stat -c %z "$file")
		touch -d "$md" "$file"
	fi
}

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
	local pass="$1"
	if [ "$useAes" = "1" ]; then
		"${toolsDir}/aes" -r /dev/urandom -e -f <(echo -n "$pass")
	else
		ccrypt -e -f -k <(echo -n "$pass")
	fi
}

function decryptAes()
{
	local pass="$1"
	if [ "$useAes" = "1" ]; then
		"${toolsDir}/aes" -d -f <(echo -n "$pass")
	else
		ccrypt -d -k <(echo -n "$pass")
	fi
}

# pass salt
function pass2hash()
{
	local pass="$1"
	local salt="$2"
	local acmd="argon2"
	if [ -f "${toolsDir}/${acmd}" ]; then
		acmd="${toolsDir}/${acmd}"
	fi

	# argon2 has a build-in limit of 126 chars on pass length
	local state=$(set +o)
	set +x
	pass=$(echo -n "$pass" | sha512sum | cut -d ' ' -f 1 | tr -d '\n' | while read -n 2 code; do printf "\x$code"; done | base64 -w 0)
	eval "$state"
	echo -n "$pass" | "$acmd" "$salt" -id "${cskHashToolOptions[@]}" -l 128 -r
}

# pass key
function debugKey()
{
	if [ "$cskDebug" = "1" ]; then
		dumpError ""
		dumpError "DEBUG [$1]"
		dumpError "DEBUG [$2]"
	fi
}

# file pass key
function encodeKey()
{
    local file="$1"
    local pass="$2"
    local key="$3"
    
    debugKey "$pass" "$key"
    
    local salt=$(head -c 32 /dev/urandom | base64 -w 0)
    hash=$(pass2hash "$pass" "$salt")
    
    if [ "$file" = "-" ]; then
		file="/dev/stdout"
    fi
    
    > "$file"
    echo -n "$salt" | base64 -d >> "$file"
    echo -n "$key" | base64 -d | encryptAes "$hash" >> "$file"
    # random file size
    local r=$((1 + RANDOM % 512))
    head -c "$r" /dev/urandom >> "$file"
    touchFile "$file"
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
        local hash=$(pass2hash "$pass" "$salt")
		touchFile "$file"
        echo -n "$data" | base64 -d | decryptAes "$hash"
    else
        onFailed "no such file: $file"
    fi
}

function keyFileHash()
{
	local keyFile="$1"
	head -c 1024 "$keyFile" | sha256sum | cut -d ' ' -f 1
}

function readKeyFiles()
{
	local count=0
	local keyFile=""
	
	if [ "$csmNoKeyFiles" = "1" ]; then
		return
	fi
	
	while :
	do
		count=$((count+1))
		if [ "$cskInputMode" = "4" ]; then
			keyFile="$(zenity --file-selection --title='Select a File' 2> /dev/null)"
		else
			read -e -p "Key file $count (or Enter if none): " keyFile
		fi
		if [ ! -f "$keyFile" ]; then
			break
		fi
		csmKeyFiles+=( "$(keyFileHash "$keyFile")" )
	done
}

function computeKeyFilesHash()
{
	local hash=""
	if (( ${#csmKeyFiles[@]} )); then
		# read order does not matter
		hash=$(printf '%s\n' "${csmKeyFiles[@]}" | sort | sha256sum | cut -d ' ' -f 1)
	fi
	echo "$hash"
}

function readPassFromFile()
{
	if [ -e "$1" ] || [ "$1" = "-" ]; then
		head -n 1 "$1" | tr -d '\n'
	else
		onFailed "cannot read from file: $1"
	fi
}

function readPassword()
{
	if [ -n "$cskPassFile" ]; then
		pass="$cskPassFile"
	elif [ "$cskInputMode" = "1" ]; then
		read -p "Password: " pass
	elif [ "$cskInputMode" = "2" ]; then
		pass=$(xclip -o)
	elif [ "$cskInputMode" = "3" ]; then
		pass=$(zenity --password --title="Password" 2> /dev/null)
	elif [ "$cskInputMode" = "4" ]; then
		pass=$(zenity --entry --title="Password" --text="Password (visible):"  2> /dev/null)
	else
		read -p "Password: " -s pass
		if [ "${1:-}" = "1" ]; then
			# new password from console, ask to re-enter
			dumpError ""
			if [ -t 0 ] ; then
				read -p "Renter password: " -s pass2
				dumpError ""
				if [ "$pass" != "$pass2" ]; then
					onFailed "passwords do not match"
				fi
			fi
		fi
	fi
	if [ -z "$pass" ]; then
		onFailed "no password"
	fi
	echo "$pass"
}

function readPass()
{
	local hash=$(computeKeyFilesHash)
	local pass=$(readPassword "${1:-}")
	pass="$pass$hash"
	echo "$pass"
}

function readNewPass()
{
	readPass "1"
}

# file pass key
function encodeMany()
{
	dumpError "#  using hash tool parameters:" "${cskHashToolOptions[@]}"
	echo "$1"
	encodeKey "$1" "$2" "$3"
	
	local count=$(($cskBackup + 0))
	if [ "$count" -gt "64" ]; then
		count=64
	fi
	for ((i=1 ; i <= $count; i++))
	{
		local file="${1}.${i}"
		echo "$file"
		encodeKey "$file" "$2" "$3"
	}
}

function getKey()
{
	# can be passed from outside
	CS_KEY="${CS_KEY:-}"
	local key=""
	if [ ! -z "$CS_KEY" ]; then
		dumpError "#  using key from CS_KEY"
		key="$CS_KEY"
	else
		key=$(head -c 512 /dev/urandom | base64 -w 0)
	fi
	echo "$key"
}

function encryptFile()
{
	readKeyFiles
	local pass=$(readNewPass)
	local key=$(getKey)
	encodeMany "$1" "$pass" "$key"
}

function decryptFile()
{
	readKeyFiles
	local pass=$(readPass)
    decodeKey "$1" "$pass"
}

function reEncryptFile()
{
	local file="$1"
	dumpError "# Current"
	readKeyFiles
	local pass1=$(readPass)
	dumpError ""
	local key=$(decodeKey "$file" "$pass1" | base64 -w 0)
	dumpError "# New"
	
	if [ "$cskSameKeyFiles" != "1" ]; then
		csmNoKeyFiles="$csmNoKeyFiles2"
		csmKeyFiles=( "${csmKeyFiles2[@]}" )
	else
		csmNoKeyFiles="1"
		dumpError "#  using same key files"
	fi
	
	if [ "$cskSamePass" = "1" ]; then
		dumpError "#  using same password"
		pass="$pass1"
	else
		if [ -n "$cskPassFile2" ]; then
			cskPassFile="$cskPassFile2"
		fi
		readKeyFiles
		pass=$(readNewPass)
	fi

	if [ "$cskSameHashToolOptions" != "1" ]; then
		cskHashToolOptions=( "${cskHashToolOptions2[@]}" )
	else
		dumpError "#  using same hash tool options"
	fi
	
	if [ -n "$cskFile2" ]; then
		file="$cskFile2"
	fi	
	
	encodeMany "$file" "$pass" "$key"
	dumpError "Done: $file"
}

function checkNumber()
{
	local re='^[0-9]+$'
	if ! [[ "$1" =~ $re ]] ; then
		dumpError "$1 not a number"
		exit 1
	fi
}

function showHelp()
{
	dumpError "Usage: $(basename "$0") [enc | dec | chp] file [options]"
	dumpError "Options:"
	dumpError " -i inputMode : used for password"
	dumpError "    Password input modes:"
	dumpError "     0 read from console, no echo (default)"
	dumpError "     1 read from console with echo"
	dumpError "     2 read from 'xclip -o'"
	dumpError "     3 read from 'zenity --password'"
	dumpError "     4 read from 'zenity --text'"
	dumpError " -p passFile : (enc | chp) read pass from first line in passFile"
	dumpError " -pn passFile : (chp) read pass from first line in passFile, used for new file"
	dumpError " -s : (chp) use same password for new file, -pn is ignored"
	dumpError " -sk : (chp) use same key files for new file, -kfn, -kn are ignored"
	dumpError " -sh : (chp) use same hash tool options for new file, -hn is ignored"
	dumpError " -k : (enc | chp) do not ask for keyfiles"
	dumpError " -kn : (chp) do not ask for keyfiles, used for new file"
	dumpError " -kf keyFile : (enc | chp) use keyFile"
	dumpError " -kfn keyFile : (chp) use keyFile, used for new file"
	dumpError " -b count : (enc | chp) generate file.count backup copies"
	dumpError " -h hashToolOptions -- : default -h ${cskHashToolOptions[@]} --"
	dumpError " -hn hashToolOptions -- : (chp) default -hn ${cskHashToolOptions2[@]} --, used for new file"
	dumpError " -d -- (enc | chp) dump password and key on screen for debug"
	dumpError "Examples:"
	dumpError ' CS_KEY=$(cskey.sh dec s.txt | base64 -w 0) cskey.sh enc d.txt -h -p 8 -m 16 -t 1000 --'
}

# cmd file options
function main()
{
	dumpError ""
	local cskCmd="${1:-}"
	if [ -z "$cskCmd" ]; then
		showHelp
		exit 1
	fi
	shift
	cskFile="${1:-}"
	if [ -z "$cskFile" ]; then
		dumpError "! required file"
		exit 1
	fi
	shift
	
	while [ -n "${1:-}" ]; do
		local current="${1:-}"
		case "$current" in
			-d)
				cskDebug="1"
			;;
			-i)
				cskInputMode="${2:-}"
				if [ -z "$cskInputMode" ]; then
					dumpError "! required -i inputMode"
					exit 1
				fi
				shift
			;;
			-b)
				cskBackup="${2:-}"
				if [ -z "$cskBackup" ]; then
					dumpError "! required -b backupCount"
					exit 1
				fi
				checkNumber "$cskBackup"
				shift
			;;
			-h)
				shift
				cskHashToolOptions=()
				while [ "${1:-}" != "--" ]; do
					cskHashToolOptions+=( "${1:-}" )
					shift
				done
			;;
			-hn)
				shift
				cskHashToolOptions2=()
				while [ "${1:-}" != "--" ]; do
					cskHashToolOptions2+=( "${1:-}" )
					shift
				done
			;;
			-s|-sp)
				cskSamePass="1"
			;;
			-sk)
				cskSameKeyFiles="1"
			;;
			-sh)
				cskSameHashToolOptions="1"
			;;
			-p)
				local passFile="${2:-}"
				if [ -z "$cskHashToolOptions2" ]; then
					dumpError "! required -p passFile"
					exit 1
				fi
				cskPassFile=$(readPassFromFile "$passFile")
				shift
			;;
			-pn)
				local passFile="${2:-}"
				if [ -z "$cskHashToolOptions2" ]; then
					dumpError "! required -pn passFile"
					exit 1
				fi
				cskPassFile2=$(readPassFromFile "$passFile")
				shift
			;;
			-fn)
				cskFile2="${2:-}"
				if [ -z "$cskFile2" ]; then
					dumpError "! required -fn file"
					exit 1
				fi
				shift
			;;
			-k)
				csmNoKeyFiles="1"
			;;
			-kn)
				csmNoKeyFiles2="1"
			;;
			-kf)
				local kf="${2:-}"
				if [ -z "$kf" ]; then
					dumpError "! required -kf file"
					exit 1
				fi
				csmKeyFiles+=( "$(keyFileHash "$kf")" )
				shift
			;;
			-kfn)
				local kfn="${2:-}"
				if [ -z "$kfn" ]; then
					dumpError "! required -kfn file"
					exit 1
				fi
				csmKeyFiles2+=( "$(keyFileHash "$kfn")" )
				shift
			;;
			*)
				dumpError "! unknown option: $current"
				exit 1
			;;
		esac
		shift
	done

	case "$cskCmd" in
		enc|e)
			encryptFile "$cskFile"
		;;
		dec|d)
			decryptFile "$cskFile"
		;;
		chp|c)
			reEncryptFile "$cskFile"
		;;
		*)
			dumpError "! unknown command: $cskCmd"
			showHelp
		;;
	esac
}

main "$@"
