#Opera Browser On Lubuntu

2016-12-19

<!--- tags: browser linux -->

After downloading [Opera](http://www.opera.com/download) browser `opera-stable_*_amd64.deb` file, I used archive `file-roller` to extract `data.tar.xz` from that. From `data.tar.xz`, I extracted the `opera` folder from its `./usr/lib/x86_64-linux-gnu/` location and copied it to `$HOME/opt/opera`. I deleted the following files:

```
rm $HOME/opt/opera/opera_autoupdate
rm $HOME/opt/opera/opera_crashreporter
```

Opera has more or less same command-line arguments as Chromium, apart of `--private` in place of `--incognito`, so I created a `$HOME/opt/opera.sh` file:

```
#!/bin/bash

$HOME/opt/opera/opera --disk-cache-dir=/dev/null --disk-cache-size=1 --private --start-maximized --no-first-run --user-data-dir=$HOME/Private/opera
```

Created also a startup `$HOME/opt/opera.desktop` file (if you want Opera to show in menu in Lubuntu, copy this file in `$HOME/.local/share/applications`):

```
[Desktop Entry]
Version=1.0
Name=Opera
Exec=/home/user/opt/opera.sh
Terminal=false
Type=Application

Icon=/home/user/opt/opera.png
Categories=Network;WebBrowser;
```

I used `opera://plugins` can be used to disable the build in news reader.

I have my own local startup page, and speed dial is of not much use. I installed [Custom New Tab Page](https://addons.opera.com/en/extensions/details/custom-new-tab-page/) extension to get rid of it. Using [User-Agent Switcher](https://addons.opera.com/en/extensions/details/user-agent-switcher/), I made Opera look like Chrome. And given, we are at extensions, I also installed [Download Chrome Extension](https://addons.opera.com/en/extensions/details/download-chrome-extension-9/).

After configuring the settings, I [discovered](http://superuser.com/questions/956087/opera-31-remove-default-search-engines) one cannot disable, remove, or replace search engines. As my custom start page has a search box, I do not really need to search in address bar, and do not want to leak that typed URL information to any search engine. The solution to this problem, turned out to be easy. I configured Opera to use as default search engine something I would never use, such as DuckDuckGo.com, and then edited my `/etc/hosts` to append:

```
0.0.0.0 duckduckgo.com
``` 

To switch window [decorations](http://openbox.org/wiki/Help:Actions#ToggleDecorations), I have in `$HOME/.config/openbox/lubuntu-rc.xml`:

```xml
 <keybind key="W-S-d">
  <action name="ToggleDecorations"/>
 </keybind>
```

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2016/2016-11-29-From-User-Stories-To-Code.md'>From User Stories To Code</a></ins>
