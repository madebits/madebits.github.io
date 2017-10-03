# Script to Start Google Chrome

2021-12-19

<!--- tags: linux -->

The following Bash script helps start Chrome with minimal shared local state between runs:

```bash
#!/bin/bash -

export LC_MEASUREMENT=en_US.UTF-8
export LC_PAPER=en_US.UTF-8
export LC_MONETARY=en_US.UTF-8
export LC_NAME=en_US.UTF-8
export LC_ADDRESS=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8
export LC_TELEPHONE=en_US.UTF-8
export LC_IDENTIFICATION=en_US.UTF-8
export LC_TIME=en_US.UTF-8
export TZ="America/Los_Angeles"
export LC_ALL=en_US

# https://peter.sh/experiments/chromium-command-line-switches/

options=(
--disable-reading-from-canvas
#--disable-remote-fonts
--disable-bundled-ppapi-flash
--disable-breakpad
--disable-background-mode
--disable-3d-apis
--disable-webgl
--disable-features=PreloadMediaEngagementData,MediaEngagementBypassAutoplayPolicies,RecordMediaEngagementScores,RecordWebAudioEngagement
--dns-prefetch-disable
--disable-translate
--disable-preconnect
--disable-plugins-discovery
--disable-background-mode
--disable-notifications
--disable-speech-api
--disable-sync
--disable-gpu-shader-disk-cache
--shader-disk-cache-size-kb=1
--no-referrers
--no-pings
--no-experiments
--reset-variation-state
--enable-dom-distiller
)

profileDir=/home/$USER/.config/google-chrome

shopt -s dotglob

/bin/fuser /opt/google/chrome/chrome > /dev/null
lastExit=$?
if [ "$lastExit" = "1" ]; then
    echo "chrome cleanup"
    rm -rf -- "/home/$USER/.config/google-chrome/Crash Reports"

    for f in $profileDir/* ; do
        if [ -d "$f" ]; then
            dName=$(basename -- "$f")
            if [ "$dName" = "Default" ]; then
                echo "keeping  $f"
            else
                rm -rf -- "$f"
            fi
        else
            rm -f -- "$f"
        fi
    done

    for f in $profileDir/Default/* ; do
        dName=$(basename -- "$f")
        if [ -d "$f" ]; then
            case "$dName" in
                Extensions|"Local Extension Settings"|"Sync Extension Settings")
                echo "keeping  $f"
                ;;
                *)
                rm -rf -- "$f"
                ;;
            esac
        else
            case "$dName" in
                Bookmarks|Preferences) #|"Web Data"
                echo "keeping  $f"
                ;;
                *)
                rm -f -- "$f"
                ;;
            esac
        fi
    done

fi

/usr/bin/google-chrome-stable ${options[@]} --disk-cache-dir=/dev/null --disk-cache-size=1 --media-cache-size=0 --incognito -start-maximized --no-first-run --user-data-dir=$profileDir
```

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2021/2021-11-26-Using-brightnessctl.md'>Using brightnessctl</a></ins>
