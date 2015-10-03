#Ubuntu Block Application Internet Access

2017-05-09

<!--- tags: linux -->

This TIL (today I learned) post is based on an `iptables` [trick](https://ubuntuforums.org/archive/index.php/t-1188099.html) to disable Internet access for some specific application. Create a new group (e.g: named `no-internet`) and filter out traffic based on that group. Start applications with blocked Internet access as that group (via `sg`):

```
sudo groupadd -g 1999 no-internet
sudo usermod -aG no-internet `id -un`

#re-login may be needed

sudo iptables -I OUTPUT -o lo -m owner --gid-owner no-internet -j ACCEPT
sudo iptables -I OUTPUT -m owner --gid-owner no-internet -m limit --limit 30/min -j LOG --log-prefix "No-Internet: "
sudo iptables -I OUTPUT -m owner --gid-owner no-internet -j DROP

# use sg command to start apps, you can make an alias out of this

sg no-internet firefox

# then in a new terminal monitor Internet access

journalctl -kf | grep No-Internet
```

I log the dropped requests with *No-Internet* prefix, so that it is easy to filter them out using `journalctl -kf | grep No-Internet`. If case of `firefox`, these are mostly DNS lookups on port 53 that fail. I limited the logs frequency, but you may like to remove the `-m limit --limit 30/min` part for more fun with logs. Requests to local interface `lo` are allowed.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2017/2017-05-16-The-New-Docker.md'>The New Docker</a> <a rel='next' id='fnext' href='#blog/2017/2017-05-07-Windows-10-on-Virt-Manager.md'>Windows 10 on Virt Manager</a></ins>
