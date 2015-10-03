#Using DNSCrypt on Ubuntu 14.04

2014-12-12

<!--- tags: linux dns -->

[DNSCrypt](https://www.opendns.com/about/innovations/dnscrypt/) enables making encrypted DNS quires to the DNS providers that support it. There is [PPA](https://launchpad.net/~shnatsel/+archive/ubuntu/dnscrypt) for DnsCrypt for Ubuntu, but it is not maintained at the time of this writing and it has no [binary](http://askubuntu.com/questions/490325/dnscrypt-on-ubuntu-14-04) for Ubuntu 14.04 LTS. To install DNSCryp I used these steps, that I tried on Lubuntu 14.04 LTS:

* Visit [DNSCryp PPA packages](https://launchpad.net/~shnatsel/+archive/ubuntu/dnscrypt/+packages) and download [libsodium](https://launchpad.net/~shnatsel/+archive/ubuntu/dnscrypt/+files/libsodium4_0.4.5-0~trusty5_amd64.deb) for *trusty* and [dnscrypt-proxy](https://launchpad.net/~shnatsel/+archive/ubuntu/dnscrypt/+files/dnscrypt-proxy_1.4.0-0~oldconf2%2Bsaucy1_amd64.deb) for *saucy* (I used the 64 bit version for my machine, you may need the 32 bit versions).

* I used `gdebi-gtk` tool to install first `libsodium4_0.4.5-0~trusty5_amd64.deb` and then `dnscrypt-proxy_1.4.0-0~oldconf2+saucy1_amd64.deb` (you can also use `dpkg -i`).

* `dnscrypt-proxy` runs then locally in address `127.0.0.2` on port `53` (use `netstat -tuplen` to verify).

* The default DNSCryp PPA package `apparmor` profile prevents Ubuntu 14.04 from shutting down. To [fix](https://github.com/jedisct1/dnscrypt-proxy/issues/104) that I edited it (`sudo leafpad /etc/apparmor.d/usr.sbin.dnscrypt-proxy`) and replacing its content with the [following](https://raw.githubusercontent.com/xuzhen/dnscrypt-proxy/562ddd4aad05562e6792a47cf39e3c2c6504c6d9/apparmor.profile.dnscrypt-proxy):

	```
	# Last Modified: Tue Dec 02 22:20:12 2014

	#include <tunables/global>

	/usr/sbin/dnscrypt-proxy {
	  #include <abstractions/base>

	  network inet stream,
	  network inet6 stream,
	  network inet dgram,
	  network inet6 dgram,

	  capability net_admin,
	  capability net_bind_service,
	  capability setgid,
	  capability setuid,
	  capability sys_chroot,
	  capability ipc_lock,

	  /bin/false r,
	  /etc/ld.so.cache r,
	  /etc/nsswitch.conf r,
	  /etc/passwd r,

	# In case of custom libsodium installation
	  /usr/local/lib/{@{multiarch}/,}libsodium.so* mr,

	# Reasonable pidfile location - tweak this if you prefer a different one
	  /run/dnscrypt-proxy.pid rw,

	}
	```

	After you do this, run `sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.dnscrypt-proxy`.

* Optional: `dnscrypt-proxy` configuration for the init service daemon is found in `/etc/default/dnscrypt-proxy`. The parameters (with -- added) are documented in `man dnscrypt-proxy`. I edited `/etc/default/dnscrypt-proxy` as root to specify an alternative DNS server. The list of the official available servers can be found in [GitHub](https://github.com/jedisct1/dnscrypt-proxy/blob/master/dnscrypt-resolvers.csv), or locally in `/usr/share/dnscrypt-proxy/dnscrypt-resolvers.csv`. To verify that a given server works use `dig -p 443 @176.56.237.171 google.com` (replace ip and port as needed). If you edit `/etc/default/dnscrypt-proxy`, you should run `sudo restart dnscrypt-proxy` afterwards.

* Verify that `dnscrypt-proxy` runs by using `ps -ef | grep dnscrypt`. Then verify it can resolve addresses by using `dig @127.0.0.2 google.com` (if you configured `tcp-only` for `dnscrypt-proxy` then use `dig +vc @127.0.0.2 google.com`). If you use opendns provider a quick [check](https://support.opendns.com/entries/21737309-How-do-I-know-DNSCrypt-is-working-) is use `dig @127.0.0.2 debug.opendns.com txt` - it should show something like `dnscrypt enabled`. However, to know for sure DNS requests are using DNSCrypt have a look at [wireshark](http://askubuntu.com/questions/105366/how-to-check-if-dns-is-encrypted) DNS/TCP packets. They should not contain any readable domains.

* If all ok, you can replace you current DNS servers in the Network Manager UI. If you use DHCP, select *Automatic (DHCP) addresses only*, and set the 127.0.0.2 in *Additional DNS servers*. Once done, run `sudo service network-manager restart` for it to take effect. Verify the server used with `nm-tool | grep -i dns`. `


DNSCrypt should work after this. If it does not then `sudo stop dnscrypt-proxy` service and run the command from `ps -ef | grep dnscrypt` manually via `sudo` appending `--loglevel=1024` to the log messages. This can come handy if you have some firewall issues. To use tcp with firewalls, use 53 and not 443 as resolver port and specify `--tcp-only` option.

DNSCrypt only encrypts the DNS lookups (web site name to its IP number) between you and the DNSCrypt used server. It only protects you from man-in-middle DNS attacks from you local network or your ISP. The raw IP addresses of sites you visit and their contents are still visible (use HTTPS when possible to hide contents *somehow* - people can still guess what you see by measuring the size of transmitted documents). If you want to fully prevent anyone in your local network or your ISP from looking at the IP addresses of the sites you visit then consider using some VPN or Tor.

To uninstall DNSCrypt use `dpkg --purge dnscrypt-proxy libsodium4` and reconfigure DNS servers in the Network Manager UI.

**Advanced**: NetworkManager uses dnsmasq to cache DNS. So the dnsmasq will cache from the DNSCrypt. You can manually [configure](https://wiki.archlinux.org/index.php/DNSCrypt#Example:_configuration_for_dnsmasq) dnsmasq to use DNSCrypt as follows. Edit `/etc/default/dnscrypt-proxy` to use IP 127.0.0.1 port 2053 (any port will do). Then edit `/etc/NetworkManager/NetworkManager.conf` and comment out:

```
#dns=dnsmasq
```
Then run `sudo apt-get install dnsmasq` to create the dnsmasq service and the configuration file. Edit `/etc/dnsmasq.conf` file to set:

```
no-resolv
server=127.0.0.1#2053
listen-address=127.0.0.1
```

Finally, restart `sudo service dnscrypt-proxy restart`, `sudo service dnsmasq restart`. Finally in NetworkManager settings set 127.0.0.1 as DNS server (same as above) and `sudo service network-manager restart`. Test dnscrypt-proxy works using and that dns works using `dig google.com`.

**Really Advanced :o):** `dnscrypt-proxy` can use one DNSCrypt server at a time. This can be a problem if the server is temporary not reachable. To remedy this problem, we can run more than once instance of `dnscrypt-proxy` at the same time, each pointing to a different DNSCrypt server. I did these tests on my Arch Linux box, so the commands below are not Ubuntu (14.04) specific as they use `systemd` services. DNS in your system will not work while you do these changes.

Customize `dnscrypt-proxy.service` and `dnsmasq.service` using:

```
sudo systemctl edit --full dnscrypt-proxy.service
sudo systemctl edit --full dnsmasq.service
```

These command will create copies in `/etc/systemd/system` folder. Do not change `dnscrypt-proxy.service` at this time, just create the copy. In the customized `dnsmasq.service`, [append](https://serverfault.com/questions/503041/dnsmasq-multiple-forwarding-servers-for-domain-entries) `--all-servers` to `ExecStart` parameters - this enables `dnsmasq` to use all its configured servers in parallel.

To be able starting more than one `dnscrypt-proxy` instance, we will use `systemd` service [instances](http://0pointer.de/blog/projects/instances.html):

```
# rename
sudo mv /etc/systemd/system/dnscrypt-proxy.service /etc/systemd/system/my-dnscrypt-proxy@.service
# copy config with a new name
sudo cp /etc/conf.d/dnscrypt-proxy /etc/conf.d/my-dnscrypt-proxy1
```

Then edit `etc/systemd/system/my-dnscrypt-proxy@.service`  to point to the correct configuration file:

```
...
Before=dnsmasq.service
...
[Service]
EnvironmentFile=/etc/conf.d/my-dnscrypt-proxy%i
...
```

`/etc/conf.d/my-dnscrypt-proxy1` contains the configuration of first instance. I used the following local address for the proxy in `/etc/conf.d/my-dnscrypt-proxy1`:

```
...
DNSCRYPT_LOCALIP=127.0.0.2
DNSCRYPT_LOCALPORT=2051
...
```

We can add another instance, by creating a copy of it:

```
sudo cp /etc/conf.d/my-dnscrypt-proxy1 /etc/conf.d/my-dnscrypt-proxy2
```

Edit `/etc/conf.d/my-dnscrypt-proxy2` to point to the second DNSCrypt server. I used the following local address for the proxy in `/etc/conf.d/my-dnscrypt-proxy2`:

```
...
DNSCRYPT_LOCALIP=127.0.0.2
DNSCRYPT_LOCALPORT=2052
...
```

You can add more servers as needed in the similar way. They have to run at different addresses (and/or ports). Any loopback address/port will do as long they are not is use.

Next edit `/etc/dnsmasq.conf`, this time the custom configuration looks as follows (list all `dnscrypt-proxy` servers and ports):

```
...
no-resolv
server=127.0.0.2#2051
server=127.0.0.2#2052
...
```

Configure NetworkManager settings (IPv4) to use *Automatic (DHCP) addresses only*, and set the 127.0.0.1 in *Additional DNS servers*. This means NetworkManager will use `dnsmasq` as DNS source and `dnsmasq` will use the different `dnscrypt-proxy` instances as source for DNS servers. 

If everything is configured ok, you are ready to start the services:

```
sudo systemctl daemon-reload

# disable original dnscrypt-proxy.service
sudo systemctl stop dnscrypt-proxy.service
sudo systemctl disable dnscrypt-proxy.service

# enable my-dnscrypt-proxy service instances, repeat as needed
sudo systemctl start my-dnscrypt-proxy@1.service
sudo systemctl enable my-dnscrypt-proxy@1.service
sudo systemctl start my-dnscrypt-proxy@2.service
sudo systemctl enable my-dnscrypt-proxy@2.service

# restart rest
sudo systemctl restart dnsmasq.service
sudo systemctl restart NetworkManager.service
```

After this check DNS works, and check DnsCrypt is active. If not fix any errors and re-try.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2014/2014-12-16-Moving-From-EF5-Database-First-to-EF6-Code-First.md'>Moving From EF5 Database First to EF6 Code First</a> <a rel='next' id='fnext' href='#blog/2014/2014-11-14-A-Minimal-GitHub-Static-Site.md'>A Minimal GitHub Static Site</a></ins>
