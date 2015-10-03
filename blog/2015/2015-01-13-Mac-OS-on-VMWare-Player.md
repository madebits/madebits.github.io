#Mac OS on VMware Player

2015-01-13

<!--- tags: virtualization -->

To get Mac OS work in a virtual machine, I went through the steps listed in [sysprobs](http://www.sysprobs.com/working-os-x-10-9-mavericks-vmware-image-for-windows-os-intel-processor) web site. Below is refinement of the main steps for educational purposes only. I tried these on a Windows 7 64 bit machine with a CPU that supports virtualization. They should work same on Linux. The virtual machine needs around 16 GB of disk space to apply all steps listed here.

1. You need to download and install a copy of [VMware Player](https://my.vmware.com/web/vmware/downloads). VMware Player current version is 7, and it is free for non-commercial use.

2. VMware Player supports Mac OS, but the support is not free and has to be unlocked. You can download the [unlocker](http://www.insanelymac.com/forum/files/file/20-vmware-unlocker-for-os-x/) after registration. I used *unlocker203.zip* file and run `win-install.cmd` as administrator from there. It modifies VMware Player executables, so consider disabling automatic updates in VMware Player settings.

3. There is a ready-made VMware Player machine called *OS_X_Mavericks_10.9_Retail_VMware_Image* or *OS X Mavericks 10.9 Retail VMware Image*. You may have to search for it in Google. It is not official, but if you just want to look at it as a hobby it could be ok. The file is around 5 GB and it may take some time to download.

4. Once you have the *OS X Mavericks 10.9 Retail VMware Image.7z* file, uncompress it to some folder. Then from VMware Player choose [File / Open] to open the *OS X Mavericks\OS X Mavericks.vmx* inside it. Once open, go to the virtual machine settings. In the Options / General make sure Apple Mac OS version OS X 10.8 is selected (it has to be 10.8, it is not a typo). If you do not see Mac OS listed, then the patch of step 2 did not work. Then in Hardware settings adjust the amount of RAM (at least 2GB) and the number of CPUs you want to assign to the machine. Once done, start the virtual machine.

5. Depending on how fast your hard disk is (SSD is recommended) the machine will start and guide you through initial setup (OS X is already installed only the initial setup will be run). You can select a user name and password and finally you can login.

6. The first thing I had to do was to mount the *VMware Unlocker - Mac OS X Guest\VMware 8.x + 9.x + 10.x Series\Tools\darwin.iso* which is also part of *OS_X_Mavericks_10.9_Retail_VMware_Image* files. It will trigger the installation on VMware Player Tools in within the Mac OS virtual machine. Restart the virtual machine after that. Shared folders will then work.

7. To fix the OS X screen resolution, I found a [trick](http://hints.macworld.com/article.php?story=20131030130206132) that helps list resolutions in the Display Settings (hold down the option key and click the "Scaled" radio button). This allowed me to select a proper resolution for my screen and be able to then run the machine in full screen mode.

8. I went to the App Store / Updates and updated my system to the latest version of OS X 10.9.5. This is needed if you want to run `XCode`. If you want you can also upgrade to OS X Yosemite. I did not do that as it is a big download. An Apple ID account is needed, and you will be offered to register one for free (you do not need to specify a payment option). You should confirm your account creation via email. The system downloaded the 1.5 GB updates and I had to restart it two times to finish installation.

9. Given VMware Player only exposes a standard graphic card with no 3D acceleration to the machine, I found it useful to [disable](http://apple.stackexchange.com/questions/14001/how-to-turn-off-all-animations-on-os-x) most of the animations.

10. After this, I went to the App Store and installed XCode (2.4 GB download). Once XCode was installed, I tried a test iOS 8 project in the emulator and it seems to run ok.

![](blog/images/osx.png)

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2015/2015-01-15-Clustering-People.md'>Clustering People</a> <a rel='next' id='fnext' href='#blog/2015/2015-01-07-ASP.NET-vNext-in-Ubuntu-14.04-LTS.md'>ASP.NET vNext in Ubuntu 14.04 LTS</a></ins>
