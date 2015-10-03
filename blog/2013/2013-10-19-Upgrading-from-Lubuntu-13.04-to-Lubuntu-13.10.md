#Upgrading from Lubuntu 13.04 to Lubuntu 13.10

2013-10-19

<!--- tags: linux -->

I upgraded a machine having Lubuntu 13.04 to the latest Lubuntu 13.10 version today. The upgrade via the Ubuntu UI went smooth, thought I was asked to confirm replace of two of my modified files (they show a diff when prompting, but no way to merge). I re-enabled my disabled PPAs using Synaptic afterwards.

I have two xfce-power-manager icons in `lxpanel` system tray. It [seems](http://forums.solydxk.com/viewtopic.php?f=7&t=1445), `xfce-power-manager` shows now a icon per device with battery it detects (I have the laptop battery, and a wireless mouse, and a wireless touchpad - and I use solaar to view their status). I investigated a bit, but till now, I found no way to remove the new mouse icon (other than remove both). Update: I switched off all `xfce-power-manager` icons and ended up using the build-in `lxpanel` battery status applet.

After the upgrade, I removed some Lubuntu default apps I do not need: `xpad`, `abiword`, `gnumeric`, `gpicview`, `ace-of-penguins`. The last version of the previous 3.8 kernel is still left in the system. If everything works, you can remove it manually to save space. The 13.10 comes with kernel version 3.11.0-12-generic.

Lubuntu has now Firefox as default browser. To change back to Chromium as default (I had both Firefox and Chromium also before installed), I used "Preferences / Preferred Application" menu. See also: http://askubuntu.com/questions/79305/how-do-i-change-my-default-browser. Update: The Preferred Application GUI did not work to change the default browser. I had to use in command-line `sudo update-alternatives --config x-www-browser`. Chromium in this version has somehow a problem with the existing `~/.config/Chromium/Default` profile. I ended up creating a new profile, and porting the part of the old profile I needed.

In my 64 bit machine with Radeon graphics, Chromium tab text is [broken](https://code.google.com/p/chromium/issues/detail?id=123104). Also Vimium extension is broken and does not work in this Chromium build. Vimium works on SWIron fork of Chromium (for same Chromium version), so now I am using SWIron as default browser. Update: chromium-browser was fixed on version 30. As SWIron Chromium build shares the profile with Chromium, it is easy to switch between the two.

In 13.10, the preferred way to lock screen is `lxlock` that delegates to `lightdm`. `xcreensaver` can be still used if wished. To use `lxlock` edit `~/.config/openbox/lubuntu-rc.xml` and look for (see https://bugs.launchpad.net/ubuntu/+source/lubuntu-default-settings/+bug/1204052):

```
<!-- Lock the screen on Ctrl + Alt + l-->
    <keybind key="C-A-l">
      <action name="Execute">
        <command>xscreensaver-command -lock</command>
      </action>
    </keybind>
```

Replace the command with:

```
<!-- Lock the screen on Ctrl + Alt + l-->
    <keybind key="C-A-l">
      <action name="Execute">
        <command>lxlock</command>
      </action>
    </keybind>
```
For me, I had to change also:
```
<keybind key="W-l">
      <action name="Execute">
        <startupnotify>
          <enabled>true</enabled>
          <name>Xscreensaver Lock</name>
        </startupnotify>
        <command>xscreensaver-command -lock</command>
      </action>
    </keybind>
```    
Similar to above to:
```
<keybind key="W-l">
      <action name="Execute">
        <startupnotify>
          <enabled>true</enabled>
          <name>LxLock</name>
        </startupnotify>
        <command>lxlock</command>
      </action>
    </keybind>
```

Run `openbox --reconfigure` to apply the changes.

`lxkeymap` is no more delivered. The preferred way now is to use `lxpanel` plugin. I have `lxkeymap` from 13.04 install and it still works, but I used `lxpanel` plugin also before, and the time I was not very sure why `lxkeymap` was there.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-10-22-Lubuntu-13.10-Radeon-Laptop-Screen-Black-After-Upgrade.md'>Lubuntu 13.10 Radeon Laptop Screen Black After Upgrade</a> <a rel='next' id='fnext' href='#blog/2013/2013-10-05-Autostart-MediaTomb-in-Lubuntu.md'>Autostart MediaTomb in Lubuntu</a></ins>
