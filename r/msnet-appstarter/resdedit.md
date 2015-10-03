#AppStarter: Changing EXE Icon and Information Tutorial

[AppStarter](#r/msnet-appstarter.md)

There are several free and commercial EXE resource editors that can be used to change icon and information of an EXE file. This tutorial describes how to use one of them.

[ResEdit](http://www.resedit.net/) is free EXE resource editor for Windows. To replace the EXE file information and icon first **make a backup copy** of the original EXE. Then download ResEdit from its web site, unzip in a folder, and run resedit.exe, and follow these steps:

![](r/msnet-appstarter/re/001.png)

Step 1: Ignore ResEdit configuration requests. Do **not** create a new project.

![](r/msnet-appstarter/re/002.png)

Step 2: Use open button in toolbar to open the EXE file.

![](r/msnet-appstarter/re/003.png)

Step 3: Edit Version information fields. Double-click on a field value and enter text. Set at least FileDescription and CompanyName.

![](r/msnet-appstarter/re/004.png)

Step 4: Right-click on the icon resource, and select [Insert an Icon] from context menu. Specify the icon file you want to use. For best results, the icon file must contain same icon image in at least the following resolutions (in pixels): 16x16, 32x32, 48x48, 64x64.

![](r/msnet-appstarter/re/005.png)

Step 5: Write down somewhere the old icon id, e.g.: 32512 and then right-click on the old icon and select [Remove from project] menu to delete it. Then right-click on the new icon and select [Rename] from context menu. Enter the id of the old icon, e.g.: 32512 and confirm the dialog.

![](r/msnet-appstarter/re/006.png)

Step 6: When done save the file, using the save button in toolbar. Then close ResEdit - you are done.

![](r/msnet-appstarter/re/007.png)

Step 7: Verify the changes you made to the EXE file, using Windows Explorer (right-click on file and select [Properties] and then go to [Details] tab). The modified EXE file could have a different size than the original one.

Get latest version of [ResEdit](http://www.resedit.net/) from its web site. A older version of the files is mirrored here ([32 bit](r/msnet-appstarter/re/ResEdit-win32.7z), [64 bit](r/msnet-appstarter/re/ResEdit-x64.7z)).

[AppStarter](#r/msnet-appstarter.md)