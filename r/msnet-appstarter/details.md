#AppStarter: Details

[AppStarter](#r/msnet-appstarter.md) | [Details](#r/msnet-appstarter/details.md) | [Server Configuration](#r/msnet-appstarter/server.md) | [Client Configuration](#r/msnet-appstarter/client.md) | [Tips & Hints](#r/msnet-appstarter/tips.md) | [Tools](#r/msnet-appstarter/tools.md)

AppStarter is a web based application deployment tool for Microsoft Windows. AppStarter is written in Microsoft .NET 2.0. It can be used to deploy applications independent of any programming technology, without any application changes. AppStarter runs on Windows XP, Windows Vista, Windows 7, and Windows 8 - in both 32 bit and 64 bit versions.

AppStarter can be used to deploy applications that:

* Have all files within one folder (including sub-folders) and that can be replicated by copying this folder.
* Are run periodically time after time by user. Applications that run all the time, such as Windows services are not supported.
* Can put their files in a public accessible location of a web server (via HTTP or HTTPS). This is the only requirement AppStarter has for the server-side.

AppStarter copies the latest version of your application in the user local profile and runs the application locally. This means your application, when run, has same permissions and full disk access as any other local application started by the user (there is no sand-boxing of any kind).

AppStarter offers basic means to register file type associations and optionally to show an text license window to the user. The rest of deployment actions if needed should be handled by your application on the first run.

AppStarter offers a convenient alternative to distributing your application via an installer. An installer requires the user to always apply manually the latest version. AppStarter gets the latest version automatically. AppStarter only updates changed files, so the user does not need to re-download the complete package. This saves effort and bandwidth to both parties.

AppStarter offers also a convenient alternative on implementing web updates for your application on your own. Instead of spending time to come with a reusable professional update library on your own, you can use AppStarter out of the box. Applications deployed via AppStarter do not need any code changes to benefit from AppStarter automatic web updates.

AppStarter updates your application and itself if needed seamlessly and unobtrusively (can be disabled by configuration). When user starts your application via AppStarter for the first time, a download progress dialog is shown until application has been downloaded. The other times, a local copy of the application is started immediately and AppStarter checks in background if an update is needed. If so, the new files are downloaded silently and replaced the next time the user runs the application. This means users can run your application after the first time even without having Internet access. AppStarter does not run all the time, so it does not consume system resources all the time. When AppStarter is doing something in background, it shows a notification icon in task bar, so that the process is transparent to the user. Users can decide to see what AppStarter is doing by double-clicking the icon. The icon disappears when AppStarter stops running.

AppStarter is designed with a minimalistic user interface to keep it small in size and to avoid having to customize many resources. The set of supported features has been carefully selected to be complete at a minimum, and not to bloat the application file size. You can customize the icon, file description, and all of the strings shown to the user.

AppStarter is transactional. It replaces your files all together or none of them. It could be stopped at any time by user, and it resumes its state again transparently in the next run, including resuming of partial downloads, and does file checksum verifications. AppStarter can be configured to support portable applications by checking if it is started from a removable device and downloading files locally to the executable file, rather than in the user local profile. AppStarter can replace also itself automatically if needed without the user noticing it.

AppStarter can be used to deploy any number of applications. Each application gets its own customized starter executable, which is the only small file you need to distribute to the users. Getting AppStarter configured for your application is easy and it is supported by a few command-line tools provided as part of the download package.

[AppStarter](#r/msnet-appstarter.md) | [Details](#r/msnet-appstarter/details.md) | [Server Configuration](#r/msnet-appstarter/server.md) | [Client Configuration](#r/msnet-appstarter/client.md) | [Tips & Hints](#r/msnet-appstarter/tips.md) | [Tools](#r/msnet-appstarter/tools.md)