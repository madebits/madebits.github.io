#Ubuntu: Chromium Flags Per User

2016-12-24

<!--- tags: linux browser -->

I like how the start script of `chromium-browser` on Arch Linux [expects](https://wiki.archlinux.org/index.php/Chromium_tweaks#Making_Flags_Persistent) per user Chromium [flags](http://peter.sh/experiments/chromium-command-line-switches/) to be added in `$XDG_CONFIG_HOME/chromium-flags.conf`. Same effect can be achieved in Ubuntu as follows:

* **Method 1**: Modify as root `/etc/chromium-browser/default` to look:

    ```bash
    # Default settings for chromium-browser. This file is sourced by /bin/sh from
    # /usr/bin/chromium-browser

    USER_PARAMS=""
    USER_FILE=$XDG_CONFIG_HOME/chromium-flags.conf
    if [ -f "$USER_FILE" ]; then
        USER_PARAMS=`grep -v '^#' "$USER_FILE" | tr '\n' ' '`
    fi

    # Options to pass to chromium-browser
    CHROMIUM_FLAGS="$USER_PARAMS"
    ```

* **Method 2**: Another way to achieve same is to leave `/etc/chromium-browser/default` unchanged:

    ```bash
    # Default settings for chromium-browser. This file is sourced by /bin/sh from
    # /usr/bin/chromium-browser

    # Options to pass to chromium-browser
    CHROMIUM_FLAGS=""
    ```

 and instead, add a new file `/etc/chromium-browser/customizations/99-user`:

    ```bash
    USER_PARAMS=""
    USER_FILE=$XDG_CONFIG_HOME/chromium-flags.conf
    if [ -f "$USER_FILE" ]; then
        USER_PARAMS=`grep -v '^#' "$USER_FILE" | tr '\n' ' '`
        CHROMIUM_FLAGS="${CHROMIUM_FLAGS} ${USER_PARAMS}"
    fi
    ```

Using any of the above methods, per user arguments can be defined one per line in `~/.config/chromium-flags.conf`, for example:

```
--disk-cache-dir=/dev/null
--disk-cache-size=1
--incognito
--force-device-scale-factor=1
--start-maximized
--no-first-run
--user-data-dir=/home/user/Private/chromium
#test
--ignore-gpu-blacklist
--enable-vaapi
```

Lines starting with `#` are treated as comments.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-12-30-Lubuntu-on-Dell-Latitude-E5570.md'>Lubuntu on Dell Latitude E5570</a> <a rel='next' id='fnext' href='#blog/2016/2016-12-19-Opera-On-Ubuntu.md'>Opera On Ubuntu</a></ins>
