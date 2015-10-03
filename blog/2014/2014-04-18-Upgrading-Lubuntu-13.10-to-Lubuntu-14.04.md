#Upgrading Lubuntu 13.10 to Lubuntu 14.04

2014-04-18

<!--- tags: linux -->

I was offered today to upgrade my Lubuntu 13.10 to 14.04 via the Ubuntu Software Updater tool and I did upgrade.

Ubuntu upgrade process has not changed:

* I was notified to have to kill or restart `xscreensaver` because of incompatibilities. I had to do same last year during the 13.10 upgrade. I am not sure why it was needed again this time.
* I was asked to keep or replace my changed file for `/etc/init/mediatomb.conf`, and `/etc/systemd/logind.conf`. As usual the Ubuntu upgrade tool shows the output of the `diff` command. It would be nice they offer a merge tool there.
* I had changed some files in other locations (`/usr`) they were overwritten without warning, which is same as before. I have list of such changes, so I can replay them.
* I had to re-enable the disabled custom ppa-s that still work manually after the upgrade.
* I removed the Lubuntu default apps I do not use: `abiword`, `gnumeric`, `xpad`, `mtpaint` and `sylpheed`.

I encountered till now the following visible problems after the update:

* Keyboard input method has been changed to ibus by default. This has two drawbacks, it shows the ibus icon in the panel, and the real one, the keyboard input did not work for me in Chromium browser, or when it worked it was too slow. I had to go to [Preferences / Language Support] menu and change the 'Keyboard input method system:' from 'ibus' to 'none'. The Language Support will complain when you open it that the language support is not installed completely. You do not need to do that, just click on 'Remind Me Later' there.
* pcmanfm manages now each desktop wallpaper separately. The 'Use same wallpaper on every desktop' option does not work for me. I have now to specify the wallpaper twice when I need to change it, once for each monitor I use, a real nuisance. `--set-wallpaper` command-line option only changes the first desktop wallpaper too.
* Right click menu in the second monitor pcmanfm desktop is also somehow broken. It sometimes shows itself truncated and when it shows it is shown only on the edge, not where you right-click.
* Lightdm login screen is not showing the wallpaper in full resolution in my second monitor. It used to work before.
* Pcmanfm cannot rename anymore `*.desktop` files.
* Pcmanfm does not read anymore `~/.gtk-bookmarks`, now it uses `~/.config/gtk-3.0/bookmarks`. They are in same format - you can copy them over.
* Network Manager Applet is no more starting [Bug 1308348](https://bugs.launchpad.net/ubuntu/+source/lxpanel/+bug/1308348), thought it is listed in `~/.config/lxsession/Lubuntu/desktop.conf` as `network_gui/command=nm-applet`. In theory, one can go in [Preferences / Default Appication for LXSession] menu and the in Core applications and set Network GUI to `nm-applet`. It is not preserved on reboot, so it did not work for me. I had to add it manually to: `~/.config/lxsession/Lubuntu/autostart` as `@/usr/bin/nm-applet`. Network Manager Applet is no more asking for a password to change the settings - this seems to be the intended behavior.
* Unrelated to Lubuntu: `chromium-browser -start-maximized` option does not work anymore for me for the latest installed `chromium-browser` version: 34.0.1847.116 Ubuntu 14.04 aura (260972). I have an openbox shortcut to toggle maximize, but I added one now especially for Chromium in `~/.config/openbox/lubuntu-rc.xml`:
```
<application name="Chromium-browser">
    <maximized>true</maximized>
</application>
```
To get Adobe Flash work with latest Chromium, I had to: `sudo apt-get install pepperflashplugin-nonfree`. The new plugin shows full screen flash windows (such as those of YouTube) with a visible window frame named "Unnamed Window" for me. To fix that I added also to `~/.config/openbox/lubuntu-rc.xml` in section the following:
```
<application title="Unnamed Window">
	<maximized>true</maximized>
	<fullscreen>yes</fullscreen>
</application>
```

I have to get used now to these new quirks. The main UI changes and improvement in this release, apart of things that broke, are in PcManFm:

* Custom action can be added as context-menus. I have written about it before in this blog.
* Dual-pane view - I found it buggy as it does not remember the viewport when you switch between the panes, making it pretty useless as it is for drag & drop - which would had been its main use case.
* One can configure to show the tray icon in desktop (in desktop preferences dialog). The only difference it makes from doing a shortcut on your own it shows when it is full or not. But still there is no context-menu to empty the trash directly. You have to open PcManFm to do that So it is not as useful as it may seem.
* Trash behavior for files in removable media can be configured which is nice. I hate when the trash folder showed there before.
* Hidden file icons can be shown shadowed. This I found very nice. I need no more to show / hide hidden files. I can leave them now always on and have them use gray icons by default.
* There is now a regex *View / Filter* menu, but if you remove the \* by mistake and leave it empty you see no files anymore - you have to remember about the star. I would have preferred from the usability point of view that empty (trimmed) is same as \* for that. Same for the search, which was there before, I would have preferred when I type `string` to mean `*string*` by default.
* Icon zoom can now be controller via menu or via Ctrl and mouse wheel - very nice.
Context menu has been fixed for gvfs mounted file systems (sftp, ftp, etc). It was broken since Lubuntu 13.04. Now copy, delete, etc, are back there in the context menu. And there is now a helper dialog to connect to a server.
* Context-menu on several places, including the side pane, have been extended. There are also per folder settings, but this I personally really do not like, and have to be careful to never click that.
* `lxshortcut` is now integrated in desktop file properties, but rename of desktop files in no more possible. Seems like a bug.
* In side pane, the home folder is now named always Home Folder and not with the actual user name. This I do not like much as I do not know sometimes what user it is, but I can easy remedy that by bookmarking the home folder for each user with its actual name if I need it, so that it is easy visible.

As it is usual with Lubuntu, it really gets tested the first week after the release :). There are too few people to test it fully in every combination before. So from this point of view, this release is a success, and despite the few problems which are there in some form every time, this is or will be a good long term support release. I personally helped fixed a small bug in a Ubuntu app for this release, wrote some of the first pcmanfm custom actions, and read (thought was not so very active) the scarce Lubuntu mail list.

**Update**: None of applications in `/etc/xdg/autostart` folder can start at login in Lubuntu 14.04. I looked thought all shortcuts there that are for LXDE or for any desktop environment and made up this list to be added to `~/.config/lxsession/Lubuntu/autostart` file in case you do not have these any of these already there:
```
@xfce4-power-manager
@update-notifier
@start-pulseaudio-x11
@system-config-printer-applet
@light-locker
```

For the last one I am using: `@light-locker --lock-after-screensaver=1 --no-lock-on-suspend --no-late-locking`.

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-04-26-Restoring-Chromium-Configuration-Folder.md'>Restoring Chromium Configuration Folder</a> <a id='fnext' href='#blog/2014/2014-04-10-Minimal-Graphical-Ubuntu-Install-in-Docker.md'>Minimal Graphical Ubuntu Install in Docker</a></ins>
