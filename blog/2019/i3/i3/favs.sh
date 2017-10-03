#!/bin/sh

#https://emojipedia.org/search/?q=box

bl=$(/etc/acpi/actions/bl-status.sh)
up=$(uptime | cut -d ',' -f 1)
mem=$(free -h | grep Mem: | tr -s ' ' | cut -d ' ' -f 3,2,4)

sel=$(zenity --timeout=30 --window-icon=question --height 1000 --width 640 --list --title="🧑 ${USER} | 🕛 ${up} | Ⓜ️ ${mem} | ☀️ ${bl}% | 💻 Apps" --column "Apps"\
 ☠️i3-Kill 🎛️i3-Toggle-Layout 🔲i3-New-Workspace ⛵i3-Move-To-New-Workspace 🛠️i3-Config 🌀i3-Reload 🔊Volume\
 🌐Browser 📂Files 📧Email 💥Sublime 📝Geany 🗳️DropBox 🌎Firefox\
 📦VirtualBox 🔑VeraCrypt 🔐KeepassXC 🎦Vlc 🎶Audacious\
 🖼️Gimp 🏢Office 🧮Calculator 🗂️Ranger 💻Terminal\
 💽Disks 🔄Updates 👨‍💻Synaptic ️🖨️Printers 📚DiskSpace ⚡SysMon 🔋PowerStats\
 📲Logout ♻️Reboot ⛔Shutdown 2>/dev/null)

sleep 0.1
case "$sel" in
    ☠️i3-Kill)
        i3-msg 'kill'
        ;;
    🛠️i3-Config)
        exec geany -i $HOME/.config/i3status/config $HOME/.config/i3/start.sh $HOME/.config/i3/favs.sh $HOME/.config/i3/config &
        ;;
    🌀i3-Reload)
        i3-msg reload
        i3-msg restart
        ;;
    ⛵i3-Move-To-New-Workspace)
        ~/.config/i3/i3-move-to-new-workspace.sh
        ;;
    📚DiskSpace)
        exec baobab
        ;;
    🎶Audacious)
        exec audacious
        ;;
    📦VirtualBox)
        exec virtualbox
        ;;
    📧Email)
        exec thunderbird
        ;;
    🔑VeraCrypt)
        exec /usr/bin/veracrypt
        ;;
    🔐KeepassXC)
        exec keepassxc
        ;;
    🗳️DropBox)
        $HOME/.dropbox-dist/dropboxd
        ;;
    🌐Browser)
        exec chromium-browser
        ;;
    🌎Firefox)
        firefox
        ;;
    📂Files)
        exec nautilus
        ;;
    💥Sublime)
        exec $HOME/opt/sublime_text_3/sublime_text
        ;;
    📝Geany)
        exec geany -i
        ;;
    🔄Updates)
        #exec zenity --password | sudo -S update-manager
        update-manager 
        ;;
    💽Disks)
        exec gnome-disks
        ;;
    👨‍💻Synaptic)
        #exec zenity --password | sudo -S synaptic
        synaptic-pkexec &
        ;;
    🧮Calculator)
        exec speedcrunch
        ;;
    🏢Office)
        exec libreoffice
        ;;
    🎦Vlc)
        exec vlc $HOME/Desktop/music.xspf
        ;;
    ⚡SysMon)
        exec gnome-system-monitor
        ;;
    🖼️Gimp)
        exec gimp
        ;;
    🗂️Ranger)
        exec xterm -e ranger
        ;;
    💻Terminal)
        exec xterm
        ;;
    📲Logout)
        i3-msg exit
        ;;
    ♻️Reboot)
        systemctl reboot
        ;;
    ⛔Shutdown)
        systemctl poweroff -i
        ;;
    ↗️...)
        #sleep 0.1
        rofi -modi 'window#drun#run' -show window -show-icons -sort -width 90 -lines 30 -sidebar-mode -columns 4 -terminal xterm &
        ;;
    🔊Volume)
        exec pavucontrol
        ;;
    🔊Volume-Up)
        pactl set-sink-volume @DEFAULT_SINK@ +20%
        ;;
    🔉Volume-Down)
        pactl set-sink-volume @DEFAULT_SINK@ -20%
        ;;
    🔇Volume-0)
        pactl set-sink-volume @DEFAULT_SINK@ 0
        ;;
    🎛️i3-Toggle-Layout)
         i3-msg 'layout toggle tabbed stacking split' &
        ;;
    🔲i3-New-Workspace)
        ~/.config/i3/i3-new-workspace.sh
        ;;
    🔋PowerStats)
         exec gnome-power-statistics
        ;;
    ️🖨️Printers)
        exec system-config-printer
        ;;
    *)
        exit 1
esac

exit 0
