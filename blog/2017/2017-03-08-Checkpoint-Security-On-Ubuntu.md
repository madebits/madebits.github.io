#Checkpoint Security On Ubuntu

2017-03-08

<!--- tags: linux -->

Thanks to a *tip* from a friend, based on instruction [here](http://kenfallon.com/checkpoint-snx-install-instructions-for-major-linux-distributions/), I installed `snx` on Ubuntu. The following steps summary is a reminder to self, in case I need to do this again.

[Checkpoint](https://www.checkpoint.com/) does not offer `snx` for direct download, however, in your corporate Checkpoint website, there is link to *Download SSL Network Extender manual installation* for Linux. The downloaded `snx_install.sh` has to be made executable and run as root. It is binary, so it is up to you to choose on what machine you trust to run it. Additionally, the following libraries are needed:

```
sudo apt install libstdc++5:i386 libpam0g:i386 libx11-6:i386
```

After installation, `/usr/bin/snx` becomes available, and a tunnel can be created by using: `snx -s remote.example.com -u user`. Run `snx --help` for a full list of options.

Starting `snx`, creates a tunnel named `tunsnx` visible via `ifconfig`. To allow traffic to pass through, local firewall rules may need to be adapted:

```
/sbin/iptables -A INPUT  -j ACCEPT -i tunsnx
/sbin/iptables -A OUTPUT -j ACCEPT -o tunsnx
```

An alternative way to start `snx` without having to type server and use all the time is to add a `~/.snxrc` file:

```
server remote.example.com
username user
reauth yes
```

Then we can run only `snx`. Full list of options for `~/.snxrc` file from documentation are:

```
   - server          SNX server to connet to
   - sslport         The SNX SSL port (if not default)
   - username        the user name
   - certificate     certificate file to use
   - calist          directory containing CA files
   - reauth          enable automatic reauthentication. Valid values { yes, no }
   - debug           enable debug output. Valid values { yes, 1-5 }
   - cipher          encryption algorithm to use. Valid values { RC4 / 3DES }
   - proxy_name      proxy hostname 
   - proxy_port      proxy port
   - proxy_user      username for proxy authentication
```

To access windows remote desktops, install `sudo apt install freerdp-x11` and use something like (machine name works also in place of IP, but name resolution may take some time, IPs are faster):

```
xfreerdp /v:10.11.11.11 /u:user
```

Or with some more [options](http://manpages.ubuntu.com/manpages/yakkety/man1/xfreerdp.1.html) (note `+cmd` is same as `/cmd`):

```
xfreerdp /cert-ignore /f /compression +clipboard /v:10.11.11.11 /u:user /toggle-fullscreen /bpp:8 +async-input +async-update +async-transport +async-channels -wallpaper -themes /drive:home,$HOME/work-remote /sound
```

`Ctr+Alt+Enter` toggles fullscreen and if `xfreerdp` hangs `Ctrl+Alt+F1` can be used to access the console to kill it (`Ctrl+Alt+F7` to get back).

To stop `snx` use:

```
snx -d
```

I am usually, a left mouse user and RDP does not transfer the mouse settings. To easy swap the mouse buttons as I need them, I keep installed in the machines and pinned in taskbar via a shortcut a small [program](https://superuser.com/questions/205861/keyboard-shortcut-to-swap-mouse-buttons) based on this code:

```cs
// csc mouse-swap.cs /win32icon:mouse.ico
// https://superuser.com/questions/205861/keyboard-shortcut-to-swap-mouse-buttons
using System.Runtime.InteropServices;
using System;

class SwapMouse
{
    [DllImport("user32.dll")]
    public static extern Int32 SwapMouseButton(Int32 bSwap);

    static void Main(string[] args)
    {
        int rightButtonIsAlreadyPrimary = SwapMouseButton(1);
        if (rightButtonIsAlreadyPrimary != 0)
        {
            SwapMouseButton(0);  // Make the left mousebutton primary
        }
    }
}
```


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2017/2017-03-22-User-Driven-Password-Policy.md'>User Driven Password Policy</a> <a rel='next' id='fnext' href='#blog/2017/2017-02-21-Integrating-GO.CD-with-Nexus.md'>Integrating GO.CD with Nexus</a></ins>
