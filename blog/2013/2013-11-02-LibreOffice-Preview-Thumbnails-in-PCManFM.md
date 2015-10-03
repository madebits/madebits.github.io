#LibreOffice Preview Thumbnails in PCManFM in Lubuntu

2013-11-02

<!--- tags: linux -->

PCManFM (libfm) can display thumbnails for arbitrary file types (not supported directly by PCManFM) using information found in `/usr/share/thumbnailers`. In `/usr/share/thumbnailers` there are (can be) text files ending in `*.thumbnailer` (their exact name does not matter to libfm). A `*.thumbnailer` file connects an external thumbnail tool with the file mime types they apply to.

An external thumbnail tool (or script) receives as input a file path (it can be a `file://` URL, thought in my tests they can as plain paths quoted with `''`) and an output path. The tool then should generate in the given output path a PNG image for the given input file.

##PCManFM thumbnails for LibreOffice

It turns out, Libre/OpenOffice alredy stores a thumbnailof the document in PNG format inside the document's file. Libre/OpenOffice document files are renamed ZIP files, so the thumbnail can be read from it easy from `Thumbnails/thumbnail.png`. I started with a Ubuntu forum [post](http://ubuntuforums.org/showthread.php?t=76566) that shows a python script to extract a Libre/OpenOffice document thumbnail. The original script uses some gnome specific library not found in Lubuntu, so I modified it a bit to make it gnome independent:

```
#!/usr/bin/python
# released into the public domain http://creativecommons.org/licenses/publicdomain
import zipfile
import sys
import urllib2

inURL=sys.argv[1]
if inURL.startswith("file://"):
	inURL = inURL[7:]
	inURL = urllib2.unquote(inURL)

outURL=sys.argv[2]
zip=zipfile.ZipFile(inURL,mode="r")
picture=zip.read("Thumbnails/thumbnail.png")
thumbnail=open(outURL,"w")
thumbnail.write(picture)
thumbnail.write("/n")
zip.close()
thumbnail.close()
```
I copied the above script as `oo-thumbnailer` in `/usr/local/bin` as root and made it executable for anyone (world). Then I created (as root) a new file called `oo.thumbnailer` in `/usr/share/thumbnailers` folder, with the following content:

```
[Thumbnailer Entry]
TryExec=oo-thumbnailer
Exec=/usr/local/bin/oo-thumbnailer %i %o
MimeType=application/vnd.oasis.opendocument.text;application/vnd.oasis.opendocument.presentation;application/vnd.oasis.opendocument.spreadsheet;application/vnd.oasis.opendocument.graphics;
```

This file works (tested) for LibreOffice Writer (otd), Impress (odp), Calc (ods), and Draw (odg) files. I use only these. A system restart is needed to apply these changes.

In the same way, other thumbnailers can be created for other file types. Another possible parameter for the thumbnailer tool, other that `%i` - input file url and `%o` - output file, is `%s` - size in pixels (e.g. 256). PCManFM will resize on its own the result thumbnail if the size does not match.

##PCManFM thumbnails for plain text files

Create (as root) in `/usr/local/bin` a file called `text-thumbnailer` with following executable script (requires `imagemagic`):
```
#!/bin/bash

/usr/bin/convert -density 72 txt:"$1"[1] png:"$2"
```

Another alternative syntaxt for `convert` command used with the script above is (this works only for files that do not contain spaces in the name):

```
/usr/bin/convert -size $3x$3 -density 72x72 -fill "#000" -pointsize 10 label:"$(head -n 16 $1 | sed 's/%/%%/g')" "png:$2"
```

This looks better, but is much slower that the other.

Then in `/usr/share/thumbnailers` I created (as root) a file called `text.thumbnailer` with the following text content:

```
[Thumbnailer Entry]
TryExec=text-thumbnailer
Exec=/usr/local/bin/text-thumbnailer %i %o %s
MimeType=text/plain;
```

After a restart, this seems to work for text files. If you open a text file in a text editor, you may need to refresh (`F5`) PCManFM for the thumbnail to re-appear.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-11-04-Freecom-DVB-T-USB-Receiver-in-Lubuntu.md'>Freecom DVB T USB Receiver in Lubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-11-01-ArchiveMount-in-Lubuntu.md'>ArchiveMount in Lubuntu</a></ins>
