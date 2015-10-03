#Fully Remove Installed Packages in Lubuntu

2012-08-25

<!--- tags: linux -->

I found it hard to fully uninstall installed packages on Lubuntu. By default `apt-get remove` only removes the named package. To completely remove installed packages use (`packagenames` below is the list of package names to remove separated by space):

```
sudo apt-get remove --purge --auto-remove packagenames
```

This full `apt-get remove` removes most of the time all files that were installed (I know there are synonyms for some of these options, but only in this form it works as I want for me).

Sometimes even the above is not enough. In these cases, the log of installed packages in `/var/lib/dpkg/info` folder can be used. The folder lists log files named after the modified (installed) packages. If you know when you approximately installed something then you have a chance to fully remove it. This is normally useful to me when I install some software and then I find out (using `df -h`) that it took more space during install than reported. Then I use `/var/lib/dpkg/info` logs immediately to properly remove all installed packages. You can look at the files on that folder listed by date:

```
ls -lt /var/lib/dpkg/info | less
```

Or use `find` to list only files modified for example in last 30 minutes:
```
find /var/lib/dpkg/info -type f -mmin -1000 -printf "%T+\t%f\n" | sort -r
```
Make sure you only identify only the packages modified recently (within the time frame you did the install). The package log files are named something like (example only): `touchpad-indicator.list` `icedtea-netx:amd64.list`. From these file names you only need the full part, as it is the package name (e.g., `touchpad-indicator` `icedtea-netx`). Once you have identified the packages to remove, you can uninstall them using same full `apt-get remov`e command as shown above.

Installed package files are also cached locally. They are not removed by the above. To clean them use `sudo apt-get clean` (or use `bleachbit` as root). To remove any non-removed dependencies left use `sudo apt-get autoremove` (`bleachbit` as root can do this too). autoremove is not to be always trusted. For best results additionally to autoremove, install `deborphan` and run it. After that, use same full `apt-get remove` as shown above to remove any packages listed by `deborphan`.

To remove packages installed using `GDebi`, look as above for last added packages and remove them using `sudo dpkg -P package`.


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2012/2012-08-30-Reading-a-Text-File-from-Command-line-in-Windows.md'>Reading a Text File from Command line in Windows</a> <a rel='next' id='fnext' href='#blog/2012/2012-08-21-Disable-History-in-Lubuntu.md'>Disable History in Lubuntu</a></ins>
