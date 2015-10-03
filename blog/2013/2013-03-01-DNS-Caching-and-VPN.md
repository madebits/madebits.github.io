#DNS caching and VPN

2013-03-01

<!--- tags: dns -->

I read some days ago about [DNS leaks](http://www.dnsleaktest.com/) while connected to a VPN, because the operating system could cache the DNS data.

I use sometimes VPN to access various media services not directly supported in my location, and I was curious to test if there were any DNS leaks.

Indeed, on my Windows 7 machine, the OS caches the DNS data. The only safe way is to cleanup the cache after starting the VPN and reset it after that (otherwise DNS resolution will not work after VPN).

The site mentioned above has the commands required, but they are more useful if combined with starting the VPN connection from command-line too, so I made two quick batch scripts (for pptp):

**vpnon.bat**

```
nslookup yahoo.com
rasdial "My VPN 1" username password
ipconfig /flushdns
netsh interface IPv4 set dnsserver "Wireless Network Connection" static 0.0.0.0 both
ipconfig /flushdns
nslookup yahoo.com
```
`set dnsserver` command will give an error (`The configured DNS server is incorrect or does not exist`), but this is ok, as the specified server `0.0.0.0` does not really exist. To verify dns lookup use `nslookup` command with some common web site address (use exit to exit it, if you do not specify an address). `ipconfig /all` can also be used to check the DNS server used. For my test VPN, once connected, it shows they use of Google public DNS servers.

**vpnoff.bat**

```
rasdial "My VPN 1" /disconnect
netsh interface IPv4 set dnsserver "Wireless Network Connection" dhcp
ipconfig /flushdns
nslookup yahoo.com
```

They have to be run with Administrator rights. Replace "My VPN 1" with the VPN configuration name on Windows, `username` and `password` your own ones, and "Wireless Network Connection" with the active network connection you use on your system (can be found either in Network Administration details, or via `netsh interface show interface`). In you are chaining VPNs add more `rasdial` calls as needed for each VPN connection.

On Lubuntu (12.04) the OS seems (at the moment) not to cache DNS data (you may need to restart the browser thought). No additional action is needed on Lubuntu other that to connect to the VPN(s).


<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-03-02-Exploring-Digital-Camera-Specifications.md'>Exploring Digital Camera Specifications</a> <a id='fnext' href='#blog/2013/2013-01-02-Using-Git-with-TFS.md'>Using Git with TFS</a></ins>
