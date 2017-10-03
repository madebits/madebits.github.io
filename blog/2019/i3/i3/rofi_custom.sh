#!/bin/bash -x

# https://emojipedia.org/

ws=(
""
"1: 🍉🍉"
"2: 🍊🍊"
"3: 🍋🍋"
"4: 🍏🍏"
"5: 🥝🥝"
"6: 🍒🍒"
"7: 🍅🍅"
"8: 🌽🌽"
"9: 🍑🍑"
"10: 🍄🍄"
)

function i3NextFreeWorkspace()
{
    local json=$(i3-msg -t get_workspaces)
    for i in {1..10} ; do
        if [[ $json != *"\"num\":$i"* ]] ; then
            echo "${ws[i]}"
            return
        fi
    done
    # default
    echo "${ws[10]}"
}

bl=$(/etc/acpi/actions/bl-status.sh)
up=$(uptime | cut -d ',' -f 1 | tr -s ' ' )
mem=$(free -h | grep Mem: | tr -s ' ' | cut -d ' ' -f 3,2,4)

if [ -z "$@"]; then
    echo "👶${USER}|🕛${up}|Ⓜ️${mem}|☀️${bl}%"
    echo "☠️ i3 Kill (A+F4|W+Q|W+F4|B2)"
    echo "🎛️ i3 Toggle Layout (W+Tab|W+w)"
    echo "🔲 i3 New Workspace (W+^)"
    echo "▶️ i3 Move to New Workspace"
    echo "⏩ i3 Move All To New Workspace"
    echo "📌 i3 Bar Toggle (W+y)"
    echo "🛸 i3 Floating Toggle (W+Shift+space)"
    echo "💎 i3 Sticky Toggle"
    echo "📺 i3 Full Screen (W+f)"
    echo "⚙️ i3 Config"
    echo "🌀 i3 Reload (W+S+r)"
    echo "🔊 Volume"
    
    echo "🌐 Browser (W+b)"
    echo "🌎 Firefox"
    echo "📂 Files (W+e|W+n)"
    echo "🔎 Search"
    echo "📧 Email"
    echo "🗳️ DropBox"
        
    echo "🔑 VeraCrypt"
    echo "🔐 KeepassXC"
    
    echo "🧮 Calculator"
    echo "🏢 Office"
    echo "💥 Sublime"
    echo "📝 Geany"
    echo "📘 VsCode"
    
    
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
    
    echo "🗂️ Ranger (W+g)"
    echo "💻 Terminal (W+Enter|W+t)"
    echo "📅 Calendar"
    
    echo "🏳️‍🌈 Lock Screen (W+Esc)"
    echo "📲 Logout"
    echo "♻️ Reboot"
    echo "⛔ Shutdown"
