#Disable Send Error Reports to Canonical in Lubuntu

2014-05-15

<!--- tags: linux -->

If something crashes Ubuntu shows an error dialog and offer the options to send the error data by default.

To fully [disable](http://linuxg.net/how-to-disable-the-apport-error-reporting-on-ubuntu-14-04-trusty-tahr/) showing of error dialogs, edit `/etc/default/apport` file and set `enabled=0`, then stop the service `sudo service apport stop`. To temporary disable apport use: `sudo service apport start force_start=1`.

I usually want to get the error report dialog pop up, only I do not want to have to send the report data. In normal Ubuntu this can be configured from the Privacy Settings. In Lubuntu, you have to edit `/etc/default/whoopsie` file and set `report_crashes=false` (and use `sudo service whoopsie stop` to stop the service).

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-05-19-Mount-EncFs-Folder-at-Login-in-Lubuntu.md'>Mount EncFs Folder at Login in Lubuntu</a> <a id='fnext' href='#blog/2014/2014-05-05-KnockoutJS-API-Reference.md'>KnockoutJS API Reference</a></ins>
