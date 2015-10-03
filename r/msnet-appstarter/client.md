#AppStarter: Client Configuration

[AppStarter](#r/msnet-appstarter.md) | [Details](#r/msnet-appstarter/details.md) | [Server Configuration](#r/msnet-appstarter/server.md) | [Client Configuration](#r/msnet-appstarter/client.md) | [Tips & Hints](#r/msnet-appstarter/tips.md)| [Tools](#r/msnet-appstarter/tools.md)

<div id='toc'></div>

AppStarter client EXE that runs on the user machine is created from the generic **appstater.exe** file provided as part of the download package. The appstater.exe is uses a **default starter** template EXE. Before the default starter is used, it must be specialized and configured for your application to create a **custom starter**.

To configure the AppStarter client, start always with a **unchanged copy** of the default starter appstater.exe and apply your application **client configuration file** (described later on) using the provided [appscreator.exe](#r/msnet-appstarter/tools.md) helper tool in a command-line window:

```
appscreator /s appstarter.exe /c myappconfig.txt /o myappstater.exe
```

You can use any name for the resulting custom starter exe instead of `myappstater.exe` (and also for the input client configuration file myappconfig.txt). The resulting custom starter myappstater.exe is the only file you need to distribute to your users in order to start your application. Do **not** change or edit the custom starter exe after creation as your configuration may be lost. If you need to change it (e.g., to modify its icon) do that on a copy of appstarter.exe before using the appscreator tool.

For testing, you can place a file called `appstarter.debugconfig` in same folder as appstarter.exe (if you have renamed it to myappstater.exe, use myappstater.debugconfig). If such file is found, appstarter will read the settings from than one, rather the ones you define using appscreator. This is used to quickly test some settings, but for real use cases, test with the ones created using appscreator tool and do not distribute appstarter.debugconfig as it cannot be remotely updated.

##Client Configuration File

Client configuration file is a text file either in ASCII or UTF8 (if UTF8 with or without BOM). The client configuration file is made of lines of form `key=value`. Spaces around key and value is ignored. The key names are predefined and are **case-insensitive**. The *values* are provided by you. You need only to specify the values of a minimum of required keys. The rest are optional and could be left to default values if you are unsure. Default values can be subject of change without notice.

Lines starting directly with `#` are treated as comments and are ignored. You should not use `##` to start your comment lines, as `##`line prefix is reserved.

|Key|Details|
|-|-|
|app.guid|(Required) A unique identifier (GUID) for each application you want to use with AppStarter. Use the guid.exe tool provided along with AppStarter to generate new valid GUIDs. Do not reuse the GUID value for more than one application. Default value is app1 and it is intended for testing only. Once you set a GUID for a given application do not change it anymore afterward for that same application.|
|app.url|(Required) The URL of the server deployment file for your application. You can use a local server (http://127.0.0.1/) URL to test deployment if you have one locally, and once everything works ok locally then test with a remote one, or you can directly test with a remote server.|
|app.url2|Optional secondary URL of the server deployment file for your application. When app.url fails, the app.url2 is tried out. The purpose of this parameter is not to help distribute server load, but to help with transactional updates (read more). Default is empty.|
|app.title|Title to use in the starter GUI windows for your application. Default is an empty string.|
|starter.reportfilesize|Set to 1 to report size of files after the file description text while they are downloaded (in GUI mode). Set to 0 not to report it.|
|starter.checkremotedate|Set to 1 to check server deployment file (app.url / app.url2) last modified timestamp reported the server and download it only if it changes. Set to 0 to download server deployment file (app.url / app.url2) all the times. If your web server reports timestamp correctly you can use 1 (which is the default).|
|app.enc|(version 1.0.2+) used to set the password used to encrypt server files (same as one used in [enc.exe](#r/msnet-appstarter/tools.md) tool). See encryption section in [server](#r/msnet-appstarter/server.md) page for details. Default empty (no password) |
|app.sslcerthash|(version 1.0.2+) if not set (empty, default) then SSL certificates are accepted if OS accepts them. If set to `none` all SSL certs are accepted (danger). If set to a string then the only `X509Certificate.GetCertHashString` matching the set value is accepted.|
|starter.checkremovabledisk|If set to 1 (default unset 0) then the starter will detect if it starting from a removable hard disk (such as a USB memory stick) and will use a working folder next to the starter EXE, instead of a folder in user profile to store the application files in client. If your application is portable and can be run from USB, you can consider putting 1 so that users can have the files they need completely on their UBS sticks.|
|starter.deltacheckhours|By default, starter checks the server app.url for possible application updates every time the EXE is started by the user. If this too much load for your web server, you can put here a value in full hours (an integer). The starter will then check server only if the time difference between the last server check is bigger that the delta check hours value you have set.|
|starter.deltacheckhoursrem|This is same as `starter.deltacheckhours`, but is used only if `starter.checkremovabledisk=1` and use is really starting from a removable disk. It allows you to specify a different check time difference for portable application copies, than for the desktop ones. If you do not set this value its default is 0, which means server will consulted in every start. If you set `starter.checkremovabledisk=1` and change starter.deltacheckhours, then do not forget to change this value too in the case you need it.|
|starter.updatebeforestart|By default (`starter.updatebeforestart=0`), appstarter starts the local copy of the application and then tries to download any newer version on background. The newer version (if any) will then be run at the next application startup. If possible, it is recommended you leave appstarter configured like this, because, the user gets something started quickly without having to know when the application is updated. This is called seamless updates, and it is the way, for example, Chrome Web Browser updates itself. If you application cannot handle this mode of operation and you need to run always the latest version if possible, then set `starter.updatebeforestart=1`. If you set `starter.updatebeforestart=1` then appstarter will always check for a new version before starting the application, and the user has to wait for the update (if any) to finish. If starter.updatebeforestart=1, then starter.deltacheck* settings are ignored (there is no need to set them).|
|starter.downdelaymls|Starter uses only one HTTP connection per client to download files to keep the server load low. This option can be used to specify an artificial delay in milliseconds after each buffer of data received from server. It can reduce traffic bandwidth in server at the expense of keeping the connection to the client longer open. From this point of view, it is not a good idea to use this option. The main intended usage is when testing with a fast local server and want some visible delay to simulate the remote server behavior. Default value is 0, and possible value can be in range [0-250]. If you set this value for a remote server, then make sure you test it.|
|starter.cmdprefix|Starter EXE supports some special command-line parameters. They all start with `--starter--` by default. Normally these parameters should not conflict with the ones you expect (they are never passed to your application EXE). If you think they can still conflict, you can change the special command prefix using this option. You can also change this special commands prefix to make it more friendly, for example, by using your application name for it.|
|starter.useragentsuffix|Starter reports a special HTTP user-agent string (see User Agent section) to the web server as part of download requests. You cannot change it, but you can append your own text to it. The text you specify is appended with a space (but it may not contain spaces - they are replaced).|
|app.arg.useragentsuffix|If you have set a `starter.useragentsuffix` it can be made optionally available not only the web server, but also to your application EXE as a command-line parameter. If you want this, specify a custom string for this parameter, for example `app.arg.useragentsuffix=--myappua`. The starter will then report to your application EXE it starts on client, the starter.`useragentsuffix=myapp123` string as one argument starting with `app.arg.useragentsuffix`, for example, `"--myappuamyapp123"`. Normally you do not need to set this parameter, but it can be used creatively in more than one way for advanced scenarios (e.g., web server set a unique `starter.useragentsuffix` for every custom starter downloaded by users; the application then gets this id and uses it for registration purposes, etc.).|
|app.arg.starterpath|If you set here a string, it is used as a command-line parameter prefix to pass the path of starter to your application. If starter is at `c:\myappstarter.exe`, and `app.arg.starterpath=--sp` then your application receives an command-line argument (among possible others) of: `"--spc:\myappstarter.exe"`. If you ever need to know the starter path in your application and do something with it (start a new application instance via the starter) then use this parameter.|
|app.license|Starter can show an optional simple application text license the first time it is run. To activate it add one or more app.license lines to your client configuration file. All `app.license` line text values are combined together in the order added joined by new lines in one big string and shown to user as the license text. Use `^p` within an `app.license` line to denote a new line, and `^t` to denote tabs.|
|app.license.w|If app.license(s) are set, use this option to change the width in pixels of license window shown to user (if you do not like default size). For best result use 640.|
|app.license.h|If app.license(s) are set, use this option to change the height in pixels of license window shown to user (if you do not like default size). For best result use 480.|
|str.`*`|The starter uses a minimum of user interface strings. If you use the `--starter--show-info--` command (see below) these strings are listed with keys starting with `str.`. You can customize all these strings by adding a key with same name in client configuration file. For example, `str.connecting=...` is shown when starter connects the server in gui mode. You can replace it with something like: `str.connecting=Connecting to server ...`. Replace (all) the strings as needed (e.g., the `str.lic.title` changes the title of the `app.license window`).|

`appstarter.exe` and its created custom starters support some special command-line parameters (described next). One of them `--starter--show-info--` is very important for the client configuration parameters.

```
appstater.exe --starter--show-info--
myappstater.exe --starter--show-info--
```

If you use `--starter--show-info--` with the generic default starter, the default values of client configuration keys are shown. All keys not starting with # in the shown text can be modified via the client configuration file and are documented above. You can copy the shown text and paste to a text file to serve as a default client configuration file which you can further modify. If you use the `--starter--show-info--` parameter with a customized starter EXE, it will show the values you have set via client configuration file. This means, you can use `--starter--show-info--` to debug and see if your parameters are really applied as you think (if have made some typing errors, then the default value remains set).

Some characters are not allowed for some of the client configuration values, such as those of `app.arg.starterpath`. The `--starter--show-info--` lists also these characters (`/` is allowed for `app.args.*`, but not allowed for the rest).

##Special Command-Line Parameters

Starter EXE supports some special command-line parameters. They all start with `--starter--` by default (can be change via `starter.cmdprefix` key in client configuration file). We will show the commands here with the default `--starter--` prefix, but the prefix could be different if you have modified it.

The special starter command-line parameters are never passed to your application EXE. They are available in all custom starters. If you mistype the parameter then it is ignored and a normal default start is done. These special parameters are usually not important for your users. They are useful to test the starter. Only `--starter--uninstall--` can be of interest to end-user as it un-installs the application.

|Option|Details|
|-|-|
|--starter--show-info--|Show current starter client configuration details. The text can be copied and used as a starting client configuration file for appscrator.exe tool. Useful to debug your configuration. Lines begging with # show internal starter and application cache data. You not need to include # lines in your client configuration file.|
|--starter--show-log--|Starter keeps a log of its actions. The log stores no user data, and it is deleted every 8KB automatically. It is intended to debug starter related problems. You may report its contents if your report a bug about starter itself.|
|--starter--clear-log--|Clears the starter log if any to start with a new one next time.|
|--starter--run-local--|Runs the local copy of the application if any and does not contact the server to check for updates. If no local copy is available then the server is still contacted.|
|--starter--kill-app--|Kills all running application instances.|
|--starter--uninstall--|Removes all starter related application data and any file type associations from the user machine. It also kills all application instances (same as `--starter--kill-app--`). This parameter can be of interest to the end-users. If the starter client data gets corrupted for some reason, this option can help to start again with a fresh clean state (and with the latest version of the application from server).|

##Changing AppStarter Icon and Exe File Information

The default starter EXE comes with a default icon and it contains some fixed EXE file information in its resources. You may leave the ion and the file information as they are, or if you like you can modify and replace them to customize the look and the description of the starter EXE file.

If you modify default starter EXE to replace its resources do so before you generate a custom starter. Make a copy of the generic default appstarter.exe and then modify its resources to be specific to your application. After doing this, use the modified EXE as /s input for the appscreator.exe. Do not modify a custom EXE, only a copy of the generic one before applying the configuration file to it.

There are several free and commercial EXE resource editors that can be used to change icon and information of an EXE file. This [tutorial](#r/msnet-appstarter/resdedit.md) describes how to use one of them.

##AppStarter User-Agent

AppStarter reports a user-agent string to web server when it does the HTTP requests. The user-agent string is made of several parts separated by space and looks similar in format to the one below:

```
WStarter 1.0.0 app.guid [MSWNT_5.1.2600_SP3] en-US CLR2.0.50727.3615 starter.useragentsuffix
```

The user-agent string is made of these parts:

* WStarter - (stands for Web Starter) and identifies AppStarter
* 1.0.0 - the internal version of AppStarter client EXE
* app.guid - is the {GUID} of your application set in client configuration file
* [MSWNT_5.1.2600_SP3] - is the OS version the client runs: MSW	(Microsoft Windows) NT 5.1.2600 Service Pack 3
* en-US - the OS language detected by the client
* CLR2.0.50727.3615 - this is the .NET run-time used by client, start with CLR
* (optional) starter.useragentsuffix string - if you set it in client configuration file

Web server can use the user-agent string to collect usage statistics, restrict usage, etc.

##AppStarter Client Storage

AppStarter stores its application related downloaded data in a folder called `WStarter\app.guid\` in the application data of user local profile `(%LOCALAPPDATA%`). This means your application is deployed per user profile and runs with current user rights. For each application deployed using AppStarter, there is a subfolder within `WStarter` named same as the app.guid set for the application in the client configuration file of that application. WStarter stands for Web Starter.

For portable applications - if `starter.checkremovabledisk=1` in client configuration file and if the disk from where AppStarter starts is removable, the `WStarter\app.guid\` folder is created in same folder as the starter EXE file.

AppStarter replaces application files in one transaction, so it needs twice as much free disk space in WStarter folder location as your application size is (in the worst case). The AppStarter maintenance data consume few space on their own (around max 10KB per application).

The `--starter--uninstall--` special command-line option deletes the contents of `WStarter\app.guid\` folder.

[AppStarter](#r/msnet-appstarter.md) | [Details](#r/msnet-appstarter/details.md) | [Server Configuration](#r/msnet-appstarter/server.md) | [Client Configuration](#r/msnet-appstarter/client.md) | [Tips & Hints](#r/msnet-appstarter/tips.md) | [Tools](#r/msnet-appstarter/tools.md)