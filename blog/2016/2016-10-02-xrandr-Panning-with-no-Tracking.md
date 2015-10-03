#xrandr Panning with no Tracking

2016-10-02

<!--- tags: linux -->

To scale up a 1366x768 screen to 1920x1080 with no tracking using [xrandr](https://www.x.org/archive/X11R7.5/doc/man/man1/xrandr.1.html), the `track_x+track_y` must be set zero:

```
xrandr --fb 1920x1080 --output LVDS1 --panning 1920x1080+0+0/1366x768+0+0/0/0/0/00 --scale 1.4x1.4
```

It can be combined with `chromium-browser` using:

```
chromium-browser --force-device-scale-factor=1.4
```

To undo the change:

```
xrandr --fb 1366x768 --output LVDS1 --scale 1x1 --panning 1366x768
```

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2016/2016-08-30-Ubuntu-Screen-Tools.md'>Ubuntu Screen Tools</a></ins>
