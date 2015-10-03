2014

#Linux TcPlay UI

<!--- tags: linux encryption -->

Zenity based user interface for [TcPlay](https://github.com/bwalex/tc-play). For Lubuntu, should work in other distros too.

Handles mounting existing containers at `$HOME/truecrypt/loop*`. There is no support to create new containers.

Start this script as your current user (and not as root).

1. You will be asked for your sudo password (required for `mount`).
1. Select the container file (if not specified in command line as first parameter).
1. You will be asked if you are using keyfiles and offer to select them (one by one). Select 'No' if you are using only a password. Press [Cancel] in file selection dialog when done selecting files.
    1. You can select either outer volume, or hidden volume keyfiles.
    2. If selected outer volume keyfiles, you can then select hidden volume keyfiles to protect the hidden volume. If you selected hidden volume keyfiles at first, just select [No] when asked about hidden keyfiles.
1. Enter the container password.
1. The container will be mounted in `$HOME/truecrypt/loop*` (using first free loop device).
1. The mounted folder will open in `pcmanfm`.
1. A dialog will remain open as long as you plan to use the mounted container. Closing that dialog, will unmount the container.

The mounted volumes are accessible with the *current logged user* rights.