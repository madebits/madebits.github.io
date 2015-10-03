#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Usage: $0 title [editor]"
	exit 1
fi

editor=$EDITOR

if [[ -n "$2" ]]; then
	editor="$2"
fi	

title=$1
year=$(date +"%Y")
date=$(date +"%Y-%m-%e")
folder="blog/$year"
fileTitle=$(echo "$1" | tr " " "-")
file="$folder/$date-$fileTitle.md"

if [ -f "$file" ]; then
	echo "Edit: $file"
	$editor "$file" &
	exit 0
fi

echo "Create: $file"
mkdir -p "$folder"
cat <<- EOF > "$file"
#$title

$date


EOF

$editor "$file" &
