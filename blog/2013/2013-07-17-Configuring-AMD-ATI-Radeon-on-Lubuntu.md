#Configuring AMD ATI Radeon on Lubuntu

2013-07-17

<!--- tags: linux -->

I wanted to connect an external monitor via HDMI to my Lubuntu laptop, and found out the `fglx` driver I was using had no obvious was to configure the scaling mode. So I decided to install the [latest AMD driver](http://support.amd.com/us/gpudownload/linux/Pages/radeon_linux.aspx).

I downloaded [latest AMD driver](http://support.amd.com/us/gpudownload/linux/Pages/radeon_linux.aspx), unzipped the `*.run` file it contained and made the `*.run` file executable.

##Wrong way to install AMD ATI Driver

I had a look at [BinaryDriverHowto/ATI](https://help.ubuntu.com/community/BinaryDriverHowto/ATI), and decided to install the `*.run` file directly, as this looked the simplest to me.

1. If you uninstall `fglrx` then `fglrx-updates` gets installed automatically and vice-versa. To remove them both, I used:
		sudo apt-get remove --purge fglrx fglrx_* fglrx-amdcccle* fglrx-dev*
1. After reboot, I ran:
		sudo ./amd-driver-installer-catalyst-13-4-x86.x86_64.run
1. And when done I ran `sudo amdconfig --initial` and restarted again.

This worked great, but it is not compatible with package database Debian keeps, so other packages cannot find `fglrx`. This become clear to me when I tried to install hardware acceleration (`xvba-va-driver`). So I had to start over.

##Correct way to install AMD ATI Driver

I used same [latest AMD driver](http://support.amd.com/us/gpudownload/linux/Pages/radeon_linux.aspx) `*.run` file as before.

1. Installed the required dependencies (for 64 bit):
		sudo apt-get install build-essential cdbs dh-make dkms execstack dh-modaliases linux-headers-generic fakeroot libqtgui4 lib32gcc1
1. Generated the .deb packages:
		sudo sh amd-driver-installer-catalyst-13-4-x86.x86_64.run --buildpkg Ubuntu/raring
You can do same from the UI, if you just start `amd-driver-installer-catalyst-13-4-x86.x86_64.run`, make sure you select the correct option in UI to generate packages.
1. Once the .deb packages were generated, I uninstalled the existing driver(s):
		sudo sh /usr/share/ati/fglrx-uninstall.sh
		sudo apt-get remove --purge fglrx fglrx_* fglrx-amdcccle* fglrx-dev*
1. No restart is required, then I ran:
		sudo dpkg -i fglrx*.deb
1. And after that:
		sudo aticonfig --initial -f
1. I verified the install with `fglrxinfo`, did a restart and configured the monitors via AMD Catalyst Control Center (CCC) (`gksu amdcccle`). After that one more restart was needed.

There is a UI tool to automate this correct install process, [Ubuntu AMD Catalyst install](http://sourceforge.net/projects/uaci/) - I may be will give it next time a try (it requires me to install too many dependencies on Lubuntu, and I do not want to do that).

##Final Changes

I was able to set the scaling via AMD Catalyst Control Center, but the setting was lost at next start-up. Then I followed the instruction on a Ubuntu [forum post](http://askubuntu.com/questions/166937/amd-radeons-overscan-is-reset-after-every-boot), and [run](http://wiki.cchtml.com/index.php/Ubuntu_Precise_Installation_Guide):
```
sudo amdconfig --set-pcs-val=MCIL,DigitalHDTVDefaultUnderscan,0
```
After reboot everything worked fine.

To get video hardware acceleration work I ran (and verified with `sudo vainfo` afterwards):
```
sudo apt-get install xvba-va-driver libva-glx1 libva-egl1 vainfo
```
AMD Catalyst Control Center works much better to configure multiple monitors with `/etcX11/xorg.conf` than `arandr` tool I was using before.


<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-07-25-Installing-Lubuntu-Alongside-Windows.md'>Installing Lubuntu Alongside Windows</a> <a id='fnext' href='#blog/2013/2013-06-22-Changing-DNS-Servers-in-Lubuntu.md'>Changing DNS Servers in Lubuntu</a></ins>
