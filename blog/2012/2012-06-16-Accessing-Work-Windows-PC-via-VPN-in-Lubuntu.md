#Accessing Work Windows PC via VPN in Lubuntu

2012-06-16

<!--- tags: linux -->

To access my work PC from home, I use a Cisco client for Windows I am given by IT. Sometimes, I need to do something quickly from home and booting Windows only for that is not very practical.

To be able to use it from Lubuntu, I had to install first VPN support by installing a Cisco compatible VPN client:

```
sudo apt-get install network-manager-vpnc vpnc
```
This enables Cisco VPN in Lubuntu Network Manager and I used it to add a new connection.

I am given a Cisco client for Window by our IT, together with a `*.pcf` file. VPN manager in Lubuntu can import that file, but the connection never success.

After several tries, I tried to localize the problem. The encrypted group password somehow could not be read. It was shown as saved in Network Manager, but it was not in the GNOME keyring file.

Some [public](http://jmatrix.net/dao/case/case.jsp?case=7F000001-933BCB-10901BBA2D1-C1E) [source code](http://www.unix-ag.uni-kl.de/~massar/bin/cisco-decode) exists to read Cisco passwords. I was able to use it compiled locally to get the plain group password from the file.

Using the plain group password and fine tuning some of the parameters by trial and error, I got a connection to my work VPN.

In Lubuntu, I could not get it to remember the group password in key ring. To [fix](http://deanproxy.com/blog/posts/2012/03/9-how-to-save-vpn-passwords-with-networkmanger.html) this, I opened the created vpn configuration file in `/etc/NetworkManager/system-connections` folder and added:

```
...
[vpn]
IPSec secret-flags=0
...

[vpn-secrets]
IPSec secret=grouppassword
```

One can also set the user password using: `Xauth password=mypassword` and by setting in `[vpn]` section: `Xauth password-flags=0`, but I did not do this. I prefer to enter the user password manually when needed.

Optionally, to resolve windows machine names I installed: `sudo apt-get install winbind` and edited (as root) `/etc/nsswitch.conf` to add `wins` to hosts line:
```
hosts:          files dns wins
```
Whether you add `wins` before or after `dns` is a matter of what protocol you prefer to access and resolve the name first.

Next install `rdesktop`. In Lubuntu, it comes as part of `grdesktop` is a GNOME front-end for the remote desktop client (`rdesktop`), which I installed at first, but the GUI is not really useful. It is better to use `rdesktop` directly via the command-line (replace `domain` and `user` with real domain and user name and `000.000.000.000` with the PC ip - which I got using `ipconfig` after a Window VPN session, the `-k de` sets the layout for my German keyboard).

```
rdesktop -r sound:local -r disk:home=/home/user/wrdesktop -r clipboard:CLIPBOARD -d domain -u user -fP 000.000.000.000 -p - -k de
```
`-r disk:home` creates `\\tsclient\home` in the remote server to point to the local shown folder. I created a desktop shortcut with the above and now after VPN connection, I can connect to the remote terminal desktop easy by clicking from GUI.

Update: I found recently `rdesktop` hangs for me time after time. I tried an alternative `sudo apt-get install freerdp-x11` that seems to work better:
```
xfreerdp -g 1920x1080 -u user --no-nla -z --plugin cliprdr --plugin rdpsnd --plugin rdpdr --data disk:home:/home/user/wrdesktop -- 000.000.000.000
```
This command is more or less same as the `rdesktop` one above.


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2012/2012-06-17-Connecting-Lubuntu-and-Windows-Machines-at-Home-Network.md'>Connecting Lubuntu and Windows Machines at Home Network</a> <a rel='next' id='fnext' href='#blog/2012/2012-06-09-Encrypted-Google-in-English.md'>Encrypted Google in English</a></ins>
