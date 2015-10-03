#Shutdown Ubuntu Every Night

2014-01-26

<!--- tags: linux -->

As a reference for myself: To shutdown my (L)Ubuntu machine everyday at 01:00 AM, in case I forget to turn it off manually before, I edited `sudo leafpad /etc/crontab` and added in the end of it:

```
0 1 * * * root /sbin/shutdown -h now
```

This `/etc/crontab` command will run as root, so no explicit `sudo` permissions are needed. I tested the entry before with another cron time to make sure it works. No restart is needed if you edit `/etc/crontab`, the changes are applied immediately.

Update: I got [surprised](http://unix.stackexchange.com/questions/9819/how-to-find-out-from-the-logs-what-caused-system-shutdown) (`last -x | less`) by this command one day while doing a git push at 01:00 AM :). It gives you no chance, the machine goes down almost immediately - but given it is a rare event for me to work so late, it is not worth to optimize it.

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-01-30-Bash-Cycle-Through-Autocomplete-Options.md'>Bash Cycle Through Autocomplete Options</a> <a id='fnext' href='#blog/2014/2014-01-25-Getting-Started-with-GNU-PG.md'>Getting Started with GNU PG</a></ins>
