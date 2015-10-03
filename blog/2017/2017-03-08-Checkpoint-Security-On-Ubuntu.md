#Checkpoint Security On Ubuntu

2017-03-08

<!--- tags: linux -->

Thanks to a *tip* from a friend, based on instruction [here](http://kenfallon.com/checkpoint-snx-install-instructions-for-major-linux-distributions/), I installed `snx` on Ubuntu. The following steps summary is a reminder to self, in case I need to do this again.

[Checkpoint](https://www.checkpoint.com/) does not offer `snx` for direct download, however, in your corporate Checkpoint website, there is link to *Download SSL Network Extender manual installation* for Linux. The downloaded `snx_install.sh` has to be made executable and run as root. It is binary, so it is up to you to choose on what machine you trust to run it. Additionally, the following libraries are needed:

```
sudo apt install libstdc++5:i386 libpam0g:i386 libx11-6:i386
```

It could be the last is not needed, I installed it, but next time, I will try first without it.

After installation, `/usr/bin/snx` becomes available, and a tunnel can be created by using: `snx -s remote.example.com -u user`. Run `snx --help` for a full list of options.

Starting `snx`, creates a tunnel named `tunsnx` visible via `ifconfig`. To allow traffic to pass through, local firewall rules may need to be adapted:

```
/sbin/iptables -A INPUT  -j ACCEPT -i tunsnx
/sbin/iptables -A OUTPUT -j ACCEPT -o tunsnx
```

To access windows remote desktops, install `sudo apt install freerdp-x11` and use something like:

```
xfreerdp /v:10.11.11.11 /u:user
```

Or with some more [options](http://manpages.ubuntu.com/manpages/yakkety/man1/xfreerdp.1.html):

```
xfreerdp /size:1920x1080 /compression +clipboard /v:10.11.11.11 /u:user /audio-mode:0 /drive:home,/home/user/work /client-hostname:remote /toggle-fullscreen
```

To stop `snx` use:

```
sudo ifonfig tunsnx down; sudo pkill snx
```

This removes the added network interface and kills `snx`.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2017/2017-02-21-Integrating-GO.CD-with-Nexus.md'>Integrating GO.CD with Nexus</a></ins>
