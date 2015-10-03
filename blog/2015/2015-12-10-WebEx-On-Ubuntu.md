#WebEx On Ubuntu 64 Bit

2015-12-10

<!--- tags: linux -->

[WebEx](http://www.webex.com/) runs ok on Ubuntu 64 bit in Firefox 64 bit, but the integrated audio support requires 32 bit version of the Java plugin (and 32 bit Firefox). I tried the following in Ubuntu 14.04 64 bit based on some [post](http://gazelle.ihe.net/content/using-webex-under-linux) and a Ubuntu [question](https://askubuntu.com/questions/111947/running-32-bit-firefox-with-sun-jre-in-64-bit-ubuntu/202415#202415). To test, [https://www.webex.com/test-meeting.html](https://www.webex.com/test-meeting.html) can be used, or start a real meeting in another device.

##WebEx on Firefox 64 bit

Lets get WebEx work in default Firefox 64 bit first without the integrated audio support. This Firefox 64 bit step needs to be done before, even if you plan to use Firefox 32 bit, as we will see later. Java JRE and its Firefox plugin are needed:

```
sudo apt-get install default-jre icedtea-plugin
```

Start Firefox and visit a WebEx meeting. Allow the Java plugin to run and trust WebEx to access and download content. WebEx will create a folder `$HOME/.webex` with a numerical folder xxxx inside. WebEx plugin will start the meeting, but some features, such as, screen share may not work. WebEx needs several 32 bit libraries to be installed to work properly. Make sure your version of `ldd` command supports 32 bit binaries by installing:

```
sudo apt-get install libgcc1:i386 lib32stdc++6
```

Then install `apt-file` and update its cache:

```
sudo apt-get install apt-file
apt-file update
```

Using `ldd` tool find missing linker dependencies in `*.so` files in `~/.webex/xxxx` folder:

```
ldd *.so | grep -i not
```

Or, for slightly better output use (you can append ` | xargs apt-file search` to automate this command further):

```
ldd *.so | grep -i not | cut -d ' ' -f 1 | uniq | tr -d '\t'
```

Look up the package of each not found `.so` file by using `apt-file search file`. You need to install `:i386` version of the packages, for example:

```
apt-file search libpangox-1.0.so.0
...
sudo apt-get install libpangox-1.0-0:i386
```

Do this for all not found `.so` files, apart of `libjawt.so => not found`. Do **not** install anything for `libjawt.so` - it will be found when the WebEx plugin is run within the browser.

At this point restarting Firefox and joining some WebEx meeting should also support the screen sharing. Only the integrated audio will not work. If you do not need integrated audio, that is all you have to do.

##WebEx with Integrated Audio

WebEx integrated audio will not work in Firefox 64 bit. We need to use the 32 bit version of Firefox. The steps above for Firefox 64 bit have to be done, before you continue (by using 64 bit Firefox as shown above, no need to repeat them for Firefox 32 bit). Look at version of Firefox you have (at this time I have 42.0 build 2) and download from Mozilla [directly](https://ftp.mozilla.org/pub/firefox/releases/) the binaries of this version for Linux 32 bit, and place them in some folder, e.g.: `~/32` (you can use any name):

```
cd
mkdir ~/32
cd ~/32
wget https://ftp.mozilla.org/pub/firefox/releases/42.0b2/linux-i686/en-US/firefox-42.0b2.tar.bz2
tar -xjvf firefox-42.0b2.tar.bz2
rm firefox-42.0b2.tar.bz2
```

You will have now a folder called `~/32/firefox` with the 32 bit Firefox binaries. 

```
file ~/32/firefox/firefox
#/home/d7/32/firefox/firefox: ELF 32-bit ...
```

Next, we need to get latest JRE 32 bit from its [web site](http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html) (for Linux x86). At this time the latest file is called `jre-8u65-linux-i586.tar.gz`. Once you download it in the `~/32` folder extract it, rename its folder to `jre`, and link its Java plugin file to the Firefox 32 bit plugins folder:

```
cd ~/32
tar -xzvf jre-8u65-linux-i586.tar.gz
rm jre-8u65-linux-i586.tar.gz
mv jre1.8.0_65/ jre/ #rename
mkdir -p .mozilla/plugins
ln -sf $PWD/jre/lib/i386/libnpjp2.so $PWD/.mozilla/plugins/
touch f32.sh
chmod +x f32.sh
```

I created also an executable shell file `f32.sh` above. Open `f32.sh` in your favorite text editor and put in the following text: 

```
#!/bin/bash
HOME=/home/$USER/32 /home/$USER/32/firefox/firefox -new-instance
```

The folder structure in `~/32` should look as follows (it is around 300MB in size):

```
.
├── .mozilla/
├── f32.sh
├── firefox/
└── jre/
```

We are almost done. Firefox 32 bit we have will not run in the default 64 bit system because it needs additional library dependencies. The best way to get them is to be bold :) and run these commands:

```
sudo apt-get install firefox:i386
sudo apt-get install firefox
```

The first command will remove Firefox 64 bit from your system and install Firefox 32 bit with its required libraries. The second command will then remove Firefox 32 bit from your system, and install back Firefox 64 bit. The libraries needed to run Firefox 32 bit will, however, remain. Now, you can run your copy of Firefox 32 bit found in the `~/32` folder using:

```
~/32/f32.sh &
```

You may also consider putting `f32.sh` in `~/bin` folder to be able to run it without specifying the path. 

Your 64 bit system is still using Firefox 64 bit for any normal browsing, but when you use the above command a 32 bit Firefox instance will be run, with the 32 bit Java plugin. Use that 32 bit Firefox instance (only) for WebEx. If you join a WebEx meeting in the 32 bit instance, the integrated audio will also work. You can update Firefox and JRE in `~/32` folder as needed in the future (download, uncompress, put to same location).

You may notice that Firefox 32 bit complains when started (logs in console) about possible plugins in `/usr/lib/mozilla/plugins` folder. They are 64 bit plugins and Firefox 32 bit cannot load them. This warning should come only once, and then those plugins will not be used after that. More evolved approaches are possible (e.g., mounting tmpfs on `/usr/lib/mozilla/plugins`), but they add no value in this particular case.

<ins class='nfooter'><a id='fprev' href='#blog/2016/2016-02-03-Bootstrapping-Intercorrelated-Data.md'>Bootstrapping Intercorrelated Data</a> <a id='fnext' href='#blog/2015/2015-11-17-Javascript-Task-Runner.md'>Javascript Task Runner</a></ins>
