#Disable History in Lubuntu

2012-08-21

<!--- tags: linux -->

My home directory ~ in Lubuntu is not encrypted, but I wanted still to use TrueTrypt volumes relatively safely there, so I undertook several changes. To see files changed in home folder in the last 5 minutes use (you can replace `~/` with any other folder path):

```
find ~/ -mmin -5 -type f -printf "%TT %p %l\n"
```

It can be useful to know where the applications write their data. As a shortcut, you can add the above command at .bashrc as alias:
```
alias findlast='watch -n 10 --differences find ~/ -mmin -5 -type f -printf "%TT %p %l\n"'
```

1. Disable recently use files list (has to be done for both current user and `root`):
	```
	rm -f ~/.local/share/recently-used.xbel 
	touch ~/.local/share/recently-used.xbel
	sudo chattr +i ~/.local/share/recently-used.xbel
	```

	If using GThumb, apply same to `$HOME/.config/gthumb/history.xbel` (same for the `root` user).

1. Disable thumbnail caching. One way to achieve that is as follows (but movie thumbnails, etc, will not work). Several applications, including pcmanfm, cache thumbnails on ~/.thumbnails folder. To disable this feature permanently, I used:
	```
	rm -r ~/.thumbnails 
	ln -s /dev/null ~/.thumbnails
	rm -r ~/.cache/thumbnails
	ln -s /dev/null ~/.cache/thumbnails
	```
	Same can be done for shotwell:
	```
	rm -r ~/.cache/shotwell/thumbs
	ln -s /dev/null ~/.cache/shotwell/thumbs	
	```
	For a better way see below, to use tmpfs.

