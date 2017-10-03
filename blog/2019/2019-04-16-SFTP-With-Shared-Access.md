# SFTP With Shared Access

2019-04-16

<!--- tags: linux devops -->

We want to set up a `shared` SFTP folder jailed within `/data/jail` directory in Ubuntu server. 

## Common Shared Folder Users

First create an SFTP only user group to restrict access:

```bash
sudo groupadd sftponly
```

Once the user group is there, we can create as many SFTP only users as we like using:

```bash
sudo adduser sftpuser001 --ingroup sftponly --shell /usr/sbin/nologin --home /data/jail/shared --no-create-home
```

All such users are assigned same home folder.

Lets make sure we have the needed folders in place. All folders that lead to *shared* folder need to be owned by *root* and have mode *755*, if not use these commands:

```bash
sudo mkdir -p /data/jail/shared
sudo chown root:root /data
sudo chmod 755 /data
sudo chown root:root /data/jail
sudo chmod 755 /data/jail
```

The *shared* folder need to owned by *root*, but belong to group *sftponly*:

```bash
sudo chown root:sftponly /data/jail/shared
sudo chmod 775 /data/jail/shared
```

To configure `openssh`, edit `/etc/ssh/sshd_config` and add (after *Subsystem sftp*):

```
Subsystem sftp /usr/lib/openssh/sftp-server
#Subsystem sftp internal-sftp

   Match Group sftpdev
   ChrootDirectory /data/jail
   ForceCommand internal-sftp -u 002
   X11Forwarding no
   AllowTcpForwarding no
   PermitOpen none
   PermitTunnel no
   Match all
```

A few things to notice here, there is no need for *Subsystem sftp internal-sftp* (I have commented it out), and the *umask* 002 is used to allow users to access each others files. 

Once done, we need to restart ssh daemon:

```bash
# optional, test config
sudo sshd -t
# restart, use status in case of errors
sudo systemctl restart sshd
```

To test the configuration, we can use:

```bash
sftp -vvv sftpuser001@localhost
ssh -vvv sftpuser001@localhost 
tail -f /var/log/auth.log
tail f- /var/log/syslog
```

Some [tutorials](https://wiki.archlinux.org/index.php/SFTP_chroot) show an additional step to `mount -o bind` jail folder to another one and use that in SFTP / user home configuration. That is not needed, but may add an extra level of `chroot` security.

## Home Only Users

Similarly, assuming we have another `sftphome` group for users that need access to their $HOME only via SFTP, we could add to configuration:

```
   Match Group sftphome
   ChrootDirectory %h
   ForceCommand internal-sftp
   X11Forwarding no
   AllowTcpForwarding no
   PermitOpen none
   PermitTunnel no
   Match all
```

For home only *user*s, the permissions on their folders needs to be:

```
sudo chown root:root /home/user
sudo chmod 755 /home/user 

sudo mkdir -p /home/user/public
sudo chown root:sftphome /home/user/public
sudo chmod 775 /home/user/public
```

We have to be careful to also set *nologin* shell for such home users (or [use](https://askubuntu.com/questions/49271/how-to-setup-a-sftp-server-with-users-chrooted-in-their-home-directories) `AllowGroups`).

It is also a good idea to set file-system [quotas](https://www.digitalocean.com/community/tutorials/how-to-set-filesystem-quotas-on-ubuntu-18-04) for STFP users.

## Ssh Host FingerPrint

To find SSH host finger print we can use:

```
ssh-keyscan localhost 2>/dev/null | ssh-keygen -E md5 -lf -
```

When clients connect first time they will be asked to verify the server fingerprint and we can share the shown server SSH fingerprints with users upfront.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2019/2019-03-25-MongoDb-with-SSL.md'>MongoDb with SSL</a></ins>
