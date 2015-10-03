#Evince Fit Keyboard Shortcuts

2015-04-14

<!--- tags: linux -->

As part of GNome efforts to have applications that can be used only by people with only one finger on a touch screen, Evince is hard to use normally. I [found](https://mail.gnome.org/archives/commits-list/2011-June/msg07910.html) two [undocumented](https://help.gnome.org/users/evince/stable/shortcuts.html.en) shortcuts that are really useful:

* w - fit width
* f - best fit

Given these options are no more in the Evince menus, but only on drop down button list that remains open for some reason even after you select an option, the recommended way in documentation using `dconf-editor` with `can_change_accels` does not work for them.

If you are using the document index side pane, some PDF document instruct Evince to reset zoom level when clicking on a index topic. The funny thing is the focus remains on the side page and the above shortcuts do not work unless the focus in on the document. There is no direct shortcut for moving the focus away (do not try TAB - you have been warned). The only way I found (without having to click with mouse to move the focus) is to hide the side bar with `F9`, or to trigger a document refresh `CTRL+r`. After these `w` and `f` work again.

Finally a GNOME joke: [Accessibility in Evince](http://blogs.igalia.com/apuentes/2013/09/04/15/) describes a method to use the keyboard to do text movement and selection in Evince using the keyboard. The keyboard shortcut for this `F7` is not documented in Evince, and pressing `F7` in Evince opens a bar where you can select to activate this feature only using mouse. Even the `Esc` key does not work to hide that `F7` opened bar.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2015/2015-04-15-Micro-Libraries.md'>Micro Libraries</a> <a rel='next' id='fnext' href='#blog/2015/2015-03-24-Encrypted-Swap-File-in-Linux.md'>Encrypted Swap File in Linux</a></ins>
