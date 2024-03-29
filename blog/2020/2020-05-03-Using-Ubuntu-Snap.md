# Using Ubuntu Snap

2020-05-03

<!--- tags: linux -->

<a href="https://en.wikipedia.org/wiki/Snap_(package_manager)">Snap</a> is not easy avoidable anymore in Ubuntu desktop. An understanding of snap beyond the *bona-fine* basics is required by reading `man snap` and [online](https://snapcraft.io/docs/) documentation.

<div id='toc'></div>

## Snap Files

Snap uses `*.snap` package [files](https://snapcraft.io/docs/snap-format), which are [SquashFS](https://en.wikipedia.org/wiki/SquashFS) package files, a low-overhead, read-only, compressed file [system](https://tldp.org/HOWTO/SquashFS-HOWTO/index.html). SquashFS packages are optimized for small size and low-resource unpacking, not for fast unpack speed.

Snap application files are obtained, for example, via `snap install gimp` -- I am using [gimp](https://snapcraft.io/gimp) as an example snap application. They are stored in `/var/lib/snapd/snaps/`, which seems [cannot](https://askubuntu.com/questions/1029562/move-snap-packages-to-another-location-directory) be easy changed. 

Snap applications are managed by `snapd` service (`systemctl status snapd.service`) that connects their snap defined interfaces and enforces [security](https://snapcraft.io/docs/snap-confinement), given snaps can be [published](https://snapcraft.io/docs/permission-requests) by everyone.

## Snap Mounts

The system top level `/snap` [folder](https://snapcraft.io/docs/system-snap-directory) is where `*.snap` application files are mounted *read-only*, with `/span/gimp/current` being a link to the current revision:

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

Given snaps usually include files to run in many platforms, they are bigger than the corresponding `deb` packages.

Mounted snaps consume `loop` devices:

```bash
$ df -h | grep gimp
/dev/loop17                  176M  176M     0 100% /snap/gimp/262
/dev/loop20                  176M  176M     0 100% /snap/gimp/265

# or
$ df -h /snap/gimp/265
/dev/loop20                  176M  176M     0 100% /snap/gimp/265
```

I am not sure why they need to mount all revisions, I guess just to make `mount` and `df` commands unusable (`df -h -x squashfs`). They have patched, however, `gnome-disks` not to show snap loop devices. 

The binary files declared within snap meta files are created as links in `/snap/bin` (which is added to the end of system `$PATH` in Ubuntu, so snaps take precedence):

```bash
$ ls -l /snap/bin | grep gimp
lrwxrwxrwx 1 root root 13 Mai  1 13:08 gimp -> /usr/bin/snap
```

To view commands of a snap use:

```bash
$ snap info gimp
```

All commands link to `/usr/bin/snap` which uses a common trick to figure out what command is, based on program path invocation information. The `/snap/gimp/current/snap` folder contains details how the snap package was built:

```bash
$ ls -l /snap/gimp/current/snap
total 221
drwxr-xr-x 2 root root     61 Apr 28 15:16 command-chain
drwxr-xr-x 2 root root     50 Apr 28 15:16 hooks
-rw-r--r-- 1 root root 206882 Apr 28 15:16 manifest.yaml
-rwxr-xr-x 1 root root  18564 Apr 28 14:30 snapcraft.yaml
```

The `gimp` process, runs confined under current user:

```bash
$ pstree -pu
...
           ├─gimp(3750,user)─┬─script-fu(3883)───{script-fu}(3884)
           │                 ├─{gimp}(3864)
           │                 ├─{gimp}(3865)
           │                 ├─{gimp}(3866)
           │                 ├─{gimp}(3867)
           │                 ├─{gimp}(3868)
           │                 ├─{gimp}(3869)
           │                 ├─{gimp}(3870)
           │                 ├─{gimp}(3872)
           │                 ├─{gimp}(3873)
           │                 └─{gimp}(3875)

```

Snap creates temporary folders for run snaps, e.g for `gimp` under `/tmp/snap.gimp/tmp/` (it looks to me, to be without execute rights).

## Snap Desktop Files

Snap `*.desktop` files are under `/var/lib/snapd/desktop/`. To customize them, copy the `*.desktop` file from `/var/lib/snapd/desktop/` under `~/.local/share/applications`. For example, for `chromium`:

```
Exec=env BAMF_DESKTOP_FILE_HINT=/var/lib/snapd/desktop/applications/chromium_chromium.desktop /snap/bin/chromium --disk-cache-dir=/dev/null --disk-cache-size=1 --incognito -start-maximized --no-first-run %U
```

## Snap Configuration

To get [configuration](https://snapcraft.io/docs/configuration-in-snaps) options of a snap use (*set/unset* option can be used to set/clear them):

```bash
$ sudo snap get -d gimp
$ sudo snap get -d core # system
```

Snaps can choose to [react](https://snapcraft.io/docs/supported-snap-hooks#heading--the-configure-hook) to configuration changes.

## Removing Old Revisions

To remove an old [revision](https://snapcraft.io/docs/keeping-snaps-up-to-date#heading--controlling-updates), one can use:

```bash
$ snap list --all | grep gimp
gimp                  2.10.18                        262   latest/edge      snapcrafters  disabled
gimp                  2.10.18                        265   latest/edge      snapcrafters  -

$ sudo snap remove gimp --revision 262
```

One can make a bash [script](https://www.linuxuprising.com/2019/04/how-to-remove-old-snap-versions-to-free.html) to automate this given the lost people who created snap *forgot* to make that an option (need to be run with `sudo`):

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

Ideally, snaps should not be running when running above script, but that is now hard in Ubuntu, so a system restart may be needed after running the above script.

## Connections: Interfaces = Plugs and Slots

A plug in a snap can [connect](https://snapcraft.io/docs/interface-managements) to a slot in another [snap](https://snapcraft.io/docs/snapcraft-interfaces).

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

To see what snaps use a given interface we can use:

```
$ snap interface network
```

Examples of snap [interfaces](https://snapcraft.io/docs/supported-interfaces):

* [:home](https://snapcraft.io/docs/home-interface) *core* snap interface gives the application access to non-hidden files in real `$HOME` directory. This is off, unless a [classic](https://snapcraft.io/docs/snap-confinement) snap, or an [approved](https://snapcraft.io/docs/permission-requests) snap. That means there is no way to know, until you install the snap, which may be too late, due to [hooks](https://snapcraft.io/docs/supported-snap-hooks).
* [:personal-files](https://snapcraft.io/docs/personal-files-interface) allows access to hidden $HOME folders and files.
* [:network](https://snapcraft.io/docs/network-interface) gives access to network
  -  `:network` is not good when combined with `:home` although most snaps have both auto-plugged, as it is the case for `gimp` above. It can be removed using `sudo snap disconnect gimp:network :network` and it can be added back using `sudo snap connect gimp:network :network`. These changes are preserved by `snap refresh`. Connecting or disconnecting an interface may cause snap to execute code (via interface hooks).
* [content](https://snapcraft.io/docs/content-interface) allows snaps of same publisher to share data with each-other.
* [:browser-support](https://snapcraft.io/docs/browser-support-interface) access to local system via modern browser APIs.
* [:password-manager-service](https://snapcraft.io/docs/password-manager-service-interface) access to system password services.
* [:x11](https://snapcraft.io/docs/x11-interface) monitor mouse/keyboard input and graphics output of other apps, a feature shared by all x11 applications.

One can connect or disconnect defined *plugs* in a snap, but cannot add more, which is kind of [sad](https://askubuntu.com/questions/1178913/adding-a-plug-or-interface-to-existing-snap), as original snap authors can never foresee all use cases:

```bash
$ snap connect gimp:personal-files :personal-files
error: snap "gimp" has no plug named "personal-files"
```

While `snap info --verbose gimp` works without having to install a snap, the `snap connections gimp` works only after a snap is installed (it also does not show plugs for configure / install / uninstall hooks). To view connections without having to install try:

```bash
snap download gimp # e.g gimp_252.snap file is created
mkdir -p $HOME/tmp/mnt
sudo mount -t squashfs -o ro gimp_252.snap $HOME/tmp/mnt
```

Then look in `meta` and `snap` folders for *hooks* and *plugs* defined in `yaml` files.

## Snap Home

The parts of `$HOME` that a snap application needs are mapped under `$HOME/snap` folder:

```bash
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

Using [layouts](https://snapcraft.io/docs/snap-layouts) a snap can map any snap folder data on these folders. For example, docker snap, uses `/var/snap/docker/common/var-lib-docker` for `/var/lib/docker` (can be found with `docker info` command).

### Snap Data Snapshots

To make a [snapshot](https://snapcraft.io/docs/snapshots) of all data use `snap save` (saved in `/var/lib/snapd/snapshots` folder). To view saved data snapshots, use `snap saved`. It lists snapshot `id` is in the first *Set* column. To remove a snapshot use `snap forget id`.

If you make a type and forget `d` in the end of `snap saved`, you end up creating a new full snapshot which gets listed, rather than viewing what is there. 

Snapshots are created automatically for removed snaps (listed with `auto` in Notes), unless you use `snap remove --purge gimp`.

### Application Configuration

The `HOME/snap/*/current/.config` path will link to latest `$HOME/.config` folder as seen by application, but only if application is run once, otherwise link is invalid (e.g. if snap updates the application in between runs).

### Application Cache

My `$HOME/.cache` is mounted in `tmpfs` (despite my encrypted disk partition) as I do not want applications to share cache data between runs. `snap` is a regression in this regard. Deleting application cache folders manually is possible, but inconvenient:

```bash
ls -d snap/*/common/.cache | xargs rm -rf
```

## Within The Snap

To view the world as a snap sees it from within, we can get a [shell](https://snapcraft.io/tutorials/advanced-snap-usage#6-and-more) using:

```bash
snap run --shell gimp
# then within snap shell
env | grep SNAP
SNAP_DESKTOP_RUNTIME=/snap/gimp/252/gnome-platform
SNAP_USER_DATA=/home/user/snap/gimp/252
SNAP_REVISION=252
SNAP_ARCH=amd64
SNAP_INSTANCE_KEY=
SNAP_USER_COMMON=/home/user/snap/gimp/common
SNAP_LAUNCHER_ARCH_TRIPLET=x86_64-linux-gnu
SNAP=/snap/gimp/252
SNAP_COMMON=/var/snap/gimp/common
SNAP_NAME=gimp
SNAP_INSTANCE_NAME=gimp
SNAP_DATA=/var/snap/gimp/252
SNAP_COOKIE=uSiqYplNbNuej3yGeSWIxI9MmoNIksa7gDZgRJ_yATiuWFRjz4jr
SNAP_REEXEC=
SNAP_CONTEXT=uSiqYplNbNuej3yGeSWIxI9MmoNIksa7gDZgRJ_yATiuWFRjz4jr
SNAP_VERSION=2.10.18
SNAP_LIBRARY_PATH=/var/lib/snapd/lib/gl:/var/lib/snapd/lib/gl32:/var/lib/snapd/void

$ env | grep XDG
XDG_CONFIG_HOME=/home/user/snap/gimp/252/.config
XDG_DATA_DIRS=/home/user/snap/gimp/252/.local/share:/home/user/snap/gimp/252:/snap/gimp/252/data-dir:/snap/gimp/252/usr/share:/snap/gimp/252/gnome-platform/usr/share:...:/var/lib/snapd/desktop:/var/lib/snapd/desktop
XDG_CACHE_HOME=/home/user/snap/gimp/common/.cache
XDG_RUNTIME_DIR=/run/user/1000/snap.gimp
XDG_DATA_HOME=/home/user/snap/gimp/252/.local/share
XDG_CONFIG_DIRS=/snap/gimp/252/gnome-platform/etc/xdg:...:/etc/xdg

$ env | grep HOME
HOME=/home/user/snap/gimp/252

$ ls /
bin  boot  dev  etc  home  lib  lib64  media  meta  mnt  opt  proc  root  run  sbin  snap  srv  sys  tmp  usr  var  writable
```

User defined environment variables outside of snap are visible to snap. Some of `XDG_` variables are changed to writable snap folders.

The disk configuration the snap sees is in `/var/lib/snapd/mount/snap.gimp.fstab`.


## Snap Store

Snap store [tracks](https://snapcraft.io/docs/snap-store-metrics) snap installs and usage. Geo-location data based on IPs are also collected.

The unique tracking machine id is kept in `/var/lib/snapd/state.json` in `{"data": { "device": { "serial": "ID" } }}`. Snap usage data (kept also in`/var/lib/snapd/state.json`) includes start and stop times. Snaps are traced via unique cookies (found in `/var/lib/snapd/cookie` folder that match *snap-cookies* inside `/var/lib/snapd/state.json`. Snap cookie is passed to each snap via *SNAP* environment variables  `SNAP_COOKIE=Nv9FlFlPr7MwhvBbV66BxXLQbk6YlJ4hMntXdYbgNNBF`. Even if you reset your device id, your can still be continuously uniquely identified via the snap cookies.

To reset your [device-serial](https://forum.snapcraft.io/t/cant-install-or-refresh-snaps-on-arch-linux/8690/27) use:

```bash
$ sudo systemctl stop snapd
$ sudo cat /var/lib/snapd/state.json | \
    jq 'delpaths([["data", "auth", "device"]])' > state.json-new
$ sudo cp state.json-new /var/lib/snapd/state.json
$ sudo systemctl start snapd
```

To reset both device serial and cookies, use this modified version:

```bash
sudo systemctl stop snapd
sudo sh -c 'ls /var/lib/snapd/cookie/*'
sudo sh -c 'rm /var/lib/snapd/cookie/*'
sudo cat /var/lib/snapd/state.json | jq 'delpaths([["data", "auth", "device"], ["data", "snap-cookies"]])' > state.json-new
sudo cp state.json-new /var/lib/snapd/state.json
sudo systemctl start snapd
```

Same as a convenience script to save to a file and make executable and use to run snap commands:

```bash
#!/bin/bash -

if [ $(id -u) != "0" ]; then
    exec /usr/bin/sudo -S "$0" "$@"
    exit $?
fi

systemctl stop snapd &> /dev/null
# sh -c 'ls /var/lib/snapd/cookie/*'
sh -c 'rm /var/lib/snapd/cookie/*'
cat /var/lib/snapd/state.json | jq 'delpaths([["data", "auth", "device"], ["data", "snap-cookies"]])' > state.json-new
cp state.json-new /var/lib/snapd/state.json
systemctl start snapd
echo ":) $@"
sleep 2
if [[ "$#" -gt 0 ]]; then
    snap "$@"
else
    snap refresh
fi
```

The device-serial ID and list of installed snaps and their usage data are sent to store on every refresh, which happens automatically and periodically. Refresh period can be controlled using [refresh.hold](https://snapcraft.io/docs/keeping-snaps-up-to-date#heading--refresh-hold), and postponed up to 2 months. To pause them for [longer](https://askubuntu.com/questions/930593/how-to-disable-autorefresh-in-snap) add in `/etc/hosts` (need to be removed when `snap install` or `snap refresh`):

```
0.0.0.0 api.snapcraft.io
```

Given Ubuntu distributes parts of desktop via snap, disable of refresh means some desktop software software updates cannot be delivered.

## Limited Hacking

I tried `rclone` snap and it did not work. It needs access to profile for dot config files, but it has only home. Fixing that by reading `rclone` docs and passing config file via environment variables, brought up the next issue, and so on. The snap state is also old. This leave me as user with no choice, but download and install `rclone` on my own. This will in general endanger users.

A similar situation with `chromium` browser arises, where the snap is inadequate for many users. This will result in direct installs of Google Chrome binaries from Google web site.

While *snap* is maybe ok for GNOME and other Ubuntu parts, it is not a replacement for current third-party software via `apt`.

## Summary

Ubuntu snap is an interesting concept, with impressive achievements and with several unpolished corners, that creates an illusion of security, and that is here to stay.

* Consider only installing snaps maintained by [Canonical](https://forum.snapcraft.io/t/snaps-officially-supported-by-canonical/1719), or other parties you trust. Avoid *devmode* and *classic* snaps, unless you really trust the provider.
* https://snapcraft.io/store is scarce on snap details. Some people write a link to their *yaml* definition in read-me there, some not. The store itself gives no details on permissions needed by a snap, during install, use, and removal. The only way to know what is inside, is to download and examine files on your own.
* Avoid *Ubuntu Software Center* `snap-store` as it may not be clear what it installs. Look carefully to `deb` packages and they may be transitional *snap* installs. Better install directly via `snap install` after own evaluation.
* Creating a snap is a complex process, and the build process is transparent about code and dependencies used and can be reproduced. This is good, but due to complexity, things may land to a snap that are not obvious, or end up being in non-maintained versions within the snap.
* Snap services (systemd snap.*.service units) are not usable in servers due to forced updates. `snap install docker` is maybe the only snap service needed. Rest can be installed and controlled better via `docker`.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2021/2021-11-24-Extensions.md'>Extensions</a> <a rel='next' id='fnext' href='#blog/2019/2019-11-13-ETL-Solutions.md'>ETL Solutions</a></ins>
