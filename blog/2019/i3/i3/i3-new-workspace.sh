#!/bin/bash
# Based on https://github.com/sandeel/i3-new-workspace
# Script occupies free workspace with lowest possible number

ws=(
""
"1: ❤️"
"2: 💛"
"3: 💚"
"4: 💙"
"5: 💜"
"6: 🔶"
"7: 🔷"
"8: 🔴"
"9: 🔵"
"10: ⚪"
)

WS_JSON=$(i3-msg -t get_workspaces)
for i in {1..10} ; do
    if [[ $WS_JSON != *"\"num\":$i"* ]] ; then
        i3-msg workspace number "${ws[i]}"
        break
    fi
done
