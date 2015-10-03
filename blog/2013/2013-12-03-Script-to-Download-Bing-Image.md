#Script to Download Bing Image

2013-12-03

<!--- tags: linux photo -->

A one liner `curl` based script to download Bing image, by default as a file named `bing.jpg`.

```
#!/bin/sh
curl -s "http://www.bing.com$(curl -s http://www.bing.com/?cc=us | grep -h "/az/.*jpg" | sed -n '/\/az\/.*jpg/ s/.*\(\/az\/.*jpg\).*/\1/p')" -o ${1:-"bing.jpg"}
```
Well, actually with shebang line, there are two lines :), but the curl one is a one-liner. To change the output file name, modify the `-o` part.

In Lubuntu, a modified version, can be used to change the wallpaper on every login to the current Bing image:
```
#!/bin/bash

outPath="/home/user/Pictures/bing.jpg";
curl -s "http://www.bing.com$(curl -s http://www.bing.com/?cc=us | grep -h "/az/.*jpg" | sed -n '/\/az\/.*jpg/ s/.*\(\/az\/.*jpg\).*/\1/p')" -o ${1:-$outPath}
if [ -f "$outPath" ]; then
	pcmanfm --set-wallpaper="$outPath"
fi
```

To run it at startup, add to `~/.config/lxsession/Lubuntu/autostart` a line:
```
@/home/user/bin/bingwallpaper.sh
```
Where `/home/user/bin/bingwallpaper.sh` is the executable file where you saved the above script.

**Update:** [Bing Image Gallery](http://www.bing.com/gallery/)

<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-12-27-A-Look-at-UEFI-Boot.md'>A Look at UEFI Boot</a> <a id='fnext' href='#blog/2013/2013-12-01-Emitting-Source-Code-Examples-From-PHP-Pages.md'>Emitting Source Code Examples From PHP Pages</a></ins>