else
    cmd="$@"
    case $cmd in
        "☠️ i3 Kill (A+F4|W+Q|W+F4|B2)")
            /usr/bin/i3-msg 'kill' > /dev/null
            ;;
        "🎛️ i3 Toggle Layout (W+Tab|W+w)")
            /usr/bin/i3-msg 'layout toggle tabbed stacking split' > /dev/null
            ;;
        "🔲 i3 New Workspace (W+^)")
            /usr/bin/i3-msg workspace number "$(i3NextFreeWorkspace)" > /dev/null
            ;;
        "▶️ i3 Move to New Workspace")
            nws="$(i3NextFreeWorkspace)"
            #i3-msg "move container to workspace number ${nws}; workspace number ${nws}" > /dev/null
            /usr/bin/i3-msg "move container to workspace number ${nws}" > /dev/null
            sleep 0.2 > /dev/null
            /usr/bin/i3-msg workspace number "$nws" > /dev/null
            ;;
        "⏩ i3 Move All To New Workspace")
            nws="$(i3NextFreeWorkspace)"
            /usr/bin/i3-msg "rename workspace to \"${nws}\"" > /dev/null
            ;;
        "🛸 i3 Floating Toggle (W+Shift+space)")
            /usr/bin/i3-msg 'floating toggle; move position center' > /dev/null
            ;;
        "💎 i3 Sticky Toggle")
            /usr/bin/i3-msg 'sticky toggle' > /dev/null
            ;;
        "📺 i3 Full Screen (W+f)")
            /usr/bin/i3-msg 'fullscreen toggle' > /dev/null
            ;;
        "📌 i3 Bar Toggle (W+y)")
            /usr/bin/i3-msg 'bar mode toggle' > /dev/null
            ;;
        "⚙️ i3 Config")
            /usr/bin/geany -i $HOME/.config/i3status/config $HOME/.config/i3/start.sh $HOME/.config/i3/rofi_custom.sh $HOME/.config/i3/config > /dev/null &
            ;;
        "🌀 i3 Reload (W+S+r)")
            /usr/bin/i3-msg reload > /dev/null
            /usr/bin/i3-msg restart > /dev/null
            ;;
        "🔊 Volume")
            /usr/bin/pavucontrol > /dev/null &
            ;;
            

        "🌐 Browser (W+b)")
            ~/bin/chrome.sh > /dev/null &
            ;;
        "🌎 Firefox")
            /usr/bin/firefox > /dev/null &
            ;;
        "📂 Files (W+e|W+n)")
            /usr/bin/nautilus > /dev/null &
            ;;
        "🔎 Search")
            /usr/bin/catfish > /dev/null &
            ;;
        "📧 Email")
            /usr/bin/thunderbird > /dev/null &
            ;;
        "🗳️ DropBox")
            $HOME/.dropbox-dist/dropboxd > /dev/null &
            ;;            

        "🔑 VeraCrypt")
            /usr/bin/veracrypt > /dev/null &
            ;;
        "🔐 KeepassXC")
            /usr/bin/keepassxc > /dev/null &
            ;;
                
        "🧮 Calculator")
            /usr/bin/speedcrunch > /dev/null &
            ;;
        "🏢 Office")
            /usr/bin/libreoffice > /dev/null &
            ;;
        "💥 Sublime")
            $HOME/opt/sublime_text_3/sublime_text > /dev/null &
            ;;
        "📝 Geany")
            /usr/bin/geany -i > /dev/null &
            ;;
        "📘 VsCode")
            ~/opt/VSCode-linux-x64/code > /dev/null &
            ;;

        "🎦 Vlc")
            /usr/bin/vlc $HOME/Desktop/music.xspf > /dev/null &
            ;;
        "🎶 Audacious")
            /usr/bin/audacious > /dev/null &
            ;;
        "🖼️ Gimp")
            /usr/bin/gimp > /dev/null &
            ;;

        "📦 VirtualBox")
            /usr/bin/virtualbox > /dev/null &
            ;;
        "👨‍💻 Synaptic Install")
            #exec zenity --password | sudo -S synaptic
            /usr/bin/synaptic-pkexec  > /dev/null &
            ;;
        "🔄 System Updates")
            #zenity --password | sudo -S update-manager
            /usr/bin/update-manager > /dev/null &
            ;;
        "💽 Disks")
            /usr/bin/gnome-disks > /dev/null &
            ;;
         
        "🔋 Power Stats")
            /usr/bin/gnome-power-statistics > /dev/null &
            ;;
        "⚡ System Monitor")
            gnome-system-monitor > /dev/null &
            ;;
        "📚 Disk Space")
            /usr/bin/baobab > /dev/null &
            ;;
        "️🖨️ Printers")
            system-config-printer > /dev/null &
            ;;
            
        "🗂️ Ranger (W+g)")
            ~/.config/i3/term.sh -e $HOME/git/ranger/ranger.py > /dev/null &
            ;;
        "💻 Terminal (W+Enter|W+t)")
            ~/.config/i3/term.sh > /dev/null &
            ;;
        "📅 Calendar")
            /usr/bin/zenity --calendar --text="$(date)" --width=320 > /dev/null &
            ;;
        
        "🏳️‍🌈 Lock Screen (W+Esc)")
            echo "Password1!" | xclip -i -sel p -f | xclip -i -sel c -f | xclip -i -sel s -f > /dev/null
            /usr/bin/i3lock -u -i ~/bin/img/i3lock.png > /dev/null
            ;;
        "📲 Logout")
            /usr/bin/i3-msg exit > /dev/null
            ;;
        "♻️ Reboot")
            systemctl reboot > /dev/null
            ;;
        "⛔ Shutdown")
            systemctl poweroff -i > /dev/null
            ;;
    esac
fi
