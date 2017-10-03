#!/bin/bash -x

ws=(
""
"1: ❤️❤️"
"2: 💛💛"
"3: 💚💚"
"4: 💙💙"
"5: 💜💜"
"6: 🔶🔶"
"7: 🔷🔷"
"8: 🔴🔴"
"9: 🔵🔵"
"10: ⚪⚪"
)

function i3NextFreeWorkspace()
{
    local json=$(i3-msg -t get_workspaces)
    for i in {1..10} ; do
        if [[ $json != *"\"num\":$i"* ]] ; then
            echo "${ws[i]}"
            break
        fi
    done
    # default
    echo "${ws[10]}"
}

bl=$(/etc/acpi/actions/bl-status.sh)
up=$(uptime | cut -d ',' -f 1)
mem=$(free -h | grep Mem: | tr -s ' ' | cut -d ' ' -f 3,2,4)

if [ -z "$@"]; then
    echo "🧑 ${USER} | 🕛 ${up} | Ⓜ️ ${mem} | ☀️ ${bl}%"
    echo "☠️ i3 Kill"
    echo "🎛️ i3 Toggle Layout"
    echo "🔲 i3 New Workspace"
    echo "⛵ i3 Move to New Workspace"
    echo "🛠️ i3 Config"
    echo "🌀 i3 Reload"
    echo "🔊 Volume"
    
    echo "🌐 Browser"
    echo "🌎 Firefox"
    echo "📂 Files"
    echo "📧 Email"
    echo "🗳️ DropBox"
    
    echo "🔑 VeraCrypt"
    echo "🔐 KeepassXC"
    
    echo "🧮 Calculator"
    echo "🏢 Office"
    echo "💥 Sublime"
    echo "📝 Geany"
    
    echo "🎦 Vlc"
    echo "🎶 Audacious"
    echo "🖼️ Gimp"
    
    echo "📦 VirtualBox"
    echo "👨‍💻 Synaptic Install"
    echo "🔄 System Updates"
    echo "💽 Disks"
    
    echo "⚡ System Monitor"
    echo "🔋 Power Stats"
    echo "📚 Disk Space"
    echo "️🖨️ Printers"
    
    echo "🗂️ Ranger"
    echo "💻 Terminal"
    echo "📅 Calendar"
    
    echo "📲 Logout"
    echo "♻️ Reboot"
    echo "⛔ Shutdown"
else
    cmd=$@
    case $cmd in
        "☠️ i3 Kill")
            i3-msg 'kill' > /dev/null
            ;;
        "🎛️ i3 Toggle Layout")
            i3-msg 'layout toggle tabbed stacking split' > /dev/null
            ;;
        "🔲 i3 New Workspace")
            i3-msg workspace number "$(i3NextFreeWorkspace)" > /dev/null
            ;;
        "⛵ i3 Move to New Workspace")
            nws="$(i3NextFreeWorkspace)"
            i3-msg move container to workspace number "$nws" > /dev/null
            sleep 0.2 > /dev/null
            i3-msg workspace number "$nws" > /dev/null
            ;;
        "🛠️ i3 Config")
            geany -i $HOME/.config/i3status/config $HOME/.config/i3/start.sh $HOME/.config/i3/rofi_custom.sh $HOME/.config/i3/config > /dev/null &
            ;;
        "🌀 i3 Reload")
            i3-msg reload > /dev/null
            i3-msg restart > /dev/null
            ;;
        "🔊 Volume")
            pavucontrol > /dev/null &
            ;;
            

        "🌐 Browser")
            chromium-browser > /dev/null &
            ;;
        "🌎 Firefox")
            firefox > /dev/null &
            ;;
        "📂 Files")
            nautilus > /dev/null &
            ;;
        "📧 Email")
            thunderbird > /dev/null &
            ;;
        "🗳️ DropBox")
            $HOME/.dropbox-dist/dropboxd > /dev/null &
            ;;            

        "🔑 VeraCrypt")
            /usr/bin/veracrypt > /dev/null &
            ;;
        "🔐 KeepassXC")
            keepassxc > /dev/null &
            ;;
                
        "🧮 Calculator")
            speedcrunch > /dev/null &
            ;;
        "🏢 Office")
            libreoffice > /dev/null &
            ;;
        "💥 Sublime")
            $HOME/opt/sublime_text_3/sublime_text > /dev/null &
            ;;
        "📝 Geany")
            geany -i > /dev/null &
            ;;

        "🎦 Vlc")
            vlc $HOME/Desktop/music.xspf > /dev/null &
            ;;
        "🎶 Audacious")
            audacious > /dev/null &
            ;;
        "🖼️ Gimp")
            gimp > /dev/null &
            ;;

        "📦 VirtualBox")
            virtualbox > /dev/null &
            ;;
        "👨‍💻 Synaptic Install")
            #exec zenity --password | sudo -S synaptic
            synaptic-pkexec  > /dev/null &
            ;;
        "🔄 System Updates")
            #zenity --password | sudo -S update-manager
            update-manager > /dev/null &
            ;;
        "💽 Disks")
            gnome-disks > /dev/null &
            ;;
         
        "🔋 Power Stats")
            gnome-power-statistics > /dev/null &
            ;;
        "⚡ System Monitor")
            gnome-system-monitor > /dev/null &
            ;;
        "📚 Disk Space")
            baobab > /dev/null &
            ;;
        "️🖨️ Printers")
            system-config-printer > /dev/null &
            ;;
            
        "🗂️ Ranger")
            xterm -e ranger > /dev/null &
            ;;
        "💻 Terminal")
            xterm > /dev/null &
            ;;
        "📅 Calendar")
            zenity --calendar --text="$(date)" --width=320 > /dev/null &
            ;;
            
        "📲 Logout")
            i3-msg exit > /dev/null
            ;;
        "♻️ Reboot")
            systemctl reboot > /dev/null
            ;;
        "⛔ Shutdown")
            systemctl poweroff -i > /dev/null
            ;;
    esac
fi
