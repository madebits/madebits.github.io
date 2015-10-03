#Windows 10 on virt-manager in Ubuntu

2017-05-07

<!--- tags: linux virtualization -->

To install [virt-manager](https://virt-manager.org/) with QEMU/[KVM](https://help.ubuntu.com/community/KVM/Installation) support on Ubuntu (tested on 17.04) use:

```
$ sudo apt install qemu-kvm libvirt-bin bridge-utils virt-manager
```

KVM will work only if hardware visualization is [supported](https://wiki.archlinux.org/index.php/KVM) by CPU and enabled in BIOS.

Optional related tools to help with VM disks can be installed via:

```
sudo apt install libguestfs-tools
```

###Group Membership

Add current user to `libvirt-qemu` group (`virt-manager` will complain about group `libvirtd`, but the correct groups to use in Ubuntu are `libvirt` and `libvirt-qemu`).  

```
$ sudo adduser `id -un` libvirt-qemu
```

###Configuration Files

Configuration of VMs is stored in `/etc/libvirt`. [Nested](https://docs.openstack.org/developer/devstack/guides/devstack-with-nested-kvm.html) virtualization is enabled by default in `/etc/modprobe.d/qemu-system-x86.conf`.

##Creating a Windows 10 VM

Using `virt-manager` [UI](https://www.howtogeek.com/117635/how-to-install-kvm-and-create-virtual-machines-on-ubuntu/), create a new Windows 10 VM. I use mostly defaults including, IDE Disk and CDROM, NAT, Spice, and Video QXL. 

###Disk Image

Either use `virt-manager` UI to create the disk image, or create a *raw* image on your own (as `root`) using (file name does not matter):

```
# truncate -s 128G win10.raw
```

This command creates [sparse](https://wiki.archlinux.org/index.php/sparse_file) files. `truncate` command can be used to extend the disk size if needed. Same effect can be achieved using: `qemu-img create -f raw -o size=128G win10.raw`. You can [switch](https://easyengine.io/tutorials/kvm/convert-qcow2-to-raw-format/) at any time to `qcow2` format. 

###QEMU Process

Once the VM is started, use `ps aux | grep qemu` to find the exact command-line used. Example, of my QEMU process with two vCPUs managed via KVM. The two other threads are the QEMU process itself and the virtual machine IO.

```
...
  ├─qemu-system-x86─┬─{CPU 0/KVM}
  │                 ├─{CPU 1/KVM}
  │                 └─2*[{qemu-system-x86}]

```

##Host Keyboard Grab Key

In `virt-manager` *Edit / Preferences* menu, *Console* tab, you can change the grab key. I usually use only right `Ctr` key, same as in Virtualbox. The toolbar is not show for me in fullscreen due to some bug, so I use the grab key, and then `F11` key to exit the fullscreen, if I cannot find the invisible toolbar button blindly using the mouse (toolbar works if you use `virt-viewer`).

##Basic Networking

A `virbr0` bridge will be created during install, along with a NAT [tap](http://www.innervoice.in/blogs/2013/12/08/tap-interfaces-linux-bridge/):

```
$ ifconfig
...
virbr0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
...
vnet0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::fc54:ff:fe12:a474  prefixlen 64  scopeid 0x20<link>
...
```

This is convenient, but you may need to allow traffic via firewall:

```
$ sudo iptables -A INPUT  -i virbr0  -j ACCEPT
$ sudo iptables -A OUTPUT -o virbr0  -j ACCEPT
```

To make firewall rules permanent if needed use: `sudo netfilter-persistent save`.

To find the IP of the guest VM from outside use:

```
$ virsh net-list
# ... default
$ virsh net-dhcp-leases default
```

If you share a folder in the VM, you can access it using Samba in your Ubuntu file manager of choice using `smb://IP/share`. Similarly, host network services, if you have SSH (SCP) (use [WinScp](https://winscp.net/eng/download.php) from guest), or Samba shared folders, are visible on the Windows guest via the host IP.

##Spice Guest Tools

Windows 10 guest works fine without any custom software installed. However, to get most of Spice, such as to share clipboard, install [Spice guest tools](https://www.spice-space.org/download/binaries/spice-guest-tools/), in the Windows guest.

###Folder Sharing

Spice guest tools offer several other features, such as direct [folder sharing](https://www.spice-space.org/spice-user-manual.html#_folder_sharing):

* Install [spice-webdavd](https://www.spice-space.org/download/windows/spice-webdavd/) on Windows guest, and enable the *Spice webdav proxy* windows service (`sc start spice-webdavd`).
* Add to VM as hardware a Channel of Spice Port with `org.spice-space.webdav.0`. 
* Due to a [bug](https://bugzilla.redhat.com/show_bug.cgi?id=1444637) in `virt-manager`, you need to use `virt-viewer` to connect to the virtual machine:

 ```
 virsh list
 virsh start virtualMachineName
 virt-viewer -a virtualMachineName
 virsh shutdown virtualMachineName
 ```

* In the `virt-viewer` in *File / Preferences* menu you can share a folder. After sharing the folder, in Window guest open a `cmd.exe` console as Administrator and run the following commands:

 ```
 sc start spice-webdavd
 "C:\Program Files (x86)\SPICE webdavd\map-drive.bat"
 ```

This will add the mapped drive, as last free drive `Z:`, on Windows guest.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2017/2017-04-27-Cross-Cutting-Concerns-Evolution.md'>Cross Cutting Concerns Evolution</a></ins>
