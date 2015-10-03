#Mount EncFs Folder at Login in Lubuntu

2014-05-19

<!--- tags: linux encryption -->

I found some [code](http://obensonne.bitbucket.org/blog/20100130-encfs-keyring.html) to mount an *encfs* folder at login without using *pam* on Lubuntu. This has the benefit the encfs password can be different from the login password. If also saves the effort to get pam_enfs properly working. [gnome-enfs](https://bitbucket.org/obensonne/gnome-encfs) script should also work in Lubuntu, but I have not tested it.

To get started, install enfs:
```
sudo apt-get install encfs
```
In Lubuntu, you may need to install also:
```
sudo apt-get install libpam-gnome-keyring
```

Create an encrypted folder within $HOME folder:

```
ENCFS6_CONFIG="$HOME/.encfs6.xml" encfs ~/.EncFsPrivate ~/EncFsPrivate
```

I am using an encfs config file outside `~/.EncFsPrivate` folder. Enter any password you like when asked. Every plain file you create or put in `~/EncFsPrivate` will be encrypted in `~/.EncFsPrivate`.

To unmount `~/EncFsPrivate` use:
```
fusermount -u ~/EncFsPrivate
```
To mount it again manually use same encfs as before and enter the password.

To automate the process at login download [gkeyring.py](https://github.com/kparal/gkeyring) and create a login keyring entry that will contain the password using:
```
python gkeyring.py --set -n "EncFsPrivate" -p encfs=private --keyring login
```

Where `encfs=private` can be a unique key=subkey value.

In Lubuntu if login keyring does not exist (yet) and you get an error above, create it manually. The easiest to do that is by installing seahorse UI via:

```
sudo apt-get install seahorse
```

Use the login password for the newly created login keyring. After a system restart, `libpam-gnome-keyring` should take care to unlock gnome login keyring at login.

Slightly modified version of the [code](http://obensonne.bitbucket.org/blog/20100130-encfs-keyring.html), I found:
```
#!/usr/bin/python

import os.path
import subprocess
import sys
import gtk
import gnomekeyring as gk

if len(sys.argv) < 4:
    print("Usage: " + sys.argv[0] + "keyringPassId encfsPrivateDir encfsPublicDir [encfs6.xml]")
    sys.exit(1)

ENCFS_XML=''
PASS_ID = sys.argv[1].split('=');
PATH_ENCRYPTED = os.path.expanduser(sys.argv[2])
PATH_DECRYPTED = os.path.expanduser(sys.argv[3])

if len(sys.argv) > 4:
    ENCFS_XML=os.path.expanduser(sys.argv[4])

if len(PASS_ID ) != 2:
    print("keyringPassId must be of form key=subkey")
    sys.exit(1)

# get the encfs-dropbox item:
try:
    items = gk.find_items_sync(gk.ITEM_GENERIC_SECRET, {PASS_ID[0]: PASS_ID[1]})
    item = items[0] # clean up your keyring if this list has multiple items
except gk.NoMatchError:
    print("no entry in keyring")
    sys.exit(1)

# run encfs:
cmd = ["/usr/bin/encfs", "-S", PATH_ENCRYPTED, PATH_DECRYPTED]
env = os.environ.copy()
if len(ENCFS_XML) > 0:
	env['ENCFS6_CONFIG'] = ENCFS_XML
p = subprocess.Popen(cmd, stdin=subprocess.PIPE, env=env)
err = p.communicate(input="%s\n" % item.secret)[1]

# either there is an error or we are done:
if err:
    print(err)
    sys.exit(1)
```

Save it for example as `~/bin/emount.py` and make it executable. Now, to mount the encfs folder automatically at login in Lubuntu add to `~/.config/lxsession/Lubuntu/autostart` file a line (replace user with your user name):

```
@/home/user/bin/emount.py encfs=private ~/.EncFsPrivate ~/EncFsPrivate ~/.encfs6.xml
```

Where `encfs=private` is the same unique key=subsey used above and then the two folders same as used with encfs. The last parameter is the custom `~/.encfs6.xml` path.

You can use this method to create more than one such folder under your `$HOME` directory, for Dropbox, or for example to store the Firefox profile (using: `firefox -profilemanager` to create a new profile within `~/EncFsPrivate` folder), or the Chromium one (using for example: `chromium-browser --user-data-dir=/home/user/EncFsPrivate/Chromium`), and so on.

To also unmount the encfs folder automatically at logout, edit `/etc/lightdm/lightdm.conf` and under `[SeatDefaults]` add the path to a script using `session-cleanup-script=/path/to/script`. The executable script can look as this sample I found:

```
mount -t fuse.encfs | grep "user=$USER" | awk '{print $3}' | while read MPOINT ; do
    sudo -u $USER fusermount -u "$MPOINT"
done
```

**Update1**: I tested [gnome-enfs](https://bitbucket.org/obensonne/gnome-encfs) and works fine on Lubuntu. gnome-enfs writes a desktop shortcut in `~/.config/autostart`, but by default Lubuntu 14.04 ignores those, so you may need to add the gnome-encfs autostart command to `~/.config/lxsession/Lubuntu/autostart` manually.

I did a small change to [gnome-encfs](blog/images/gnome-encfs) (<= my copy) to add a new -u (--umount) option that unmounts all mounted gnome-encfs paths at once.

**Update2**: For a UI tool that automates most of these, use [Gnome Encfs Manager](http://www.libertyzero.com/GEncfsM/). It works ok in Lubuntu, apart of un-mount at logout that has to be done manually as shown above.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2014/2014-05-22-Changing-Lubuntu-Logout-Window-Message.md'>Changing Lubuntu Logout Window Message</a> <a rel='next' id='fnext' href='#blog/2014/2014-05-15-Disable-Send-Error-Reports-to-Canonical-in-Lubuntu.md'>Disable Send Error Reports to Canonical in Lubuntu</a></ins>
