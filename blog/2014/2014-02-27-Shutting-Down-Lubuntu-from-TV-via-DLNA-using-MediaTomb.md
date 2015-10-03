#Shutting Down Lubuntu from TV via DLNA using MediaTomb

2014-02-27

<!--- tags: linux dlna -->

I use my Lubuntu installation to stream movies over wireless LAN to my TV via [DLNA](http://www.dlna.org/) using [MediaTomb](http://mediatomb.cc/). Given my Lubuntu machine is another room, I sometimes forget or am too lazy to go and shut it down in the evening. I have a cron job that shutdowns it at night, but it would be great if I could shut it down directly from the TV, using the TV remote. It turns out this can be easy done in MediaTomb (miss)using a *transcoder*.

The following method allows anyone in your home LAN to shutdown the the Lubuntu PC via a DLNA capable client (such as a TV, or VideoLanClient), so it is kind of security risk. For my home LAN usage this risk is acceptable.

First configure (as root) `/etc/mediatomb/config.xml` file to define a transcoder. Add the following lines to the shown sections in `config.xml` file (`...` means other existing content in the file):

```
<extension-mimetype ignore-unknown="no">
  <map from="sh" to="video/shell"/>
  ...
<transcoding enabled="yes">
    <mimetype-profile-mappings>
    <transcode mimetype="video/shell" using="shell"/>  
    <!-- comment out other transcoders if you do not want to use them -->
  ...
<profiles> 
    <profile name="shell" enabled="yes" type="external">
       <mimetype>video/mpeg</mimetype>
       <accept-url>no</accept-url>
       <first-resource>yes</first-resource>
       <accept-ogg-theora>no</accept-ogg-theora>
       <agent command="/bin/bash" arguments="%in"/>
       <buffer size="14400000" chunk-size="512000" fill-size="120000"/>
      </profile>
 ...
```

This will mark all found `*.sh` files in your mediatomb media folders as videos with `video/shell` mime type and defines a transcoder that runs them via `bash` shell.


After saving the changes to config.xml, restart MediaTomb using: `sudo service mediatomb restart`.

Now that MediaTomb is configured, we need to define a folder where we put potential `*.sh` files. Under my usual media folder, where I keep my videos, I defined a sub-folder called `commands` and added a `shutdown.sh` text file with the following content:

```
#! /bin/bash

date >> /var/log/mediatomblog.txt
sudo /sbin/shutdown -h now 2>> /var/log/mediatomblog.txt
```

I made `shutdown.sh` executable for all users. I also created an empty file `/var/log/mediatomblog.txt` and made it writable by all users too. When `shutdown.sh` is run, the current date it written in `/var/log/mediatomblog.txt`. Like this I know when a shutdown via DLNA was made.

Make sure the `commands` folder, where the `shutdown.sh` resides, is added to the MediaTomb media folders (via the MediaTomb web interface). MediaTomb should then list `shutdown.sh` as a video file (in TV too).

The final puzzle piece is to give MediaTomb rights to do a shutdown. MediaTomb daemon runs transcoders under a special user with limited right called (guess what): `mediatomb`. We need to allow this used to use `sudo` for `/sbin/shutdown` without having to type a password. To do this run `sudo visudo` and add a line that looks as follows there:

```
mediatomb ALL=(ALL) NOPASSWD: /sbin/shutdown
```

After this save and close the file (`Esc:wq` in `vim`).

Now, you are ready to test either using `vlc` (VideoLanClient), or your TV. Browse your DLNA media files on TV and then find and run (open) `shutdown.sh`. After a few seconds, my TV claims the video file is invalid and that the device is disconnected, and my Lubuntu machine is then really shutdown.

The above method shuts down the computer immediately. Alternatively, you may want to get a notification and a chance to cancel the shutdown. One way to do this is to install first: `sudo apt-get install libnotify-bin` and then modify the `shutdown.sh` as shown:

```
#! /bin/bash

date >> /var/log/mediatomblog.txt
sudo /sbin/shutdown -h +5 2>> /var/log/mediatomblog.txt &
DISPLAY=:0.0 XAUTHORITY=/home/user/.Xauthority notify-send -i clock -t 300000 "$(date) DLNA inited shutdown in 5 minutes. To cancel run: sudo shutdown -c"
```

Here, I have set shutdown in 5 minutes (note the `&` in the end of the command, it has to be there). I show then a notification to the user I use to log in in my machine. You have to replace the `user` part in `/home/user/.Xauthority` with your own `user` name.

For this to really work, you have to make also the `~/.Xauthority` file in your home folder readable by all users (`chmod o+r ~/.Xauthority`). This is in theory a bit of extra security risk, as any user in local machine can show you then application windows, but in practice, you may find it ok.


With these modifications, when selecting `shutdown.sh` as video in your TV, the current logged user in the Lubuntu machine will get a notification popup that the machine is about to be shutdown. The pop up remains shown for 5 minutes, unless you click to hide it. As the popup message suggests, opening a command line and typing: `sudo shutdown -c` will cancel the shutdown if needed. If not, the system will shutdown in 5 minutes.

You can run any `*.sh` file you add to MediaTomb media folders like this. If you find other interesting use cases, other that shutdown, let me know.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2014/2014-03-16-Using-Different-GTK-Theme-for-Root-Applications.md'>Using Different GTK Theme for Root Applications</a> <a rel='next' id='fnext' href='#blog/2014/2014-02-25-Project-Management-Notes.md'>Project Management Notes</a></ins>
