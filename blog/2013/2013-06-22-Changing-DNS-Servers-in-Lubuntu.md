#Changing DNS Servers in Lubuntu

2013-06-22

<!--- tags: linux dns -->

To change DNS servers in Lubuntu, go to Network Manager, Edit the connection you use. In IPv4 Settings tab, change the Method from *Automatic (DHCP)* to *Automatic (DHCP) addresses only*. Then in DNS servers enter the list of servers (IPs or names) separated by comma. Click Save and restart the machine when done (or `sudo restart network-manager`). Verify after restart using `nm-tool | grep -i dns` that the servers are same as those set (or you can use `nmcli dev list iface eth0 | grep IP4` - replace `eth0` with the network interface of interest).

You can find free DNS servers to use, for example, at [opennicproject.org](http://www.opennicproject.org/).

If you have a DSL connection, than by default your local router IP is used as DNS - this forwards to your ISP DNS server. After changing my DNS servers as shown above, I found I could not access anymore my DSL router web interface by name. To fix this I added an entry to my `/etc/hosts` file with my router LAN address, and its name (your router may be in a different address and have another name):
```
192.168.2.1	speedport.ip
```
Alternatively, you can also add your router address (ISP DNS) to the end of your DNS servers list in the network IPv4 Settings as done for the rest above.

Despite changing the servers locally, your ISP may transparently capture your DNS traffic packets and redirect them to its own DNS server. You can check this running the test in [dnsleaktest.com](http://www.dnsleaktest.com/). If that is the case, the only safe way to change DNS is using a VPN connection.



<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-07-17-Configuring-AMD-ATI-Radeon-on-Lubuntu.md'>Configuring AMD ATI Radeon on Lubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-06-10-Lubuntu-Unlock-Default-Keyring-at-Login.md'>Lubuntu Unlock Default Keyring at Login</a></ins>
