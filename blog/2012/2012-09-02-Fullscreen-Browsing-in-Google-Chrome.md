#Fullscreen Browsing in Google Chrome

2012-09-02

<!--- tags: browser -->

Google Chrome browser fullscreen implementation is very [limited](http://code.google.com/p/chromium/issues/detail?id=8022) when it comes to do normal navigation. The following is a method to navigate with Google Chrome in fullscreen mode without additional software.

First problem to solve is how to move around already opened tabs. The following Chrome keyboard shortcuts help with this:

* Shift+Esc - this open the Chrome Task Manager. It lists, among others, all open tabs. A double-click with mouse switches to that tab.
* Ctrl+Tab switches to next tab in order (if you open a link in a new tab, then Ctrl+Tab moves you to it).
* Ctrl+Shift+Tab switches to previous tab in order.
* Ctrl+click or middle click opens a link in new tab.
* Ctrl+W or Ctrl+F4 closes an open tab.
* Ctrl+H accesses history.
* Ctrl+D to bookmark a page.
* Ctrl+Shit+O to open bookmarks.

Second problem to solve is how to open new links because the address bar is not visible on full mode. A solution to this is to use as Home page something that has some kind of address bar. The Home page can be open any time using Alt+Home shortcut.

The simplest is to set as home page in Chrome some search engine URL, for example, in Settings, Home Page, Open this page, set as address: http://www.bing.com This will show the Bing search box that can be used at some extend also to navigate to new addresses. Most people browse web anyway usually like this.

Another one method is to use a custom static HTML file as home page. For example, create a text file named `home.html` somewhere, and set its local path address (e.g.: `file:///home/user/Scripts/home.html`) as home page, similar to above. The `home.html` file contents could then look as follows:

```
<html>
<title>Home</title>
<script>
function openUrl(){
	var address = document.getElementById('url').value;
	var useNewTab = document.getElementById('newtab').checked;
	if(!(startsWith(address, "http://")
		|| startsWith(address, "https://")
		|| startsWith(address, "ftp://")
		|| startsWith(address, "ftps://")
		|| startsWith(address, "mailto://")
		|| startsWith(address, "javascript://"))){
		address = "http://" + address;
	}
	if(useNewTab) {
		window.open(address, '_blank');
		window.focus();
	}
	else {
		window.location.href = address;
	}
}

function startsWith(str, prefix)
{
	return (str.toLowerCase().indexOf(prefix) == 0)
}

function selectAll(){
	document.getElementById('url').select();	
}
</script>
<body>
<center>
<form onsubmit="openUrl(); return false;">
<label for="url">Address:</label>
<input id="url" type="text" value="bing.com" size="70" onClick="selectAll()" />
<label for="newtab">New tab:</label>
<input id="newtab" type="checkbox" /> <!-- checked="checked" -->
<input type="submit" value="Open"/>
</form>
</center>
</body>
</html>
```

This custom `home.html` file can be also extended to contain also your most used links, and also submission forms for Bing and Google, as I have done.


<ins class='nfooter'><a id='fprev' href='#blog/2012/2012-09-08-Lubuntu-Toggle-Desktop-Icons-on-Double-Click.md'>Lubuntu Toggle Desktop Icons on Double Click</a> <a id='fnext' href='#blog/2012/2012-08-30-Reading-a-Text-File-from-Command-line-in-Windows.md'>Reading a Text File from Command line in Windows</a></ins>
