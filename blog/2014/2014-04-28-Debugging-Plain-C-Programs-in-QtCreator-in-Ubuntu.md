#Debugging Plain C Programs in QtCreator in Ubuntu

2014-04-28

<!--- tags: cpp linux qt -->

It has been a while I had to write C code in Ubuntu and I wanted to see if I could debug plain C programs using [qtcreator](http://en.wikipedia.org/wiki/Qt_Creator) in Lubuntu. I created a simple C (non Qt) console application and tried to build, run, and debug it in qtcreator. Of the three actions, only the first option worked out of the box.

During both run and debug, I got a strange qtcreator error: `Cannot change to working directory '/home/...'`. The error is very misleading and after a lot of googgling, I [found out](http://www.raspberrypi.org/forums/viewtopic.php?f=33&t=11706), it was related to the terminal used. One has to configure `xterm` in qtcreator by going to *"Tools -> Options -> Environment -> Terminal"* and set it to `/usr/bin/xterm -e` (the default is `/usr/bin/x-terminal-emulator -e`). Once this was set, run worked.

For debug, I got then a more helpful error related to `'ptrace: Operation not permitted. ... For more details, see /etc/sysctl.d/10-ptrace.conf'`. It [seems](http://askubuntu.com/questions/41629/after-upgrade-gdb-wont-attach-to-process) for security reasons there are `ptrace` limitations by default on Ubuntu. They can be turned off temporarily using:
```
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
```
The change can be made permanent by editing `/etc/sysctl.d/10-ptrace.conf` to change the value there from 1 to 0.

While qtcreator is somehow a big install (~200MB in Lubuntu), once you have it, it is a nice IDE for C/C++ in Ubuntu, even if you do not need to program Qt interfaces.

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-05-01-Disable-HTML5-Video-in-Chromium.md'>Disable HTML5 Video in Chromium</a> <a id='fnext' href='#blog/2014/2014-04-26-Restoring-Chromium-Configuration-Folder.md'>Restoring Chromium Configuration Folder</a></ins>
