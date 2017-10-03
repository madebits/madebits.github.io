#Using Ubuntu Snap

2020-05-03

<!--- tags: linux -->

<a href="https://en.wikipedia.org/wiki/Snap_(package_manager)">Snap</a> is not easy avoidable anymore in Ubuntu desktop, so I spend some time to keep a few notes from documentation (and `man snap`) I had to scan to understand it.

<div id='toc'></div>

## Snap Files

Snap uses `snap` package [files](https://snapcraft.io/docs/snap-format), which are [SquashFS](https://en.wikipedia.org/wiki/SquashFS) package files, using a low-overhead read-only compressed file [system](https://tldp.org/HOWTO/SquashFS-HOWTO/index.html). Snap application files (obtained via `snap install gimp`) are stored in `/var/lib/snapd/snaps/`, which seems [cannot](https://askubuntu.com/questions/1029562/move-snap-packages-to-another-location-directory) be easy changed. They are managed by `snapd` service (`systemctl status snapd.service`) that connects their snap defined interfaces and enforces [security](https://snapcraft.io/docs/snap-confinement), given snaps can be [published](https://snapcraft.io/docs/permission-requests) by everyone.

## Snap Mounts

Based on snap [documentation](https://snapcraft.io/docs/system-snap-directory) the system top level `/snap` folder is where `*.snap` application files are mounted read-only, with `/span/<app>/current` being a link to current revision:

```bash
$ mount | column -t | grep snap | grep gimp
/var/lib/snapd/snaps/gimp_262.snap                  on  /snap/gimp/262                   type  squashfs         (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/gimp_265.snap                  on  /snap/gimp/265                   type  squashfs         (ro,nodev,relatime,x-gdu.hide)

$ ls -l /snap/gimp/
total 0
drwxr-xr-x 12 root root 168 Apr  6 19:28 262
drwxr-xr-x 12 root root 168 Apr 28 15:16 265
lrwxrwxrwx  1 root root   3 Mai  1 13:08 current -> 265

$ ls -lh /var/lib/snapd/snaps/gimp_262.snap
-rw------- 1 root root 176M Apr 13 12:19 /var/lib/snapd/snaps/gimp_262.snap
```

Mounted snaps consume `loop` devices:

```bash
$ df -h | grep gimp
/dev/loop17                  176M  176M     0 100% /snap/gimp/262
/dev/loop20                  176M  176M     0 100% /snap/gimp/265
```

I am not sure why they need to mount all revisions, I guess just to make `mount` and `df` commands unusable (`df -h -x squashfs`), but they have patched `gnome-disks` not to show snap loop devices. 

The binary files declared within snap meta files are linked to `/snap/bin` (it seem to be added to `$PATH` in Ubuntu):

```bash
$ ls -l /snap/bin | grep gimp
lrwxrwxrwx 1 root root 13 Mai  1 13:08 gimp -> /usr/bin/snap
```

To view commands of a snap use:

```bash
$ snap info gimp
```

All commands link to `/usr/bin/snap` which uses a common trick to figure out what command is, based on link invocation information. The `./snap` folder contains details how the snap package was built:

```bash
$ ls -l /snap/gimp/current/snap
total 221
drwxr-xr-x 2 root root     61 Apr 28 15:16 command-chain
drwxr-xr-x 2 root root     50 Apr 28 15:16 hooks
-rw-r--r-- 1 root root 206882 Apr 28 15:16 manifest.yaml
-rwxr-xr-x 1 root root  18564 Apr 28 14:30 snapcraft.yaml
```

## Snap Configuration

To get configuration options of a snap use (*set/unset* option can be used to set/clear them):

```bash
$ sudo snap get -d gimp
$ sudo snap get -d core # system
```

## Removing Old Revisions

To remove an old [revision](https://snapcraft.io/docs/keeping-snaps-up-to-date#heading--controlling-updates), one can use:

```bash
$ snap list --all | grep gimp
gimp                  2.10.18                        262   latest/edge      snapcrafters  disabled
gimp                  2.10.18                        265   latest/edge      snapcrafters  -

$ sudo snap remove gimp --revision 262
```

One can make a bash [script](https://www.linuxuprising.com/2019/04/how-to-remove-old-snap-versions-to-free.html) to automate this given the lost people who created snap forgot to make that an option:

```bash
#!/bin/bash
# Removes old revisions of snaps
# CLOSE ALL SNAPS BEFORE RUNNING THIS
set -eu

LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done
```

## Connections: Interfaces = Plugs and Slots

A plug in snap can [connect](https://snapcraft.io/docs/interface-managements) to a slot in another [snap](https://snapcraft.io/docs/snapcraft-interfaces).

```bash
$ sudo snap connections | grep gimp
Interface                 Plug                                       Slot                              Note
content[gnome-3-28-1804]  gimp:gnome-3-28-1804                       gnome-3-28-1804:gnome-3-28-1804   -
content[gtk-2-engines]    gimp:gtk-2-engines                         gtk2-common-themes:gtk-2-engines  -
content[gtk-3-themes]     gimp:gtk-3-themes                          gtk-common-themes:gtk-3-themes    -
content[icon-themes]      gimp:icon-themes                           gtk-common-themes:icon-themes     -
content[sound-themes]     gimp:sound-themes                          gtk-common-themes:sound-themes    -
desktop                   gimp:desktop                               :desktop                          -
desktop-legacy            gimp:desktop-legacy                        :desktop-legacy                   -
gsettings                 gimp:gsettings                             :gsettings                        -
home                      gimp:home                                  :home                             -
network                   gimp:network                               :network                          -
opengl                    gimp:opengl                                :opengl                           -
unity7                    gimp:unity7                                :unity7                           -
wayland                   gimp:wayland                               :wayland                          -
x11                       gimp:x11                                   :x11                              -

```

Examples of core snap [interfaces](https://snapcraft.io/docs/supported-interfaces):

* [:home](https://snapcraft.io/docs/home-interface) *core* snap interface gives the application access to non-hidden files in real `$HOME` directory. 
* [:personal-files](https://snapcraft.io/docs/personal-files-interface) allows access to hidden $HOME folders and files.
* [:network](https://snapcraft.io/docs/network-interface) gives access to network. It can be removed using `sudo snap disconnect gimp:network :network` and can be added back using `sudo snap connect gimp:network :network`. These changes are preserved by `snap refresh`.

## Snap Home

The parts of `$HOME` that a snap application needs are mapped under `$HOME/snap` folder:

```
$ ls -l ~/snap/gimp
total 8
drwxr-xr-x 4 d7 d7 4096 Mai  3 20:04 265
drwxr-xr-x 3 d7 d7 4096 Mai  3 20:04 common
lrwxrwxrwx 1 d7 d7    3 Mai  3 20:04 current -> 265

```

The folders seen in this location are visible as environment [variables](https://snapcraft.io/docs/environment-variables) within the snap application:

* `SNAP_USER_DATA=~/snap/gimp/current` *This directory is backed up and restored across `snap refresh` and `snap revert` operations.* This is the folder snap application sees as `$HOME`. Several files here link to real user `$HOME` folder files.
* `SNAP_USER_COMMON=~/snap/gimp/common` *Directory for user data that is common across revisions of a snap.*

System versions of these also exit for root snap packaged services (`sudo snap services`):

* `SNAP_DATA=/var/snap/gimp/current`
* `SNAP_COMMON=/var/snap/gimp/common`

To make a [snapshot](https://snapcraft.io/docs/snapshots) of all data use `snap save` (saved in `/var/lib/snapd/snapshots` folder). To view saved data snapshots, use `snap saved`. It list snapshot `id` is in the first *Set* column. To remove a snapshot use `snap forget id`.

### Application Configuration

The `HOME/snap/*/current/.config` path will link to latest `$HOME/.config` folder as seen by application, but only if application is run once, otherwise link is invalid (e.g. if snap updates the application in between runs).

### Application Cache

My `$HOME/.cache` is mounted in `tmpfs` (despite my encrypted disk partition) as I do not want applications to share cache data between runs. `snap` is a regression in this regard. Deleting application cache folders manually is possible, but inconvenient:

```bash
ls -d snap/*/common/.cache | xargs rm -rf
```

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2019/2019-11-13-ETL-Solutions.md'>ETL Solutions</a></ins>
