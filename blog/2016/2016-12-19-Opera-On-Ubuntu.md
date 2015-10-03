#Opera Browser On Lubuntu

2016-12-19

<!--- tags: browser linux -->

In a quest to find some alternative webkit based browser for Lubuntu, I gave [Opera](http://www.opera.com/download) browser a try.

##Download and Install

After downloading [Opera](http://www.opera.com/download) `opera-stable_*_amd64.deb` file, I used archive `file-roller` to extract `data.tar.xz` from that. From `data.tar.xz`, I extracted the `opera` folder from its `./usr/lib/x86_64-linux-gnu/` location and copied it to `$HOME/opt/opera`. Finally, I deleted the following files:

```
rm $HOME/opt/opera/opera_autoupdate
rm $HOME/opt/opera/opera_crashreporter
```

##Command-Line

Opera has more or less same [command-line](http://peter.sh/experiments/chromium-command-line-switches/) arguments as Chromium, apart of `--private` in place of `--incognito`. I created a bash script `$HOME/opt/opera-browser` executable file:

```
#!/bin/bash

$HOME/opt/opera/opera --disk-cache-dir=/dev/null --disk-cache-size=1 --private --start-maximized --no-first-run --user-data-dir=$HOME/Private/opera
```

After start, I used `opera://plugins` can be used to disable the build in news reader and `opera://flags` to fine-tune some of the options.

##Desktop Shortcut

I created also a startup `$HOME/opt/opera.desktop` file (if you want Opera to show in menu in Lubuntu, copy this file in `$HOME/.local/share/applications`):

```
[Desktop Entry]
Version=1.0
Name=Opera
Exec=/home/user/opt/opera-browser
Terminal=false
Type=Application

Icon=/home/user/opt/opera.png
Categories=Network;WebBrowser;
```

##Startup Page and Extensions

I have my own local startup page and do not need any of speed-dial functionality. I installed [Custom New Tab Page](https://addons.opera.com/en/extensions/details/custom-new-tab-page/) extension to get rid of it. Using [User-Agent Switcher](https://addons.opera.com/en/extensions/details/user-agent-switcher/), I made Opera look like Chrome. I also installed [Download Chrome Extension](https://addons.opera.com/en/extensions/details/download-chrome-extension-9/).

##Search Engines

While configuring Opera browser settings, I [discovered](http://superuser.com/questions/956087/opera-31-remove-default-search-engines) that it is not possible to disable, remove, or replace search engines. As my custom start page has a search box, I do not really need to search in address bar, and do not want to leak that typed URL information to any search engine. 

The solution to this problem, turned out to be easy. I configured Opera to use as default search engine something I would never use, such as *DuckDuckGo.com*, and then edited my `/etc/hosts` to append:

```
0.0.0.0 duckduckgo.com
``` 

##Removing System Window Border

To switch window [decorations](http://openbox.org/wiki/Help:Actions#ToggleDecorations), I have a generic rule in `$HOME/.config/openbox/lubuntu-rc.xml`:

```xml
 <keybind key="W-S-d">
  <action name="ToggleDecorations"/>
 </keybind>
```

But for Opera, it makes sense to add its own [rule](http://openbox.org/wiki/Help:Applications) (I found the class name using `xprop`):

```xml
  <applications>
  <application class="Opera">
    <decor>no</decor>
  </application>
  </applications>
```

With this change, Opera consumes same amount of screen space for tabs as Chromium.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2016/2016-11-29-From-User-Stories-To-Code.md'>From User Stories To Code</a></ins>
