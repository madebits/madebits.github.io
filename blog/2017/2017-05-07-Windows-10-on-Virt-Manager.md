#Windows 10 on Virt-Manager in Ubuntu

2017-05-07

<!--- tags: linux virtualization -->

Setting up a Windows machine in Ubuntu with KVM via [virt-manager](https://virt-manager.org/) is easy, but some peculiarities have to be mastered. 

<div id='toc'></div>

##Installation

To install [virt-manager](https://virt-manager.org/) with QEMU/[KVM](https://help.ubuntu.com/community/KVM/Installation) support on Ubuntu (tested on 17.04) use:

```
$ sudo apt install qemu-kvm libvirt-bin bridge-utils virt-manager
```

KVM will work only if hardware visualization is [supported](https://wiki.archlinux.org/index.php/KVM) by CPU and enabled in BIOS. The result of this command should be > 0:

```
$ grep -ciE 'vmx|svm' /proc/cpuinfo
```

Optional tools to help with VM disks can be installed via:

```
$ sudo apt install libguestfs-tools
```

###Group Membership

Add current user to `libvirt-qemu` group (`virt-manager` will complain about group `libvirtd`, but the correct groups to use in Ubuntu are `libvirt` and `libvirt-qemu`).  

```
$ sudo adduser `id -un` libvirt-qemu
```

###Configuration Files

Configuration of VMs is stored in `/etc/libvirt`. [Nested](https://docs.openstack.org/developer/devstack/guides/devstack-with-nested-kvm.html) virtualization is enabled by default in `/etc/modprobe.d/qemu-system-x86.conf`. To [manually](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/5/html/Virtualization/chap-Virtualization-Managing_guests_with_virsh.html) [edit](https://www.centos.org/docs/5/html/5.2/Virtualization/chap-Virtualization-Managing_guests_with_virsh.html) a VM configuration use:

```bash
# view
virsh dumpxml win10
# edit
virsh edit win10
# export
virsh dumpxml win10 > win10.xml
# import
virsh create win10.xml # new
virsh define win10.xml
```

##Creating a Windows 10 VM

Using `virt-manager` [UI](https://www.howtogeek.com/117635/how-to-install-kvm-and-create-virtual-machines-on-ubuntu/), create a new Windows [10](https://superuser.com/questions/1057518/windows-10-taskbar-how-to-make-it-thinner-when-vertical) VM. I used mostly defaults including, IDE Disk and CDROM, NAT, Spice, and Video QXL, and I choose to [copy](https://fedoraproject.org/wiki/How_to_enable_nested_virtualization_in_KVM) host CPU information. Sound device model `ich9` seems to be working better for me with Windows 10. I run into some small [bug](https://bugzilla.redhat.com/show_bug.cgi?id=1377155#c12) with HID device and applied the suggested fix.

###Disk Image

Either use `virt-manager` UI to create the disk image, or create a *raw* image on your own (as `root`) using (file name does not matter):

```
# truncate -s 128G win10.raw
```

This command creates [sparse](https://wiki.archlinux.org/index.php/sparse_file) files. `truncate` command can be used to extend the disk size if needed. Same effect can be achieved using: `qemu-img create -f raw -o size=128G win10.raw`. You can [switch](https://easyengine.io/tutorials/kvm/convert-qcow2-to-raw-format/) at any time to `qcow2` format. 

To backup the [sparse](https://wiki.archlinux.org/index.php/sparse_file#Archiving_with_.60tar.27) disk image files in an external disk use:

```bash
# backup
tar -Scf /media/backup/win10.tar /data/kvm/win10.raw
# restore
tar -C /data/kvm/ -xvf /media/backup/win10.tar
```

###QEMU Process

Once the VM is started, use `ps aux | grep qemu` to find the exact command-line used. Example, of my QEMU process with two vCPUs managed via KVM.

```
...
 ├─qemu-system-x86─┬─{CPU 0/KVM}
 │                 ├─{CPU 1/KVM}
 │                 └─2*[{qemu-system-x86}]
```

##Connecting to VM

In `virt-manager` *Edit / Preferences* menu, *Console* tab, you can change the grab key. I used only right `Ctr` key, same as in Virtualbox. 

The toolbar is not show for me in fullscreen of `virt-manager` VM console due to some bug, so I use the grab key, and then `F11` key to exit the fullscreen, if I cannot find the invisible toolbar button blindly using the mouse (toolbar works if you use `virt-viewer`).  

Apart of using `virt-manager` an alternative way to access the machine is to use `virt-viewer` directly:

```
virt-viewer win10 -af --hotkeys=toggle-fullscreen=shift+f11
```

Or, by using `remote-viewer` that comes with `virt-viewer` (it needs a URI, or a settings file):

```bash
remote-viewer $(virsh domdisplay win10) -f --hotkeys=toggle-fullscreen=shift+f11
```

Some `virt-viewer` settings (documented in `man remote-viewer`) can be configured in `$XDG_CONFIG_HOME/virt-viewer/settings` file (such files can be also used with `remote-viewer` in place of URI). Most of settings are global. The ones that are per machine need the machine UUID, that can be found via: `virsh domuuid win10`.

###RDP

Another alternative is to use [RDP](https://wiki.archlinux.org/index.php/QEMU#Remote_Desktop_Protocol) (`sudo apt install freerdp-x11`), but performance is not as good as Spice. `Ctrl+Alt+Enter` toggles fullscreen. I am also sharing a folder - this is the simplest way to share a folder:

```bash
xfreerdp /bpp:32 /v:192.168.122.74 /u:userName /drive:home,$HOME/work-remote /sound /f /toggle-fullscreen +async-input +async-update +async-transport +async-channels +clipboard
```

###Finding Guest IP

To find the IP of the guest VM from outside use:

```
$ virsh domifaddr win10
```

Or, by using the more evolved:

```bash
$ virsh net-list
# ... default
$ virsh net-dhcp-leases default
```

To parse out only the IP use this complex line:

```bash
$ virsh domifaddr win10 | tail -2 | head -1 | tr -s ' ' | cut -d ' ' -f 5 | cut -d '/' -f 1
```

You could add it to `$HOME/.bashrc` as:

```bash
virship() {
virsh domifaddr "$1" | tail -2 | head -1 | tr -s ' ' | cut -d ' ' -f 5 | cut -d '/' -f 1
}
```

And use it as:

```bash
virship win10
```


##Basic Networking

A `virbr0` bridge will be created during install, along with a NAT [tap](http://www.innervoice.in/blogs/2013/12/08/tap-interfaces-linux-bridge/) when VM runs:

```bash
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

This is convenient, and `iptables` has been [modified](https://jamielinux.com/docs/libvirt-networking-handbook/appendix/example-of-iptables-nat.html):

```bash
$ sudo cat /proc/net/ip_tables_names
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

###Network Shared Folders

If you share a folder in the VM, you can access it using Samba in your Ubuntu file manager of choice using `smb://IP/share` (where IP is the guest IP address). Similarly, host network services, if you have SSH (SCP), or Samba shared folders, are visible on the Windows guest via the host IP. Use [WinScp](https://winscp.net/eng/download.php) from guest for host SSH/SCP. To access host SSH/SCP, host firewall need to adapted:

```bash
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

Spice guest tools offer several other features, such as direct [folder sharing](https://www.spice-space.org/spice-user-manual.html#_folder_sharing) via [WebDAV](https://en.wikipedia.org/wiki/WebDAV):

* Install [spice-webdavd](https://www.spice-space.org/download/windows/spice-webdavd/) on Windows guest, and enable the *Spice webdav proxy* windows service (`sc start spice-webdavd`).
* Add to VM as hardware a Channel of Spice Port with `org.spice-space.webdav.0`. 
* Due to a [bug](https://bugzilla.redhat.com/show_bug.cgi?id=1444637) in `virt-manager`, you need to use `virt-viewer` to connect to the virtual machine:

 ```bash
 virsh list --all
 virsh start win10
 virt-viewer -af win10
 virsh shutdown win10
 ```

* In the `virt-viewer` in *File / Preferences* menu you can share a folder. After sharing the folder, in Window guest open a `cmd.exe` console as Administrator and [run](https://github.com/lofyer/spice-webdav) the following commands:

 ```
 sc start spice-webdavd
 "C:\Program Files (x86)\SPICE webdavd\map-drive.bat"
 ```

This will add the mapped drive, as last free drive `Z:`, on Windows guest.

### Spice Viewer Options

Both `virt-viewer` and `remote-viewer` that comes with it, [accept](https://www.spice-space.org/spice-user-manual.html#_client_2) `--help-spice` to lists Spice specific available options. For example, to share a folder via WebDAV append `--spice-shared-dir=$HOME/temp`.

###Ubuntu Guests

In Ubuntu guests, to install Spice guest tools use:

```
sudo apt install spice-vdagent spice-webdavd xserver-xorg-video-qxl linux-image-extra-virtual
```

The last one `linux-image-extra-virtual` is need to use `9p` shared folders.

####Sharing via WebDAV

To access WebDAV shared folders use [gvfs](https://wiki.ubuntuusers.de/gvfs-mount/):

```bash
sudo apt install gvfs-bin
gvfs-mount dav://127.0.0.1:9843/
#umount
gvfs-mount -u dav://127.0.0.1:9843/
```

WebDAV port can be found using any of:

```bash
ps aux | grep webdavd
systemctl status spice-webdavd.service
```

####Sharing via Filesystemshare

To use [9p](https://askubuntu.com/questions/819773/is-there-something-like-virtualbox-guest-additions-for-qemu-kvm) shared folders, add a [Filesystemshare](http://wiki.qemu.org/Documentation/9psetup) to the VM, using *Mapped* mode and give it a target path [tag](https://www.kernel.org/doc/Documentation/filesystems/9p.txt), for example: `share` - this is just a tag, not a path. 

Select a host folder to share, e.g. `/data/share`. VM [runs](http://rabexc.org/posts/p9-setup-in-libvirt) as user `librivt-qemu` under group `kvm` (configurable in `/etc/libvirt/qemu.conf`) - ensure this user and group has [access](https://unix.stackexchange.com/questions/257372/how-can-i-store-files-in-the-mounted-shared-folder), along with your own user to the host shared folder.

New files are in guest are created as non-shareable with the group. Normally, the following setting should be enough, but they do not work:

```bash
chown -R libvirt-qemu:kvm /data/share
sudo setfacl -R -m u:$(id -un):rwx,g:(id -gn):rwx /data/share
sudo setfacl -m default:u::rwx,default:g::rwx /data/share
sudo setfacl -m default:m::rwx /data/share
```

The above does not work as somehow default and mask ACL is ignored for new files. A permission fix is need in host after creation of new files guest:

```bash
$ sudo setfacl -R -m u:libvirt-qemu:rwx,u:$(id -un):rwx /data/share
$ getfacl share
# file: share
# owner: libvirt-qemu
# group: kvm
user::rwx
user:u7:rwx
user:libvirt-qemu:rwx
group::rwx
group:kvm:rwx
group:u7:rwx
mask::rwx
other::rwx
default:user::rwx
default:group::rwx
default:mask::rwx
default:other::rwx
```

In guest, mount the share by referring it by its tag `share` (create `/mnt/share` if not there):

```bash
sudo mount -t 9p -o trans=virtio,version=9p2000.L,rw share /mnt/share
```

To [add](http://troglobit.github.io/blog/2013/07/05/file-system-pass-through-in-kvm-slash-qemu-slash-libvirt/) it to `/etc/fstab` use:

```bash
share /mnt/share  9p  trans=virtio,version=9p2000.L,rw  0 0
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2017/2017-05-09-Ubuntu-Block-Application-Internet-Access.md'>Ubuntu Block Application Internet Access</a> <a rel='next' id='fnext' href='#blog/2017/2017-04-27-Cross-Cutting-Concerns-Evolution.md'>Cross Cutting Concerns Evolution</a></ins>
