#Exploring Linux: Startup of LightDM in Lubuntu Dekstop

2013-10-24

<!--- tags: linux -->

I spent some time to understand where LightDM fits in the startup of Lubuntu (13.04 and 13.10). 

Some background: A X **display manager** (lightdm) manages user login and one or more **X servers** (X11). A **window manager** (openbox) manages window layout of a X server, and a **desktop environment** (lxde) manages look and feel of the desktop (and the look and feel of what is inside an X window). A **session manager** (lxsession), manages the user login session.

In the init (upstart) services, `/etc/init.d/lightdm` is a link to the generic `/lib/init/upstart-job`. `upstart-job` knows what do to based on its link file name (`lightdm`). The actual settings of lightdm upstart-job are then read from: `/etc/init/lightdm.conf` (jobname + .conf).

`/etc/init/lightdm.conf` upstart script says: *The display manager service (LightDM) manages the X servers running on the system, providing login and auto-login services.* At system start up, LightDM takes over from Plymouth and starts the X server and the desktop session.

To set LightDM as default display manager (https://wiki.ubuntu.com/LightDM) use: `$sudo dpkg-reconfigure lightdm`. The value is stored in `/etc/X11/default-display-manager` (as `/usr/sbin/lightdm`, which is read then from `/etc/init/lightdm.conf`).

As a user you can manage (if ever needed) the LightDM job via upstart service interface: `$sudo start lightdm`. This command delegates then to `/etc/init.d/lightdm` that uses `/etc/init/lightdm.conf`.

LightDM reads its own configuration from `/etc/lightdm/`. In `/etc/lightdm/lightdm.conf` one can configure scripts to run for LightDM login and LightDM desktop sessions (`display-setup-script`, `session-setup-script`). The `lightdm-gtk-greeter` can be also configured.

Using pstree -ap we see:

```
init,1
  ├─lightdm,947
  │   ├─Xorg,1002 :0 -core -auth /var/run/lightdm/root/:0 -nolisten tcp vt7...
  │   │   ├─{Xorg},1213
  │   │   └─{Xorg},1214
  │   ├─lightdm,1481 --session-child 11 19
  │   │   ├─lxsession,1530 -s Lubuntu -e LXDE
  │   │   │   ├─lxpanel,1651 --profile Lubuntu
  │   │   │   │   └─{lxpanel},1720
  │   │   │   ├─openbox,1648 --config-file ~/.config/openbox/lubuntu-rc.xml
  │   │   │   ├─pcmanfm,1655 --desktop --profile lubuntu
  │   │   │   │   └─{pcmanfm},1721
  │   │   │   ├─polkit-gnome-authentication-agent-1,1656
  │   │   │   │   ├─{polkit-gnome-au},1675
  │   │   │   │   └─{polkit-gnome-au},2357
  │   │   │   ├─ssh-agent,1612 /usr/bin/dbus-launch --exit-with-session ...
  │   │   │   ├─xscreensaver,1652 -no-splash
  │   │   │   ├─{lxsession},1634
  │   │   │   └─{lxsession},1649
  │   │   └─{lightdm},1483
  │   ├─{lightdm},991
  │   └─{lightdm},992
```

There are two `lighdm` instances in my machine, one that manages the login session and the one that manages the desktop session:
```
  947 ?        SLsl   0:00 lightdm
 1481 ?        Sl     0:00 lightdm --session-child 11 19
```

LightDM login instance starts `/usr/bin/X` and then after login the LightDM desktop instance. `/var/run/lightdm/root/:0` passed to `/usr/bin/X` contains the **MIT-MAGIC-COOKIE** (you may need this e.g, if using `x11vnc`).

LightDM desktop instance starts then `lxsession`. The default user-session name `Lubuntu` is stored in `/etc/lightdm/lightdm.conf`. That is used to find the session to use in `/usr/share/xsessions`. Sessions are `*.desktop` files (can be selected also via the greeter). `Lubuntu.desktop` has in Lubuntu 13.04 `Exec=/usr/bin/startlubuntu`. Then `/usr/bin/startlubuntu` calls `/usr/bin/lxsession -s Lubuntu -e LXDE`. In 13.10, `Lubuntu.desktop` `Exec` calls directly `/usr/bin/lxsession -s Lubuntu -e LXDE`.

From the PIDs, we can see that `lxsession` starts first `ssh-agent`, then `openbox`, `lxpanel`, `xscreensaver`, `pcmanfm`, `polkit-gnome-authentication-agent-1`. The order corresponds to the entries in `~/.config/lxsession/Lubuntu/autostart` file.

One more thing to notice from `pstree` output is that the processes started from `pcmanfm` desktop show up as orphans (without any parent) directly under `init`, whereas they started from `lxterminal` (even in background) belong to it and die with it when the terminal bash instance is closed.

I got the above pstree view from Lubuntu 13.04 on Virtualbox. On my Lubuntu 13.10 (both 32 and 64 bit), the shown part of the process tree looks slightly different.

```
init,1
  ├─lightdm,1122
  │   ├─Xorg,1135 -core :0 -auth /var/run/lightdm/root/:0 -nolisten tcp vt7...
  │   ├─lightdm,1272 --session-child 12 19
  │   │   ├─init,1470 --user
...
  │   │   │   ├─lxsession,1553 -s Lubuntu -e LXDE
  │   │   │   │   ├─lxpanel,1578 --profile Lubuntu
```
 
There is an `init --user` process started by LightDM desktop session instance (**session-job**), and then all the rest of started processes belong to it (sub-init). Session upstart process (`init -- user`) reads its jobs from `/usr/share/upstart/sessions` and from (by default empty) `~/.config/upstart/`. I find session upstart idea elegant not only because upstart functionality is reused, but also because one can identify easy the session jobs from their relation to `init --user` process.

LightDM log is in `/var/log/lightdm/lightdm.log`. In same folder `/var/log/lightdm`, there are also the X and the greeter logs. In `lightdm.log`, we see that LightDM is registered as D-Bus component `org.freedesktop.DisplayManager`. It runs `/usr/lib/lightdm/lightdm-greeter-session /usr/sbin/lightdm-gtk-greeter` and then `/usr/sbin/lightdm-session /usr/bin/lxsession -s Lubuntu -e LXDE`. A `~/.dmrc` file is written (the session name and settings are stored here). `~/.dmrc` cannot be used to change the LightDM on the fly, but it shows what session is currently used.

**References:**

* https://wiki.ubuntu.com/LightDM
* https://wiki.archlinux.org/index.php/LightDM
* http://afrantzis.wordpress.com/2012/06/11/changing-gdmlightdm-user-login-settings-programmatically/
* http://www.freedesktop.org/wiki/Software/LightDM/
* http://upstart.ubuntu.com/cookbook/#system-job
* http://upstart.ubuntu.com/cookbook/#session-job
* http://upstart.ubuntu.com/cookbook/#session-init
* http://wiki.lxde.org/en/LXSession


<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-10-26-Disable-Hibernate-in-Lubuntu.md'>Disable Hibernate in Lubuntu</a> <a id='fnext' href='#blog/2013/2013-10-22-Lubuntu-13.10-Radeon-Laptop-Screen-Black-After-Upgrade.md'>Lubuntu 13.10 Radeon Laptop Screen Black After Upgrade</a></ins>
