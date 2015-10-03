#Disabling ZRAM in Lubuntu 13.10

2013-11-06

<!--- tags: linux -->

I usually run Lubuntu without any swap memory. It runs fully ok like that for me. Since Lubuntu 13.10, a memory based swap file using zram is active by default.

A compressed memory driver `zram` is used to create swap partitions in memory (using part of RAM). It is triggered via an upstart service called `zram-config` (`sudo service zram-config start|stop|status|restart|reload|force-reload`), configured in `/etc/init/zram-config.conf`. `zram-config` creates a `zram` device per logical CPU found, and then uses half of system memory for `zram` devices (each device gets `totalmemory / 2 / numOfDevices`). Then `swapon` command is used to add the swap partitions (one per zram device created). This means `sudo swapoff -a` removes zram (and all swap, if you have any) from the current session. The swap can be seen via `cat /proc/swaps`. The free command also shows the swap size (check for zram using `dmesg | grep zram`).

I left `zram-config` run at first to see whether I liked it or not. If you do not want to use it, to remove it, based on Ubuntu [forum](http://askubuntu.com/questions/19320/recommended-way-to-enable-disable-services) instructions, I created a `zram-conf.override` file in `/etc/init`, with `manual` as text inside (another way is to just rename the `.conf` file to something else, e.g., `.conf.disabled`).

**Update:** zram-config is fully ok. I was a bit suspicions of it at first, but it is running great. I will keep this post, as it has details on how zram-config works.

<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-11-13-German-Umlauts-on-US-Keyboard-on-Lubuntu.md'>German Umlauts on US Keyboard on Lubuntu</a> <a id='fnext' href='#blog/2013/2013-11-04-Freecom-DVB-T-USB-Receiver-in-Lubuntu.md'>Freecom DVB T USB Receiver in Lubuntu</a></ins>
