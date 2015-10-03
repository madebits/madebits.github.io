#Back to Classic Desktop

2012-11-01

<!--- tags: linux -->

I used GNOME3 for some time under Linux Mint 12 and I found it nice. I installed some extensions and I got very fast used to switch between the applications preview screen and the full screen applications.

This went on for some time, until I had understood (by using Lubuntu in my Asus Eee PC) I was spending unnecessary time switching between the applications preview screen and the applications. I decided to get back using a more classic UI (Lubuntu / LXDE) and I felt like I had missed the old desktop with icons and application panels that do not get into your way when doing things.

I got something back from GNOME3 to Lubuntu. Given I mainly use Lubuntu on my Asus Eee PC, I thought full-screen applications would make sense, given the relative small screen size. I modified openbox config to open all application windows full-screen. In `~/.config/openbox/lubuntu-rc.xml` I added the following I found in a forum in applications element:

```
<application class="*">
 <maximized>yes</maximized>
</application>
<application type="dialog">
  <maximized>no</maximized>
</application>
```

This worked ok for most of the applications (thought some dialogs showed bigger than they should, I guess their windows were not marked as dialogs). I was very happy with the full screen set up for some month or so. But then I missed again the possibility to have more than one window visible at the same time, so now am back where I started with Lubuntu and I plan to spend some more time with it as my main system. A classic minimal desktop seems now much more useful that the more exotic setups I have tried before.

One thing that makes Lubuntu look nice is the icon theme:

```
sudo add-apt-repository ppa:tiheum/equinox
sudo apt-get update
sudo apt-get install faenza-icon-theme
```

<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-01-02-Using-Git-with-TFS.md'>Using Git with TFS</a> <a id='fnext' href='#blog/2012/2012-09-29-Upgrading-Asus-Eee-PC-X101.md'>Upgrading Asus Eee PC X101</a></ins>
