#!/bin/bash

#I: folder pass resize

if [[ ! -d "$1" || -z "$2" ]]; then
	echo "Usage: $0 folder pass"
	exit 1
fi

folder="$1"
pass="$2"
resize=100
if [[ -n "$3" ]]; then
	resize="$3"
fi

urlPrefix="@@@"
outDir="mb-gallery"
outFile="${outDir}/index.md"
count=0
rm -rf "${outDir}"
total=$(find "${folder}" -maxdepth 1 -type f -iname "*.jpg" | wc -l)
if [[ $total -eq 0 ]]; then
	exit 0
fi
mkdir "${outDir}"

echo -e "#<i class='fa fa-th'></i> Gallery\n\n" >> "${outFile}"

find "${folder}" -maxdepth 1 -type f -iname "*.jpg" | sort | while read filePath; do
	count=$((count+1))	
	echo "${count} / ${total} : ${filePath}"
	fileData=$(convert -resize ${resize}% "$filePath" jpeg:- | base64 -w 0)
	fileDataThumb=$(convert -resize 100x100 "$filePath" jpeg:- | base64 -w 0)
	
	echo -e "[![@nosave@@inline@](data:image/jpeg;base64,${fileDataThumb})](${urlPrefix}${count}.dx) " >> "${outFile}"

	links="[<i class='fa fa-th'></i>](${urlPrefix}index.dx)"
	prevCount=$((count-1))
	nextCount=$((count+1))
	if [[ $prevCount -ge 1 ]]; then
		links="[<i class='fa fa-chevron-circle-left'></i>](${urlPrefix}${prevCount}.dx) ${links}"
	fi
	if [[ $nextCount -le $total ]]; then
		links="${links} [<i class='fa fa-chevron-circle-right'></i>](${urlPrefix}${nextCount}.dx)"
	fi

	echo -e "${count} / ${total} ${links}\n\n" >> "${outDir}/${count}.md"
	if [[ $nextCount -le $total ]]; then
		echo -e "[![@nosave@@responsive@](data:image/jpeg;base64,${fileData})](${urlPrefix}${nextCount}.dx)\n\n" >> "${outDir}/${count}.md"
	else
		echo -e "![@nosave@](data:image/jpeg;base64,${fileData})\n\n" >> "${outDir}/${count}.md"
	fi
	echo -e "${count} / ${total} ${links}\n\n" >> "${outDir}/${count}.md"

	$(./menc.js "${outDir}/${count}.md" "${pass}" > "${outDir}/${count}.dx")
	$(rm "${outDir}/${count}.md")
done

echo -e "\n\n**#${total}**\n" >> "${outFile}"

$(./menc.js "${outFile}" "${pass}" > "${outDir}/index.dx")
$(rm "${outFile}")
