#Getting Started with Sublime Text on Lubuntu

2013-11-28

<!--- tags: linux -->

[Sublime Text](http://www.sublimetext.com/) is a programmer friendly cross-platform text editor. It is a bit like a modern-time Vim. You can configure it at will, and even extend it as wished using Python. Unlike Vim, Sublime Text is neither free, nor open source. This being said, you can use it unregistered as long as you like, or even crack it if you feel it is your right do to that.

Sublime Text has a learning curve, but that is smaller than the one required to master Vim to the same level. This guide is based on version 3 of Sublime Text in (L)Ubuntu, though all of this very likely applies same to version 2. Sublime Text comes with some documentation, but you can Google out most of what you need.

For Ubuntu, you can download Sublime Text binary either as a .deb file, or as .tar.bz2 file - with the later you have more control where you put it, but you have to create shortcuts and file associations on your own.

Sublime Text is not an IDE, but as a programmer's text editor it is quite capable and can be used to edit files for a bunch a languages. It also runs ok my Asus EeePC x101 which has a limited screen resolution - thought there I have to scroll up and down on some of the menus.

First thing you may want to do after you run Sublime Text, is to make side bar visible with [View / Side Bar / Show Side Bar] menu. You can open whole folders there, and save them as a project via [Project / Save Project As] menu. Sublime Text will look for files in open folders, if you use [Goto / Goto Anything] menu (Ctrl+P).

Sublime Text has a lot of settings that can be accessed via [Preferences] menu. There are Default settings useful to see what is there. To change them, you copy them and paste them to User settings. Same pattern applies to plugin settings. The settings text are in JSON format. I found myself adding the following setting (after googling) to better control auto-complete, and show editor ruler helpers. Sublime Text will beautify the settings and strip off the comments.

```
"auto_complete_commit_on_tab": true,
"auto_complete_selector": "source, text",
"auto_complete_with_fields": true,
"rulers": [ 80, 120],
"spell_check": true,
"update_check": false,
// do not remember open files
"hot_exit": false,
"remember_open_files": false,
"update_check": false,
```

In the same way, you can view and modify the key bindings. Sublime Text uses a lot of key shortcuts (more that you can see in the menus), and the plugins use even more. The key bindings differ also slightly between platform and versions, so what you read may not apply to your platform. In Lubuntu, I found out it was better for me to disable most OpenBox key bindings for Ctrl, Alt and Shift combinations. This makes sense, as then these key bindings are available to applications.

Before you start to write any first text in Sublime Text editor, you have to get some plugins :). The first plugin is [Package Control](https://sublime.wbond.net/installation). It is installed, by copy and pasting some Python code to [View / Show Console] line. Normally, you need to restart Sublime Text after you install plugins, thought some of them may already work even without a restart. The Package Control adds [Preference / Package Control] menu where via the Install action, you can easy install other plugins. Some of the Sublime Text plugins, mimic Sublime Text lack of proper documentation - some others are better documented. Not all plugins are free, have a look at their web pages before you install them.

These are some free plugins I installed at first:

```
Package Control
Emmet
FuzzyFileNav
Git
SideBarEnhancements
SideBarGit
SublimeCodeIntel - this is too big
Autoprefixer
Terminal
Tag
Modific
Stackoverflow Search
IndentGuides (has to be installed manually)
Hex Viewer
View In Browser
SublimeREPL - does not work for bash somehow
```

Most Sublime Text and plugins actions are accessible via [Tools / Command Palette] menu (Ctrl+Shift+P). Some plugins add also their own (sub) menus.

Some of the plugins may need node.js. To install node.js on Ubuntu use:
```
sudo apt-get install nodejs
```
If you are not using the unrelated Ubuntu node package (Amateur Packet Radio Node Program), you should link `/usr/bin/nodejs` to `/usr/bin/node`:
```
sudo ln -s /usr/bin/nodejs /usr/bin/node
```
Using Package Control you can install also themes like, Theme - Soda. It decorates the Sublime Text (menus and tabs) to something that looks better. To activate it add to User Settings:
```
"theme": "Soda Light.sublime-theme"
```
For the dark Soda theme, set `Soda Dark.sublime-theme`.

A custom build command to open the browser can be defined in [Tools / Build System / New Build System]:
```
{
	"cmd": ["/usr/bin/chromium-browser", "$file"]
}
```

Some non-obvious keyboard [shortcuts](https://gist.github.com/eteanga/1736542): Making a selection, and pressing Ctrl+D extends the selection to include the next match. You can edit then all selected matches at once. To skip one in between use Ctrl+K, Ctrl + D. Alt+F3 automatically selects all matches, but that may have limited usability. To wrap selected text in a tag [use](https://coderwall.com/p/d1qphg) Alt-Shift-W.

Sublime Text does not seem to work with `gfvs` (fuse). This means you cannot use Sublime Text to do remote edits on (S)FTP mounted locations - which depending on the use case is a real limitation. Other free as beer editors on Linux (GEdit, Geany, etc) handle gfvs ok.

Creating files in right locations is challenging. If you add to your `.bashrc` the following [snippet](https://unix.stackexchange.com/questions/168580/make-parent-directories-while-creating-a-new-file), helps create files and folders quickly via command line:

```
ptouch() {
  for p in "$@"; do
    _dir="$(dirname -- "$p")"
    [ -d "$_dir" ] || mkdir -p -- "$_dir"
    touch -- "$p"
  done
}
```


<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-12-01-Emitting-Source-Code-Examples-From-PHP-Pages.md'>Emitting Source Code Examples From PHP Pages</a> <a id='fnext' href='#blog/2013/2013-11-25-Changing-SSH-Port-on-Lubuntu.md'>Changing SSH Port on Lubuntu</a></ins>
