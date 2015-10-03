#Upgrading Asus Eee PC X101

2012-09-29

I found myself spending more time than I originally thought on my **Asus Eee PC X101** and decided to upgrade its storage replacing the build-in 8GB SSD with a OCZ 60GB mSata SSD and to upgrade the RAM from 1 to 2 GB. I spent around 80 Euro on these, and while not much per se, they count for half of the original price I paid for this machine.

Given the extra space, I decided to install both Windows 7 and Lubuntu. I took care while installing Windows 7 so that it does not create a hidden system partition, and tried first Lubuntu via Wubi which was ok, but later on I decided to give it its own 20GB partition. I disabled pagefile in Windows and swap in Lubuntu. Windows after SP1 and all updated consumed around 9GB, while Lubuntu around 2.4GB (both along with minimal office install).

I used [UNetbootin](http://madebits.com/blog/unetbootin.sourceforge.net/) to make a bootable Windows 7 USB. Windows 7 drivers (32 bit) can be downloaded from Asus [website](http://www.asus.com/Eee/Eee_PC/Eee_PC_X101/#download). I used `Setup.exe` on most of them instead of `AsusSetup.exe`, as usually any software from Asus is not worth it. Windows 7 install went without problems. Lubuntu was more interesting. I have done three Lubuntu installs on this machine: on the original 8GB SSD, via Wubi, and finally on separate partition. In the three cases, Lubuntu installer behaved differently and the end system was slightly differently configured. I had a backup of the original install, so I took some of the settings back from there.

The new SSD is definitively faster. Windows 7 rates it at 7.3 in the performance index (1.0 min – 7.9 max). The numbers below from `sudo hdparm -tT` vary on each run, but they give an idea of the relative performance:

* OCZ Nocti 60GB SSD mSATA
		Timing cached reads:   1448 MB in  2.00 seconds = 724.45 MB/sec
		Timing buffered disk reads: 360 MB in  3.01 seconds = 119.65 MB/sec
* Original Asus 8GB SSD
		Timing cached reads:   1426 MB in  2.00 seconds = 713.59 MB/sec
		Timing buffered disk reads: 136 MB in  3.04 seconds =  44.67 MB/sec
* Class 10 32GB Micro SD Card I use on the same machine
		Timing cached reads:   1396 MB in  2.00 seconds = 697.94 MB/sec
		Timing buffered disk reads:  58 MB in  3.06 seconds =  18.98 MB/sec

These numbers confirm my observation that Asus generally uses low quality storage components on its machines.

Lubuntu starts more or less same fast as before. The new SSD made a huge difference to Windows 7. These are among the fastest startups, shutdowns, and service pack installs of Windows 7 I have seen.

I set a grub background image, by copying an image to `/boot/grub` and then run `sudo update-grub`. For best results use an image size within `640x480` (png or jpg). To get the time to see it :) and may be not only for that, change grub menu timeout by editing `sudo leafpad /etc/default/grub` and set in seconds `GRUB_TIMEOUT=60`. You may need also to comment `#GRUB_HIDDEN_TIMEOUT=0` line.

Additionally, I set `GRUB_DEFAULT=saved` and `GRUB_SAVEDEFAULT=true` to remember the last selected entry, and run `sudo chmod -x /etc/grub.d/20_memtest86+` to remove memtest entries. 
Run `sudo update-grub` again after these changes.

Apart of small issues and the time spent re-installing stuff, in overall, I am quite happy with the upgrade.

<ins class='nfooter'><a id='fprev' href='#blog/2012/2012-11-01-Back-to-Classic-Desktop.md'>Back to Classic Desktop</a> <a id='fnext' href='#blog/2012/2012-09-08-Lubuntu-Toggle-Desktop-Icons-on-Double-Click.md'>Lubuntu Toggle Desktop Icons on Double Click</a></ins>
