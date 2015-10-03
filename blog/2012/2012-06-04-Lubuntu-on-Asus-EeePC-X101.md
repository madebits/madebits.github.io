#Lubuntu on Asus EeePC X101

2012-06-04

<!--- tags: linux -->

Asus X101 comes with MeeGo OS. I did a bit of research before I bought it and made up my mind to install Linux, namely [Lubuntu](http://lubuntu.net/) (version 12.04 at this time). Lubuntu is part of Ubuntu, a good maintained distribution with a lot of community support, and installs a minimal set of applications, being suitable for Asus X101 with 8GB SSD. I went for the 32 bit version of Lubuntu (less memory, smaller binaries than 64 bit version).

![](blog/images/x101screen.png)

Using [UNetBootin](http://unetbootin.sourceforge.net/), I created a Lubuntu bootable USB. Plugged the Lubuntu live USB, restarted the machine, and on power on pressed Esc key. Selected the USB from boot menu that showed up and installed Lubuntu after a quick live test using defaults. After installing Lubuntu and the software I needed (more on this next time), I still have 3.9GB free on the main 8GB SSD.

```
df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       6.5G  2.3G  3.9G  38% /
...
```
Some things, I did after the installation:

Modified OpenBox configuration in `~/.config/openbox/lubuntu-rc.xml` by adding the following shortcuts to start Chrome and open all windows maximized by default (used openbox --reconfigure in terminal to apply these.):

```
<keyboard>
    <keybind key="W-b">
      <action name="Execute">
        <command>/usr/bin/chromium-browser</command>
      </action>
    </keybind>
    <keybind key="W-l">
      <action name="Execute">
        <startupnotify>
          <enabled>true</enabled>
          <name>Xscreensaver Lock</name>
        </startupnotify>
        <command>xscreensaver-command -lock</command>
      </action>
    </keybind>
    <keybind key="W-m">
        <action name="Execute">
            <command>lxpanelctl menu</command>
        </action>
    </keybind>
    <keybind key="W-x">
      <action name="Execute">
        <command>lubuntu-logout</command>
      </action>
    </keybind>
    <keybind key="A-F6">
      <action name="ToggleMaximize"/>
    </keybind>
    <keybind key="A-S-d">
      <action name="ToggleDecorations"/>
    </keybind>
    
    <keybind key="W-Escape">
      <action name="Execute">
        <command>xkill</command>
      </action>
    </keybind>

    <!-- Aero Snap for Openbox Begin Code http://ubuntuforums.org/showthread.php?t=2076433 -->
    <keybind key="W-Left">        # HalfLeftScreen
      <action name="UnmaximizeFull"/>
      <action name="MoveResizeTo">
        <x>0</x>
        <y>0</y>
        <height>100%</height>
        <width>50%</width>
      </action>
    </keybind>
    <keybind key="W-Right">        # HalfRightScreen
      <action name="UnmaximizeFull"/>
      <action name="MoveResizeTo">
        <x>-0</x>
        <y>0</y>
        <height>100%</height>
        <width>50%</width>
      </action>
    </keybind>
    <keybind key="W-Up">        # HalfUpperScreen
      <action name="UnmaximizeFull"/>
      <action name="MoveResizeTo">
        <x>0</x>
        <y>0</y>
        <width>100%</width>
        <height>50%</height>
      </action>
    </keybind>
    <keybind key="W-Down">        # HalfLowerScreen
      <action name="UnmaximizeFull"/>
      <action name="MoveResizeTo">
        <x>0</x>
        <y>-0</y>
        <width>100%</width>
        <height>50%</height>
      </action>
    </keybind>
    <keybind key="W-space">
      <action name="ToggleMaximize"/>
    </keybind>
  <!-- Aero Snap for Openbox End Code-->
...
<applications>
    <application class="*">
      <maximized>yes</maximized>
    </application>
    <application type="dialog">
      <maximized>no</maximized>
    </application>
```

Window maximize is not working same on all window dialogs, but it still is more useful than the default alternative.

Additionally, I changed `Alt-Tab` to list open windows horizontally, by commenting dialog option in `~/.config/openbox/lubuntu-rc.xml`:
```
<keybind key="A-Tab">
      <action name="NextWindow">
        <!-- <dialog>icons</dialog>  -->
...
```

Uninstalled notification-daemon and installed [xfce4-notifyd](http://askubuntu.com/questions/88274/how-can-i-make-smaller-pop-ups-on-lubuntu). In `/usr/share/applications` modified Notifications (`xfce4-notifyd-config`) shortcut so that it shows up in Preferences, and configured notifications to be shown bottom-right for 1 second.

To free space, run `sudo apt-get clean` once installed everything. After updating, I also removed the older [kernel](https://help.ubuntu.com/community/Lubuntu/Documentation/RemoveOldKernels).

Screen size of 1024x600 can be changed in Lubuntu to emulate bigger screen sizes in software. The following worked for me to temporary scale up the screen to 1280x720:
```
xrandr --fb 1280x720 --output LVDS1 --scale 1.25x1.2 --panning 1280x720
```
Both scale and panning are needed. To restore back the original 1024x600 resolution I use the following:
```
xrandr --fb 1024x600 --output LVDS1 --scale 1x1 --panning 1024x600
```



<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2012/2012-06-05-CSharp--Reflection-ExtendedActivator.md'>CSharp  Reflection ExtendedActivator</a> <a rel='next' id='fnext' href='#blog/2012/2012-06-03-SD-Card-Memory-Card-Write-Protection-Removal.md'>SD Card Memory Card Write Protection Removal</a></ins>
