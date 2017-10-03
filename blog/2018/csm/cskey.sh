#!/bin/bash

# cskey.sh

set -eu -o pipefail

if [ $(id -u) != "0" ]; then
    (>&2 echo "! using sudo recommended")
fi

# none of values in this file is secret
# change default argon2 params in cskHashToolOptions as it fits you here
# https://crypto.stackexchange.com/questions/37137/what-is-the-recommended-number-of-iterations-for-argon2

#state
cskFile=""
cskDebug="0"
cskInputMode="0"
cskBackup="0"
cskBackupNewKey="0"
cskHashToolOptions=( "-p" "8" "-m" "14" "-t" "1000" )
cskPassFile=""
cskKeyFiles=()
cskNoKeyFiles="0"
cskKey=""
cskSessionPass=""
cskSessionSecret=""
cskSessionKeyFile=""
cskSessionAutoPass="0"

user="${SUDO_USER:-$(whoami)}"
currentScriptPid=$$
toolsDir="$(dirname $0)"
useAes="0"
if [ -f "${toolsDir}/aes" ]; then
	useAes="1"
fi

function dumpError()
{
	(>&2 echo "$@")
}

function onFailed()
{
	dumpError "!" "$@"
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

# file
function ownFile()
{
	if [ -f "$1" ]; then
		chown $(id -un "$user"):$(id -gn "$user") "$1"
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
		"${toolsDir}/aes" -c 5000000 -r /dev/urandom -e -f <(echo -n "$pass")
	else
		ccrypt -e -f -k <(echo -n "$pass")
	fi
}

function decryptAes()
{
	local pass="$1"
	if [ "$useAes" = "1" ]; then
		"${toolsDir}/aes" -c 5000000 -d -f <(echo -n "$pass")
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
		dumpError
		while [ -n "${1:-}" ]; do
			dumpError "DEBUG [${1}]"
			shift
		done
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
    ownFile "$file"
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
		if [ -z "$fileData" ]; then
			onFailed "cannot read: $file"
		fi
		local salt=$(echo -n "$fileData" | base64 -d | head -c 32 | base64 -w 0)
		local data=$(echo -n "$fileData" | base64 -d | tail -c +33 | head -c "$keyLength" | base64 -w 0)
        local hash=$(pass2hash "$pass" "$salt")
		touchFile "$file"
		if [ -n "$cskSessionKeyFile" ]; then
			dumpError
			readSessionPass
			echo -n "$data" | base64 -d | decryptAes "$hash" | encryptAes "$cskSessionSecret" > "$cskSessionKeyFile"
			debugKey "$cskSessionKeyFile" $(echo -n "$data" | base64 -d | decryptAes "$hash" | base64 -w 0)
		else
			echo -n "$data" | base64 -d | decryptAes "$hash"
		fi
    else
        onFailed "no such file: $file"
    fi
}

function keyFileHash()
{
	local keyFile="$1"
	head -c 1024 "$keyFile" | sha256sum | cut -d ' ' -f 1
	if [ "$?" != "0" ]; then
		onFailed "cannot read keyFile: ${keyFile}"
	fi
}

function readKeyFiles()
{
	local count=0
	local keyFile=""
	
	if [ "$cskNoKeyFiles" = "1" ] || [ -n "$cskSessionPass" ]; then
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
		cskKeyFiles+=( "$(keyFileHash "$keyFile")" )
	done
}

function computeKeyFilesHash()
{
	local hash=""
	if (( ${#cskKeyFiles[@]} )); then
		# read order does not matter
		hash=$(printf '%s\n' "${cskKeyFiles[@]}" | sort | sha256sum | cut -d ' ' -f 1)
	fi
	echo "$hash"
}

# file
function readPassFromFile()
{
	if [ -e "$1" ] || [ "$1" = "-" ]; then
		head -n 1 "$1" | tr -d '\n'
		if [ "$?" != "0" ]; then
			onFailed "cannot read file: ${1}"
		fi
	else
		onFailed "cannot read file: ${1}"
	fi
}

function readSessionPass()
{
	if [ -z "$cskSessionSecret" ]; then
		# session specific
		local sData1=$(uptime -s)
		local sData2=$(ps ax | grep -E 'systemd --user|cron|udisks' | grep -v grep | tr -s ' ' | cut -d ' ' -f 2 | tr -d '\n')
		local sessionData="${user}${sData1}${sData2}"
		local sSecret="${sessionData}"
		if [ "$cskSessionAutoPass" = "0" ]; then
			if [ "$cskInputMode" = "1" ] || [ "$cskInputMode" = "e" ]; then
				read -p "Session password: " rsp
			else
				read -p "Session password: " -s rsp
			fi
			sSecret="${sessionData}${rsp}"
		fi
		cskSessionSecret=$(echo -n "${sSecret}" | sha256sum | cut -d ' ' -f 1)
		debugKey "${sSecret}" "${cskSessionSecret}"
		dumpError
	fi
}

# file
function readSessionPassFromFile()
{
	if [ -e "$1" ] || [ "$1" = "-" ]; then
		if [ -z "$cskSessionSecret" ]; then
			onFailed "no session password"
		fi
		local p=$(cat "$1" | base64 -w 0)
		if [ -z "$p" ]; then
			onFailed "cannot read file: ${1}"
		fi
		echo -n "$p" | base64 -d | decryptAes "$cskSessionSecret"
	else
		onFailed "cannot read file: ${1}"
	fi
}

function readPassword()
{
	if [ -n "$cskPassFile" ]; then
		pass="$cskPassFile"
	elif [ "$cskInputMode" = "1" ] || [ "$cskInputMode" = "e" ]; then
		read -p "Password: " pass
	elif [ "$cskInputMode" = "2" ] || [ "$cskInputMode" = "c" ]; then
		pass=$(xclip -o -selection clipboard)
	elif [ "$cskInputMode" = "3" ] || [ "$cskInputMode" = "u" ]; then
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
	if [ -n "$cskSessionPass" ]; then
		echo "$cskSessionPass"
		return
	fi
	
	local hash=$(computeKeyFilesHash)
	local pass=$(readPassword "${1:-}")
	pass="${pass}${hash}"
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
	local key="$3"
	encodeKey "$1" "$2" "$key"
	
	local count=$(($cskBackup + 0))
	if [ "$count" -gt "64" ]; then
		count=64
	fi
	for ((i=1 ; i <= $count; i++))
	{
		local pad=$(printf "%02d" ${i})
		local file="${1}.${pad}"
		echo "$file"
		if [ "$cskBackupNewKey" = "1" ]; then
			key=$(getKey)
			dumpError "#  using new key"
		fi
		encodeKey "$file" "$2" "$key"
	}
}

function getKey()
{
	# can be passed from outside
	CS_KEY="${CS_KEY:-}"
	local key=""
	if [ -n "$cskKey" ]; then
		dumpError "#  using user-define key"
		key="$cskKey"
	elif [ -n "$CS_KEY" ]; then
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
	dumpError
    decodeKey "$1" "$pass"
}

function checkNumber()
{
	local re='^[0-9]+$'
	if ! [[ "$1" =~ $re ]] ; then
		dumpError "$1 not a number"
		exit 1
	fi
}
# file
function createSessionPass()
{
	local file="$1"
	if [ "$file" = "-" ]; then
		file="/dev/stdout"
	fi
	readKeyFiles
	local pass=$(readPass)
	dumpError
	readSessionPass
	debugKey "${cskSessionSecret}" "${pass}"

	echo -n "$pass" | encryptAes "$cskSessionSecret" > "$file"
	ownFile "$file"
}

# file keybase64
function createSessionKey()
{
	local file="$1"
	if [ "$file" = "-" ]; then
		file="/dev/stdout"
	fi
	local key="$2"
	readSessionPass
	debugKey "${cskSessionSecret}" "${key}"

	echo -n "$key" | base64 -d | encryptAes "$cskSessionSecret" > "$file"
	ownFile "$file"
}

# file
function loadSessionPass()
{
	local file="${1:-}"
	if [ -z "$file" ]; then
		return
	fi
	readSessionPass
	set +e
	local sPass=$(readSessionPassFromFile "$file")
	set -e
	if [ -z "$sPass" ]; then
		onFailed "cannot read file: ${file}"
	fi
	cskSessionPass="$sPass"
}

# file
function loadSessionKey()
{
	local file="${1:-}"
	if [ -z "$file" ]; then
		return
	fi
	readSessionPass
	cskKey=$(cat ${file} | decryptAes "$cskSessionSecret" | base64 -w 0)
	if [ -z "$cskKey" ]; then
		onFailed "cannot read: ${file}"
	fi
}

function showHelp()
{
	dumpError "Usage: $(basename "$0") [enc | dec | ses] file [options]"
	dumpError "Options:"
	dumpError " -i inputMode : used for password"
	dumpError "    Password input modes:"
	dumpError "     0 read from console, no echo (default)"
	dumpError "     1|e read from console with echo"
	dumpError "     2|c read from 'xclip -o -selection clipboard'"
	dumpError "     3|u read from 'zenity --password'"
	dumpError "     4 read from 'zenity --text'"
	dumpError " -c encryptMode : use 1 for aes tool, 0 or any other value uses ccrypt"
	dumpError " -p passFile : (enc) read pass from first line in passFile"
	dumpError " -ap file : read pass from session file, other pass input options are ignored"
	dumpError " -k : (enc) do not ask for keyfiles"
	dumpError " -kf keyFile : (enc) use keyFile (combine with -k)"
	dumpError " -b count : (enc) generate file.count backup copies"
	dumpError " -bk : (enc) generate a new key for each -b file"
	dumpError " -h hashToolOptions -- : default -h ${cskHashToolOptions[@]} --"
	dumpError " -key file : (enc) read key data as base64 -w 0 from file"
	dumpError " -akey file : (enc) read key data from session encrypted file (see -ao)"
	dumpError " -ao outFile : (dec) write key in session encrypted file"
	dumpError " -aa : auto session password"
	dumpError " -d : dump password and key on stderr for debug"
	dumpError "Examples:"
	dumpError ' sudo bash -c '"'"'key=$(cskey.sh dec d.txt | base64 -w 0) && cskey.sh enc d.txt -key <(echo -n "$key") -d'"'"''
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
	cskFile="${1:?"! file"}"
	shift
	
	local apf=""
	local akeyf=""
	
	while [ -n "${1:-}" ]; do
		local current="${1:-}"
		case "$current" in
			-d)
				cskDebug="1"
			;;
			-i)
				cskInputMode="${2:?"! -i inputMode"}"
				shift
			;;
			-b)
				cskBackup="${2:?"! -b backupCount"}"
				checkNumber "$cskBackup"
				shift
			;;
			-bk)
				cskBackupNewKey="1"
			;;
			-h)
				shift
				cskHashToolOptions=()
				while [ "${1:-}" != "--" ]; do
					cskHashToolOptions+=( "${1:-}" )
					shift
				done
			;;
			-p)
				local passFile="${2:?"! -p passFile"}"
				cskPassFile=$(readPassFromFile "$passFile")
				shift
			;;
			-aa)
				cskSessionAutoPass="1"
			;;
			-ap)
				apf="${2:?"! -ap file"}"
				shift
			;;
			-k)
				cskNoKeyFiles="1"
			;;
			-kf)
				local kf="${2:?"! -kf file"}"
				cskKeyFiles+=( "$(keyFileHash "$kf")" )
				shift
			;;
			-key)
				local kk="${2:?"! -key file"}"
				cskKey=$(cat "${kk}")
				if [ -z "$cskKey" ]; then
					onFailed "cannot read: ${kk}"
				fi
				shift
			;;
			-akey)
				akeyf="${2:?"! -akey file"}"
				shift
			;;
			-c)
				useAes="${2:?"! -c encryptMode"}"
				shift
			;;
			-ao)
				cskSessionKeyFile="${2:?"! -ao file"}"
				shift
			;;
			*)
				dumpError "! unknown option: $current"
				exit 1
			;;
		esac
		shift
	done
		
	loadSessionPass "${apf}"
	loadSessionKey "${akeyf}"

	case "$cskCmd" in
		enc|e)
			encryptFile "$cskFile"
		;;
		dec|d)
			decryptFile "$cskFile"
		;;
		ses|s)
			createSessionPass "$cskFile"
		;;
		*)
			dumpError "! unknown command: $cskCmd"
			showHelp
		;;
	esac
}

main "$@"
