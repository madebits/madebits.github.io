#Changing Lubuntu Logout Window Message

2014-05-22

<!--- tags: linux -->

Lubuntu logout window is a bit too big. I already use a smaller custom banner image for `/usr/share/lubuntu/images/logout-banner.png`, but the text shown on the top is also too long. I think they have hardcoded 'Logout Lubuntu 14.04 session?' as default text there. The text to show can be passed to `lxsession-logout` via the `-p` parameter.

`lxsession-logout` is invoked via `lxsession` (using org.lxde.SessionManager.SessionLaunch dbus service). The only way to hook to that call I could found, is to rename `/usr/bin/lxsession-logout` to `/usr/bin/lxsession-logout-original` and then add an executable bash script with name `/usr/bin/lxsession-logout` with this content:
```
#!/bin/bash

/usr/bin/lxsession-logout-original -p "$USER" "$@"
```

Here, I replaced the original Lubuntu message with current user name. I pass the other parameters as they are (`--banner /usr/share/lubuntu/images/logout-banner.png --side=top`). If you wish you can overwrite all of them:

```
#!/bin/bash

/usr/bin/lxsession-logout-original -p "$USER" --banner /usr/share/lubuntu/images/vlogout.png --side=left
```

![](blog/images/logout.png)

This is now my final setup.

**Update:** In case you want to fully customize the logout screen, backup  `/usr/bin/lxsession-logout` and replace it (as root) with an executable script with this content:

```
#!/bin/sh

sel=$(zenity --height 230 --list --title="$USER - Shutdown" --column "Action" Shutdown Reboot Logout Lock)

case "$sel" in
    Lock)
        i3lock -c 111111 #xscreensaver -lock
        ;;
    Logout)
        kill -15 $_LXSESSION_PID
        ;;
    Reboot)
        dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart
        ;;
    Shutdown)
        dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop
        ;;
    *)
        exit 1
esac

exit 0
```

![](blog/images/logout2.png)

I am using here `sudo apt-get install i3lock` to lock the screen as I like `i3lock`, but you can use `xscreensaver` or something else. This is smaller, but you cannot add an image :).

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-05-27-Using-Dropbox-to-keep-EncFS-Configuration-File-Safe.md'>Using Dropbox to keep EncFS Configuration File Safe</a> <a id='fnext' href='#blog/2014/2014-05-19-Mount-EncFs-Folder-at-Login-in-Lubuntu.md'>Mount EncFs Folder at Login in Lubuntu</a></ins>
