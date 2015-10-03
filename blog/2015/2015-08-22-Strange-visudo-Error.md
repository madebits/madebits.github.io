#Strange visudo Error

2015-08-22

I run into a strange `visudo` error in Ubuntu 14.04. If I try to edit via `sudo visudo`, or `sudo -i` and then `visudo`, I cannot save my changes, and get the following error:

```
visudo: error renaming /etc/sudoers.tmp, /etc/sudoers unchanged: Device or resource busy
```

I thought first it was some SSD related issue (I have a SSD). After failing to find anything in Google, I noticed by chance this is related to `chromium-browser` being open. As soon as I open `chromium-browser`, I get same error, and and soon as I close it, `visudo` works - fully reproducible. 

After a further look, it turned out that I use `firejail chromium-browser` to start Chrome. If I start `chromium-browser` without `firejail` then `visudo` works without problems, so it seems to be related to [firejail](https://l3net.wordpress.com/projects/firejail/) usage. However, just starting only `firejail` (with `bash`) I do not get this problem. So it should be related somehow to `firejail` *chromium-browser* profile.

I have customized the `chromium-browser.profile` (in `~.config/firejail`) to add `blacklist /etc/sudoers`. But, I fail to see how this affects `visudo` in a separate terminal.


<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-08-23-Scrum-Master-Certification.md'>Scrum Master Certification</a> <a id='fnext' href='#blog/2015/2015-07-30-Gulp-Broserify-Babel.md'>Gulp Broserify Babel</a></ins>
