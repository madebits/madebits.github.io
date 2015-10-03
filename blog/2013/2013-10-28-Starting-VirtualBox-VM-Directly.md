#Starting a VirtualBox VM Directly

2013-10-28

<!--- tags: virtualization -->

To get a list of VirtualBox virtual machines in Lubuntu [use](https://www.virtualbox.org/manual/ch08.html):

```
$ vboxmanage list vms
"WinXP" {f730aa4a-22f0-4723-a0a2-682cedb4be54}
```

For each vm, the above command lists the vm name and its id. Then create a shell script, e.g., `~/bin/xpstart.sh` with these data:

```
#!/bin/bash

vboxmanage setextradata "WinXP" GUI/Seamless on
vboxmanage startvm f730aa4a-22f0-4723-a0a2-682cedb4be54
```

Here, I start my Windows XP vm is *seamless* mode. You can use either the vm name or its id with startvm. 

Finally, I created a `xpstart.desktop` shortcut in my desktop:
```
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=WinXP
Icon=background
Exec=/home/user/bin/xpstart.sh
```

Inside the vm in Windows XP, I set the autohide for the taskbar of Windows XP, so that the taskbar is not shown, and put my preferred applications to auto start my adding shortcut links to Startup folder. So now, when I start the vm via the above desktop shortcut in Lubuntu, after a while I have my XP applications open in the seamless mode in my Lubuntu desktop screen.

<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-11-01-ArchiveMount-in-Lubuntu.md'>ArchiveMount in Lubuntu</a> <a id='fnext' href='#blog/2013/2013-10-26-Disable-Hibernate-in-Lubuntu.md'>Disable Hibernate in Lubuntu</a></ins>
