#MComix on Lubuntu

2013-08-14

<!--- tags: linux -->

[MComix](http://sourceforge.net/p/mcomix/wiki/Home/) is a nice image viewer I am using in Lubuntu.

* +MComix opens fast. I have associated jpg and png files with it, and it launches pretty quickly once I click one of them in PCManFm file manager.
* +Once a file is open, you can move back and forth between all files in the original folder.
* +It can preview images in archives (rar and zip among others). This is very nice. It cannot preview password protected archives, and I am not sure what its limits about the number of images in the archive are.
* +You can also open folders with it and view all image files in the folder.
* -It lacks zoom on mouse-wheel, but the keyboard support is enough for me.
* -It has kind of smart scroll, which while I understand how it is supposed to work, I find confusing, and I think the program would be better without it (I have disabled it, but still Shift + mouse wheel does not do horizontal scroll).
* -The original [Comix](http://comix.sourceforge.net/) (MComix is a maintained fork of that), shows file number on top of thumbnails. MComix replaces that with a standard GTK list where the file number is in first column, that consumes some more space.

You can configure it to start on full screen, which I did.

I switched the key bindings of "File / Close", and "File / Quit" menus, using `Ctrl+W` to quit - as this is same in Eog, Chromium, and PCManFm. To do that, I edited, `leafpad ~/.config/mcomix/keybindings-gtk.rc` and uncommented and switched the key for these two lines:

```
(gtk_accel_path "<Actions>/mcomix-main/quit" "<Primary>w")
(gtk_accel_path "<Actions>/mcomix-main/close" "<Primary>q")
```

MComix uncompresses opened archive files on `/tmp/mcomix.*` folders. While MComix mostly removes these folders ok, sometimes some of them still remain. For me `/tmp` is mounted on RAM with `tmpsfs` so no such files remain there between system start-ups.

Current version of MComix is 1.00, but in Ubuntu repositories currently you can find only 0.99. I installed first 0.99 from the Ubuntu repositories. Then I saw 1.00 had a feature I really was thinking would be nice - the capability to run custom external commands on current file (and some nice fixes and improvements). So I decided to get version 1.00.

I did that on a very lazy way. I downloaded 1.00 from MComix web site, and uncompressed in `~/bin/mcomix-1.00` folder. Made sure `mcomixstarter.py` inside it was executable by anyone, and then I modified as root, the desktop starter file in `/usr/share/applications/mcomix.desktop` to change `Exec=mcomix %f` line with `Exec=/home/user/bin/mcomix-1.00/mcomixstarter.py %f`. Like this, I have officially 0.99 installed, and if 1.00 comes to the Ubuntu repositories I will get it. But for all practical purposes I am now using 1.00.

I added as the first three external commands via the GUI (they are stored in `~/.config/mcomix/preferences.conf` and will be lost if you run 0.99 version):

```
"openwith commands": [
    [
      "WallpaperStrech", 
      "pcmanfm --wallpaper-mode=scretch  --set-wallpaper %F", 
      "", 
      true
    ], 
    [
      "WallpaperFit", 
      "pcmanfm --wallpaper-mode=fit  --set-wallpaper %F", 
      "", 
      true
    ], 
    [
      "WallpaperCenter", 
      "pcmanfm --wallpaper-mode=center  --set-wallpaper %F", 
      "", 
      true
    ], 
    [
      "-", 
      "", 
      "", 
      false
    ], 
    [
      "Gimp", 
      "gimp %F", 
      "", 
      false
    ], 
    [
      "Eog", 
      "eog -f %F", 
      "", 
      false
    ]
  ], 
```

Like this I can easy set LXDE wallpaper from MComix (I disabled use of these for archives as the files are only temporary), and launch also Gimp and Gnome Image Viewer (on full screen mode).

I wanted also to be able to copy file paths from MComix. The "Edit / Copy" menu only copies the image in clipboard, not the path. To fix this, installed [xclip](http://askubuntu.com/questions/210413/what-is-the-command-line-equivalent-of-copying-a-file-to-clipboard) (`sudo apt-get install xclip`) and created an executable shell script in `/home/user/bin/copyfile.sh` with the following content:

```
#!/bin/bash

echo "$1" | xclip -i -selection clipboard -t text/uri-list
```

Then I added an another external command in MComix, called `CopyPath` as `/home/user/bin/copyfile.sh "%F"`. Like this, while I view a file in MComix, I can copy it and paste it somewhere else in PCManFm file manager.


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-08-20-Sort-Photos-By-EXIF-Date.md'>Sort Photos By EXIF Date</a> <a rel='next' id='fnext' href='#blog/2013/2013-08-09-Reconnect-External-IP-for-Speeport-w504v.md'>Reconnect External IP for Speeport w504v</a></ins>
