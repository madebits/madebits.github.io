#!/bin/bash

TOOLSDIR=$(dirname $0)
sidebar="index/sidebar.md"
contents="index/contents.md"
feed="index/atom.xml"
baseUrl="https://madebits.github.io/"
noscriptIndex="noscript.html"

p_cleanUp()
{
	if [ -f $noscriptIndex ]; then
		rm $noscriptIndex
	fi
	rm -rf index/*
	touch "$sidebar"
	echo "#Blog | [Latest](#blog)" >> "$contents"
	echo "" >> "$contents"
	echo "<div class='bloglinks'>" >> "$contents"
#cat <<- EOF > "$feed"
#<?xml version="1.0" encoding="utf-8"?>
#<?xml-stylesheet type="text/xsl" href="../styles/atom.xsl"?>
#<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en">
#	<id>${baseUrl}</id>
#	<title>MadeBits</title>
#	<updated>$(date +"%Y-%m-%d")T12:00:00Z</updated>
#	<link href="${baseUrl}"/>
#EOF
}

p_getFileName()
{
	fileName=$(basename "$1")
	fileName="${fileName%.*}"
	echo $fileName
}

p_processLinks()
{
	#echo "P: $previous C: $current N: $next"
	line=$(grep -n "^ *<div class='nfooter'>" "$current" | cut -d: -f1)
	
	if [[ $line -lt 1 ]]; then
		line=$(grep -n "^ *<ins class='nfooter'>" "$current" | cut -d: -f1)
	fi

	tempFile=".tmpfile"
	if [ -f $tempFile ]; then
		rm $tempFile
	fi
	if [[ $line -ge 1 ]]; then
		head -n $(($line - 1)) "$current" > "$tempFile"
		rm "$current"
		mv "$tempFile" "$current"
	fi	

	data="<ins class='nfooter'>"
	append=0
	if [[ -n $previous ]]; then
		append=1
		fileName=$(p_getFileName "$previous")
		title=$(echo "$fileName" | cut -d "-" -f 4- | tr "-" " ")
		data="${data}<a id='fprev' href='#${previous}'>${title}</a> "
	fi
	if [[ -n $next ]]; then
		append=1
		fileName=$(p_getFileName "$next")
		title=$(echo "$fileName" | cut -d "-" -f 4- | tr "-" " ")
		data="${data}<a id='fnext' href='#${next}'>${title}</a>"
	fi
	data="${data}</ins>"
	if [[ append -eq 1 ]]; then
		echo "$data" >> "$current"
	fi
}

p_feedEntry()
{
	echo "<entry><title>$1</title><link href=\"$baseUrl#$2\"/><id>$baseUrl#$2</id><updated>$3T12:00:00Z</updated><summary>$4</summary></entry>" >> "$feed"
}

p_cleanUp

totalCount=$(find blog/ -type f -iname "*.md" -o -iname "*.mx" | wc -l)
if [[ totalCount -eq 0 ]]; then
	exit 0
fi

count=0
lastYear=''
lastMonth=''
currentFile=''

previous=''
current=''
next=''

find blog/ -type f -iname "*.md" -o -iname "*.mx" | sort -r | while read filePath; do
	count=$((count+1))

	# re-build index

	fileName=$(p_getFileName "$filePath")
	year=$(echo "$fileName" | cut -d "-" -f 1)
	month=$(echo "$fileName" | cut -d "-" -f 2)
	day=$(echo "$fileName" | cut -d "-" -f 3)
	day=$(echo "$day" | cut -d " " -f 1)
	title=$(echo "$fileName" | cut -d "-" -f 4- | tr "-" " ")
	link="* $year-$month-$day [$title](#$filePath)"
	link2="* [$title](#$filePath)"
	if [[ "$lastYear" -ne "$year" ]]; then
		lastYear=$year;
		currentFile="index/${year}.md"
		if [ -f "$currentFile" ]; then
			rm "$currentFile"
		fi
		echo "[$year](#$currentFile)" >> "$contents"
		echo "" >> "$currentFile"
		echo "#$year | [Archives](#${contents})" >> "$currentFile"
	fi
	if [[ ${lastMonth#0} -ne ${month#0} ]]; then
		lastMonth=$month;
		echo "" >> "$currentFile"
		echo "###$month" >> "$currentFile"
	fi
	echo "${link}" >> "$currentFile"
	if [[ $count -le 8 ]]; then
		echo "${link2}" >> "$sidebar"
		#p_feedEntry "$title" "$filePath" "$year-$month-$day" "$(head -n 5 "$filePath" | tail -n 1)"
	fi
	if [[ $count -eq 1 ]]; then
		echo "var homeUrl='$filePath';" > scripts/home.js
	fi

	# add previous / next links

	previous=$current
	current=$next
	next=$filePath
	#process previous
	if [[ $count -gt 1 ]]; then
		p_processLinks
	fi
	#process last
	if [[ $count -eq $totalCount ]]; then
		previous=$current
		current=$next
		next=''
		p_processLinks
	fi
done

echo "</div>" >> "$contents"

#cat <<- EOF >> "$feed"
#</feed>
#EOF

echo "<h1>MadeBits - No JavaScript - Site Index</h1>" >> $noscriptIndex
echo "<p>JavaScript is required to view <a href=\"index.html\">contents</a> of this web site.</p><ul>" >> $noscriptIndex

find ./blog ./r -type f -iname "*.md"  -o -iname "*.mx" -o -iname "*.html" | sort | while read filePath; do
	fileName=$(p_getFileName "$filePath")
	dirName=$(dirname "$filePath");
	title=$(echo "$fileName" | tr "-" " ")
	if [[ $fileName == "404" ]]; then
		continue
	fi
	tags=$(head -n 10 "$filePath" | grep '<!--- tags')
	echo "<li><a href=\"index.html#$filePath\">($dirName) =&gt; $title</a> $tags</li>" >> $noscriptIndex
done
echo "</ul>" >> $noscriptIndex

if [[ $1 == "push" ]]; then
	echo "Publishing ..."
	${TOOLSDIR}/mserverpush.sh
fi 
