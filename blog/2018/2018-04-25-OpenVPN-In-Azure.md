#OpenVPN In Azure

2018-04-25

<!--- tags: linux devops -->

This a summary of steps to setup [OpenVPN](https://openvpn.net/index.php/open-source/downloads.html) in Azure, in a Ubuntu Server 16.04 virtual machine. This VPN can used as personal VPN to access the Internet/vnet via the VM, but it cannot be used to connect to [virtual network](https://docs.microsoft.com/en-us/azure/app-service/web-sites-integrate-with-vnet) from an *app service*.

To set up OpenVPN in Ubuntu server, I followed steps in a [DigitalOcean tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04) steps. I choose to use `port 443` and `proto tcp` in OpenVPN server configuration.

In Azure, you need (at least) to open port `tpc/443` free for VM, in *Networking*, *InBound Port Rules* (e.g., allow *HTTPS* from predefined ones).

My VM has a dynamic IP, so I used the Azure host name in `remote` field on client configuration:

```
remote something.westeurope.cloudapp.azure.com 443
```

To allow VPN traffic through all interfaces in VM, `iptables` needs to be [configured](https://arashmilani.com/post?id=53) in VM:

```
iptables -A INPUT -i eth0 -m state --state NEW -p tcp --dport 443 -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -A OUTPUT -o tun+ -j ACCEPT
```

The `iptables` rules need to made persistent once tested (`sudo apt-get install iptables-persistent netfilter-persistent`).

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2018/2018-04-26-Lubuntu-18.04-Disable-initfsram-Resume.md'>Lubuntu 18.04 Disable initfsram Resume</a> <a rel='next' id='fnext' href='#blog/2018/2018-01-27-Dirac-Notation-Cheatsheet.md'>Dirac Notation Cheatsheet</a></ins>
