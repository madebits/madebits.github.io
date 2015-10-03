#!/bin/bash

TOOLSDIR=$(dirname $0)
INPUTDIR=.
RESIZE=100%
SUFFIX=".dx"
OUTDIR="./mb-gallery"
THUMBSIZE=100
TITLE="Gallery"

if [[ $# -eq 0 ]] ; then
    echo 'Usage: -i inputDir -p password [-r resize] [-s suffix] [-o outputDir] [-t thumbSize] [-h headerTitle]'
    exit 1
fi

while [[ $# > 1 ]]
do
key="$1"

case $key in
    -i|--input)
    INPUTDIR="$2"
    shift
    ;;
    -p|--password)
    PASS="$2"
    shift
    ;;
    -r|--resize)
    RESIZE="$2"
    shift
    ;;
    -s|--suffix)
    SUFFIX="$2"
    shift
    ;;
    -o|--output)
    OUTDIR="$2/gallery"
    shift
    ;;
    -t|--thumbsize)
    THUMBSIZE="$2"
    shift
    ;;
    -h|--header)
    TITLE="$2"
    shift
    ;;

    #--default)
    #DEFAULT=YES
    #;;
    *)
    echo "Unknown option $1"
    exit 1
    ;;
esac
shift
done

if [[ -z "$INPUTDIR" ]]; then
	echo "-i required"
	exit 1
fi
if [[ -z "$PASS" ]]; then
	echo "-p required"
	exit 1
fi

URLPREFIX="@@@"
outFile="${OUTDIR}/index.md"
rm -rf "${OUTDIR}"
count=0
total=$(find "${INPUTDIR}" -maxdepth 1 -type f -iname "*.jpg" | wc -l)
if [[ $total -eq 0 ]]; then
	exit 0
fi
mkdir -p "${OUTDIR}"

echo -e "#<i class='fa fa-th'></i> ${TITLE}\n\n" >> "${outFile}"

find "${INPUTDIR}" -maxdepth 1 -type f -iname "*.jpg" | sort | while read filePath; do
	count=$((count+1))	
	echo "${count} / ${total} : ${filePath}"
	fileData=$(convert -resize ${RESIZE} "$filePath" jpeg:- | base64 -w 0)
	fileDataThumb=$(convert -resize ${THUMBSIZE}x${THUMBSIZE} "$filePath" jpeg:- | base64 -w 0)
	
	echo -e "[![@nosave@@inline@](data:image/jpeg;base64,${fileDataThumb})](${URLPREFIX}${count}${SUFFIX}) " >> "${outFile}"

	links="[<i class='fa fa-th'></i>](${URLPREFIX}index${SUFFIX})"
	prevCount=$((count-1))
	nextCount=$((count+1))
	if [[ $prevCount -ge 1 ]]; then
		links="[<i class='fa fa-chevron-circle-left'></i>](${URLPREFIX}${prevCount}${SUFFIX}) ${links}"
	fi
	if [[ $nextCount -le $total ]]; then
		links="${links} [<i class='fa fa-chevron-circle-right'></i>](${URLPREFIX}${nextCount}${SUFFIX})"
	fi

	#echo -e "${count} / ${total} ${links}\n\n" >> "${OUTDIR}/${count}.md"
	echo -e "<br>" >> "${OUTDIR}/${count}.md"
	if [[ $nextCount -le $total ]]; then
		echo -e "[![@nosave@@responsive@](data:image/jpeg;base64,${fileData})](${URLPREFIX}${nextCount}${SUFFIX})\n\n" >> "${OUTDIR}/${count}.md"
	else
		echo -e "[![@nosave@@responsive@](data:image/jpeg;base64,${fileData})](${URLPREFIX}1${SUFFIX})\n\n" >> "${OUTDIR}/${count}.md"
	fi
	echo -e "${count} / ${total} ${links}\n\n" >> "${OUTDIR}/${count}.md"

	$(${TOOLSDIR}/menc.js "${OUTDIR}/${count}.md" "${PASS}" > "${OUTDIR}/${count}${SUFFIX}")
	$(rm "${OUTDIR}/${count}.md")
done

echo -e "\n\n<i class='fa fa-picture-o'></i> #${total}\n" >> "${outFile}"

$(${TOOLSDIR}/menc.js "${outFile}" "${PASS}" > "${OUTDIR}/index${SUFFIX}")
$(rm "${outFile}")

biggestFile=$(find ${OUTDIR} -maxdepth 1 -printf '%s %p\n' | sort -nr | head -1 | cut -d ' ' -f 2)
echo "Biggest file in ${OUTDIR} (max 11M):"
du -h "${biggestFile}"