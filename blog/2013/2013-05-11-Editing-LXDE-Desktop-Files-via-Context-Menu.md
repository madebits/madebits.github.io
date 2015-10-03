#Editing LXDE Desktop Files via Context Menu

2013-05-11

<!--- tags: linux -->

In Lubuntu PCManFM, there is GUI menu entry to create a new shortcut [Create New... / Shortcut] from context menu, but no menu to edit an existing shortcut. You can always open a `.desktop` file as text and edit it, but `lxshortcut` allows you additionally to conveniently select an icon too. Somehow editing a `.desktop` file after creation with `lxshortcut` is not possible by default via the context menu in PCManFM.

One way to remedy this, is to choose [Open With...] from context menu for an existing .desktop file, and then in Custom Command Line tab use `lxshortcut -i %f` as command and click on Ok button.

PCManFm creates a `.desktop` file too for the new custom command in `~/.local/share/applications/` directory and adds an entry referring to it inside `mimeapps.list` file in same folder (mime type for `.desktop` files is `application/x-desktop`). These can be both edited manually to customize further the created custom command file.

```
[Desktop Entry]
Type=Application
Name=Edit Shortcut
Exec=lxshortcut -i %f
Categories=Other;
NoDisplay=true
MimeType=application/x-desktop
Icon=folder
```
In a similar way, a context menu to set an image as wallpaper can be added with `pcmanfm -w %f`, and then edited to look like:
```
[Desktop Entry]
Type=Application
Name=Set As Wallpaper
Exec=pcmanfm --wallpaper-mode=stretch -w %f
Categories=Other;
NoDisplay=true
MimeType=image/jpeg;image/png;
Encoding=UTF-8
Name[en_US]=Set As Wallpaper
Icon=preferences-desktop-wallpaper
```

In `mimeapps.list` file set as first application your default image viewer (for me `miv.desktop`) then the newly created wallpaper shortcut:
```
[Added Associations]
image/jpeg=gpicview.desktop;userapp-wallpaper.desktop;
image/png=gpicview.desktop;userapp-wallpaper.desktop;
```
It would be nice these were both delivered as part of default pcmanfm context menus.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-05-23-Exploring-Linux-UDEV-in-Context.md'>Exploring Linux UDEV in Context</a> <a rel='next' id='fnext' href='#blog/2013/2013-05-04-Using-Two-Monitors-on-Lubuntu.md'>Using Two Monitors on Lubuntu</a></ins>
