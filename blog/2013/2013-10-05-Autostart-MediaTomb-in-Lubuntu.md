#Autostart MediaTomb in Lubuntu

2013-10-05

<!--- tags: linux -->

My `mediatomb` daemon stopped starting at startup in Lubuntu for some unknown reason. I put a workaround to get mediatomb started again automatically at boot.

##Attempt One: Via Upstart (Did not work)

I had a look at `/etc/init/mediatomb.conf` and the networked dependency looked ok:
```
start on (local-filesystems and net-device-up IFACE!=lo)
```
I can start mediatomb after startup manually (sudo service mediatomb start), so I suspected the network dependency was not working at boot. I tried first, without success using:
```
start on (local-filesystems and static-network-up and net-device-up IFACE!=lo)
```
Then I gave up and hardcoded my wireless interface there:
```
start on (local-filesystems and static-network-up and net-device-up IFACE=wlan0)
```
The hardcoded interface value seemed to work at first ok. But after a few days I found out it still starts only sporadically.

##Attempt Two: rc.local (Works ok)

This breaks all the idea of upstart dependencies, but it works in all cases (at least for me).

I added in `/etc/rc.local` before `exit 0`:

```
#!/bin/sh -e
#...
# By default this script does nothing.
service mediatomb start
exit 0
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-10-19-Upgrading-from-Lubuntu-13.04-to-Lubuntu-13.10.md'>Upgrading from Lubuntu 13.04 to Lubuntu 13.10</a> <a rel='next' id='fnext' href='#blog/2013/2013-09-29-Tilda-in-Lubuntu.md'>Tilda in Lubuntu</a></ins>
