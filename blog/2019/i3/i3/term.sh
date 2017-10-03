#!/bin/bash

xrdb -load ~/.config/i3/.Xresources
#xterm "$@"
urxvt "$@"
