#Windows 10 on virt-manager in Ubuntu

2017-05-07

<!--- tags: linux virtualization -->

To install [virt-manager](https://virt-manager.org/) with QEMU/[KVM](https://help.ubuntu.com/community/KVM/Installation) support on Ubuntu (tested on 17.04) use:

```
$ sudo apt install qemu-kvm libvirt-bin bridge-utils virt-manager
```

KVM will work only if hardware visualization is [supported](https://wiki.archlinux.org/index.php/KVM) by CPU and enabled in BIOS.

Optional tools to help with VM disks can be installed via:

```
sudo apt install libguestfs-tools
```

###Group Membership

Add current user to `libvirt-qemu` group (`virt-manager` will complain about group `libvirtd`, but the correct groups to use in Ubuntu are `libvirt` and `libvirt-qemu`).  

```
$ sudo adduser `id -un` libvirt-qemu
```

###Configuration Files

Configuration of VMs is stored in `/etc/libvirt`. [Nested](https://docs.openstack.org/developer/devstack/guides/devstack-with-nested-kvm.html) virtualization is enabled by default in `/etc/modprobe.d/qemu-system-x86.conf`. To manually edit a VM configuration use:

```
# view
virsh dumpxml win10
# edit
virsh edit win10
```

##Creating a Windows 10 VM

Using `virt-manager` [UI](https://www.howtogeek.com/117635/how-to-install-kvm-and-create-virtual-machines-on-ubuntu/), create a new Windows 10 VM. I use mostly defaults including, IDE Disk and CDROM, NAT, Spice, and Video QXL. I found Sound device model `ich9`  to be working better for me with Windows 10. I run into some small [bug](https://bugzilla.redhat.com/show_bug.cgi?id=1377155#c12) with HID device.

###Disk Image

Either use `virt-manager` UI to create the disk image, or create a *raw* image on your own (as `root`) using (file name does not matter):

```
# truncate -s 128G win10.raw
```

This command creates [sparse](https://wiki.archlinux.org/index.php/sparse_file) files. `truncate` command can be used to extend the disk size if needed. Same effect can be achieved using: `qemu-img create -f raw -o size=128G win10.raw`. You can [switch](https://easyengine.io/tutorials/kvm/convert-qcow2-to-raw-format/) at any time to `qcow2` format. 

###QEMU Process

Once the VM is started, use `ps aux | grep qemu` to find the exact command-line used. Example, of my QEMU process with two vCPUs managed via KVM.

```
...
 ├─qemu-system-x86─┬─{CPU 0/KVM}
 │                 ├─{CPU 1/KVM}
 │                 └─2*[{qemu-system-x86}]
```

##Connecting and Host Keyboard Grab Key

In `virt-manager` *Edit / Preferences* menu, *Console* tab, you can change the grab key. I usually use only right `Ctr` key, same as in Virtualbox. 

The toolbar is not show for me in fullscreen due to some bug, so I use the grab key, and then `F11` key to exit the fullscreen, if I cannot find the invisible toolbar button blindly using the mouse (toolbar works if you use `virt-viewer`).  

Alternative way to access the machine:

```
virt-viewer win10
```

Or:

```
remote-viewer $(virsh domdisplay win10) -f --hotkeys=toggle-fullscreen=shift+f11
```

Another alternative is to use [RDP](https://wiki.archlinux.org/index.php/QEMU#Remote_Desktop_Protocol) (`sudo apt install freerdp-x11`), via (Ctrl+Alt+Enter toggles fullscreen). I am also sharing a folder:

```
xfreerdp /bpp:32 /v:192.168.122.74 /u:userName /drive:home,$HOME/work-remote /sound /f /toggle-fullscreen +async-input +async-update +async-transport +async-channels +clipboard
```

To find the IP of the guest VM from outside use:

```
$ virsh domifaddr win10
```

Or the more evolved:

```
$ virsh net-list
# ... default
$ virsh net-dhcp-leases default
```

To parse only the IP use this evolved line:

```
$ virsh domifaddr win10 | tail -2 | head -1 | tr -s ' ' | cut -d ' ' -f 5 | cut -d '/' -f 1
```

You can add it to `$HOME/.bashrc` as:

```
virship() {
virsh domifaddr "$1" | tail -2 | head -1 | tr -s ' ' | cut -d ' ' -f 5 | cut -d '/' -f 1
}
```

And use it as:

```
virship win10
```


##Basic Networking

A `virbr0` bridge will be created during install, along with a NAT [tap](http://www.innervoice.in/blogs/2013/12/08/tap-interfaces-linux-bridge/) when VM runs:

```
$ ip addr show
...
4: virbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
...
5: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast master virbr0 state DOWN group default qlen 1000
...
7: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master virbr0 state UNKNOWN group default qlen 1000
...

$ route -n | grep vir
192.168.122.0   0.0.0.0         255.255.255.0   U     0      0        0 virbr0

```

This is convenient, and `iptables` has been modified:

```
$ sudo iptables -S | grep vir
-A INPUT -i virbr0 -p udp -m udp --dport 53 -j ACCEPT
-A INPUT -i virbr0 -p tcp -m tcp --dport 53 -j ACCEPT
-A INPUT -i virbr0 -p udp -m udp --dport 67 -j ACCEPT
-A INPUT -i virbr0 -p tcp -m tcp --dport 67 -j ACCEPT
-A INPUT -i virbr0 -p tcp -m tcp --dport 80 -j ACCEPT
-A FORWARD -d 192.168.122.0/24 -o virbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -s 192.168.122.0/24 -i virbr0 -j ACCEPT
-A FORWARD -i virbr0 -o virbr0 -j ACCEPT
-A FORWARD -o virbr0 -j REJECT --reject-with icmp-port-unreachable
-A FORWARD -i virbr0 -j REJECT --reject-with icmp-port-unreachable
-A OUTPUT -o virbr0 -p udp -m udp --dport 68 -j ACCEPT
-A OUTPUT -o virbr0 -p udp -m udp --dport 68 -j ACCEPT
-A OUTPUT -o virbr0 -p udp -m udp --dport 53 -j ACCEPT
-A OUTPUT -o virbr0 -p tcp -m tcp --dport 53 -j ACCEPT

$ sudo iptables -S -t nat
-P PREROUTING ACCEPT
-P INPUT ACCEPT
-P OUTPUT ACCEPT
-P POSTROUTING ACCEPT
-A POSTROUTING -s 192.168.122.0/24 -d 224.0.0.0/24 -j RETURN
-A POSTROUTING -s 192.168.122.0/24 -d 255.255.255.255/32 -j RETURN
-A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -p tcp -j MASQUERADE --to-ports 1024-65535
-A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -p udp -j MASQUERADE --to-ports 1024-65535
-A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -j MASQUERADE

$ sudo iptables -S -t mangle
-P PREROUTING ACCEPT
-P INPUT ACCEPT
-P FORWARD ACCEPT
-P OUTPUT ACCEPT
-P POSTROUTING ACCEPT
-A POSTROUTING -o virbr0 -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill
```

If you share a folder in the VM, you can access it using Samba in your Ubuntu file manager of choice using `smb://IP/share`. Similarly, host network services, if you have SSH (SCP) (use [WinScp](https://winscp.net/eng/download.php) from guest), or Samba shared folders, are visible on the Windows guest via the host IP. To access host SSH, firewall need to adapted:

```
$ sudo iptables -A INPUT  -i virbr0  -j ACCEPT
$ sudo iptables -A OUTPUT -o virbr0 -m state --state ESTABLISHED,RELATED -j ACCEPT
$ sudo iptables -A OUTPUT -o virbr0 -p tcp --sport 22 -j ACCEPT
```

##Spice Guest Tools

Windows 10 guest works fine without any custom software installed. However, to get most of Spice and QEMU, such as to share clipboard, install [Spice guest tools](https://www.spice-space.org/download/binaries/spice-guest-tools/), in the Windows guest. Spice guest tool already contains the [Virtio Drivers](https://fedoraproject.org/wiki/Windows_Virtio_Drivers).

For Windows 10, also [FLEXVDI](http://depot.flexvdi.com/guest-tools/) guest tools [can](https://pve.proxmox.com/wiki/SPICE) be used (they contain the Spice guest tools) - I tried them and they come with an older version of Spice guest tools.  

* I changed Windows VM [NIC](https://pve.proxmox.com/wiki/Paravirtualized_Network_Drivers_for_Windows) type from `rtl3189` to `virtio`.
* To [change](https://pve.proxmox.com/wiki/Paravirtualized_Block_Drivers_for_Windows) the VM disk type from IDE to VirtIO SCSI, I used first *Add Hardware* button to a new *Controller* of Type: SCSI, Model: VirtIO SCSI and started the VM. The controller was shown in the Windows Device Manager. After that, I shut down the VM, and changed the Disk bus to SCSI. After starting the VM, I checked disk type was changed in the Device Manager. 

Hard disk access [stats](https://superuser.com/questions/130143/how-to-measure-disk-performance-under-windows) on VM (these number vary, but can give a rough idea):

 ```
 C:\Windows\system32>winsat disk -drive c
    Windows System Assessment Tool
    ...
    > Disk  Random 16.0 Read                       603.31 MB/s          8.4
    > Disk  Sequential 64.0 Read                   3102.16 MB/s          9.3
    > Disk  Sequential 64.0 Write                  2862.25 MB/s          9.2
    > Average Read Time with Sequential Writes     0.155 ms          8.7
    > Latency: 95th Percentile                     0.495 ms          8.7
    > Latency: Maximum                             4.372 ms          8.6
    > Average Read Time with Random Writes         0.231 ms          8.8
 ```

For comparison, this is what I get for Windows 10, on latest [VirtualBox](http://www.johnwillis.com/2014/03/virtualbox-speeding-up-guest-vm-lot.html):

* VirtualBox with SATA controller (without Host I/O cache) on same machine:

 ```
    > Disk  Random 16.0 Read                       99.93 MB/s          7.1
    > Disk  Sequential 64.0 Read                   255.00 MB/s          7.5
    > Disk  Sequential 64.0 Write                  175.51 MB/s          7.2
    > Average Read Time with Sequential Writes     1.139 ms          7.5
    > Latency: 95th Percentile                     3.850 ms          6.8
    > Latency: Maximum                             7.045 ms          8.3
    > Average Read Time with Random Writes         1.194 ms          8.2
 ```

* VirtualBox with SATA controller Host I/O cache enabled:
 
 ```
    > Disk  Random 16.0 Read                       167.61 MB/s          7.5
    > Disk  Sequential 64.0 Read                   408.18 MB/s          8.0
    > Disk  Sequential 64.0 Write                  456.21 MB/s          8.1
    > Average Read Time with Sequential Writes     0.819 ms          7.8
    > Latency: 95th Percentile                     1.492 ms          8.0
    > Latency: Maximum                             93.018 ms          7.7
    > Average Read Time with Random Writes         0.320 ms          8.8
 ```

* VirtualBox with SAS controller with Host I/O cache (SCSI is not recognized by Windows 10, so I cannot test with that, but SAS should be faster than SCSI):

 ```
    > Disk  Random 16.0 Read                       176.90 MB/s          7.6
    > Disk  Sequential 64.0 Read                   433.18 MB/s          8.0
    > Disk  Sequential 64.0 Write                  452.66 MB/s          8.1
    > Average Read Time with Sequential Writes     0.118 ms          8.8
    > Latency: 95th Percentile                     0.247 ms          8.8
    > Latency: Maximum                             2.666 ms          8.7
    > Average Read Time with Random Writes         0.133 ms          8.9
 ```

###Folder Sharing

Spice guest tools offer several other features, such as direct [folder sharing](https://www.spice-space.org/spice-user-manual.html#_folder_sharing):

* Install [spice-webdavd](https://www.spice-space.org/download/windows/spice-webdavd/) on Windows guest, and enable the *Spice webdav proxy* windows service (`sc start spice-webdavd`).
* Add to VM as hardware a Channel of Spice Port with `org.spice-space.webdav.0`. 
* Due to a [bug](https://bugzilla.redhat.com/show_bug.cgi?id=1444637) in `virt-manager`, you need to use `virt-viewer` to connect to the virtual machine:

 ```
 virsh list
 virsh start win10
 virt-viewer -af win10
 virsh shutdown win10
 ```

* In the `virt-viewer` in *File / Preferences* menu you can share a folder. After sharing the folder, in Window guest open a `cmd.exe` console as Administrator and run the following commands:

 ```
 sc start spice-webdavd
 "C:\Program Files (x86)\SPICE webdavd\map-drive.bat"
 ```

This will add the mapped drive, as last free drive `Z:`, on Windows guest. [WebDAV](https://en.wikipedia.org/wiki/WebDAV) is not necessary better than SFTP.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2017/2017-05-09-Ubuntu-Block-Application-Internet-Access.md'>Ubuntu Block Application Internet Access</a> <a rel='next' id='fnext' href='#blog/2017/2017-04-27-Cross-Cutting-Concerns-Evolution.md'>Cross Cutting Concerns Evolution</a></ins>
