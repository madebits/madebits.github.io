#Upgrading To Windows 10

<!--- tags: linux, windows -->

2016-02-07

After reviewing Windows 8 beta some years ago while adapting some software to run with it, I become aware that Windows is evolving to be an untrusted personal operating system, in same level as Android, Chrome OS, and others. I made back then the decision to move slowly to Linux based desktops for personal use at home, where I know at least more or less accurately what is running. As of today, no one at my home uses Windows anymore and almost all my machines run only Linux. [JetBrains](https://www.jetbrains.com/) software fills most of my personal needs for application development IDEs in Linux. 

Still, having an updated copy of Windows running on real hardware (and not in a virtual machine) is useful up and now mainly for running Visual Studio, and some other work related software. I decided to upgrade my single dual boot machine with Windows 7 and Ubuntu to Windows 10, given a) it is *free*, b) some of new .NET and Visual Studio features only work with latest version of Windows, c) given I do not really use Windows privately anymore, Windows 10 privacy issues do not affect me much.

I am not sure why Microsoft is insisting on such intrusive data collection strategies. Data collection makes sense to counterweight what competitors already do, and I guess most people will accept that at some point of time. However, insisting on collecting data at any cost and not offering some way to disable it fully, pushes existing power users out of Windows. Software created by hobbyist power users originally for own use stood for a large part of Windows software diversity offerings in the past. With Windows store and invasive data collection power users generally avoid Windows, resulting in less useful new software being written for that platform.

##Getting Window 10

I had not booted Windows 7 at home since last August and latest updates there were from last June. I used the [media creation tool](https://www.microsoft.com/en-in/software-download/windows10) to do the Windows 10 upgrade. The download went smooth, but the check for Windows 10 updates hanged. I had to restart windows update service several times:

```
net stop wuauserv
net start wuauserv
```

I am not sure if it got any updates like this, but the UI progress reported it did. I triggered a windows update after I installed Windows 10 to be sure I got all latest patches.

##Grub (kind of) Preserved

When I had installed Windows 7, I made sure there was no recovery partition created, so I had only two partitions on the SSD (I am not using UEFI). I  never needed to do a Windows recovery and I see no value in a recovery partition. It seems Windows 10 does not work without a recovery partition and the installer created a 450MB one after the first. This may have drawbacks in case I need to re-size volumes. It also moved the Ubuntu partition one up, from `/dev/sda2` to `/dev/sda3`, resulting in a `grub` rescue prompt on next restart. Being a relatively late adopter has its benefits. The [question](https://askubuntu.com/questions/654316/windows-10-and-ubuntu-dual-boot/654994#654994) had been already answered. At the `grub` rescue prompt, I tested first where Ubuntu was and then temporary redirected `grub` to that
location:

```
ls (hd0,msdos3)/
set prefix=(hd0,msdos3)/boot/grub
set root=(hd0,msdos3)
insmod normal
normal
```

I had to repeat this a few times until Windows 10 installation was finished. Then I booted to Ubuntu and made the `grub` change permanent by running:

```
sudo grub-install /dev/sda
sudo update-grub
```

After that, I got the normal grub prompt for Ubuntu and for Windows 10.

##E6510 Peculiarities

Windows 10 upgrade lost my switched button settings for the mouse. The display driver of my E6510 model was not found at first. It seems officially Dell does not support Windows 10 on this model. After installing Dell driver detect tool, my nVidia display driver was restored and I had FHD resolution back. My swapped mouse button setting was lost again after the display driver installation and I had to reconfigure it back. The free fall sensor of the machine did not work in Windows 10, but it is of no use to me, given I have replaced the magnetic HDD with a SSD. The Cisco VPN Client was not compatible and was removed. I have to check what would be a replacement for that.

##Minimizing Windows 10 Exposure

After the installation, the Disk Cleanup tool removed around 30GB of data. The customary [Windows 10 configuration](
https://www.reddit.com/r/Windows10/comments/3f38ed/guide_how_to_disable_data_logging_in_w10/) has to be done next, and I installed [Classic Shell](http://www.classicshell.net/) as a start menu replacement. Given I use no Microsoft account, the default Windows 10 Start menu implementation is limited in functionality for me. Windows Start menu, Search, and PC settings search somehow do not work properly with Windows Search service disabled since Windows 8. The old Control Panel is still searchable with Windows Search service disabled. The Classis Shell Start menu search is somehow lacking, but it is the only option at the moment.

##References

* https://www.microsoft.com/en-in/software-download/windows10
* https://www.reddit.com/r/Windows10/comments/3f38ed/guide_how_to_disable_data_logging_in_w10/
* http://www.classicshell.net/
* https://github.com/crazy-max/HostsWindowsBlocker
* http://tinywall.pados.hu/
* http://www.hwinfo.com/misc/RemoveW10Bloat.htm
* https://www.oo-software.com/en/shutup10
* https://github.com/WindowsLies/BlockWindows
* http://www.guidingtech.com/54080/make-windows-10-secure/
* https://technet.microsoft.com/en-us/library/mt577208.aspx
* https://forums.spybot.info/showthread.php?72686-Spybot-Anti-Beacon-for-Windows-10
* http://www.makeuseof.com/tag/6-hidden-windows-10-features/
* http://www.howtogeek.com/219936/how-to-disable-quick-access-in-file-explorer-on-windows-10/
* http://www.howtogeek.com/224616/30-ways-windows-10-phones-home/
* http://computerstepbystep.com/windows_event_log_service.html
* http://www.ghacks.net/2016/02/16/how-to-make-any-program-the-default-on-windows-10/
* http://www.ghacks.net/2016/07/26/you-will-use-cortana-says-microsoft/

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-02-12-Using-Autofac-to-Organize-CSharp-Code.md'>Using Autofac to Organize CSharp Code</a> <a rel='next' id='fnext' href='#blog/2016/2016-02-03-Bootstrapping-Intercorrelated-Data.md'>Bootstrapping Intercorrelated Data</a></ins>
