#!/bin/bash

xrdb -load ~/.config/i3/.Xresources
#xterm "$@"
#urxvtcd -pixmap "$HOME/.urxvt/bg.png;style=tiled" "$@"
urxvtcd "$@"
