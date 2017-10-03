#!/bin/bash

xrdb -I$HOME/.config/i3  -load ~/.config/i3/.Xresources
#xterm "$@"
#urxvtcd -pixmap "$HOME/.urxvt/bg.png;style=tiled" "$@"
urxvtcd "$@"
