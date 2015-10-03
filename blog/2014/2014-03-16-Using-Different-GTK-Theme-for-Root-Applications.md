#Using a Different GTK Theme for Root Applications in Lubuntu

2014-03-16

<!--- tags: linux -->

I start pcmanfm as root sometimes (via `gksu`) and I wanted it to look different from my normal user one.

After failing to set a different GTK theme manually for root using all possible gtk settings, I found a [hint](http://askubuntu.com/questions/57990/set-a-specific-theme-for-root-launched-applications). One can copy a different GTK root theme (as root) under `/root/.themes` (create folder `.themes` as it does not exist by default), and (the hint) **rename** the theme (folder) same as the default GTK theme set in your normal Lubuntu account.

For example, I downloaded and copied in `/root/.themes the FlatStudioDark` GTK theme, and then renamed (as root) `FlatStudioDark` to `Lubuntu-default` (my user theme).

Summary of the needed commands:
```
sudo mkdir  /root/.themes
sudo cp -r ~/.themes/FlatStudioDark/ /root/.themes/
sudo mv /root/.themes/FlatStudioDark /root/.themes/Lubuntu-default
```
Or as a shorter alternative, these commands do same:
```
sudo mkdir -p /root/.themes/Lubuntu-default
sudo cp -r ~/.themes/FlatStudioDark/* /root/.themes/Lubuntu-default
```
This seems to work ok for gtk widgets and it is a great improvement to better distinguish the root application windows from the normal ones. This technique does not work for Openbox themes as they are X session wide.

For the root specific GTK theme to work, you have to remember to start GUI application as root using `gksu` (or `gksudo`) and not `sudo`, because only `gksu` sets the home folder of the root GUI applications to the `/root` one.
<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-03-17-Custom-PcManFM-Context-Menu-Actions.md'>Custom PcManFM Context Menu Actions</a> <a id='fnext' href='#blog/2014/2014-02-27-Shutting-Down-Lubuntu-from-TV-via-DLNA-using-MediaTomb.md'>Shutting Down Lubuntu from TV via DLNA using MediaTomb</a></ins>
