
#gksu Is Dead, Long Live pkexec

2018-04-24

<!--- tags: linux -->

`gksu` has been [removed](https://jeremy.bicha.net/2018/04/18/gksu-removed-from-ubuntu/) in latest Ubuntu 18.04. The nearest alternative left to use is `pkexec`. Some workarounds are needed to use `pkexec` in scripts, given `pkexec` is not a drop-in replacement for `gksu`.

##Replacing gksu

With `gksu`, one could use code similar to the following, to re-run as *root* a script that contained UI commands started from a *non-root* user: 

```bash
#!/bin/bash

if [[ $(id -u) != "0" ]]; then
    gksu "$0" $@
    exit 0
fi
# root here
echo $@
```

Ideally, using `pkexec` as replacement would be same as easy, but the following code does **not** work:

```bash
if [[ $(id -u) != "0" ]]; then
    pkexec "$0" $@
    exit 0
fi
# root here
echo $@
```

There are two issues to overcome to make this code work.

##First Problem

If you run the above script as `test.sh`, you get:

```
Error executing ./test.sh: No such file or directory
```

It seems, `pkexec` works reliably only with absolute paths. One [way](https://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself) to achieve that:

```bash
if [[ $(id -u) != "0" ]]; then
    absScriptPath="$( cd "$(dirname "$0")" ; pwd -P )/$(basename "$0")"
    pkexec "$absScriptPath" $@
    exit 0
fi
# root here
echo $@
```

##Second Problem

If you run a command that needs access to the user interface from `pkexec` as in this example, it will fail:

```bash
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

The following error is reported:

```
Unable to init server: Could not connect: Connection refused

(zenity:31120): Gtk-WARNING **: 20:14:17.933: cannot open display:
```

The `man pkexec` says: "*pkexec will not allow you to run X11 applications as another user since the $DISPLAY and $XAUTHORITY environment variables are not set*". You have to [edit](https://unix.stackexchange.com/questions/203136/how-do-i-run-gui-applications-as-root-by-using-pkexec) the *polkit* files, and that per each application! We can work around that by passing in the variables we need, in a new iteration of the script:

```bash
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

##A Poor Man's gksu

Finally, we can use the idea above to create a poor man's `gksu.sh` replacement script:

```bash
#!/bin/bash

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
$@
```

This script can be used as follows:

```
./gksu.sh leafpad /etc/fstab
```

More environment variables can be passed as needed in same fashion.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2018/2018-04-25-OpenVPN-In-Azure.md'>OpenVPN In Azure</a> <a rel='next' id='fnext' href='#blog/2018/2018-01-27-Dirac-Notation-Cheatsheet.md'>Dirac Notation Cheatsheet</a></ins>
