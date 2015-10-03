#AppStarter: Tools

[AppStarter](#r/msnet-appstarter.md) | [Details](#r/msnet-appstarter/details.md) | [Server Configuration](#r/msnet-appstarter/server.md) | [Client Configuration](#r/msnet-appstarter/client.md) | [Tips & Hints](#r/msnet-appstarter/tips.md) | [Tools](#r/msnet-appstarter/tools.md)

AppStarter download package contains bundled several small command-line tools that are useful to generate the information needed for the server and client configuration files. The tools must be run in command-line (cmd.exe DOS) window.

* **appscreator.exe** : Creates a customized AppStarter **client** EXE. appscreator.exe takes as input the generic appstarter.exe template and a custom application configuration file and outputs a customized starter exe for the specific application. Using the appscreator.exe is described in client configuration. Parameters:
	* /c configFile - a valid text configuration file is required
	* /s appstarter.exe - the path of the generic appstarter.exe file. If not specified program checks for a file named appstarter.exe in current folder
	* /o output.exe - the path where to write the generated custom starter exe file. If not specified, then the file named same the generic inputted appstarter.exe with the string "-out" appended after the name

* **appslist.exe** : Generates a server deployment file from files in a given folder. Using the appslist.exe is described in server deployment file. When run without any parameters appslist.exe generates a server deployment file for files found in current directory. To fine tune its behavior use these parameters:
	* /i directory - input directory where application files are found
	* /r - if specified, the sub-directories of input directory are also processed
	* /u baseUrl - the base server URL to use to access files
	* /o outputFile - the file where to write generated output. If no file is specified, the output is written in console
	* /e suffix;suffix;... - the file extensions to process, separated by ;, for example, /e .exe;.dll;.chm If not specified then all found accessible files are listed
	* /s starterExe - if you are deploying the starter exe, then specify its file name (not path), so that the special string *starter* is used for its path
	* /t - if specified, some generic display text is added for common exe, dll files, and chm files
	* /f - by default file last write timestamp is used as file version. If you specify /f then appslist will try to get the file version from file resources, if none found, then still the last write timestamp will be used
	* /m - generates minimal format without file length and checksum (not recommended). If /m is used, options affecting extended fields are ignored
	* /c - adds a comment in beginning of the output explaining file record fields
	* /a appendTextFile - appends a given text file (for example containing file type association text) to the end of the generated file

* **md5.exe** file : Takes one or more files as input parameters and prints out their corresponding MD5 (RFC 1321) checksum on console one per file. The MD5 checksum is same as the one generated, for example, by PHP md5 (md5_file). You can use any other tool to generated MD5 checksum of your files, but compare first its output for a given file with the md5.exe tool provided with AppStarter to be sure its outputs same value. 

* **guid.exe** : Generates a globally unique identifier (GUID) of 128 bits in string form. Every generated GUIDs is very likely unique, and no two generated GUIDs are same. The tool is similar to guidgen.exe that comes with Visual Studio. It generates GUIDs in Windows Registry format. You can use any other tool to generate valid GUIDs. The tool can be run without any arguments. It prints a different GUID on console every time it is run. If the AppStarter documentation states you need a GUID, then generate a proper one. Do not fake them!

* **enc.exe** :	Encrypts a directory files (in all sub-folders) with a password. Encryption is done in place (unencrypted files are deleted (no wipe, do not use this tool to store secrets!) and replaced with encrypted one). Parameters:
	* /i inputDir - directory files to encrypt in place
	* /p password - same password has to be specified in app.enc client option
	* /d  - if specified decrypt, default is encrypt

[AppStarter](#r/msnet-appstarter.md) | [Details](#r/msnet-appstarter/details.md) | [Server Configuration](#r/msnet-appstarter/server.md) | [Client Configuration](#r/msnet-appstarter/client.md) | [Tips & Hints](#r/msnet-appstarter/tips.md) | [Tools](#r/msnet-appstarter/tools.md)