#Using keynav to move mouse pointer on Lubuntu

2016-07-27

<!--- tags: linux -->

[keynav](http://www.semicomplete.com/projects/keynav/) enables using keyboard to emulate mouse clicks. Default `vi`-like key binds are ok, but I also would like to use the arrow keys, so I created `~/.keynavrc` to augment default keys:

```
daemonize

Left cut-left
Down cut-down
Up cut-up
Right cut-right
Return warp,click 1,end
shift+Left move-left
shift+Down move-down
shift+Up move-up
shift+Right move-right
```

To start `keynav` automatically, I added to `~/.config/lxsession/Lubuntu`:

```
@keynav
```

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2016/2016-07-26-Getting-Started-With-Spark-Ml.md'>Getting Started With Spark Ml</a></ins>
