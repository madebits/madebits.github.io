#*xdg-open* Failing on Folders on Lubuntu

2014-01-06

<!--- tags: linux -->

For some reason `xdg-open /somefolderpath` stopped working properly in my Lubuntu 13.10:
```
$ xdg-open /home
Warning: unknown mime-type for "/home" -- using "application/octet-stream"
Error: no "view" mailcap rules found for type "application/octet-stream"
Created new window in existing browser session.
```

This results in folders opened in my default web browser from all applications that rely on `xdg-open`, including the browser itself.

I debugged `/usr/bin/xdg-open` and found first that when it calls `detectDE()` function, it cannot detect that it is LXDE, and goes on with `generic` that defaults to opening in browser. `detectDE()` looks at `$DESKTOP_SESSION`, which is set to Lubuntu. `detectDE()` expects it contains LXDE to consider it as an LXDE one. A possible fix for this would be to add to `detectDE()` in `/usr/bin/xdg-open`:

```
elif [ x"$DESKTOP_SESSION" = x"Lubuntu" ]; then DE=lxde;
```

Or alternatively one could start it as:
```
DESKTOP_SESSION=LXDE xdg-open /home
```
After finding this fix, I still was not sure whether this was really the problem, so I compared how it behaves in an another Lubuntu machine where it still works.

I found out, it also fails to detect LXDE there, and uses still `generic`. The difference was in the output of: `xdg-mime query default inode/directory`

```
default='mcomix.desktop;' (machine that fails)
default='pcmanfm.desktop;' (machine that works)
```
After I saw this, I recalled that I selected once `mcomix` to open a folder from `pcmanfm`. So I had a look at: `~/.local/share/applications/mimeapps.list` and there it was:

```
[Default Applications]
inode/directory=mcomix.desktop;
```

To fix it I moved it under:
```
[Added Associations]
inode/directory=mcomix.desktop;
```

Somehow despite it is written in `[Default Applications]`, it has to be in `[Added Associations]` instead.


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2014/2014-01-25-Getting-Started-with-GNU-PG.md'>Getting Started with GNU PG</a> <a rel='next' id='fnext' href='#blog/2013/2013-12-31-Skype-Video-Flipped-Vertically-on-Asus-Laptop.md'>Skype Video Flipped Vertically on Asus Laptop</a></ins>
