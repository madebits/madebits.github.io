#Lubuntu Toggle Desktop Icons on Double-Click

2012-09-08

<!--- tags: linux -->

I have got used to [Fences](http://www.stardock.com/products/fences/) on Windows to hide or show all desktop items using a double-click on an empty part of desktop. I miss this somehow on Lubuntu. The following script is my attempt to mimic that behavior at some extend.

```
#!/bin/bash

dir=~/Desktop/
files1="${dir}*.desktop"
files2="${dir}.*.desktop"
show=1

# hide
for i in $(ls -r $files1) ; do 
	if [ -e $i ]; then
	match=$(cat $i | grep $0)
	if [ $? -eq 1 ]; then
		show=0
		f=$(basename $i)
		nf=".${f}" 
		echo "Hide: ${dir}${f} ${dir}${nf}"
		mv "${dir}${f}" "${dir}${nf}"
	fi
fi
done

#show
if [ $show -eq 1 ]; then
	for i in $(ls -r $files2); do
	if [ -e $i ]; then
		f=$(basename $i)
		nf=${f#.}
		echo "Show: ${dir}${f} ${dir}${nf}"
		mv "${dir}${f}" "${dir}${nf}"
	fi
	done
fi
```

The script if run will "hide" all `*.desktop` shortcut icons from desktop, renaming them by adding a dot in front of original name. When run a second time, the script undoes that. So basically the script switches the visibility of `~/Desktop/*.desktop` items each time it is run.

I did the script only for `*.desktop` files, given that renaming folders may have side effects. I have also mostly `*.desktop` files on my desktop.

To run the script, copy it somewhere in your home folder (e.g.: as `~/bin/switchdesktopicons.sh`) and make it executable (`chmod u+x ~/bin/switchdesktopicons.sh`). Then create a shortcut (e.g., `switchvisibility.desktop` - the name does not matter) on desktop, and set as its executable to run to the full absolute path to the script: `Exec=/home/vasian/bin/switchdesktopicons.sh` (replace vasian with your user name). If you use the LXDE gui tool to create the shortcut then the Exec= part is not needed.

The script will hide all `*.desktop` icons apart of the one pointing to it (it detects it based on the Exec line). So now you can hide/show the rest of `*.desktop` icons from desktop by double-clicking this file (do not double-click it too fast more than once, otherwise you may hide/show them twice).


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2012/2012-09-29-Upgrading-Asus-Eee-PC-X101.md'>Upgrading Asus Eee PC X101</a> <a rel='next' id='fnext' href='#blog/2012/2012-09-02-Fullscreen-Browsing-in-Google-Chrome.md'>Fullscreen Browsing in Google Chrome</a></ins>
