#Freecom DVB-T USB Receiver in Lubuntu

2013-11-04

<!--- tags: linux -->

I have an old Freecom DVB-T USB receiver, I bought some years ago and wanted to connect it to my Asus EeePC X101 running Lubuntu 13.10 (32bit).

After connecting the Freecom DVB-T USB receiver and examining `/var/log/syslog` and `dmesg` output, I found it was identified as `WideView WT-220U PenType Receiver (based on ZL353)` with PCI id `14aa:022b`. It needs some specific firmware `dvb-usb-wt220u-zl0353-01.fw` that is part of `linux-firmware-nonfree` package. You may decide to only extract `dvb-usb-wt220u-zl0353-01.fw` from `linux-firmware-nonfree` package and copy it manually as root in `/lib/firmware`, or install `linux-firmware-nonfree` completely (it is not so big).

After installing the firmware, I installed first `me-tv` package. The receiver seemed to work ok, but `me-tv` could only detect 4 of the 12 DVB-T channels they support around here (Wuerzburg).

After reading [wiki.ubuntuusers.de/TV](http://wiki.ubuntuusers.de/TV), I tried first installing `sudo apt-get install w-scan`. `w_scan` found same 4 channels as `me-tv`. Then I tried `scan` tool, part of `dvb-apps` package.
```
scan /usr/share/dvb/dvb-t/de-Bayern > wuerburg-2013-channels.conf
```
It successfully identified all channels (`wuerburg-2013-channels.conf`):

```
ZDF:506000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_1_2:QAM_16:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:545:546:514
3sat:506000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_1_2:QAM_16:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:561:562:515
ZDFinfo:506000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_1_2:QAM_16:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:577:578:516
neo/KiKA:506000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_1_2:QAM_16:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:593:594:517
arte:594000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_1_2:QAM_16:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:33:34:2
Phoenix:594000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_1_2:QAM_16:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:49:50:3
EinsPlus:594000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_1_2:QAM_16:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:97:98:6
Das Erste:594000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_1_2:QAM_16:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:513:514:32
Bayerisches FS Nord:666000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_AUTO:QAM_16:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:529:530:33
BR-alpha:666000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_AUTO:QAM_16:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:561:562:35
hr-fernsehen:666000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_AUTO:QAM_16:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:1041:1042:65
MDR Thüringen:666000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_AUTO:QAM_16:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:1585:1586:99
```

I imported then the channels file in `me-tv` and it worked ok. I removed laterm `me-tv` in favor of  [vlc](http://wiki.ubuntuusers.de/VLC), as I do not want to have too many software programs installed. The channels file can also be used with VLC ("Media / Open File ...", to see channels in the playlist, Ctrl+L). EPG is under "Tools / Program Guide", for TeleText, install `vlc-plugin-zvbi` package. Using "View / Advanced" menu option in VLC, the stream can be recorded (by default in `~/Downloads` folder) as `*.ts` files. `ts` files can be played with VLC back, or converted to normal MPEG files using:

```
ffmpeg -i input.ts -vcodec copy -acodec copy output.mpg
```

Ubuntu will recommend to replace `ffmpeg` with `avconv` - the later is usually faster (by default `ffmpeg` in Ubuntu repos uses only one CPU core). For me `ffmpeg` is a link to avconv.

Update: I installed the stick same in Lubuntu 13.10 64 bit in another machine. I installed only `linux-firmware-nonfree` and `vlc-plugin-zvbi` and created a shortcut to start `vlc wuerburg-2013-channels.conf` (using the previously generated channels file). It worked also fully ok. This is kind of funny as Freecom only offers 32 bit windows drivers for this stick :).

**Update:** It seems `linux-firmware-nonfree` is no more distributed as of Ubuntu 16.04, due to some [conflicts](https://launchpad.net/ubuntu/xenial/amd64/linux-firmware-nonfree/1.16) with `linux-firmware`. The needed firmware for my stick, [dvb-usb-wt220u-zl0353-01.fw](blog/images/dvb-usb-wt220u-zl0353-01.fw) is not problematic. I extracted it from the [deb](http://launchpadlibrarian.net/182181877/linux-firmware-nonfree_1.16_all.deb) file and copied it manually to `/lib/firmware`.


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-11-06-Disabling-ZRAM-in-Lubuntu.md'>Disabling ZRAM in Lubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-11-02-LibreOffice-Preview-Thumbnails-in-PCManFM.md'>LibreOffice Preview Thumbnails in PCManFM</a></ins>
