#!/bin/bash

# cskey.sh

set -eu

# none of values in this file is secret
# change default argon2 params as it fits you here
# https://crypto.stackexchange.com/questions/37137/what-is-the-recommended-number-of-iterations-for-argon2
argon2pmt="8,14,1000"

# can be passed from outside
CS_ECHO="${CS_ECHO:-0}"
CS_ECHO_KEY="${CS_ECHO_KEY:-0}"
CS_KEY="${CS_KEY:-}"
CS_SAME_PASS="${CS_SAME_PASS:-}"
CS_BACKUP="${CS_BACKUP:-0}"
CS_PMT="${CS_PMT:-}"

toolsDir="$(dirname $0)"
# set to 1 to use my aes tool, 0 uses ccrypt
useAes=0
if [ -f "${toolsDir}/aes" ]; then
	useAes=1
fi

if [ -n "$CS_PMT" ]; then
	argon2pmt="$CS_PMT"
fi

SCRIPT_PID=$$
function failed()
{
	kill -9 "$SCRIPT_PID"
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

function touchFile()
{
	local file=$1
	if [ -f "$file" ]; then
		local md=$(stat -c %z "$file")
		touch -d "$md" "$file"
	fi
}

# pass salt "p,m,t"
function pass2hash()
{
	local pass="$1"
	local salt="$2"
	local aa="${3:-$argon2pmt}"
	local aaArgs=(${aa//,/ })
	if [ "${#aaArgs[@]}" -ne "3" ]; then
		(>&2 echo "! p,m,t")
		failed
	fi
	local ap="${aaArgs[0]}"
	local am="${aaArgs[1]}"
	local at="${aaArgs[2]}"
	# argon2 has a build-in limit of 126 chars on pass length
	pass=$(echo -n "$pass" | sha512sum | cut -d ' ' -f 1 | tr -d '\n' | while read -n 2 code; do printf "\x$code"; done | base64 -w 0)
	echo -n "$pass" | argon2 "$salt" -id -t $at -m $am -p $ap -l 128 -r
}

# file pass key
function encodeKey()
{
    local file="$1"
    local pass="$2"
    local key="$3"
    
    local pmt="${4:-$argon2pmt}"
    
    debugKey "$pass" "$key"
    
    local salt=$(head -c 32 /dev/urandom | base64 -w 0)
    hash=$(pass2hash "$pass" "$salt" "$pmt")
    
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
    
    local pmt="${3:-$argon2pmt}"
    
    if [ -e "$file" ] || [ "$file" = "-" ]; then
		local fileData=$(head -c 600 "$file" | base64 -w 0)
		local salt=$(echo -n "$fileData" | base64 -d | head -c 32 | base64 -w 0)
		local data=$(echo -n "$fileData" | base64 -d | tail -c +33 | head -c "$keyLength" | base64 -w 0)
        local hash=$(pass2hash "$pass" "$salt" "$pmt")
		touchFile "$file"
        echo -n "$data" | base64 -d | decryptAes "$hash"
    else
        (>&2 echo "! no such file: $file")
        failed
    fi
}

function readKeyFiles()
{
	files=()
	local count=0
	local hash=""
	local fileHash=""
	while :
	do
		count=$((count+1))
		if [ "$CS_ECHO" = "3" ]; then
			keyFile="$(zenity --file-selection --title='Select a File' 2> /dev/null)"
		else
			read -e -p "Key file $count (or Enter if none): " keyFile
		fi
		if [ ! -f "$keyFile" ]; then
			break
		fi
		fileHash=$(head -c 1024 "$keyFile" | sha256sum | cut -d ' ' -f 1)
		files+=( "$fileHash" )
	done
	if (( ${#files[@]} )); then
		# read order does not matter
		hash=$(printf '%s\n' "${files[@]}" | sort | sha256sum | cut -d ' ' -f 1)
	fi
	echo "$hash"
}

function dumpKbLine()
{
	(>&2 echo "$1")
}

# experimental
function readPassMapping()
{
	local alpha=( a b c d e f g h i j k l m n o p q r s t u v w x y z 
	A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 
    \< \> \[ \] \( \) \{ \} / \\ \$ \? ! \| \~ \& % . , : \; + - _ \# = 
    0 1 2 3 4 5 6 7 8 9 )
	local coded=( $(shuf -e "${alpha[@]}") )

	dumpKbLine "# Password keymap (chars after # or not in map are taken as they are): "
	dumpKbLine ""
	dumpKbLine "$(echo "${alpha[@]}" | fold -w 52 | head -n 1 )"
	dumpKbLine "$(echo "${coded[@]}" | fold -w 52 | head -n 1 )"
	dumpKbLine "$(echo --- )"
	dumpKbLine "$(echo "${alpha[@]}" | fold -w 52 | head -n 2 | tail -n 1 )"
	dumpKbLine "$(echo "${coded[@]}" | fold -w 52 | head -n 2 | tail -n 1 )"
	dumpKbLine "$(echo --- )"
	dumpKbLine "$(echo "${alpha[@]}" | fold -w 52 | head -n 3 | tail -n 1 )"
	dumpKbLine "$(echo "${coded[@]}" | fold -w 52 | head -n 3 | tail -n 1 )"
	dumpKbLine "$(echo --- )"
	dumpKbLine "$(echo "${alpha[@]}" | fold -w 52 | head -n 4 | tail -n 1 )"
	dumpKbLine "$(echo "${coded[@]}" | fold -w 52 | head -n 4 | tail -n 1 )"
	
	read -p "Password: " pass
	local passLen=${#pass}
	local decoded=""
	for (( i=0; i<${passLen}; i++ )); do
		p="${pass:$i:1}"
		if [ "$p" = "#" ]; then
			i=$((i+1))
			if [ "$i" -ge "${passLen}" ]; then
				failed
			fi
			p="${pass:$i:1}"
			decoded="${decoded}${p}"
		else
			found="0"
			for j in "${!coded[@]}"; do
				c="${coded[j]}"
				if [ "$c" = "$p" ]; then
					found="1"
					a="${alpha[j]}"
					decoded="${decoded}${a}"
					break
				fi
			done
			if [ "$found" = "0" ]; then
				decoded="${decoded}${p}"
			fi
		fi
	done
	
	echo "$decoded"
}

function readPassword()
{
	if [ "$CS_ECHO" = "1" ]; then
		read -p "Password: " pass
	elif [ "$CS_ECHO" = "2" ]; then
		pass=$(zenity --password --title="Password" 2> /dev/null)
	elif [ "$CS_ECHO" = "3" ]; then
		pass=$(zenity --entry --title="Password" --text="Password (visible):"  2> /dev/null)
	elif [ "$CS_ECHO" = "4" ]; then
		pass=$(readPassMapping)
	else
		read -p "Password: " -s pass
	fi
	if [ -z "$pass" ]; then
		(>&2 echo "! no password")
		failed
	fi
	echo "$pass"
}

function readPass()
{
	local hash=$(readKeyFiles)
	local pass=$(readPassword)
	pass="$pass$hash"
	echo "$pass"
}

function readNewPass()
{
	local hash=$(readKeyFiles)
	local pass=$(readPassword)
	if [ -z "$pass" ]; then
		failed
	fi
	if [ -z "$CS_ECHO" ] || [ "$CS_ECHO" -le "0" ] ; then
		(>&2 echo)
		if [ -t 0 ] ; then
			read -p "Renter password: " -s pass2
			(>&2 echo)
			if [ "$pass" != "$pass2" ]; then
				(>&2 echo "! passwords do not match")
				failed
			fi
		fi
    fi
    pass="$pass$hash"
	echo "$pass"
}

# pass key
function debugKey()
{
	if [ "$CS_ECHO_KEY" = "1" ]; then
		(>&2 echo)
		(>&2 echo "[$1]")
		(>&2 echo "[$2]")
	fi
}

function encryptFile()
{
	local file="${1:-secret.bin}"
	shift
	local pass=$(readNewPass)
	local key=""
	if [ ! -z "$CS_KEY" ]; then
		(>&2 echo "# Using key from CS_KEY")
		key="$CS_KEY"
	else
		key=$(head -c 512 /dev/urandom | base64 -w 0)
	fi
	echo "${file}"
	encodeKey "$file" "$pass" "$key" "$@"
	if [ "$CS_BACKUP" = "1" ]; then
		echo "${file}.bak"
		encodeKey "${file}.bak" "$pass" "$key" "$@"
	fi
}

function decryptFile()
{
	local file="${1:-secret.bin}"
	shift
	local pass=$(readPass)
    decodeKey "$file" "$pass" "$@"
    local key=""
}

function reEncryptFile()
{
	local file="${1:-secret.bin}"
	shift
	(>&2 echo "# Current")
	local pass1=$(readPass)
	(>&2 echo)
	local key=$(decodeKey "$file" "$pass1" "$@" | base64 -w 0)
	(>&2 echo "# New")
	if [ ! -z "$CS_SAME_PASS" ]; then
		(>&2 echo "# Using CS_SAME_PASS")
		pass="$pass1"
	else
		pass=$(readNewPass)
	fi

	if [ ! -z "${2:-}" ]; then
		shift 1
		(>&2 echo "# Using new argon2 params:" "$@" )
	fi

	echo "${file}"
	encodeKey "$file" "$pass" "$key" "$@"
	if [ "$CS_BACKUP" = "1" ]; then
		echo "${file}.bak"
		encodeKey "${file}.bak" "$pass" "$key" "$@"
	fi
	(>&2 echo "Done: $file")
}

# mode file
function main()
{
    local mode="$1"
    shift
    case "$mode" in
        enc)
			encryptFile "$@"
		;;
		enc2)
			CS_BACKUP=1
			encryptFile "$@"
        ;;
        dec)
			decryptFile "$@"
        ;;
        chp)
			reEncryptFile "$@"
        ;;
        chp2)
			CS_BACKUP=1
			reEncryptFile "$@"
        ;;
        *)
            (>&2 echo "Usage: $(basename "$0") [enc | enc2 | dec | chp | chp2] file [\"p,m,t\"]")
            (>&2 echo " file is overwritten by enc and chp, backup it as needed before")
            (>&2 echo " default argon2 \"p,m,t\" are: \"$argon2pmt\"")
            (>&2 echo 'Examples:')
            (>&2 echo ' CS_KEY=$(cskey.sh dec s.txt | base64 -w 0) cskey.sh enc d.txt "8,16,1000"')
            (>&2 echo ' CS_SAME_PASS=1 cskey.sh chp d.txt "8,14,1000" "8,16,1000"')
        ;;
    esac
}

main "$@"
