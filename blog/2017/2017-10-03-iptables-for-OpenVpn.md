#iptables for OpenVpn

2017-10-03

<!--- tags: linux -->

Two small [iptables](https://wiki.archlinux.org/index.php/iptables) scripts for dealing with [openvpn](https://openvpn.net/).

##OpenVpn Config

OpenVpn configuration is in `*.conf` files under `/etc/openvpn`:
```
...
remote-random
...
user nobody
group nogroup
```

In Ubuntu, the client is better to run under `nobody`. If several VPN servers are used then `remote-random` helps randomly select them.

To create the client [service](https://community.openvpn.net/openvpn/wiki/Systemd) use (for a file named `/etc/openvpn/myvpn.conf`):

```bash
sudo apt install openvpn
sudo systemctl start openvpn-client@myvpn
sudo systemctl enable openvpn-client@myvpn
```

##Forcing All Traffic via OpenVpn

I modified this script I found online to be able to deal with several local interfaces and cards.

```bash
#!/bin/bash

# based on
# https://airvpn.org/topic/4390-drop-all-traffic-if-vpn-disconnects-with-iptables/
# iptables setup on a local pc
# dropping all traffic not going trough vpn
# allowes traffic in local area network
# special rules for UPNP and Multicast discovery

FW="/sbin/iptables"

local_networks=(
"192.168.0.0/24"
)
local_networks_count=${#local_networks[@]}

local_interfaces=(
"wlp2s0"
)
local_interfaces_count=${#local_interfaces[@]}

virtual_interfaces=(
"tun0"
)
virtual_interfaces_count=${#virtual_interfaces[@]}

#VPN Servers
servers=(
8.8.8.8 # replace with real ones
9.9.9.9
)
servers_count=${#servers[@]}

#---------------------------------------------------------------
# Remove old rules and tables
#---------------------------------------------------------------
echo "Deleting old iptables rules..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
iptables -t security -F
iptables -t security -X

echo "Setting up new rules..."
#---------------------------------------------------------------
# Default Policy - Drop anything!
#---------------------------------------------------------------
$FW -P INPUT DROP
$FW -P FORWARD DROP
$FW -P OUTPUT DROP

#---------------------------------------------------------------
# Allow all local connections via loopback.
#---------------------------------------------------------------
$FW -A INPUT  -i lo  -j ACCEPT
$FW -A OUTPUT -o lo  -j ACCEPT

# Make sure you can communicate with any DHCP server
iptables -A INPUT -s 255.255.255.255 -j ACCEPT
iptables -A OUTPUT -d 255.255.255.255 -j ACCEPT

#---------------------------------------------------------------
# Allow Multicast for local network.
#---------------------------------------------------------------

for (( c = 0; c < $local_interfaces_count; c++ ))
do
	for (( d = 0; d < $local_networks_count; d++ ))
	do
		$FW -A INPUT  -j ACCEPT -p igmp -s ${local_networks[d]} -d 224.0.0.0/4 -i ${local_interfaces[c]}
		$FW -A OUTPUT  -j ACCEPT -p igmp -s ${local_networks[d]} -d 224.0.0.0/4 -o ${local_interfaces[c]}
	done
done

#---------------------------------------------------------------
# UPnP uses IGMP multicast to find media servers.
# Accept IGMP broadcast packets.
# Send SSDP Packets.
#---------------------------------------------------------------
#$FW -A INPUT  -j ACCEPT -p igmp -s $LCL -d 239.0.0.0/8  -i $local_interface
#$FW -A OUTPUT -j ACCEPT -p udp  -s $LCL -d 239.255.255.250 --dport 1900  -o $local_interface

#---------------------------------------------------------------
# Allow all bidirectional traffic from your firewall to the
# local area network
#---------------------------------------------------------------

for (( c = 0; c < $local_interfaces_count; c++ ))
do
	for (( d = 0; d < $local_networks_count; d++ ))
	do
		$FW -A INPUT  -j ACCEPT -s ${local_networks[d]} -i ${local_interfaces[c]}
		$FW -A OUTPUT -j ACCEPT -d ${local_networks[d]} -o ${local_interfaces[c]}
	done
done

#---------------------------------------------------------------
# Allow all bidirectional traffic from your firewall to the
# virtual private network
#---------------------------------------------------------------

for (( c = 0; c < $virtual_interfaces_count; c++ ))
do
	$FW -A INPUT  -j ACCEPT -i ${virtual_interfaces[c]}
	$FW -A OUTPUT -j ACCEPT -o ${virtual_interfaces[c]}
done

#---------------------------------------------------------------
# Connection to VPN servers (TPC,UDP 443)
#---------------------------------------------------------------
for (( c = 0; c < $servers_count; c++ ))
do
	for (( d = 0; d < $local_interfaces_count; d++ ))
	do
		$FW -A INPUT  -j ACCEPT -p udp -s ${servers[c]} --sport 443 -i ${local_interfaces[d]}
		$FW -A OUTPUT -j ACCEPT -p udp -d ${servers[c]} --dport 443 -o ${local_interfaces[d]}
		$FW -A INPUT  -j ACCEPT -p tcp -s ${servers[c]} --sport 443 -i ${local_interfaces[d]}
		$FW -A OUTPUT -j ACCEPT -p tcp -d ${servers[c]} --dport 443 -o ${local_interfaces[d]}
	done
done

#---------------------------------------------------------------
# Log all dropped packages, debug only.
# View in /var/log/syslog or /var/log/messages
#---------------------------------------------------------------
#iptables -N logging
#iptables -A INPUT -j logging
#iptables -A OUTPUT -j logging
#iptables -A logging -m limit --limit 2/min -j LOG --log-prefix "IPTables general: " --log-level 7
#iptables -A logging -j DROP
```
After this script is run, to make it persistent in Ubuntu run:

```
sudo netfilter-persistent save
```

##Minimal Firewall

The following script disables the above rules, but still leaves up a minimal firewall active:

```bash
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
iptables -t security -F
iptables -t security -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -P INPUT DROP

iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable

iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
```

These firewall rules will not force traffic via VPN tunnel, but are useful to when testing system temporary without VPN.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2017/2017-10-05-Clustering-Express-Node-Servers.md'>Clustering Express Node Servers</a> <a rel='next' id='fnext' href='#blog/2017/2017-09-11-From-Requirements-To-Stories.md'>From Requirements To Stories</a></ins>
