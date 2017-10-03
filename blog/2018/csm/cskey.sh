#!/bin/bash

# cskey.sh

set -e

# none of values in this file is secret
# change default argon2 params as it fits you here
adt="1000"
adm="16"
adp="8"

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
    
    local at="${4:-$adt}"
	local am="${5:-$adm}"
	local ap="${6:-$adp}"
    
    local salt=$(head -c 32 /dev/urandom | base64 -w 0)
    hash=$(echo -n "$pass" | argon2 "$salt" -id -t $at -p $ap -m $am -l 128 -r)
    
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
    
    local at="${3:-$adt}"
	local am="${4:-$adm}"
	local ap="${5:-$adp}"
    
    if [ -e "$file" ] || [ "$file" = "-" ]; then
		local fileData=$(head -c 600 "$file" | base64 -w 0)
		local salt=$(echo -n "$fileData" | base64 -d | head -c 32 | base64 -w 0)
		local data=$(echo -n "$fileData" | base64 -d | tail -c +33 | head -c "$keyLength" | base64 -w 0)
        local hash=$(echo -n "$pass" | argon2 "$salt" -id -t $at -p $ap -m $am -l 128 -r)
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
				exit 1
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

function readPass()
{
	local hash=$(readKeyFiles)
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
		exit 1
	fi
	pass="$pass$hash"
	echo "$pass"
}

function readNewPass()
{
	local pass=$(readPass)
	if [ -z "$pass" ]; then
		exit 1
	fi
	if [ -z "$CS_ECHO" ] || [ "$CS_ECHO" -le "0" ] ; then
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
	echo "$pass"
}

# mode file
function main()
{
    local mode="$1"
    local file="${2:-secret.bin}"
    local key=""
    case "$mode" in
        enc)
			shift 2
            pass=$(readNewPass)
            
            if [ ! -z "$CS_KEY" ]; then
				(>&2 echo "# Using key from CS_KEY")
				key="$CS_KEY"
			else
				key=$(head -c 512 /dev/urandom | base64 -w 0)
            fi
            
            if [ "$CS_ECHO_KEY" = "1" ]; then
				(>&2 echo)
				(>&2 echo "[$pass]")
				(>&2 echo "[$key]")
			fi
            encodeKey "$file" "$pass" "$key" "$@"
        ;;
        dec)
			shift 2
			pass=$(readPass)
            decodeKey "$file" "$pass" "$@"
        ;;
        chp)
			shift 2
			(>&2 echo "# Current")
			pass1=$(readPass)
            (>&2 echo)
            key=$(decodeKey "$file" "$pass1" "$@" | base64 -w 0)
            (>&2 echo "# New")
            if [ ! -z "$CS_SAME_PASS" ]; then
				(>&2 echo "# Using CS_SAME_PASS")
				pass="$pass1"
			else
				pass=$(readNewPass)
            fi
            if [ "$CS_ECHO_KEY" = "1" ]; then
				(>&2 echo)
				(>&2 echo "[$pass]")
				(>&2 echo "[$key]")
			fi
			if [ ! -z "$6" ]; then
				shift 3
				(>&2 echo "# Using new argon2 params:" $@ )
			fi
            encodeKey "$file" "$pass" "$key" "$@"
            (>&2 echo "Done: $file")
        ;;
        *)
            (>&2 echo "Usage: basename($0) [enc | dec | chp] file [t m p]")
            (>&2 echo " file is overwritten by enc and chp, backup it as needed before")
            (>&2 echo " default argon2 t m p are: $adt $adm $adp")
            (>&2 echo 'Examples:')
            (>&2 echo ' CS_KEY=$(cskey.sh dec s.txt | base64 -w 0) cskey.sh enc d.txt 1000 16 8')
            (>&2 echo ' CS_SAME_PASS=1 cskey.sh chp d.txt 1000 14 8 1000 16 8')
            exit 1
        ;;
    esac
}

main "$@"
