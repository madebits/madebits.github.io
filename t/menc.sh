#! /bin/bash

if [[ ! -d "$1" || -z "$2" ]]; then
	echo "Usage: $0 folder file"
	exit 1
fi

outFile="$2"

if [ -f "$outFile" ]; then
	rm "$outFile"
fi

echo -e "#Photos\n" >> "$outFile"
find "$1" -type f -iname "*.jpg" | sort | while read filePath; do
	fileData=$(base64 -w 0 "$filePath")
	echo -e "![](data:image/jpeg;base64,${fileData})\n" >> "$outFile"
done

echo -e "\n**End**\n" >> "$outFile"