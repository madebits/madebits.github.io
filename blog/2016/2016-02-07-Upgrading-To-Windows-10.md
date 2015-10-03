#Upgrading To Windows-10

2016-02-07

I decided to upgrade my dual boot machine with Windows 7 and Ubuntu to Windows 10. I had not booted Windows 7 at home since last August and latest updates there were from last June. I used the media creation tool to do the Windows 10 upgrade. The download went smooth, but the check for updates hanged. I had to restart windows update service several times:

```
net stop wuauserv
net start wuauserv
```

I am not sure if it got any updates like this, but the UI progress reported it did.

When I installed my Windows 7, some time ago, I made sure there was no recovery partition created, so I had only two partitions on the SSD (I am not using UEFI). I had never the need to do a Windows recovery and see no value in a recovery partition for myself. It seems Windows 10 does not work without a recovery partition, and the installed created a 450MB one after the first. This may have drawbacks in case I need to re-size volumes, and it moved the Ubuntu partition one up, form `sda2` to `sda3`, resulting in a `grub` rescue prompt on next restart. Being a relatively late adopter has its benefits. The [question](https://askubuntu.com/questions/654316/windows-10-and-ubuntu-dual-boot/654994#654994) had been already asked. At the `grub` rescue prompt, I tested first where Ubuntu was and then temporary redirected `grub` to that
location:

```
ls (hd0,msdos3)/
set prefix=(hd0,msdos3)/boot/grub
set root=(hd0,msdos3)
insmod normal
normal
```

I had to repeat this a few times until Windows 10 installation was finished. Then I booted in Ubuntu and it made the `grub` change permanent by running:

```
sudo grub-install /dev/sda
sudo update-grub
```

After this I got the normal grub prompt for Ubuntu and for Windows 10.

Windows 10 upgrade lost my switched button settings for the mouse. The display driver of my E6510 model was not found at first. It seems officially Dell does not support Windows 10 on this model. After installing Dell driver detect tool, my nVidia display driver was restored. My swapped mouse button setting was lost again after the display driver installation and I had to reconfigure it back. The free fall sensor of the machine did not work in Windows 10, but it is of no use to me given I have replaced the magnetic HDD with SSD. The Cisco VPN Client was not compatible and was removed. I have to check what would be a replaced for that.

The customary [Windows 10 configuration](
https://www.reddit.com/r/Windows10/comments/3f38ed/guide_how_to_disable_data_logging_in_w10/) has to be done next, and I installed [classic shell](http://www.classicshell.net/), start menu replacement.

<ins class='nfooter'><a id='fnext' href='#blog/2016/2016-02-03-Bootstrapping-Intercorrelated-Data.md'>Bootstrapping Intercorrelated Data</a></ins>
