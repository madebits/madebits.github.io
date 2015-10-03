#Lubuntu on Dell Latitude E5570

2016-12-30

<!--- tags: linux -->

I use a Dell Latitude E5570 machine (i7-6820HQ at 2.7Gz and 16 GB RAM) with Windows 10 and wanted to have a possibility to run Lubuntu on it via an external USB. 

##Installation

Boot menu on this machine is accessible via `F12` key, and BIOS via `F2` key. I installed Lubuntu 16.10 in a *SanDisk Extreme* 64 GB USB stick connected to one of USB 3.0 ports. I was somehow unlucky with the install, as I run into two issues - [first](http://askubuntu.com/questions/689595/bootloader-install-failed) was caused by the way I created the install USB, and second related to disk being formatted for a previous install attempt. This made me spent more time that I though to install Lubuntu, as I had to figure out what was happening. After trial and error, finally Lubuntu run from the external USB. USB stick is quite fast:

```bash
$ dd bs=2M count=512 if=/dev/zero of=test1 conv=fdatasync
...
1073741824 bytes (1,1 GB, 1,0 GiB) copied, 5,97716 s, 180 MB/s
```

After I installed all core software I need (and a VM), I still have plenty of space left:

```bash
$ df -h | grep -E "sdb|Avail"
Filesystem         Size  Used Avail Use% Mounted on
/dev/sdb1           58G   12G   46G  21% /
```

##Startup

I get some issues reported at startup, which I had [no](https://bugzilla.kernel.org/show_bug.cgi?id=107381) time to loop up what they mean yet:

```bash
u7@vm-l10:~/git/madebits.github.io$ dmesg | grep -iE "failed|error"
[    1.864524] radeon 0000:01:00.0: failed VCE resume (-110).
[   10.115169] EXT4-fs (sdb1): re-mounted. Opts: errors=remount-ro
[   10.337342] int3403 thermal: probe of INT3403:02 failed with error -22
[   10.542047] dell_laptop: Setting old previous keyboard state failed
[   10.607802] iwlwifi 0000:02:00.0: Direct firmware load for iwlwifi-8000C-24.ucode failed with error -2
[   10.607827] iwlwifi 0000:02:00.0: Direct firmware load for iwlwifi-8000C-23.ucode failed with error -2
[   10.622297] iwlwifi 0000:02:00.0: Direct firmware load for iwlwifi-8000C-22.ucode failed with error -2
[   11.005477] thermal thermal_zone6: failed to read out thermal zone (-5)
[   11.568827] radeon 0000:01:00.0: failed VCE resume (-110).
[   13.122759] Bluetooth: hci0: Setting Intel event mask failed (-16)
```

Lubuntu seems to run ok and all the hardware is working. There is nothing that requires immediate attention.

##TouchPad

TouchPad is [not](https://bugzilla.kernel.org/show_bug.cgi?id=121281) a Synaptic one:

```bash
$ xinput list
⎡ Virtual core pointer                      id=2    [master pointer  (3)]
...
⎜   ↳ ImPS/2 BYD TouchPad                       id=13   [slave  pointer  (2)]
```

The basic functionality seems to work fine, but I am not a big user of touchpad, so I disabled it at `~/.config/lxsession/Lubuntu/autostart`:

```
@xinput disable 'ImPS/2 BYD TouchPad'
```

##Graphics

The device has both Intel and ATI graphics:

```bash
$ lspci | grep -iE "vga|display"
00:02.0 VGA compatible controller: Intel Corporation HD Graphics 530 (rev 06)
01:00.0 Display controller: Advanced Micro Devices, Inc. [AMD/ATI] Mars [Radeon HD 8670A/8670M/8750M] (rev 81)
```

It seems, the Intel GPU is used. There is sometimes video tearing on the top of the screen in fullscreen mode in Chrome browser, but given it is rate, at the moment, I can live with that.

##Battery

Battery lasts around 3-4 hours with [TLP](http://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html) active (with default settings). This is somehow more that the battery lasts on Windows 10, but this could be related to the different applications and the screen brightness.

##Time

My dual-boot was affected by the different ways Ubuntu and Windows interpret time zone of the bios time. To [fix](http://askubuntu.com/questions/169376/clock-time-is-off-on-dual-boot) that I had to run in Ubuntu:

```bash
$ sudo timedatectl set-local-rtc 1
$ timedatectl | grep local
 RTC in local TZ: yes
Warning: The system is configured to read the RTC time in the local time zone.
         'timedatectl set-local-rtc 0'.
```

The output of grep also shows how to undo this if ever needed.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2016/2016-12-24-Ubuntu-Chromium-Flags-Per-User.md'>Ubuntu Chromium Flags Per User</a></ins>
