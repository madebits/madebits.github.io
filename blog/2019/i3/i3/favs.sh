#!/bin/sh

#https://emojipedia.org/search/?q=box

bl=$(/etc/acpi/actions/bl-status.sh)
up=$(uptime | cut -d ',' -f 1)
mem=$(free -h | grep Mem: | tr -s ' ' | cut -d ' ' -f 3,2,4)

sel=$(zenity --window-icon=question --height 900 --width 640 --list --title="🧑 ${USER} | 🕛 ${up} | Ⓜ️ ${mem} | ☀️ ${bl}% | 💻 Apps" --column "Apps"\
 ↗️... ☠️i3Kill 🌐Browser 📂Files 📧Email 💥Sublime 📝Geany 🗳️DropBox 🌎Firefox\
 📦VirtualBox 🔑VeraCrypt 🔐KeepassXC 🎦Vlc 🎶Audacious\
 🖼️Gimp 🏢Office 🧮Calculator 🗂️Ranger 💻Terminal\
 💽Disks 🔄Updates 👨‍💻Synaptic 📚DiskSpace ⚡SysMon 🔋PowerStats 🛠️i3Config 🎛️i3Toggle-Layout 🔊Volume-Up 🔉Volume-Down 📲Logout ♻️Reboot ⛔Shutdown   2>/dev/null)

case "$sel" in
    ☠️i3Kill)
        i3-msg 'kill'
        ;;
    🛠️i3Config)
        exec geany -i $HOME/.config/i3/config $HOME/.config/i3/favs.sh $HOME/.config/i3/start.sh $HOME/.config/i3status/config
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
        exec zenity --password | sudo -S update-manager
        ;;
    💽Disks)
        exec gnome-disks
        ;;
    👨‍💻Synaptic)
        exec zenity --password | sudo -S synaptic
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
        sleep 0.1
        rofi -modi 'window#drun#run' -show window -show-icons -sort -width 90 -lines 30 -sidebar-mode -columns 4 &
        ;;
    🔊Volume-Up)
        pactl set-sink-volume 0 +20%
        ;;
    🔉Volume-Down)
        pactl set-sink-volume 0 -20%
        ;;
    🎛️i3Toggle-Layout)
         i3-msg 'layout toggle tabbed stacking split' &
        ;;
    🔋PowerStats)
         exec gnome-power-statistics
        ;;
    *)
        exit 1
esac

exit 0
