#Upgrading to Lubuntu 16.04.1

2016-07-30

<!--- tags: linux -->

I upgraded my machines at home from Lubuntu 14.04 LTS to 16.04.1 LTS. I waited until the new version was offered via the *Software Updater* tool. The update process went mostly quite well:

* I was left without network access after install. I had played once with `dnscrypt-proxy` and `dnsmasq` and they were activated as services by `systemd`. I had to remove them both and restart to be able to use my current network configuration.
* Pulseaudio did not work and volume settings were unreachable. I happen to have run to this [issue](https://askubuntu.com/questions/23018/revert-audio-configuration-to-defaults) before (when installing 15.10 in a virtual machine), so I knew I had to clean `~/.config/pulse` folder. I had also to [restart](https://askubuntu.com/questions/15223/how-can-i-restart-pulseaudio-without-logout) pulseaudio using `pulseaudio -k`. I am affected also from some [issue](https://firejail.wordpress.com/support/known-problems/#pulseaudio) related to share memory [usage](https://bugs.freedesktop.org/show_bug.cgi?id=92141).
* Dropbox icon was not showing. As a [workaround](https://askubuntu.com/questions/732967/dropbox-icon-is-not-working-xubuntu-14-04-lts-64) I created a small script to start it as: `DBUS_SESSION_BUS_ADDRESS="" $HOME/.dropbox-dist/dropboxd`.
* `virtualbox` key has been [changed](https://askubuntu.com/questions/768569/ubuntu-16-04-update-manager-error) and I had to remove the old key using `sudo apt-key list` and `sudo apt-key del 1024D/98AB5139`, and installed the new [key](https://www.virtualbox.org/wiki/Linux_Downloads). After this, I could update `virtualbox` to version 5.1.
* `php` is silently removed and I had to install the new version `sudo apt install php7.0-cli`.
* `leafpad` seems to have a bug in this version. When saving `smb://` files you are left silently with empty files. SublimeText and `geany` both seem to work fine as replacements. `gedit` can also be used in Lubuntu in this release, as its dependencies to other Ubuntu stuff has been moved now to plugins.
* KeePass has been updated to the safer KeePassX 2 and old files need to be imported and converted.
* In one machine, I run into an `_apt` user permission [issue](https://bugs.launchpad.net/ubuntu/+source/aptitude/+bug/1543280) and had to use the workaround specified there.
* As a user of `gnome-terminal` I had to [search](https://askubuntu.com/questions/613465/upgrade-to-15-04-what-happened-to-my-gnome-terminal-tabs) where open new tab option was gone.
* I kept a copy of all configuration file diffs shown during install, and accepted all new versions. After install, I went through the diffs and took over any previous settings I still needed.
* After installation, I updated the few ppa-s I use, and did an update.

My final version:

```
cat /etc/*release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=16.04
DISTRIB_CODENAME=xenial
DISTRIB_DESCRIPTION="Ubuntu 16.04.1 LTS"
NAME="Ubuntu"
VERSION="16.04.1 LTS (Xenial Xerus)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 16.04.1 LTS"
VERSION_ID="16.04"
HOME_URL="http://www.ubuntu.com/"
SUPPORT_URL="http://help.ubuntu.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
UBUNTU_CODENAME=xenial
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-08-01-Machine-Learning-with-Spark-Readings.md'>Machine Learning with Spark Readings</a> <a rel='next' id='fnext' href='#blog/2016/2016-07-27-Using-keynav-to-move-mouse-pointer-on-Lubuntu.md'>Using keynav to move mouse pointer on Lubuntu</a></ins>
