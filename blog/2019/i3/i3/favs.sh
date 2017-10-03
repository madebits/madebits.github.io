#!/bin/sh

#https://emojipedia.org/search/?q=box

bl=$(/etc/acpi/actions/bl-status.sh)
up=$(uptime | cut -d ',' -f 1)

sel=$(zenity --window-icon=question --height 900 --width 640 --list --title="☀️ ${bl}% | 🧑 ${USER} | 🕛 ${up} | 💻 Apps" --column "Apps"\
 ↗️... 🌐Browser 📂Files 📧Email 💥Sublime 📝Geany 🗳️DropBox 🌎Firefox\
 📦VirtualBox 🔑VeraCrypt 🔐KeepassXC 🎦Vlc 🎶Audacious\
 🖼️Gimp 🏢Office 🧮Calculator 🗂️Ranger 💻Terminal\
 💽Disks 🔄Updates 👨‍💻Synaptic 📚DiskSpace ⚡SysMon 🔋PowerStats 🛠️i3Config 🔊Volume-Up 🔉Volume-Down 📲Logout 🔶Reboot ⛔Shutdown   2>/dev/null)

case "$sel" in
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
        gnome-disks &
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
    🔶Reboot)
        systemctl reboot
        ;;
    ⛔Shutdown)
        systemctl poweroff -i
        ;;
    ↗️...)
        sleep 1
        rofi -modi 'drun#window#run' -show drun -show-icons -sort &
        ;;
    🔊Volume-Up)
        pactl set-sink-volume 0 +20%
        ;;
    🔉Volume-Down)
        pactl set-sink-volume 0 -20%
        ;;
    🔋PowerStats)
         gnome-power-statistics
        ;;
    *)
        exit 1
esac

exit 0
