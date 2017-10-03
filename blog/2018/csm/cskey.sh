#!/bin/bash

# cskey.sh

set -e

# none of values in this file is secret
# change argon2 params as it fits you here
at="${3:-1000}"
am="${4:-14}"
ap="${5:-8}"

# set to 1 to use my aes tool, 0 uses ccrypt
toolsDir="$(dirname $0)"
useAes=0
if [ -f "${toolsDir}/aes" ]; then
	useAes=1
fi

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

# file pass key
function encodeKey()
{
    local file="$1"
    local pass="$2"
    local key="$3"
    local salt=$(head -c 32 /dev/urandom | base64 -w 0)
    hash=$(echo -n "$pass" | argon2 "$salt" -t $at -p $ap -m $am -l 128 -r)
    
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
        local hash=$(echo -n "$pass" | argon2 "$salt" -t $at -p $ap -m $am -l 128 -r)
		touchFile "$file"
        echo -n "$data" | base64 -d | decryptAes "$hash"
    else
        (>&2 echo "! no such file: $file")
        exit 1
    fi
}

function readKeyFiles()
{
	declare -a files
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

function readPass()
{
	local hash=$(readKeyFiles)
	if [ "$CS_ECHO" = "1" ]; then
		read -p "Password: " pass
	elif [ "$CS_ECHO" = "2" ]; then
		pass=$(zenity --password --title="Password" 2> /dev/null)
	elif [ "$CS_ECHO" = "3" ]; then
		pass=$(zenity --entry --title="Password" --text="Password (visible):"  2> /dev/null)
	else
		read -p "Password: " -s pass
	fi
	if [ -z "$pass" ]; then
		(>&2 echo "! no password")
		exit 1
	fi
	pass="$pass$hash"
	echo "$pass"
}

function readNewPass()
{
	local pass=$(readPass)
	if [ -z "$CS_ECHO" ]; then
		(>&2 echo)
		if [ -t 0 ] ; then
			read -p "Renter password: " -s pass2
			(>&2 echo)
			if [ "$pass" != "$pass2" ]; then
				(>&2 echo "! passwords do not match")
				exit 1
			fi
		fi
    fi
	if [ -z "$pass" ]; then
		(>&2 echo "! no password")
		exit 1
	fi
	pass="$pass$hash"
	echo "$pass"
}

# mode file
function main()
{
    local mode="$1"
    shift
    local file="${1:-secret.bin}"
    shift
    local key=""
    case "$mode" in
        enc)
            pass=$(readNewPass)
            key=$(head -c 512 /dev/urandom | base64 -w 0)
            if [ "$CS_ECHO_KEY" = "1" ]; then
				(>&2 echo)
				(>&2 echo "[$pass]")
				(>&2 echo "[$key]")
			fi
            encodeKey "$file" "$pass" "$key"
        ;;
        dec)
			pass=$(readPass)
            decodeKey "$file" "$pass"
        ;;
        chp)
			(>&2 echo "Current:")
			pass1=$(readPass)
            (>&2 echo)
            key=$(decodeKey "$file" "$pass1" | base64 -w 0)
            (>&2 echo "New:")
            pass=$(readNewPass)
            if [ "$CS_ECHO_KEY" = "1" ]; then
				(>&2 echo)
				(>&2 echo "[$pass]")
				(>&2 echo "[$key]")
			fi
            encodeKey "$file" "$pass" "$key"
        ;;
        *)
            (>&2 echo "Usage: $0 [enc | dec | chp] file")
            (>&2 echo "file is overwritten by enc and chp, backup it as needed before")
            exit 1
        ;;
    esac
}

main $1 $2
