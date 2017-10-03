
#gksu Is Dead Long Live pkexec

<!--- tags: linux -->

Well, [no](https://forums.linuxmint.com/viewtopic.php?t=268140) more `gksu` in latest Ubuntu 18.04, people recommend using `pkexec` instead.

With `gksu` I could add code similar to the following to re-run a script that contained `zenity` UI started from a non-root user as root: 

```bash
if [[ $(id -u) != "0" ]]; then
    gksu "$0" $@
    exit 0
fi
# root here
echo $@
```

Ideally, using `pkexec` as replacement would be same as easy:

```bash
if [[ $(id -u) != "0" ]]; then
    pkexec "$0" $@
    exit 0
fi
# root here
echo $@
```

##First Problem

If you run the above from a `test.sh` script you get:

```
Error executing ./t.sh: No such file or directory
```

It seems `pkexec` works reliably only with absolute paths. One [way](https://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself) to achieve that:

```
if [[ $(id -u) != "0" ]]; then
    absScriptPath="$( cd "$(dirname "$0")" ; pwd -P )/$(basename "$0")"
    pkexec "$absScriptPath" $@
    exit 0
fi
# root here
echo $@
```

##Second Problem

If you try to run a command that need access to user interface from `pkexec`, such as, `zenity` command in the script below:

```
if [[ $(id -u) != "0" ]]; then
    absScriptPath="$( cd "$(dirname "$0")" ; pwd -P )/$(basename "$0")"
    pkexec "$absScriptPath" $@
    exit 0
fi
# root here
echo $@
msg="$@"
zenity --info --text="$msg"
```

You get this error:

```
Unable to init server: Could not connect: Connection refused

(zenity:31120): Gtk-WARNING **: 20:14:17.933: cannot open display:
```

The `man pkexec` is very clear: "*pkexec will not allow you to run X11 applications as another user since the $DISPLAY and $XAUTHORITY environment variables are not set*". You have to [edit](https://unix.stackexchange.com/questions/203136/how-do-i-run-gui-applications-as-root-by-using-pkexec) the *polkit* files, and that per each application! Definitively, not the way to go. Can we do better:

```
if [[ $(id -u) != "0" ]]; then
    absScriptPath="$( cd "$(dirname "$0")" ; pwd -P )/$(basename "$0")"
    pkexec "$absScriptPath" "$DISPLAY" "$XAUTHORITY" "$@"
    exit 0
fi
# root here
export DISPLAY="$1"
shift
export XAUTHORITY="$1"
shift
echo $@
msg="$@"
zenity --info --text="$msg"
```

And now, finally, it *just* works.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2018/2018-04-25-OpenVPN-In-Azure.md'>OpenVPN In Azure</a> <a rel='next' id='fnext' href='#blog/2018/2018-01-27-Dirac-Notation-Cheatsheet.md'>Dirac Notation Cheatsheet</a></ins>
