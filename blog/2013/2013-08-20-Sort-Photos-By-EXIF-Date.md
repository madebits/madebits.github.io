#Sort Photos By EXIF Date

2013-08-20 

<!--- tags: linux photo -->

The following script, tested in Lubuntu, if run over a folder with JPG photos taken with a camera that stores the date in EXIF properties, will order the photos in sub-folders one per each day. The script is a modified version of [another](http://ubuntuforums.org/archive/index.php/t-1679113.html) script that does something similar. It uses `exif` tool available from Ubuntu repositories (`sudo apt-get install exif`).

The script creates sub-folders of form `yyyy/yyyy-mm/yyyy-mm-dd`.

```
#!/bin/bash

dir=$1
if [ -z "$dir" ] 
	then
	dir="."
fi
cd $dir
shopt -s nullglob
shopt -s nocaseglob
for file in *.jpg
do
	exif_time=$(exif -t 0x9003 "$file" | grep -oP '\d{4}:\d{2}:\d{2}' | tr : -)
	status=$?
	if [ "$status" == "0" ]
	then
		filename=$(basename "$file")
		year=$(echo ${exif_time} | cut -d '-' -f 1)
		yearmonth=$(echo ${exif_time} | cut -d '-' -f 1,2)
		targetfolder="${year}/${yearmonth}/${exif_time}"
		targetfile="${targetfolder}/${filename}"
		echo "Moving: ${file} to ${targetfile}"
		mkdir -p "$targetfolder"
		mv "$file" "$targetfile"
	fi
done
```

Store the script as executable file, e.g., `sortphotos.sh` and run it with the folder containing the images as follows:
```
sortphotos.sh /media/DCIM/101_PANA
```

<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-09-07-Encrypted-Containers-with-Cryptsetup.md'>Encrypted Containers with Cryptsetup</a> <a id='fnext' href='#blog/2013/2013-08-14-MComix-on-Lubuntu.md'>MComix on Lubuntu</a></ins>
