#Lubuntu: Closing Chrome Downloads Bar

2016-08-02

<!--- tags: linux -->

Chromium browser download bar is kind of [hassle](https://superuser.com/questions/111675/google-chrome-auto-close-download-bar/325787) to close unless you install some extension (which needs then access to all pages you visit). To close download bar manually one has to use `ctrl+j` and `ctrl+w`. The problem is that especially `ctrl+j` is hard to reach in the keyboard.

I tried first running `xdotool` in a loop:

```bash
xdotool search --all --onlyvisible --class chromium-browser keyup --window %@ ctrl+j ctrl+w
```

This does not work as intended, as Chromium detects the key is synthetic and ignores the `ctrl` modifier, making the above command useless (it works for `ctrl+r` thought). 

If used [without](https://unix.stackexchange.com/questions/214909/xdotool-does-not-send-keys) a window id, `xdotool` sends keys differently and Chromium cannot detect that. The only drawback is that unlike the script above, it has to be triggered manually. To do this, I added a key binding to `~/.config/openbox/lubuntu-rc.xml`:

```xml
<keybind key="W-z">
  <action name="Execute">
    <command>xdotool key ctrl+j ctrl+w</command>
  </action>
</keybind>
```

The combination of `WinKey+z` allows closing the Chromium downloads bar with a much more convenient shortcut than `ctrl+j`, `ctrl+w`.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-08-30-Ubuntu-Screen-Tools.md'>Ubuntu Screen Tools</a> <a rel='next' id='fnext' href='#blog/2016/2016-08-01-Machine-Learning-with-Spark-Readings.md'>Machine Learning with Spark Readings</a></ins>
