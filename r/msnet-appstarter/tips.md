#AppStarter: Tips & Hints

[AppStarter](#r/msnet-appstarter.md) | [Details](#r/msnet-appstarter/details.md) | [Server Configuration](#r/msnet-appstarter/server.md) | [Client Configuration](#r/msnet-appstarter/client.md) | [Tips & Hints](#r/msnet-appstarter/tips.md) | [Tools](#r/msnet-appstarter/tools.md)

The best way to be sure AppStarter works for your application is to try it out. Test the deployment scenarios and possible updates that you expect. Try adding new files and file associations and removing some of them. Try updating related files at once. Normally, AppStarter handles all of these without any problems, but to avoid surprises on what you expect, make sure you try out some of your expectations before releasing AppStarter customized executable to your users.

You can test using either a local web server, or a remote server. If you have access to server-side scripting, such as PHP, you may consider generating the server deployment file automatically based on the application identifier that AppStarter reports via HTTP user-agent string.

You can offer the customized AppStarter client executable to your users for download either as EXE file, or as a compressed file (ZIP the EXE file):

* Offering directly the EXE file has the benefit that you save yourself the effort to educate users to unzip the file before they run it. Windows will warn users if they try to run an executable file downloaded from Internet. For the AppStarter executables, this warning only comes once - the very first time they are run, after the first run AppStarter takes care to disable this warning.
* Offering a compressed executable has the benefit it is smaller in size (even thought the AppStarter executables are usually small), and that after decompression, user will not see a warning for the first time when run the executable (only if a third-party zip tool is used, Windows build-in unzip leaves the warning).
Make sure you tell users how to uninstall AppStarter applications if they ever need it (--starter--uninstall-- command-line option). Uninstalling can come also handy to users to force a new clean update of the application.

AppStarter executables need Internet access to download files. AppStarter uses the normal HTTP port 80 which is open in almost all machines. If the users have a personal firewall, you need to educate them so that they give AppStarter permission to access Internet on port 80. If AppStarter updates itself then the firewall may detect it and ask users to confirm the file change. This information should be given to your users so that they do not get surprised, even thought the people that use a personal firewall are used to such scenarios.

If you modify the AppStarter icon file make sure you use a new icon file which contains images of different sizes. This ensures the icon looks good in different system configurations. If in doubt check the default AppStarter icon to see what different sizes it supports.

[AppStarter](#r/msnet-appstarter.md) | [Details](#r/msnet-appstarter/details.md) | [Server Configuration](#r/msnet-appstarter/server.md) | [Client Configuration](#r/msnet-appstarter/client.md) | [Tips & Hints](#r/msnet-appstarter/tips.md) | [Tools](#r/msnet-appstarter/tools.md)