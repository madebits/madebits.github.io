2005

#ShtypShqip Firefox Extension

<!--- tags: javascript browser -->

`ShtypShqip` is a free Firefox browser extension that enables typing in every text box of the visited pages: ee for ë, EE for Ë, cc for ç, and CC for Ç. ShtypShqip enables typing correct Albanian without a special keyboard. This method works well for Albanian language because:

* There are no words in Albanian where the letters e and c appear double.
* When people want to type ë and ç, and they do not find them in the keyboard, they often use e and c. Typing e twice to get ë can be learned this way very fast, compared to using any other combination.
* ShtypShqip does not offer any spell-checking functionality. It offers only a convenient way to type ë and ç, when they are not found in keyboard.

##Installation

Download and open in Firefox 'shtypshqip.xpi' file (using 'File / Open File' menu). ShtypShqip will be installed and a restart of Firefox is required.

##Usage

`ShtypShqip` Firefox extension adds a 'ShtypShqip' menu item in the 'Edit' menu of Firefox.

![](r/js-shtypshqip/menu.gif)

And an icon in the bottom-right of the status bar of Firefox.

Enabled:  ![](r/js-shtypshqip/status1.gif) Disabled: ![](r/js-shtypshqip/status2.gif)

By default, ShtypShqip is enabled. You can now type ee for ë, EE for Ë, cc for ç, and CC for Ç in all form text input fields of every visited web page.

![](r/js-shtypshqip/example.gif)

To disable / enable ShtypShqip use one of these methods:

* Uncheck the 'Edit / ShtypShqip' menu.
* Use Ctrl+Shift+S keyboard shortcut.
* Click on the ShtypShqip status bar icon.
* You can disable ShtypShqip temporary for some text fields and enable it back for others.

##Options

The ShtypShqip options can be accessed via Firefox 'Tools / Add-ons' menu.

![](r/js-shtypshqip/options.gif)

* ShtypShqip affects every text input field, apart of those whose HTML names or ids contain as part any of the strings listed in You can add / remove new strings one per line here. The defaults are mostly ok. Only ANSII strings are accepted.

* You can also choose to disable default Firefox spell check of fields which can be distracting if there is no proper dictionary. (Hint: You can get a proper dictionary from [here](http://www.google.com/search?btnI=I%27m+Feeling+Lucky&q=firefox+dictionaries).)
Changes in options will be applied only to the newly opened or refreshed pages.

##Uninstall

Using Firefox 'Tools / Add-ons' menu, you can also uninstall ShtypShqip if you do not like it.