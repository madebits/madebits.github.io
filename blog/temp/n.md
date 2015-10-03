
[ip](http://baturin.org/docs/iproute2/).

## Dummy Interface

[Dummy](http://wiki.networksecuritytoolkit.org/index.php/Dummy_Interface) network interface is a local [loopback](http://www.tldp.org/LDP/nag/node72.html) interface useful for local testing. Lets try some free address:

```
$ ping -c1 192.168.2.1
PING 192.168.2.1 (192.168.2.1) 56(84) bytes of data.

--- 192.168.2.1 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms
```

Load some dummies next, but we will use only first one here `dummy0` (to remove use `sudo rmmod dummy`):

```
$ sudo modprobe dummy numdummies=3
$ ip addr | grep -A1 dummy
4: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether fe:1d:4c:2e:87:1b brd ff:ff:ff:ff:ff:ff
5: dummy1: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 5e:0b:3d:47:83:b9 brd ff:ff:ff:ff:ff:ff
6: dummy2: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 72:96:e9:3c:95:4e brd ff:ff:ff:ff:ff:ff
$ ip -d link show dummy0
4: dummy0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether fa:da:fe:57:5a:f9 brd ff:ff:ff:ff:ff:ff promiscuity 1 
    dummy addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535 
```

They get random MACs. More can be created manually:

```
$ sudo ip link add name dummy4 type dummy
```

To `ping`, we assign an address to `dummy0`:

```
$ ping -c1 192.168.2.1
PING 192.168.2.1 (192.168.2.1) 56(84) bytes of data.

--- 192.168.2.1 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

$ sudo ip addr add 192.168.2.1/24 dev dummy0
$ ip addr | grep  dummy0
4: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default qlen 1000
    inet 198.162.2.1/24 scope global dummy0

$ ping -c1 192.168.2.1
PING 192.168.2.1 (192.168.2.1) 56(84) bytes of data.
64 bytes from 192.168.2.1: icmp_seq=1 ttl=64 time=0.034 ms

--- 192.168.2.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.034/0.034/0.034/0.000 ms

$ ping -I 192.168.2.1 -c1 8.8.8.8
PING 8.8.8.8 (8.8.8.8) from 192.168.2.1 : 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=44 time=17.5 ms
```

Routing is also supported:

```
$ sudo ip route add 192.168.2.0/24 dev dummy0
RTNETLINK answers: Network is down
$ sudo ip link set dummy0 up
$ sudo ip route add 192.168.2.0/24 dev dummy0
RTNETLINK answers: File exists 
$ ip route get 192.168.2.2
192.168.2.2 dev dummy0 src 192.168.2.1 
    cache 
$ ip route show table local | grep dummy
broadcast 192.168.2.0 dev dummy0 proto kernel scope link src 192.168.2.1 
local 192.168.2.1 dev dummy0 proto kernel scope host src 192.168.2.1 
broadcast 192.168.2.255 dev dummy0 proto kernel scope link src 192.168.2.1    
```

##Bridge

[Bridge](http://www.tldp.org/HOWTO/BRIDGE-STP-HOWTO/index.html).

Interfaces added to a bridge are connected on bridge [ports](https://superuser.com/questions/694661/losing-internet-access-when-creating-ethernet-bridge-for-openvpn). Bridge is the NIC.

```
$ sudo ip addr add 192.168.2.1/24 dev dummy0
$ sudo ip addr add 192.168.3.1/24 dev dummy1
$ sudo ip link set dev dummy0 up
$ sudo ip link set dev dummy1 up
$ sudo ip link add name br0 type bridge
$ sudo ip link set dev br0 up
$ sudo ip link set dev dummy0 master br0
$ sudo ip link set dev dummy0 master br0
$ brctl show br0
bridge name bridge id       STP enabled interfaces
br0     8000.46c0f49644c2   no      dummy0
                            dummy1
$ bridge link show | grep dummytp
19: dummy0 state UNKNOWN : <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 master br0 state forwarding priority 32 cost 100 
20: dummy1 state DOWN : <BROADCAST,NOARP> mtu 1500 master br0 state disabled priority 32 cost 100

$ brctl showstp br0
br0
 bridge id      8000.46c0f49644c2
... 
dummy0 (1)
 port id        8001            state            forwarding
...
dummy1 (2)
 port id        8002            state            forwarding
...
```

If NICs are added to bridge without flushing their IPs (`ip addr flush dev dummy0`), they are still reachable via the IP.

If bridge has no IP, its mastered interfaces are visible to host. If bridge gets an IP, then its managed interfaces still see each-other, but are not visible from host.

```
sudo ip addr add 192.168.10.1/24 dev br0

```


Possible bridge [usages](https://wiki.archlinux.org/index.php/QEMU#Tap_networking_with_QEMU), in combination with `iptables` configuration:

* As a switch. Bridge has no IP address and collects other interfaces. Bridge learn about traffic passing by (via STP) and optimizes it.
* As isolated virtual LAN. Interfaces collect to a bridge can be manipulated as whole:
    * Bridge has no IP address and INPUT traffic is disabled via `iptables`. Bridge mastered virtual interfaces can speak to each other (`iptables -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT`), but not outside. A DHCP server, if needed, has to run on one of virtual interfaces.
    * Bridge has an IP address and traffic to it is allowed, but not real network interface. Mastered virtual interfaces can speak to each other and host system. Using SNAT via `iptables -t nat ... -j MAQUERADE` enabled network access beyond host. A DHCP server outside bridge can give dymanic IPs to virtual interfaces.
    * Bridge contains also one real interface (or `veth`), then virtual mastered interfaces are visible on external network.