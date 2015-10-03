2010

#AppStarter: Web Based Application Deployment Tool for Windows

<!--- tags: csharp deployment -->

[AppStarter](#r/msnet-appstarter.md) | [Details](#r/msnet-appstarter/details.md) | [Server Configuration](#r/msnet-appstarter/server.md) | [Client Configuration](#r/msnet-appstarter/client.md) | [Tips & Hints](#r/msnet-appstarter/tips.md) | [Tools](#r/msnet-appstarter/tools.md)

AppStarter is an application deployment tool for Microsoft Windows, similar to Java Web Start or .NET Click Once. It works with applications written in any language. No code changes are needed for deployed applications. AppStarter can be used to deploy Windows applications whose files are all in one folder (with sub-folders) and that are run periodically by users. AppStarter needs minimal web server support (only hosting of static files). AppStarter can update applications in background, or by always getting the latest version from server before the application is started. Unlike .NET Click Once, AppStarter runs applications without any limitations, having same rights the as the logged user.

##Server side configuration

In the examples that follow, it is assumed we have a simple application made of the following files: `app.exe`, `app.chm`, `app.dll`, `libs\lib1.dll`, `...`.

AppStarter looks in server for a text file (url is configurable in client-side), for example, `http://127.0.0.1/app/files.txt` containing the list of application files (only http and https are supported). The server deployment `files.txt` may look in its simplest form as follows:

```
http://127.0.0.1/app/app.exe|app.exe|1.0.2|*|*
http://127.0.0.1/app/app.chm|app.chm|1.0.2
http://127.0.0.1/app/app.dll|app.dll|1.0.6
http://127.0.0.1/app/libs/lib1.dll|libs/lib1.dll|1.0.5
```
Each pipe separated line contains (a) the URL where to download the file from (can be in a different server than files list), (b) the relative local path of the file in the application folder, and (c) the file version. Executable files, are marked with two additional star * flags (explained later).

This fully working simple server side configuration requires no special server-side support, no script or programming of any kind. Set up a server folder with the application files and the text list file above. To update files, you replace them in server and update `files.txt` with the new file data (new version, etc). Read more: [AppStarter server configuration](#r/msnet-appstarter/server.md)


##Client side configuration

The client configuration is done also via a text file. Create a client configuration text file named, for example, `myapp.txt` (the name does not matter) containing:

```
app.guid={B45F0675-586D-5DD9-DDD1-D057FBE0ABAD}
app.title=My App - http://MySite.com
app.url=http://127.0.0.1/app/files.txt
```

`myapp.txt` text file contains (a) the application unique id (guid), generated for example with the free `guid.exe` tool that comes with the AppStarter download, (b) application title shown by AppStarter, and (c) the (remote) server URL of the file created above for the server-side configuration.

To configure AppStarter to use these data, get a new fresh copy of `appstarter.exe` from the download package, put it and the `myapp.txt` in same folder and open a command-prompt window to that folder and run the `appscreator.exe` tool (from the download package) as shown:

```
appscreator /s appstarter.exe /c myapp.txt /o myappstater.exe
```

You can use any name instead of `myappstater.exe` and even rename it later on. The small `myappstater.exe` file is the only file you need to make available for your users to download. Once they run it, your application and all its future updates you put in the server are automatically deployed in user machines. Read more: [AppStarter client configuration](#r/msnet-appstarter/client.md)

##Tips and hints

The best way to ensure that AppStarter works for you is to try out the expected AppStarter deployment and update scenarios before releasing AppStarter based applications for your users. Read more: [AppStarter tips and hints](#r/msnet-appstarter/tips.md)


[AppStarter](#r/msnet-appstarter.md) | [Details](#r/msnet-appstarter/details.md) | [Server Configuration](#r/msnet-appstarter/server.md) | [Client Configuration](#r/msnet-appstarter/client.md) | [Tips & Hints](#r/msnet-appstarter/tips.md) | [Tools](#r/msnet-appstarter/tools.md)