#Using keynav to move mouse pointer on Lubuntu

2016-07-27

<!--- tags: linux -->

[keynav](http://www.semicomplete.com/projects/keynav/) enables using keyboard to emulate mouse clicks. It can be installed in Ubuntu using `sudo apt-get install keynav`. 

Default `vi`-like key binds are ok, but I also would like to use the arrow keys, so I created `~/.keynavrc` to augment default keys:

```
daemonize

ctrl+shift+Right start
ctrl+shift+Left end
Left cut-left
Down cut-down
Up cut-up
Right cut-right
Return warp,click 1,end
ctrl+Left move-left
ctrl+Down move-down
ctrl+Up move-up
ctrl+Right move-right
ctrl+Home windowzoom
ctrl+End cursorzoom 512 512
ctrl+semicolon start,cursorzoom 512 512
```

I found it easier to use if I start at current mouse location. To start `keynav` automatically, I added to `~/.config/lxsession/Lubuntu/autostart` file:

```
@keynav
```

Along with *daemonize* option in the configuration, this enables running `keynav` in background automatically.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-07-30-Upgrading-to-Lubuntu-16.04.1.md'>Upgrading to Lubuntu 16.04.1</a> <a rel='next' id='fnext' href='#blog/2016/2016-07-26-Getting-Started-With-Spark-Ml.md'>Getting Started With Spark Ml</a></ins>
