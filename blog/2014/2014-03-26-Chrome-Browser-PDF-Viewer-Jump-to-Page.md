#Chrome Browser PDF Viewer: Jump to Page

2014-03-26 

<!--- tags: browser -->

Chrome Browser PDF viewer can jump directly to a page, supporting `#page=number` format of the [Adobe Open PDF parameters](http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/pdf_open_parameters.pdf#page=5).

To jump to a page within an already open document, after typing `#page=number` after the link, one has to press the `Enter` key twice in the address bar. It only works on the second `Enter` key press.

Page width settings are no kept when jumping to a page, and other Adobe Open PDF parameters seem not to work, but at least now I know there is a way to jump at a given page using the keyboard.

In short, use `Ctrl+L` to focus the address bar, type `#page=number` where you want to go, press `Enter` (nothing happens). Press `Ctrl+L` and `Enter` again, now you are at page. Tested with various local and remote PDF documents and it appears to work.

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-03-29-Linux-Command-Line-like-Game-Bandit.md'>Linux Command Line like Game Bandit</a> <a id='fnext' href='#blog/2014/2014-03-22-Versioning-Home-Configuration-Files-with-Git-and-DropBox.md'>Versioning Home Configuration Files with Git and DropBox</a></ins>
