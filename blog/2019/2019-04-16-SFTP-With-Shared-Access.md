# SFTP With Shared Access

2019-04-16

<!--- tags: linux devops -->

We want to set up a `shared` SFTP folder jailed within `/data/jail` directory in Ubuntu server. First create an SFTP only user group to restrict access:

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

A few things to notice here, there is no need for *Subsystem sftp internal-sftp* (I have commented it out), and the *umask* 002 is used to allow users to access each others files. Once done, we need to restart ssh daemon:

```bash
sudo systemctl restart sshd
```

To test the configuration, we can use:

```bash
sftp sftpuser001@localhost 
tail -f /var/log/auth.log
```

Some [tutorials](https://wiki.archlinux.org/index.php/SFTP_chroot) show an additional step to `mount -o bind` jail folder to another one and use that in SFTP / user home configuration. That is not needed, but may add an extra level of `chroot` security.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2019/2019-03-25-MongoDb-with-SSL.md'>MongoDb with SSL</a></ins>
