#Tilda in Lubuntu

2013-09-29

<!--- tags: linux -->

[tilda](https://github.com/lanoxx/tilda/) combined with `tmux` makes a nice terminal combination for Lubuntu.

To install `tilda` use: `sudo apt-get install tilda`. Run it once for the command line (`tilda`) so that it can start, and right-click and choose Preferences to configure. I set the tilda key binding to `Shift-F12`, and I like to have a border for it. Also set tilda to start hidden.

tilda needs a composite window manager. For Lubuntu you can use xcompmgr: `sudo apt-get install xcompmgr`. To try it run: `xcompmgr -c &`. If you restart tilda after this, tilda background should be transparent (can be configured in tilda Preferences).

To set tilda and xcompmgr to autostart, add to `~/.config/lxsession/Lubuntu/autostart` file the following:

```
@xcompmgr -c
@tilda -c tmux
```
Here, I start `tmux` when tilda is started, you can omit `-c tmux`, or replace it with some bash script that sets up tilda initial state.

To move the tilda window, keep `Alt` key pressed and drag one of the tilda window corners.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-10-05-Autostart-MediaTomb-in-Lubuntu.md'>Autostart MediaTomb in Lubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-09-28-Tmux-on-Lubuntu.md'>Tmux on Lubuntu</a></ins>
