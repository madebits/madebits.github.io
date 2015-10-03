#Change Wallpaper at Startup in Lubuntu

2012-08-01

<!--- tags: linux -->

The following simple bash script changes the Lubuntu pcmanfm desktop wallpaper using a different file each time it is run at login from the current user Pictures folder:

```bash
#!/bin/bash

picturesPath=~/Pictures

#IFS="$(printf '\n\t')"
#allFiles=( $(find "$picturesPath" -maxdepth 1 -type f) )

allFiles=()
for f in $picturesPath/*; do
	if [ -f "$f" ]
	then
    		allFiles[${#allFiles[@]}]="$f"
	fi
done

allFilesCount=${#allFiles[*]}

if [ ${allFilesCount} -eq 0 ]
then
	exit 1
fi 

selectedFileIdx=$[ ( $RANDOM % ${allFilesCount} ) ]
selectedFile=${allFiles[$selectedFileIdx]}

if  [ -f "$selectedFile"  ]
then
	echo "$selectedFile"
 	sleep 1s #increase if problems
	pcmanfm --set-wallpaper="$selectedFile"
fi
```

Copy the script above to a text file, for example using `leafpad ~/bin/wallpaper.sh` (create `~/bin` if it does not exists) and make the file executable (`chmod u+x ~/bin/wallpaper.sh`). Then create a shortcut file in `~/.config/autostart` (`leafpad ~/.config/autostart/ChangeWallpaper.desktop` or using `lxshortcut -o ~/.config/autostart/ChangeWallpaper.desktop`) with the following content:

```
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=ChangeWallpaper
Name[en_US]=ChangeWallpaper
Exec=/home/USER/bin/wallpaper.sh
Comment[en_US]=
```

Replace `/home/USER` without your user folder.

Now Lubuntu will change the desktop wallpaper every time you login. It may take some second until the wallpaper is changed.

Update: Filling a bash array as in the above script and selecting a line randomly from it, is how a generic programmer approaches the shuffle problem. A shell programmer would better use something like (modified from Ubuntu [forums](http://ubuntuforums.org/showthread.php?t=1843824&page=2)):

```bash
#!/bin/bash

picturesPath=~/Pictures

selectedFile=$(ls "${picturesPath}"/*.* | shuf -n1)

if  [ -f "$selectedFile"  ]
then
	echo "$selectedFile"
	sleep 1s #increase if problems
	pcmanfm --set-wallpaper="$selectedFile"
fi
```

`shuf`(fle) does whatever I did above.

And this is the version that changes wallpaper every 30 seconds:

```bash
#!/bin/bash

picturesPath=~/Pictures

while :
do
	selectedFile=$(ls "${picturesPath}"/*.* | shuf -n1)
	if  [ -f "$selectedFile"  ]
	then
	    #echo "$selectedFile"
	    #sleep 1s #increase if problems
	    pcmanfm --set-wallpaper="$selectedFile"
	fi
	sleep 30
done

```


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2012/2012-08-21-Disable-History-in-Lubuntu.md'>Disable History in Lubuntu</a> <a rel='next' id='fnext' href='#blog/2012/2012-07-21-Converting-Swap-Partition-to-a-Swap-File-in-Lubuntu.md'>Converting Swap Partition to a Swap File in Lubuntu</a></ins>
