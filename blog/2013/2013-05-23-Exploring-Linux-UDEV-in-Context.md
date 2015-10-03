#Exploring Linux: UDEV in Context

2013-05-23

<!--- tags: linux -->

I spent some time to figure out the sequence of events for udev usage in a Linux system.

1. kernel starts init (`/sbin/init` in Ubuntu) that starts `/sbin/udevd` (as user root)
1. kernel detects hardware change
1. kernel exports hardware data as kernel objects ('kobjects') in `/sys` ('sysfs')
1. kernel writes a notification `uevent` in an `af_netlink` socket
1. udevd listens `uevent`(s) from kernel `af_netlink socket`
1. udevd orders events and removes duplicates
1. udevd uses ```/lib/modules/`uname -r`/modules.alias``` list (if MODALIAS is part of `uevent` data) to load the driver modules into kernel (with dependency checks same as `modprobe` does) - no user config or rules are needed for this action (other than to make sure `modules.alias` is up to date)
1. if a driver needs external firmware, kernel notifies udev via an event. udev then runs a script that finds the firmware in `/lib/firmware` and copies in to a response file prepared by the kernel
1. `udevd` matches any custom `/etc/udev/rules.d/` (templates in `/lib/udev/rules.d`) and creates `/dev` devices, modfies `/sys` info, etc, and / or runs whatever is specified there (`grep RUN /lib/udev/rules.d/*`)
1. external tools run by `udevd` (via rules) may generate d-bus events (or be d-bus server objects) - there is not direct reference from `/sbin/udevd` to d-bus; the `RUN` utilities may use d-bus (programatically use `libudev`, or `libgudev`, or `pyudev` to receive to udevd events)
1. `udisksd` (udisks-daemon for udisks1) is a separate daemon. It links `libudev` and uses udev disk storage related events, to provide them as d-bus events - in Lubuntu PCManFm uses these events for automount
1. to view uevents and udevd events in real time use `udevadm monitor`
1. to view d-bus events use `dbus-monitor`
1. to view udisksd events use `udisks --monitor`

**References:**

* http://blogas.sysadmin.lt/?p=141
* http://lists.freedesktop.org/archives/dbus/2010-April/012544.html
* https://wiki.ubuntu.com/Kernel/Firmware
* http://bobcares.com/blog/?p=483
* http://www.linuxquestions.org/questions/slackware-14/mounting-usb-storage-devices-using-udev-rules-4175431668/
* http://lists.debian.org/debian-user/2011/05/msg00717.html
* http://linux.die.net/man/8/udevadm
* http://dbus.freedesktop.org/doc/dbus-monitor.1.html
* http://www.reactivated.net/writing_udev_rules.html
* https://wiki.archlinux.org/index.php/Udev
* http://www.freedesktop.org/wiki/Software/udisks/
* http://www.freedesktop.org/software/systemd/gudev/

<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-05-24-Exploring-Linux-Security-Abstractions.md'>Exploring Linux Security Abstractions</a> <a id='fnext' href='#blog/2013/2013-05-11-Editing-LXDE-Desktop-Files-via-Context-Menu.md'>Editing LXDE Desktop Files via Context Menu</a></ins>
