#Restoring Chromium Configuration Folder

2014-04-26

<!--- tags: linux browser -->

I start Chromium web browser in incognito mode in Ubuntu using command-line arguments similar to the following:

```
--disk-cache-dir=/dev/null --disk-cache-size=1 --incognito -start-maximized --no-first-run --user-data-dir=/home/$USER/Private/chromium
```

Despite this, Chromium stores a lot of data in its profile folder. I have no idea why these data are good for me and I have found no use for them. To clean them, I created a small script that starts Chrome with a clean profile and takes over only my settings, bookmarks, and extensions from the old one.

The script below, if used to start Chromium periodically will prevent it from collecting any historic data over time locally in incognito mode:

```
#!/bin/bash

#edit these as needed
CHROME_CONFIG_PARENT_DIR=$XDG_CONFIG_HOME
CHROME_CONFIG_DIR=chromium
CHROME=/usr/bin/chromium-browser

#no need to edit

DIR="${CHROME_CONFIG_PARENT_DIR}/${CHROME_CONFIG_DIR}"
DIRTMP="${DIR}_TMP"
DIRTMP1="${DIR}_TMP1"

echo "${DIR}"

mkdir -p "${DIRTMP}/Default"
cp "${DIR}/Local State" "${DIRTMP}/"
cp "${DIR}/Default/Preferences" "${DIRTMP}/Default"
cp "${DIR}/Default/Bookmarks" "${DIRTMP}/Default"
cp -r "${DIR}/Default/Extensions/" "${DIRTMP}/Default"
cp -r "${DIR}/Default/Local Extension Settings/" "${DIRTMP}/Default"
mv "${DIR}/" "${DIRTMP1}/"
mv "${DIRTMP}/" "${DIR}/"

"$CHROME" &
chromepid=$!
sleep 3
kill $chromepid
sleep 2

rm "${DIR}/Default/Web Data-journal"
sqlite3 "${DIR}/Default/Web Data" "DELETE FROM 'keywords';"
sqlite3 "${DIR}/Default/Web Data" "INSERT INTO 'keywords' VALUES ('8','n','n','','https://{searchTerms}','0','','1396022264','0','','1','','0','0','','1396022264','B2B5BD5D-722A-9641-1288-2624FB8DD3FA','[]','','','','','','','');"
sqlite3 "${DIR}/Default/Web Data" "INSERT OR REPLACE INTO 'meta' (key, value) VALUES ('Default Search Provider ID', '8');"

"$CHROME" &

rm -rf "${DIRTMP1}/"
```

The first part of the script re-creates the current profile and takes over from the old the extensions and their state, the bookmarks, and the the preferences.

The rest is a trick to deal with search engines. They are stored in `Web Data` file, a `sqlite3` DB. I start Chromium first time to have it re-create Web Data file. Then I kill it, and set my own search engine configuration (it basically disables search from the address bar). Then I start Chromium again and remove the old profile. You need to install: `sudo apt-get install sqlite3`

I can use this file to start Chromium once a while - the profile folder size goes down then from over 20MB to less than 2MB.

As a related tip, apart of using 'uBlock' in browser, my `/etc/hosts` contains the following entries, just to be sure:

```
0.0.0.0 google-analytics.com
0.0.0.0 www.google-analytics.com
0.0.0.0 ssl.google-analytics.com
0.0.0.0 pagead.googlesyndication.com
0.0.0.0 pagead2.googlesyndication.com
0.0.0.0 adservices.google.com
0.0.0.0 imageads.googleadservices.com 
0.0.0.0 imageads1.googleadservices.com
0.0.0.0 imageads2.googleadservices.com
0.0.0.0 imageads3.googleadservices.com
0.0.0.0 imageads4.googleadservices.com
0.0.0.0 imageads5.googleadservices.com
0.0.0.0 imageads6.googleadservices.com
0.0.0.0 imageads7.googleadservices.com
0.0.0.0 imageads8.googleadservices.com
0.0.0.0 imageads9.googleadservices.com
0.0.0.0 partner.googleadservices.com
0.0.0.0 www.googleadservices.com
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2014/2014-04-28-Debugging-Plain-C-Programs-in-QtCreator-in-Ubuntu.md'>Debugging Plain C Programs in QtCreator in Ubuntu</a> <a rel='next' id='fnext' href='#blog/2014/2014-04-18-Upgrading-Lubuntu-13.10-to-Lubuntu-14.04.md'>Upgrading Lubuntu 13.10 to Lubuntu 14.04</a></ins>
