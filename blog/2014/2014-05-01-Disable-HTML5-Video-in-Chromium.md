#Disable HTML5 Video in Chromium

2014-05-01

<!--- tags: browser linux -->

HTML5 video / audio is great, but it lacks behind in usability to Adobe flash. There is also no click-to-play support as for the rest of plugins. To disable HTML5 video/audio in Chromium in (L)Ubuntu remove `libffmpegsumo.so` from `/usr/lib/chromium-browser` folder. You need to that as root. Keep the file somewhere around in case you change your mind.

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-05-05-KnockoutJS-API-Reference.md'>KnockoutJS API Reference</a> <a id='fnext' href='#blog/2014/2014-04-28-Debugging-Plain-C-Programs-in-QtCreator-in-Ubuntu.md'>Debugging Plain C Programs in QtCreator in Ubuntu</a></ins>
