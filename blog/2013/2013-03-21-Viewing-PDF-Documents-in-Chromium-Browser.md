#Viewing PDF Documents in Chromium Browser

2013-03-21

<!--- tags: browser -->

I often use my Asus EeePC X101 with Lubuntu as PDF reader to read books, using Evince as PDF reader and I am usually happy with it. Recently, I got a PDF that Evince could not properly render.

Evince shows the cover page of the book, but the rest of them it could not render. I did not want to install the full-blown `acroread` package, so I tried various other free PDF readers having more or less same results as with Evince, so I removed them again.

Then I thought to give Chromium browser a try. As it turns out the PDF viewer is not part of Chromium as it is not open source. At Ubuntu [forums](http://askubuntu.com/questions/12584/why-doesnt-chromium-have-chrome-pdf-viewer-plugin) they suggest to download the Chrome deb package, extract from it the `libpdf.so` file, and copy it (as root) under `/usr/lib/chromium-browser/`.

It worked like a charm and it could open the problematic PDF without problems. It even uses very few CPU. It lacks some of the features of Evince, but nevertheless I only plan to use it as alternative when Evince fails.

Firefox's built-in PDF preview has same rendering problems as Evince. Firefox PDF preview is more usable that Chrome one. It shows pages and table of contents. The Chrome one really lacks usability to move around PDF the document.

<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-05-04-Configuring-Wacom-Bambo-Pen-on-Lubuntu.md'>Configuring Wacom Bambo Pen on Lubuntu</a> <a id='fnext' href='#blog/2013/2013-03-04-Google-Hangout-Share-both-Screen-and-Camera.md'>Google Hangout Share both Screen and Camera</a></ins>
