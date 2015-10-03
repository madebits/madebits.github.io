#Changing SSH Port on Lubuntu

2013-11-25

<!--- tags: linux -->

Short guide on how to change the OpenSSH Port on (L)Ubuntu and configure access. OpenSSH (`sshd`) listens by default on port `22` (tcp only). To check listening services use: `sudo netstat -lnptu`:

```
...
tcp        0      0 0.0.0.0:22           0.0.0.0:*               LISTEN      7812/sshd 
...
tcp6       0      0 :::22                :::*                    LISTEN      7812/sshd  
...
```

To change the `sshd` port, edit as root (sudo) `/etc/ssh/sshd_config` and specify the new port, for example, `4444`:

```
# What ports, IPs and protocols we listen for
#Port 22
Port 4444
```

`sshd` service must then be restarted with:
```
sudo service ssh restart
```

To open the firewall (`ufw`) for the new port, first remove any existing `sshd` rules if any:
```
sudo ufw delete allow 22/tcp
```
* **Strategy 1:** Allow all devices in local network to have access, apart of some. For example, if I do not trust my router 192.168.0.1 and my TV 192.168.0.115, I can deny them and allow the rest of the local network:
	```
	sudo ufw deny from 192.168.0.1 to any port 4444
	sudo ufw deny from 192.168.0.115 to any port 4444
	sudo ufw allow from 192.168.0.0/24 to any port 4444 proto tcp
	```
	The deny rule [must be](http://ubuntuforums.org/showthread.php?t=823741) first. To delete the rules, in case you want to change them later, use delete before deny or allow with the rest of commands as shown above.

* **Strategy 2:** A better alternative is only to explicitly allow machines that should have access (and deny the rest - that is the default for any incoming, no need to change anything for that). This could be also easier to maintain.
	```
	#allow only from 192.168.0.131 and 192.168.0.124
	sudo ufw allow from 192.168.0.131 to any port 4444 proto tcp
	sudo ufw allow from 192.168.0.124 to any port 4444 proto tcp
	#default for incoming is deny
	```

To check the set rules use:
```
sudo ufw status verbose
```
If you are using [Fail2ban](https://help.ubuntu.com/community/Fail2ban), edit `/etc/fail2ban/jail.local` file to change the `sshd` monitored port there too - in the `[ssh]` section from `port = ssh` to `port = 4444` (a restart is needed after this).

Now you can access sshd from another client machine (localhost test):
```
ssh user@localhost -port 4444
```
In pcmanfm, to browse files, the port can be specified as follows in the address bar: `sftp://localhost:4444/`

To see the sshd (access) log in Ubuntu:

```
grep "sshd" /var/log/auth.log | less
```


<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-11-28-Getting-Started-with-Sublime-Text.md'>Getting Started with Sublime Text</a> <a id='fnext' href='#blog/2013/2013-11-14-Getting-Started-with-Qt-and-PySide-on-Ubuntu.md'>Getting Started with Qt and PySide on Ubuntu</a></ins>
