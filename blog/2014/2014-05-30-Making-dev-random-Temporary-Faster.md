#Making /dev/random temporary faster

2014-05-30

<!--- tags: linux -->

Reading data from `/dev/random` is usually slow as it checks for enough entropy to be collected. Most software will read from the pseudo-random `/dev/urandom` device which is faster (update: and may be [better](http://sockpuppet.org/blog/2014/02/25/safely-generate-random-numbers/)). Some software will insist reading from `/dev/random`. If we have no direct control over the software, but still want to temporary make the process faster for testing, we can use the `rngd` tool.

To test the normal read speed, run `cat /dev/random` Press `Ctrl+C` when done. Compare the output to the faster `cat /dev/urandom` (again press `Ctrl+C` when done). To make `/dev/random` temporary behave like `/dev/urandom` in case you want to test some software that uses `/dev/random`, without having to wait, install `rng-tools`:

```
sudo apt-get install rng-tools
sudo sh -c "echo 'manual' > /etc/init/rng-tools.override"
```

The second command is necessary to disable `rngd` from auto starting as a system daemon on Ubuntu.

To temporary have `/dev/random` use the faster `/dev/urandom` run:
```
sudo rngd -v -f -r /dev/urandom
```

Now we can test the software fast. Press `Ctrl+C` when done to stop `rngd` in order to revert this temporary change.

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-06-19-Connecting-Acer-Iconia-One-7-on-Lubuntu.md'>Connecting Acer Iconia One 7 on Lubuntu</a> <a id='fnext' href='#blog/2014/2014-05-29-Zenity-GUI-Script-For-TcPlay.md'>Zenity GUI Script For TcPlay</a></ins>
