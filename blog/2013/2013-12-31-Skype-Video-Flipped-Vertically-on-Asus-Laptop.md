#Skype Video Flipped Vertically on Asus Laptop

2013-12-31

<!--- tags: linux -->

Skype on my Asus machine running Lubuntu was showing my own video from the laptop integrated webcam flipped vertically.

Asus mounts the webcam top down and converts it video with software. To fix this in (L)Ubuntu, I followed the [instructions](http://forum.ubuntu-it.org/viewtopic.php?f=95&t=546530) in Ubuntu italian forums. I have 64-bit Ubuntu and Skype needs the 32 bit version of the libraries, I enabled first the 386 repositories:
```
sudo dpkg --add-architecture i386
sudo apt-get update
```

Then installed `libv4l` 32-bit:
```
sudo apt-get install libv4l-0:i386
```
To start Skype then the following command has to be used:
```
LD_PRELOAD=/usr/lib/i386-linux-gnu/libv4l/v4l1compat.so skype
```

I copied my existing Skype desktop shortcut file and modified its `Exec` line as follows (`PULSE_LATENCY_MSEC` part was already there):
```
Exec=sh -c 'env LD_PRELOAD=/usr/lib/i386-linux-gnu/libv4l/v4l1compat.so env PULSE_LATENCY_MSEC=60 skype %U'
```

Both `v4l1compat.so` and `v4l2convert.so` seem to work. I followed the [advice](http://ubuntuforums.org/archive/index.php/t-1937857.html) to use `v4l2convert.so` and modified the Skype desktop file Exec line finally to:

```
Exec=sh -c 'env LD_PRELOAD=/usr/lib/i386-linux-gnu/libv4l/v4l2convert.so env PULSE_LATENCY_MSEC=60 skype %U'
```

http://ubuntuforums.org/archive/index.php/t-1937857.html

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-01-06-xdg-open-Failing-on-Folders-on-Lubuntu.md'>xdg open Failing on Folders on Lubuntu</a> <a id='fnext' href='#blog/2013/2013-12-29-Updating-my-Laptop-to-a-SSD.md'>Updating my Laptop to a SSD</a></ins>