1. None of the above worked with Chromium browser cache, and while I start Chromium in incognito mode, I still saw no reason to leave its cache active. I modified `/usr/bin/chromium-browser` file (as root) and replace this line near the end of the file:
	```
	exec $LIBDIR/$APPNAME $CHROMIUM_FLAGS "$@"
	```
	with
	```
	exec $LIBDIR/$APPNAME --incognito --disk-cache-dir=/dev/null --disk-cache-size=1 $CHROMIUM_FLAGS "$@"
	```
	If Chromium is updated this action needs to be redone (I left the file writable). 

	A better [alternative](http://daniel.hahler.de/disable-disk-cache-in-chromium-google-chrome) is to set the flags at `/etc/chromium-browser/default`:
	```
	# Options to pass to chromium-browser
	CHROMIUM_FLAGS="--disk-cache-dir=/dev/null --disk-cache-size=1 --incognito -start-maximized"
	```
	
	My final settings for chromium using [private](https://help.ubuntu.com/community/EncryptedPrivateDirectory) folder for settings:

	```
	CHROMIUM_FLAGS="--disk-cache-dir=/dev/null --disk-cache-size=1 --incognito --force-device-scale-factor=1.4 -start-maximized --no-first-run --user-data-dir=/home/$USER/Private/chromium"
	```

	I also deleted all search engines in Chromium and put as default `http://%s`. This disables search in the address bar.
1. A nice trick for TrueCrypt in Lubuntu is to add a fake `nautilus` link so the pcmanfm opens on volume mount by creating a file `sudo leafpad /usr/bin/nautilus` with these data:
	```
	#!/bin/bash
	exec pcmanfm $3
	exit 0
	```
	and make it executable:
	```
	sudo chmod +x /usr/bin/nautilus
	```
1. Encrypting swap space (if you use that) can be done as follows:

	```
	sudo apt-get install ecryptfs-utils
	sudo ecryptfs-setup-swap
	```
	Details how to undo this can be found [here](http://www.logilab.org/blogentry/29155).	

	Better is not to use a swap file (or partition at all). I have checked that usually I do not use swap space. It can be turner off using `sudo swapoff -a`, and then on `using sudo swapon -a`.

1. I do not have `Zeitgeist` installed, but it continues to come up and now back with Ubuntu updates, so to be sure, I have an empty `Zeitgeist` db file with no write permissions:
	```
	chmod -rw ~/.local/share/zeitgeist/activity.sqlite
	```
1. If you have enough RAM, and do not need large temporary space (for DVD rips, etc), you can [mount](http://ubuntuforums.org/showthread.php?t=1054129) `/tmp` folder in RAM, by adding to `/etc/fstab` (a restart is needed after you do this):

	```
	none /tmp tmpfs defaults,nodev,nosuid,noexec 0 0
	none /var/tmp tmpfs defaults,nodev,nosuid,noexec 0 0
	```
	
	Some software may need to run files from `/tmp` folder during install. If you get errors, then temporary give `exec` rights to `/tmp` folder:
	
	```
	sudo mount -o remount,exec tmpfs /tmp
	#... install problematic package here
	sudo mount -o remount,defaults,nodev,nosuid,noexec tmpfs /tmp
	```

	Or alternatively, temporary specify: `export TMPDIR=~/tmp`.

	In same way you can put your user cache folder and that of root to RAM, by adding to fstab, make sure these folder exists first:
	```
	none /home/user/.cache tmpfs defaults,nodev,nosuid,noexec 0 0
	none /home/user/.thumbnails tmpfs defaults,nodev,nosuid,noexec 0 0
	none /root/.cache tmpfs defaults,nodev,nosuid,noexec 0 0
	none /root/.thumbnails tmpfs defaults,nodev,nosuid,noexec 0 0
	```
	To [access](http://unix.stackexchange.com/questions/4426/access-to-original-contents-of-mount-point) original content of a mounted folder (in case you need to clean up original `/tmp` later):
	```
	mkdir /mnt/root
	mount --bind / /mnt/root
	```
	The original `/tmp` content is now in `/mnt/root/tmp`. You can verify the `tmpfs` mounts using either `mount` or `df -T /tmp` commands.
1. I configured `locate` command not to search in my `/home/user` folder, by editing `/etc/updatedb.conf`, and appending my home folder to `PRUNEPATHS` there (space separated) (can be verified with `updatedb -v`). (To disable locate completely, use `sudo chmod -x /etc/cron.daily/mlocate` and `sudo rm /var/lib/mlocate/mlocate.db`).
1. Setting up a protected encrypted folder in [Ubuntu](https://help.ubuntu.com/community/EncryptedPrivateDirectory) is done via:
	```
	sudo apt-get install ecryptfs-utils
	ecryptfs-setup-private
	```
	We can copy then inside the `~/Private` folder the `chromium-browser` profile folder (location can be found via `chrome://version` and use the following command-line argument `--user-data-dir=/home/user/Private/chromium` to specify it when starting `chromium-browser`. Similarly, both `firefox` and `thunderbird` can be started with `-profilemanager` option, to create a new profile that points to a copy of their profiles put in the `~/Private` folder.
1. To [clean](https://superuser.com/questions/19326/how-to-wipe-free-disk-space-in-linux) unused free disk space, make sure first that there is no reserved space:
	```
	sudo tune2fs -m 0 /dev/sda1
	sudo tune2fs -l /dev/sda1 | grep 'Reserved block count'
	```

	Then run in a new folder once per disk partition (`102400` is not magic here, any approximate size will do):
	```
	dd if=/dev/zero of=zero.000 bs=1024 count=102400
	while :; do cat /dev/zero > zero.$RANDOM; done
	```  

	Wait until it complains that there is no disk space, press Ctrl+C to stop it, and run:
	```
	sync ; sleep 60 ; sync
	```

	Check using `df` command that *Avail*able disk space is 4 or smaller. If not, run the two commands above (while ... and sync ...) again. Repeat until `df` command reports that *Avail*able disk space is 4 or smaller.

	Finally, clean the created `rm zero.*` files. 

	All these disk cleanup commands are boring to manually type all the time, so I set up a small script:

	```
	#!/bin/bash

	#call once before manually per partition
	#sudo tune2fs -m 0 /dev/sda1
	#sudo tune2fs -l /dev/sda1 | grep 'Reserved block count'

	start=$(date +%s)
	dir=$1
	if [ -z "$dir" ]; then
		dir="$HOME/tmp"
	fi

	dir="${dir}/zero"
	mkdir -p "${dir}" || exit 1

	function cleanUp {
		if [ -d "$dir" ]; then
			echo -e "\nRemoving ${dir}"
			rm -rf "${dir}"
		fi
		end=$(date +%s)
		runtime=$((end-start))
		echo "Done: ${runtime} seconds"
		exit
	}

	trap cleanUp SIGHUP SIGINT SIGTERM

	partition=$(df -P "$dir" | tail -1 | tr -s ' ' | cut -d ' ' -f 1)
	echo -e "Creating ${dir}\nOverwriting free partition space in ${partition} (may take some time):"
	available=$(df -P "$dir" | tail -1 | tr -s ' ' | cut -d ' ' -f 4)
	echo -n "($available)"

	while : ; do
		cat /dev/zero > "${dir}/zero.$RANDOM" 2>/dev/null
		if [ $? -ne 0 ] ; then
			sync
			available=$(df -P "$dir" | tail -1 | tr -s ' ' | cut -d ' ' -f 4)
			echo -n "($available)"
			if [[ $available -lt 5 ]] ; then
				break;
			fi
		fi
	done
	sleep 10 ; sync
	cleanUp
	```

	To test the script work use something like the following command, before and after the disk clean up:

	```
	sudo foremost -t jpg -i /dev/sda1 -o /media/udata/test
	```
	

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2012/2012-08-25-Fully-Remove-Installed-Packages-in-Lubuntu.md'>Fully Remove Installed Packages in Lubuntu</a> <a rel='next' id='fnext' href='#blog/2012/2012-08-01-Change-Wallpaper-at-Startup-in-Lubuntu.md'>Change Wallpaper at Startup in Lubuntu</a></ins>
