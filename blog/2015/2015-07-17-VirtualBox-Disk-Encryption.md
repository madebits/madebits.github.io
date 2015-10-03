#VirtualBox Disk Encryption

2015-07-17

<!--- tags: virtualization encryption -->

[VirtualBox](https://www.virtualbox.org/) 5.0 comes with built-in block encryption for virtual machine images. There is a new **Encryption** tab in the **General** settings of a Virtual machine. It works in both directions without problems, but nerveless consider making a copy of `.vdi` file before trying it out.

If you have an existing virtual machine, enabling encryption and specifying a password will encrypt the `.vid` file once you confirm settings via *Ok* button. VirtualBox will then ask for that password every time you start the virtual machine immediately after the VirtualBox fake BIOS screen. It seems there is a small bug after you enter the password. The virtual machine seems to remain paused. Use the *[Machine / Paused]* menu to resume (or its keyboard shortcut (default) `CTRL+P`). VirtualBox will not re-ask for the password if you restart your machine from within its OS.

If you have an existing virtual machine using an encrypted image, then disabling encryption in **General** settings section, will ask you for the password and decrypt the `.vdi` file in place. The process in both directions is relatively fast (tested on a SSD), so if you change your mind, you can always go back and forth between encrypted and non-encrypted `.vdi` files. This process could come also handy to change the password. First decrypt with current password, and then encrypt with a new one.

Information about encryption (XTS DEK) is saved in the `.vbox` XML file for the virtual machine in the `HardDisk` element. 

```
...
      <HardDisks>
        <HardDisk uuid="{27279c18-f8fc-4a77-a8f9-2ffaab123e03}" location="Arch.vdi" format="VDI" type="Normal">
          <Property name="CRYPT/KeyId" value="test"/>
          <Property name="CRYPT/KeyStore" value="U0NORQABQUVTLVhUUzI1Ni1QTEFJTjY0AAAAAAAAAAAAAAAAAABQQktERjItU0hB&#13;&#10;..."/>
        </HardDisk>
      </HardDisks>
...      
```

If you ever want to move the encrypted `.vdi` file to a new virtual machine, you have to manually copy over this information. Given this information is important, consider making a backup copy of the `.vbox` file along with any `.vdi` backup. 

The first line in `CRYPT/KeyStore` value is the algorithm used, the rest are encryption data. They are not dependent on `uuid` (I tested that by changing the `uuid` of the `.vdi` file and importing it to a new VM). It seems same password in different VMs will generate different XTS DEKs (some random salt is used stored in `CRYPT/KeyStore`). Just knowing the password and the `.vdi` will not help recover the data. You need a copy of `CRYPT/KeyStore` value.

You have to careful if you use VirtualBox disk encryption or you may lose data. I run into a problem with `--compact` and encryption and reported a [bug](https://www.virtualbox.org/ticket/14496). First `vboxmanage --compact` cannot compact an encrypted volume. It will work without errors, but it will not compact. Compact work only with unencrypted disk images. The problem is if you ever compact a `.vdi` file, you cannot encrypt it. I [compacted](https://superuser.com/questions/529149/how-to-compact-virtualboxs-vdi-file-size) first my `.vdi` file, and then tried to encrypt it I got the following error:

```
Could not prepare disk images for encryption (VERR_VD_BLOCK_FREE): (VERR_VD_BLOCK_FREE).
Result Code: 
VBOX_E_FILE_ERROR (0x80BB0004)
Component: 
MediumWrap
Interface: 
IMedium {4afe423b-43e0-e9d0-82e8-ceb307940dda}
```

After this the `.vdi` file was corrupted and could not be booted anymore. Attaching it to another VM showed it as being unallocated and I reported this as a [bug](https://www.virtualbox.org/ticket/14496). If you play with these features make sure you make a backup of `.vdi` file before.

##Ubuntu 14.04 Host Installation

The latest version of VirtualBox for Ubuntu is only available [directly](https://www.virtualbox.org/wiki/Linux_Downloads). You can either use the .deb file directly, or to get updates, add to `/etc/apt/sources.list` the following for Ubuntu 14.04:

```
deb http://download.virtualbox.org/virtualbox/debian trusty contrib
```

And trust the repository key:

```
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
```

To [verify](https://unix.stackexchange.com/questions/175501/get-apts-key-ids-and-fingerprints-in-machine-readable-format) apt key use:

```
apt-key adv --list-public-keys --with-fingerprint --with-colons | grep -A 1 Oracle
pub:-:1024:17:54422A4B98AB5139:2010-05-18:::-:Oracle Corporation (VirtualBox archive signing key) <info@virtualbox.org>::scESC:
fpr:::::::::7B0FAB3A13B907435925D9C954422A4B98AB5139:
```

**Update:** Being an early adopter, means you have to deal with some problems. I have an Arch Linux guest and systemd (221) does not properly [recognize](http://permalink.gmane.org/gmane.comp.sysutils.systemd.devel/33072) VirtualBox, therefore vboxservice is not started. To remedy this, run ` systemctl edit --full vboxservice.service` , set `ConditionVirtualization=true` and do a `systemctl daemon-reload`. With latest `virtualbox-guest-utils` update on Arch, my second VM monitor in VirtualBox [stopped](https://bugs.archlinux.org/task/45748?string=virtualbox&project=5&type%5B0%5D=&sev%5B0%5D=&pri%5B0%5D=&due%5B0%5D=&reported%5B0%5D=&cat%5B0%5D=33&status%5B0%5D=open&percent%5B0%5D=&opened=&dev=&closed=&duedatefrom=&duedateto=&changedfrom=&changedto=&openedfrom=&openedto=&closedfrom=&closedto=) working.

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-07-21-Pure-UI-In-Javascript.md'>Pure UI In Javascript</a> <a id='fnext' href='#blog/2015/2015-06-24-Sun-and-Planets.md'>Sun and Planets</a></ins>
