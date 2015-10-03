#Software to Install on Lubuntu

<!--- tags: linux -->

2012-06-06

* arandr - screen size set up
* asunder - cp ripper
* bleachbit - file cleaner
* bum - boot-up manager, for advanced edit of startup programs.
* catfish - search for files
* chromium-browser
* deborphan - to see packages that can be safely removed. Look at `/var/lib/dpkg/info` for the date of installed packages, to undo some heavy wrong installs
* default-jdk - Java
* d-feet - dbus viewer
* ding - cool de-en local dictionary. I added an application shortcut manually for it
* eog (eye of gnome) - image viewer
* etherape - network monitor
* fbreader - a simple ebook reader. Enter key activates fullscreen.
* filezilla - ftp client that works (mostly)
* firefox
* [fonts](http://ubuntuforums.org/showthread.php?t=2027331) install in `/usr/share/fonts/truetype/` and run `sudo fc-cache -f -v` to update font cache.
* geany - text editor
* ghex - simple hex editor
* gimp - the image editor
* glchess
* gnome-alsamixer - not really needed, but a menu in sound is not working without it
* gnome-system-log gnome-screenshot baobab - part of gnome utils
* gnome-terminal
* gnomine
* gparted - disk manager
* gthumb - image viewer
* gufw - firewall ui
* gufw - simple firewall configuration
* htop - like top
* inkscape - vector image editor
* keepassx - to store passwords
* kupfer - start programs via keyboard
* libreoffice-calc
* libreoffice-impress
* libreoffice-writer
* localepurge - to clean up unused locales
* lubuntu-restricted-extras
* lxproxy - to manage proxy settings - no more available
* meld - to compare files (small)
* mediatomb - stream content to my TV. Default mediatomb firewall rules:
		sudo ufw allow 1900/tcp
		sudo ufw allow 1900/udp
		sudo ufw allow 49152/tcp
		sudo ufw allow 49152/udp
* network-manager-openvpn - for open vpn
* network-manager-pptp - for pptp vpn
* network-manager-vpnc vpnc - Cicso compatible vpn to access my work pc
* pidgin extended preferences plugin - to change font size
* pinta – image manipulation tool - this has a dependency on mono (~20MB)
* qpdfview - pdf viewer
* radiotray - I like it, put a link to /home/vasian/.config/autostart, but I stop it when running on battery.
* seahorse - manage keyrings
* [skype](https://help.ubuntu.com/community/Lubuntu/Documentation/FAQ/Guides#How_to_install_Skype) - the notebook has a build-in camera and microphone
* speedcrunch - calculator
* supertuxkart - game for kids
* [touchpad-indicator](https://help.ubuntu.com/community/SynapticsTouchpad)
		sudo add-apt-repository ppa:atareao/atareao
		sudo apt-get update
		sudo apt-get install touchpad-indicator
* TrueCrypt (or tcplay) - create encrypted containers via gui
* ttf-mscorefonts - fonts
* tuxpaint-config - to easy set full screen mode for Tux Paint.
* tuxpaint - for kids
* vim-gtk - gvim
* virtualbox
* vlc – to be able to access local UPnP/DLNA streams
* xchm - chm viewer
* xmahjong
* youtube-dl - watch youtube videos offline
* zim - Desktop Wiki to keep notes

##Links

* http://community.linuxmint.com/software
* http://www.jacknjoe.com/


<ins class='nfooter'><a id='fprev' href='#blog/2012/2012-06-09-Encrypted-Google-in-English.md'>Encrypted Google in English</a> <a id='fnext' href='#blog/2012/2012-06-05-CSharp--Reflection-ExtendedActivator.md'>CSharp  Reflection ExtendedActivator</a></ins>
