#Connecting Lubuntu and Windows Machines at Home Network

2012-06-17 

<!--- tags: linux -->

List of common commands and software to access Lubuntu Linux and Windows machines from each other in home LAN.

* To see your own machine network details use:
		ifconfig
	You will see you network interfaces (cards) and their IP addresses and other interesting data, such as bytes received and sent and broadcast address. On a Windows machine use `ipconfig`.

* To find your own host name use:
		hostname
* To see the gateway and the router address use:
		route -v
		arp -a
	Or in shorter form:
		route -n
	Usually the router is located by default at `192.168.0.1`, but it can be also be configured to be at another address (in my case `192.168.2.1`).
* To find out other machines connected in network install `sudo apt-get install nmap` and try out:
		nmap -sP 192.168.2.1-254
	If your machines double-boot and you want to find the OS for one of them try:
		sudo nmap -O 192.168.2.106
	To see windows netbios machine names (for the found IPs of nmap) install `sudo apt-get install nbtscan` and try:
		nbtscan 192.168.2.1-254
	This only lists netbios windows machines.
* To see the hostname of a Linux machine, given you know the user / password to connect to it use:
		ssh vasian@192.168.2.106 hostname
* This assumes ssh server is running on remate machine (install it using `sudo apt-get install openssh-server`).
* If have installed samba (using `sudo apt-get install samba samba-common` and optionally its GUI config tool `sudo apt-get install system-config-samba`), you can see another's Linux machine name using:
		nmblookup -A 192.168.2.106
* If you have samba installed (alternatively, just install `sudo apt-get install winbind`) and want to use netbios names, instead of IPs, a nice trick is do add `wins` to hosts: entry in `/etc/nsswitch.conf`. Whether you add wins before or after dns is a matter of what protocol you prefer to access and resolve the name first.
* To check if DLNA/UPnP (`mediatomb`) is running on a given machine (port 1900) use:
		sudo nmap -sU -p1900 192.168.2.106
* To access files on remote machine running ssh server (open-ssh) use SFTP with its address, eg.: `sftp://192.168.2.106/` in pcmanfm address box (command-line alternative `sftp vasian@192.168.2.106`).
* To access files on a remote Windows (samba) machine use it smb address is pcmanfm, eg.: smb://speedport.ip/All. Lubuntu clients can access shares via pcmanfm (Go / Network Drives menu, Bookmark it as needed).
* To connect to a windows machine using remote desktop try (install first `sudo apt-get install rdesktop`):
		rdesktop -r sound:local -u vasian -fP 192.168.2.104 -k de
	Other useful options are `-d DOMAIN` to specify the domain, and `-p -` to ask locally for the password. To toggle fullscreen use `Ctrl+Alt+Enter`. An alternative to `rdesktop` is `sudo apt-get install freerdp-x11` and then use: 
		xfreerdp -g 1920x1080 -u vasian --no-nla -z --plugin cliprdr --plugin rdpsnd --plugin rdpdr -- 192.168.2.104
* To access the shell in another Linux machine use (`-X` enables starting GUI apps from there too):
		ssh -X vasian@192.168.2.106
* From a Windows machine use [putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) to use a Lubuntu machine via ssh. Putty can also do SFTP, or use some other Windows client, such as [WinSCP](http://winscp.net/eng/index.php).
* To access desktop GUI on a remote Lubuntu machine a VNC server is required. They slightly change on what they offer, how easy are to use, and whether you can have a remote desktop without a local login (desktop share) or not.

	For example, to start `x11vnc` remotely via `ssh`:
		ssh -t -L 5900:localhost:5900 vasian@192.168.2.103 'x11vnc -localhost -display :0'
	To start `x11vnc` remotely, even if the remote user is not yet logged in, the following worked for me to set `MIT-MAGIC-COOKIE` for `lightdm` (found with `ps wwaux | grep auth`):
		ssh -t -L 5900:localhost:5900 vasian@192.168.2.106 'sudo x11vnc -localhost -display :0 -auth /var/run/lightdm/root/:0'
	You need to enter the log in and the sudo password.
* As VNC client install `sudo apt-get install xtightvncviewer`.
	If you start `x11vnc` server remotely and redirect its port via `ssh` to localhost as shown above use:

		vncviewer -fullscreen localhost
	Before you try out the fullscreen option, the following commands must be run once (as `sudo -i`):

		echo "Vncviewer*grabKeyboard: true" > /etc/X11/Xresources/xtightvncviewer
		xrdb -merge /etc/X11/Xresources/xtightvncviewer
	This activates `F8` key to exit fullscreen. If it does not work, `kill x11vnc` in remote machine to exit fullscreen mode.

	To access a VNC server without going via `ssh` use any of (`::port`):
		vncviewer 192.168.2.106
		vncviewer 192.168.2.106::5900
* `x11vnc` will connect to the remote physical desktop. To connect via VNC using a remote virtual X11 session use `Xvnc`. To do so install first in Lubuntu server machine: `sudo apt-get install vnc4server`

	From the Lubuntu client machine, start first a `ssh` session, then from within the `ssh` session start `Xvnc` and leave the ssh session terminal open:

		ssh -C -t -L 5901:localhost:5901 vasian@192.168.2.106
		vncserver :1 -localhost -geometry 1024x600 -depth 24
	You will be asked to set a password the first time you run `vncserver` command (can be changed using `vncpasswd`). You can use any other display number (>0) instead `:1` if that one is in use. The port to use with `ssh -L` is `5900 + display number`''

	On another terminal in client run:

		vncviewer -fullscreen :1
	`:1` is the display number used before with `vncserver`. You will be asked to provide the VNC password set before.

	When done, kill the vnc server on ssh session terminal and exit the ssh session.

		vncserver -kill :1
		exit
	While the default Xvnc setup may be enough, you can start the your default desktop either by editing `~/.vnc/xstartup` and adding to the end of it in its own line: `startlubuntu &`, or by typing and running same command on the terminal. When done save any work and then just exit as before (do not use Logout menu).
* To access the desktop GUI on a remote Lubuntu machine running a VNC server from Windows, use RealVNC (it is free, but you have to register).
* Xnest is an alternative to using a remove X11 virtual desktop via Xvnc. It kind of worked for me, but leaved the server machine in a very unstable state, so I cannot recommend it. If you want to try it out, install it on the Lubuntu server machine: `sudo apt-get install xnest`. From a Lubuntu client ssh to server `ssh -X vasian@192.168.2.106` and then run:

		Xnest :1 -ac -geometry 1024x600 -once -query localhost &
		DISPLAY=:1
		startlubuntu &
	Or replace `startlubuntu &` with any of these combinations:
		openbox &
		/usr/bin/lxsession -s Lubuntu -e LXDE &
	or
		x-window-manager &
		/usr/bin/lxsession -s Lubuntu -e LXDE &
* PcManFm can handle `sftp://`, `ftp://` and `smb://` URLs. To access Windows (and samba) shares, just browse to them, or enter the `smb://` address. To share folders with Windows machines install samba (and use the GUI to share locations):
		sudo apt-get install samba samba-common system-config-samba

<ins class='nfooter'><a id='fprev' href='#blog/2012/2012-07-19-Changing-FAT32-SD-Card-Mount-Permissions.md'>Changing FAT32 SD Card Mount Permissions</a> <a id='fnext' href='#blog/2012/2012-06-16-Accessing-Work-Windows-PC-via-VPN-in-Lubuntu.md'>Accessing Work Windows PC via VPN in Lubuntu</a></ins>
