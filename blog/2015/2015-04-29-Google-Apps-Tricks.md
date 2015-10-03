#Google Apps Tricks

2015-04-29

<!--- tags: browser -->

We use Google Apps at work and the very first thing IT controls is the start page of Chrome via Windows group policy. The following tricks assume you have admin access to the machine.

If you love the Google site corporate page and like to visit it when you want and not on every Chrome startup, then replace the Crome browser shortcut with a call to a .bat file (e.g.: C:\chrome.bat) with the following content:

```bat
@echo off
reg DELETE HKEY_CURRENT_USER\Software\Policies\Google\Chrome /f 2> nul
reg DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome /f 2> nul
start "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" "https://bing.com"
```

This will start Chrome with https://bing.com instead (of course you can replace it with something else).

The other great thing is all love Google analytics (me included). Even access to the internal canteen menu page is therefore tracked. To remedy this edit `%SystemRoot%\system32\drivers\etc\hosts` and append to it:

```
127.0.0.1 google-analytics.com
127.0.0.1 www.google-analytics.com
127.0.0.1 ssl.google-analytics.com
```

You need to clean Chrome browser cache and reopen Chrome for this to take effect.

Of course Chrome knows if you if you login to Google Apps (mail, etc), so it is advised you do the rest of browsing in another browser. 

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-05-12-Using-SVD-to-Reduce-Images.md'>Using SVD to Reduce Images</a> <a id='fnext' href='#blog/2015/2015-04-23-Test-Code-Coverage-As-Quality-Metric.md'>Test Code Coverage As Quality Metric</a></ins>
