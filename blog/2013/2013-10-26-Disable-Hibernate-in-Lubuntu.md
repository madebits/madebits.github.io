#Disable Hibernate in Lubuntu

2013-10-26

<!--- tags: linux -->

In (L)Ubuntu to fully [disable](http://askubuntu.com/questions/50443/way-to-disable-hibernate-from-within-gconf-editor-so-button-disappears) suspend and hibernation edit `/usr/share/polkit-1/actions/org.freedesktop.upower.policy` and set for both:

```
<allow_active>no</allow_active>
```

These settings are lost on every new Ubuntu upgrade. A [better way](http://ubuntuhandbook.org/index.php/2013/10/enable-hibernation-ubuntu-13-10/) to persist polkit changes is to create in `/var/lib/polkit-1/localauthority/50-local.d/` a file named `com.ubuntu.enable-hibernate.pkla` with this text (I have not tested this):

```
[Re-enable hibernate by default in upower]
Identity=unix-user:*
Action=org.freedesktop.upower.hibernate
ResultActive=no

[Re-enable hibernate by default in logind]
Identity=unix-user:*
Action=org.freedesktop.login1.hibernate
ResultActive=no
```

Somehow after upgrade to 13.10, after I started a shutdown and closed the laptop lid it was suspended in the middle of shutdown. I [found](http://askubuntu.com/questions/362667/xubuntu-13-10-disabling-suspend-on-lid-being-closed) that to deactivate these actions one has to edit /etc/systemd/logind.conf and set:

```
HandlePowerKey=ignore
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleLidSwitch=ignore
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-10-28-Starting-VirtualBox-VM-Directly.md'>Starting VirtualBox VM Directly</a> <a rel='next' id='fnext' href='#blog/2013/2013-10-24-Exploring-Linux-Startup-of-LightDM-in-Lubuntu.md'>Exploring Linux Startup of LightDM in Lubuntu</a></ins>
