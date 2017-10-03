2011

# Simplicity Home Theater (HTPC)

**Simplicity Home Theater** is a file browser and launcher for home theater personal computers ([HTPC](http://en.wikipedia.org/wiki/10-foot_user_interface)) running Microsoft Windows. Simplicity can be used to directly browse hard-disk folders and launch content, such as movies.

![inline](r/msnet-simplicity-home-theater/s00t.jpg) ![inline](r/msnet-simplicity-home-theater/s01t.jpg) ![inline](r/msnet-simplicity-home-theater/s03t.jpg)

![inline](r/msnet-simplicity-home-theater/s02t.jpg) ![inline](r/msnet-simplicity-home-theater/m01t.jpg) ![inline](r/msnet-simplicity-home-theater/m02t.jpg)

## Usage

The best way of using Simplicity Home Theater is to have at least two user accounts on your machine. On one user account set Windows text size to 200% and configure Simplicity Home Theater to auto start - this will be the account to use while connected in TV. The other account can then be used (locally or remotely) to manage the PC and the files using Windows Shell.

Simplicity enables browsing of system folders and launching of single files using the associated default system application or user defined custom launcher applications. Simplicity starts by showing all system logical drives or the last path browsed in the previous session. Use the keyboard Up / Down keys to move up and down list items or mouse wheel. To browse (explore) a folder, select it and press enter key.

To launch a file, select it and press enter. The file launcher list will show. It can by default run only the system associated application for the file type, but you can your own applications, by editing `lauchers.txt` configuration file. The launchers list for folders can be accessed via context menu (key and mouse).

From the launchers list you can also view more details about selected path. Same details are shown if you press space key on browser list, or click on the path bar shown below the browser list. The details list shows the parent paths, and several options, such as deleting the file or folder, or viewing full path.

The details list contains also options to exit the application and view several system details. The system details contain a clipboard text editor that can edit clipboard text copied from other applications, or to write new text to clipboard to paste it in other applications. Enter, or Escape key (or mouse right click) closes the clipboard text window. In system list you can also manage the currently running applications.

Simplicity offers directly only few file management operations, but you can configure and launch Windows Shell via it at any time for doing more advanced stuff.

All Simplicity functions can be reached either via mouse or via keyboard. Simplicity itself can be also use with a Windows Media Center minimal compatible remote control - to switch back the focus after you launch an external application, you may need a keyboard (Alt+Tab) or a mouse-like device. Some keys work only on browser window, and have no effects on the other option lists.

|Key|Function|
|-|-|
|Down|Select next item (same as mouse wheel down)|
|Up|Select previous item (same as mouse wheel up)|
|Home|Select first item|
|End|Select last item|
|Page Down|Select next page|
|Page Up|Select previous page|
|Enter|Activates selected item (same as mouse (double) click): On browser window explores folder or opens file launcher. On other windows activates selected item.|
|Space|Same as Enter key.|
|Right|Same as Enter key.|
|Application (Windows keyboard app context menu key)|On browser window shows launcher for selected item (same as mouse right-click menu, context menu).|
|Left|On browser shows details list.|
|Shift or Ctrl or Alt + Space|Same as Left key.|
|Esc (Escape)| On browser window, moves back to parent folder, or enables application exit on top root level. Cancels (closes) open window.|
|Back|Same as Esc key. (On text input Back deletes text)|
|any printable key|Selects next item starting with that key, if any.|
|MediaPlayPause|Same as Enter key.|
|MediaStop|Same as Esc key.|
|MediaNextTrack|Same as Down key.|
|MediaPreviousTrack|Same as Up key.|
|F5|On browser windows, refreshes content.|


There are two ways to start Simplicity Home Theater when you login:

* Create a shortcut to it in your system Startup folder (*C:\Users\USER\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup*), and optionally add `/fullscreen` command-line option to the shortcut path. Set also your system **taskbar in auto-hide mode**. Full screen works also when taskbar is visible (thought you may not like taskbar showing on top while launching applications).
* Use Simplicity Home Theater System / Auto Start option. When turned on Auto Start will start Simplicity Home Theater System as shell for current user at next user login. Better create a separate user account for use with Simplicity Home Theater System in auto start mode. You can turn Auto Start off at any time using same option. After re-login the default system shell will show back. Exit application option is not shown when Auto Start is turned off (you can do a system shutdown or log off). This is the best option, and you may consider adding a separate user account in your machine for Simplicity only.

Passing a path to Simplicity Home Theater command-line opens browses to that path. In no path is given in command-line Simplicity Home Theater starts with last path used from previous run.

Only one instance of Simplicity Home Theater can be run at a time.

## Configuration

Simplicity takes the current configuration from several files, by default located in a folder called `Simplicity Home Theater` under local application data of current user profile (e.g.: *C:\Users\USER\AppData\Local\Simplicity Home Theater*). The configuration files are created with default values on first run.

If the configuration files are put empty or copied in same location as Simplicity EXE, than the ones next to the EXE are used instead of the files from local application data location. This enables easy putting Simplicity on USB sticks, or sharing one of configuration files (e.g., launchers.txt) for all users (if files are read only that last path used will not be saved).

1. config.txt - (read / write) created with default configuration. This file can be edited by user so the custom values are read.
	* color.foreground - color R,G,B (0-255) (default 245,245,245)
	* color.background - color R,G,B (0-255) (default 0,0,0)
	* color.folder - color R,G,B (0-255) (default 255,165,0)
	* color.option - color R,G,B (0-255) (default 0,162,232)
	* activateOnClick - (default 1) to activate selected items with single click, 0 to use double-click
	* itemsPerPage - number of list items shown in one screen (default 11)
	* fontFamily - font family used
	* filefilter - by default all files are shown (empty). You can restrict the file types shown in browser, by putting here a suffixes separated with comma (example: filefilter=avi,mpg,mvk,wmv).
	* debugLog - debug (error) log, settings this to 1 (default 0) could make application slower
	* lastPath - application remembers last path used here. If a path is given in command-line it will take precedence
	* lastPath.isUpFolder - application internal flag about lastPath
1. launchers.txt (read) - custom application launchers to be used to open files. By default this file is empty ([example launchers.txt file](r/msnet-simplicity-home-theater/launchers.txt)). Application does not write to this file - it is only read. Each launcher is defined by a line starting with `app=`, having also several additional lines:
	* app=path to executable (must be a full absolute path) (required). As special case `app=*` denotes a shell only operation. In this case the arguments string (see below `args=` option) is executed directly via shell - * is useful, for example, to launch web links in default system browser. This must be the first file to define a custom launcher application.
	* text=name to show as menu option. If missing, the executable path name is shown.
	* icon=path to icon, if not specified the icon from exe file is taken (app=). You can overwrite that by using here an icon file (or other exe path).
	* args=arguments to pass to executable, if empty, no arguments are passed. Several meta-strings can be replaced in args value. Use quotes around meta-strings, e.g., `":f:"` as needed:
		* `:f:` is replaced with current item (file or folder) path. The folders do not have the path separator (`\`) in the end (apart of top volume folders).
		* `:F:` is replaced with current folder (for a file the containing folder) path. The path contains the path separator (`\`) in the end.
		* `:n:` is replaced with current item (file or folder) name (for files suffix is included).
	* filter=context of this launcher. If empty launcher is shown for all items (files and folders) (same as `*,?`). If not empty it should be a list of file suffixes separated by comma (e.g., .txt,.ini) to show launcher only for those file types. Two special values can be used: `*` means launcher applies to folders, and `?` means launcher applies to all file types (has precedence over particular suffixes). `*` and `?` can be also used together `*,?` - this is same and empty filter.
	Only valid and existing launcher applications are shown for items. Launchers can be reloaded without starting the application (see System option in application).

	Variables of form `$key=value` can be defined in launchers.txt, they are applied from the point they are defined to all values below that contain $key string. Lines starting with `#` are comments and are ignored. The special variable $simplicity is predefined to be the folder path (with end separator) of Simplicity.exe.

1. strings.txt - (read) stores text strings used by Simplicity GUI. You can edit this file to change text (translate it in another language, etc.). New versions of the program may add new strings to this file.
1. favorites.txt - (read / write) stores custom favorite paths. This file is modified immediately when you modify favorites - before modification a copy of it ending in *.bak is saved.
1. debuglog.txt - (write) is created at every startup if config.txt option debuglog=1.


## MediaPreview

**MediaPreview** is a separate application that is intended to be used in combination with **Simplicity Home Theater**. MediaPreview can preview most image files, and if `ffmpeg.exe` is available (see below), it can preview also most movie files. MediaPreview can preview single movies and images, or folders of such (thumbnails). To add MediaPreview as a launcher in Simplicity Home Theater, copy it to the same folder where Simplicity.exe is and the following to launchers.txt file.

```
app=$simplicityMediaPreview.exe
text=Media Preview
args=/fullscreen /ffmpeg "C:\ffmpeg\ffmpeg.exe" ":f:"
```

`/ffmpeg` option should point to a valid path in your system where `ffmpeg.exe` is found. You can get `ffmpeg.exe` from [various sources](http://www.videohelp.com/tools/ffmpeg) in Internet. Only `ffmpeg.exe` is needed for MediaPreview - the rest of files in downloaded packages can be deleted.

To run MediaPreview manually use:
```
MediaPreview.exe [options] path
```
Where the MediaPreview command-line options are:

* /ffmpeg - full absolute path to ffmpeg.exe. If ffmpeg.exe is in same location as MediaPreview.exe you do not need to specify /ffmpeg path (but it will not hurt if you do). Without ffmpeg, MediaPreview can only preview images but no movies.
* /fullscreen - start in full screen, useful if you also start Simplicity Home Theater in full screen.
* /maxrows - a number between 1 and 10 (default is 2) of thumbnails rows per folder page. The actual number depends on /maxrows and number of files.
* /slideshow - start slideshow at start up (it can be also started or stopped later on, see keyboard options below).
* /slidespeed - number in seconds between 3 and 60 (default 5) for slide show speed. The speed is measured single show of a page fully finishes.
* /loop - by default MediaPreview closes when trying to preview after files are finished. If /loop is specified preview continues back from beginning (or back from end in upwards).
* /noautorotate - by default images are automatically rotated based on EXIF information. The default behavior can be disabled by specifying this option.
* /border - if specified, a border is added to images (when more than one per page).
*
Keyboard and mouse options of MediaPreview are similar to those of Simplicity Home Theater:

|Key|Function|
|-|-|
|Esc (Escape)|Closes MediaPreview (same as right mouse click)|
|Back|Same as Escape key.|
|Enter|Same as Escape key.|
|Down|Next file / page. Same left right click, or mouse wheel scroll.|
|Up|Previous file / page.|
|Page Up|Next page.|
|Page Down|Next page.|
|Home|First file / page.|
|End|Last file / page.|
|Space|Next file / page.|
|Ctrl or Shift or Alt + Space|Start slide show. Same as mouse center button click. To stop slideshow, right click or press any key.|
|MediaPlayPause|Same as Ctrl or Shift or Alt + Space key.|
|MediaStop|Same as Esc key.|
|MediaNextTrack|Same as Down key.|
|MediaPreviousTrack|Same as Up key.|

Runs on Windows XP, Vista, Windows 7 (32 / 64 bit).
