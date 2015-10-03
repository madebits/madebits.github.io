#AppStarter: Server Configuration

[AppStarter](#r/msnet-appstarter.md) | [Details](#r/msnet-appstarter/details.md) | [Server Configuration](#r/msnet-appstarter/server.md) | [Client Configuration](#r/msnet-appstarter/client.md) | [Tips & Hints](#r/msnet-appstarter/tips.md) | [Tools](#r/msnet-appstarter/tools.md)

<div id='toc'></div>

AppStarter expects a text **server deployment file** (ASCII/UTF8) in a HTTP or HTTPS web server accessible via a public URL. The server deployment file must be small as it is accessed often by each client **AppStarter EXE**. AppStarter client checks first by default the server deployment file's last modified time-stamp, and then its contents only if needed.

##Application Files

Every application file is listed in the server-side deployment file as a one line file record made up of several fields separated by a pipe '|' (without the '' quotes). If a field of the file record is left empty (if it is optional, or has no value) you still have to specify the pipe separator. Only if all fields after a given one are empty, then you can leave out all remaining empty field separators to the end. The space around lines and individual data fields is ignored. An example of a server deployment file, specifying an application made of two files (some optional fields are left empty in middle, or in the end of lines), follows:

```
http://127.0.0.1/app/app.exe|app.exe|1.0.1|*|*
http://127.0.0.1/app/app.dll|app.dll|1.0.1|||23456
```

Details about supported file record fields (listed in the order they should be specified):

|Field|Details|
|-|-|
|1. Url|The **absolute** HTTP or HTTPS URL to the file contents pointing to your web server (port in not 80 can be specified as part of URL). In the simplest form, this is a URL to a plain file, but it can also be the URL of script that delivers the file contents. Relative URLs will not work. The URLs of different files can point to the same or to different web servers. The URL must directly deliver the file contents (no temporary html page, and no password protection, etc). AppStarter has been tested to work with HTTP and HTTPS.|
|2. Path|The **relative** local deployment path of the file inside the application folder. Paths are relative to the client local deployment folder. Specifying only the file name, e.g., app.exe will put the file directly under the root of the client local deployment folder. You can also specify sub-folders, such 'sub1/sub2/app.dll' (both slash or backslash can be used as separators). Path must contain only Windows allowed relative path characters (and not ':').|
|3. Version|The version of the file. The file is considered changed when version text changes. Make sure version string contents are not repeated over time. You can use the version of your application files, or the last written timestamp of the files, or just increment a counter. The version must be changed if you put a new version of the file in server, so that clients can obtain it correctly. Never change a file without updating its version. It will result in corrupted files in clients.|
|4. Exe Flag|Marks a file as **executable** - that is, it should be executed in the client when AppStarter is invoked (an EXE file). Use a star '*' (without the '' quotes) in this field to mark a file as executable. For non-executable files leave this field empty. The client does not rely on file suffix to detect executable files, but only uses the EXE Flag. This means: (a) you can name the executable files as you like - if your application can handle it, and (b) you can have more than one executable file started at the same time in client if this is ever needed. If more than one file is marked with the EXE Flag, then they are all executed in client in the order they are listed in server deployment file.|
|5. Arguments Flag|If you have marked one file with the EXE Flag (see above), then you should most of the time mark it also with the Arguments Flag using also another star '*' (without the '' quotes) field. The Arguments Flag tells the client AppStarter to pass to the executable file the arguments passed to the client starter. If the file is not marked with EXE flag, setting Arguments Flag has no effect. If you do not set Arguments Flag for an EXE file, then it does not receive any arguments when started! Normally, the user opens files with AppStarter client EXE and the AppStarter client EXE passes all arguments to your application EXE files that are marked with Arguments Flag when they are started. To your application, it looks like the user passed all the arguments (if any) directly to it.|
|6. Display text|(Optional) While client AppStarter downloads a server file it shows some text about it in the GUI mode to the user. This text is by default the local relative file Path. You can show any arbitrary text by setting this field, for example: 'Downloading application ...'. Text longer than 40 chars is truncated.|
|7. File Size|(Optional) The exact file size in bytes. Setting the file size is optional, but strongly recommended. The client uses the file size if you set it to better verify downloads and to resume partial downloaded files. If you are lazy to maintain this field, you may still leave it out. The client uses in this case the HTTP web server reported file size (if available) to verify the file. If not possible to determine the file size, then the client skips file size verification. If you do not want to rely on the web server and make sure client files are not truncated, set the size on your own. This makes the client more robust.|
|8. File MD5|(Optional) The MD5 hash checksum of the file contents. Setting the file MD5 checksum is optional, but strongly recommended. The client uses the file MD5 checksum, if you set it, to properly verify downloads. If you do not set the MD5 checksum, no verification of the downloaded content takes place. Specifying the MD5 makes the client more robust. To calculate the MD5 checksum of file, use the provided [md5.exe]((#r/msnet-appstarter/tools.md)) tool.|

[appslist.exe](#r/msnet-appstarter/tools.md) tool can be used to generate a server deployment file automatically from the files in a folder (and all its subfolders). Output can redirected to a text file for further manual modifications. `appslist.exe` uses by default the file's last written timestamp as file's version. See `appslist.exe` description for more details.

```
appslist /i . /u http://www.mysite/app/1/ /e .exe;.dll /o files.txt
```

The server deployment file generated by `appslist.exe` is not final, you may need to modify it manually, to add file type associations (see below) using /a option, or add remove other files, change URLs, etc.

##Encrypting Application Files

Sometimes, a firewall may prevent files such as EXE/DLL to be downloaded by AppStater. Using [enc.exe](#r/msnet-appstarter/tools.md) tool you can encrypt the application files to remedy that (version 1.0.2+). To encrypt files follow these steps:

1. Create `files.txt`, as usual, from the unencrypted original files (using `applist.exe`).
1. Use [enc.exe](#r/msnet-appstarter/tools.md) tool to encrypt the application directory files with a password. `enc.exe` encrypts files in **place** recursively in all folders (make a backup copy of the original files before!):
    ```
    enc.exe /i appDir /p password
    ```
1. In [client](#r/msnet-appstarter/client.md) configuration, specify `app.enc=password`. The password used in `enc.exe` and in `app.enc` has to be same.


##Client File Associations

AppStarter offers some support to handle custom application file associations of the client machine. The build-in file association support is enough for most applications and should be preferred against your own code, as it gives AppStarter a chance to run and update your application when user double-clicks your application files.

File type associations records are specified also as part of the server deployment file. Each file association to be created on client machine should be specified in one line starting with the required prefix `##*`. Example of a server deployment file for an application with two files and two file type associations:

```
http://127.0.0.1/app/app.exe|app.exe|1.0.1|*|*
http://127.0.0.1/app/sub/app.dll|app.dll|1.0.1|||23456
##*{6C6C001A-450C-4500-8B50-A391DCC259BB}|.myapp|My App file|app.exe|0
##*{29B773C7-DD56-45d6-BA3F3-1E925CCE1D14}|.myapp2|My Other file|sub/app.dll|1
```

File associations are organized around the concepts of file types (e.g., the file suffix .myapp) and program ids (e.g., {6C6C001A-660C-4500-8B50-A391DCDC59DD}). File suffixes that define same file type (e.g., .jpg, .jpeg) can share same program id. Different file types (even of same program) must use different program ids. Read the specific field explanation details below and check [MSDN](http://msdn.microsoft.com/en-us/library/cc144148.aspx) for more details on this topic.

AppStarter applies file associations **only** if no other program is already opening the file types you specify (otherwise only open with shell action is added for your application). This means you cannot take full ownership of already registered files on the user machine, such as, .txt, or .jpg.

Details about supported **file association record** fields:

|Field|Details|
|-|-|
|1. ProgramID|A globally unique identifier for each file type support by your application that you want to register. MSDN recommends using strings of form ProductName.FileType.VersionMajor.VersionMinor, however, it is better to use a GUID. To be sure that ProgramID is unique use a GUID string generated by the [guid.exe](#r/msnet-appstarter/tools.md) tool provided along with AppStarter. If you use once a given ProgramID for a file type, do not change it afterwards. Use same ProgramID for same file type for the lifetime of your application. Use different ProgramIDs for different file types (in the same application or in different ones). AppStarter prepends `WS` to the ProgramIDs you specify.|
|2. File Extension|The suffix of the file type you want to register. The suffix must start with a dot (it is prepended automatically if you forget it). MSDN recommends selecting both a long suffix for your files and a short one (add two lines one for each with same ProgramID).|
|3. File Description|A short description of this file type, normally shown to the user by Windows Explorer for your file.|
|4. Icon Path|(Optional) This should be one of relative paths you used for application files in the server deployment file. The file must contain the icon resource to use for this file type. If you leave this field empty then the client AppStarter EXE icon will be used. It is strongly recommended you set this value to point to one of your application files that contains the icon resource.|
|5. Icon Index|(Optional) Selects the icon resource with the specified index from the Icon Path file (usually a DLL) specified above. If empty, the first icon resource found (index 0) is used. If you are using plain icon files, leave this field empty.|
|6. Exe Path|(Optional) Normally, there is no need to set this field - you should leave it empty. AppStarter client will associate file types by default (if this field is left empty) with the client AppStarter EXE. When the user clicks one of your application file types then the client AppStarter EXE is launched first so that it has a chance to handle its deployment magic. Then it invokes your program with any arguments passed (the clicked file). If you specify in this field one of the relative paths of your files, then that file will be launched directly without going via the client AppStarter EXE, which is not recommended, as the client AppStarter EXE gets not chance to run to update your application as needed.|

##Comments and Variables

You can comment a line in server deployment file if your start it directly with `#`. You should **not** use double-diesis `##` to start your comment lines, as `##` is reserved for special lines (icons). Given that the server deployment file size must be small, it is recommended not to use comments, unless having a very strong reason for them.

Lines starting with `$$` are also special. Each `$$` line declares one simple text variable of from `$$key=value`. The space around 'key' and 'value' is ignored. Variables can be used then as `$key` (more than once) in all other lines that do not declare variables (file and file association records). Variable usage within variable definition is **not** supported. For example:

```
$$u=http://127.0.0.1/app/
$$v=1.0.1
$uapp.exe|app.exe|$v|*|*
$uapp.dll|app.dll|$v|||23456
```

Variables are available from the line where they are declared downwards. They are optional to use, but can help reduce the size of the server deployment file.

##Updating Your Application

To update your application you need to (a) **replace** its files in server and to (b) **update** the server deployment file. If you are using size and md5, do not forget to update these correctly as well. Do not forget to update the version for all changed files! The files that you update at once will be downloaded together in the client in one transaction. The client will try to keep its local state of files same as the server state. There are two ways to update server files:

* Simple: Replace all files and the server deployment file and hope the few clients connected at that very moment to the server will not get confused when they download an mixed combination of old and new files. This simple mode can be used when you update your application files independently - that is when old and new version of files can coexist in one application. Otherwise, the simple way is a bit risky as the client files may get corrupted (AppStarter has a few mechanisms to reset its state if something very bad happens and no application runs, but you should not rely on that).

* (Pseudo) Transactional: To be sure your new files are downloaded by the client all at once, no matter what, use the [app.url2](#r/msnet-appstarter/client.md) client EXE parameter. You can specify two different URLs for your application in **app.url** and **app.url2** in client configuration file and adjacently update application files in two locations. This is better explained by an example next.

Example of using transactional replace of files in server: First make sure client configuration file contains both app.url and app.ulr2 set to point to two different server folders for same application:

```
app.url=http://127.0.0.1/app/1/files.txt
app.url2=http://127.0.0.1/app/2/files.txt
```

* Server state 1: Put your new application files and the deployment file inside `app/1/` folder in server. The `app/2/` location does not exist at this point. This is the server state of the first release.

* Server state 2: You need to update several files at once to your application. Put your newer version application files and the deployment file inside `app/2/` folder in server. Once done, delete `app/1/files.txt` and after some time (see below) delete all `app/1` files (starting with files.txt). Clients will start using `app/2/`.

* Server state 3: You need to do a new update of several files at once to your application. Put your newer version application files and the deployment file inside `app/1/` folder in server. Once done, delete `app/2/files.txt` and after some time (see below) delete all `app/2` files. Clients will start using `app/1/`.

* Repeat the above steps as necessary, switching the folders on each new application update. If you delete files immediately, while some client is downloading them, the client will get an error and re-try next time it is run (with the new URL).

New files added to the server deployment file will be added to client local storage, and files removed from server deployment file will be deleted from the client. To completely remove your application you could specify only a new small exe that notifies the client about the removal. The rest of files that you remove from the server list will be deleted.

Same applies to file type associations. New ones are applied as needed to the client, and removed ones are unregistered on client (if they were registered for your application).

##Updating AppStarter in Client

You can use the server deployment file not only to update your application files and file types, but also to update the client AppStarter EXE itself. There could be two reasons to update the client AppStarter EXE: (a) you have a new version with different client parameters, or (b) you want to use an updated newer version of it.

To update client AppStarter EXE starter: (a) make the client AppStarter EXE available in the server as part of your application files and (b) create a new file record in the server deployment file. All the starter file record fields apart of the Path should be filled same as for all other application files (EXE and Arguments Flags are ignored). The only difference is the string used for the relative Path. Path has to be the special string `*starter*` typed exactly as shown. Increment the starter version text as needed, it does not need to match the real client AppStarter EXE file version - you can use a simple counter value.

```
http://127.0.0.1/app/myappstarter.exe|*starter*|1|
http://127.0.0.1/app/app.exe|app.exe|1.0.1|*|*
http://127.0.0.1/app/app.dll|app.dll|1.0.1|||23456
```

You can use the `/s` myappstarter.exe option with the appslist.exe to generate an proper AppStarter path file record.

Client AppStarter EXE contains logic to download the new version and replace itself as needed, without any explicit user interaction. If user has an active personal firewall, the firewall may detect that the client EXE is changed and prompt the user to confirm change for web access permission. You may need to educate your users to expect this to be the normal behavior.

##Advanced Server Side Techniques

Techniques that follow are not necessary to use AppStarter in server, but may help. If you need functionality as one described next, than AppStarter helps provide the raw data to support it, but you have to implement such advanced server side techniques on your own.

You can maintain server deployment file manually, or you can use a script language in server, such as PHP, to generate the server deployment file contents on the fly based on files in some folder. The script approach has the benefit that file size and md5 is always correctly updated. Calculating md5 on each request can be very slow, so you may need to cache them (the logic can be non-trivial). A server deployment file script could also can use different file URLs depending on the traffic load.

AppStarter client reports to the server a user-agent string. The AppStarter user-agent string can be used creatively in combination with server scripting in more than one way. For example, server can restrict that only AppStarter client can access the files. As another example, the user agent can be enhanced with a custom a user agent string that can be added at per user generated starter client on the fly when downloaded. The custom user agent part can then be used to identify application and/or the user.


[AppStarter](#r/msnet-appstarter.md) | [Details](#r/msnet-appstarter/details.md) | [Server Configuration](#r/msnet-appstarter/server.md) | [Client Configuration](#r/msnet-appstarter/client.md) | [Tips & Hints](#r/msnet-appstarter/tips.md) | [Tools](#r/msnet-appstarter/tools.md)