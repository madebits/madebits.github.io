#Cr!ptAES: Usage

[Cr!ptAes](#r/msnet-criptaes.md) | [Usage](#r/msnet-criptaes/usage.md) | [Encryption](#r/msnet-criptaes/encryption.md)

Cr!ptAES can encrypt, decrypt, finger print, compare, and safely wipe files. Cr!ptAES has an easy to use one-window interface. In the top of the window is the program logo and the input toolbar. Below the toolbar is the list of files and folders to be processed, followed by the configuration buttons and the password text field. In order to start processing the input files and folders, you need to click the ![inline](r/msnet-criptaes/start.gif)  Cr!pt button. Error and progress messages are shown in the lower part of the window. To resize the log window use the split bar.

##Input

Cr!ptAES encrypts individual files (and files in input folders recursively). The name and the approximate size of the original files will still be visible. If you want to encrypt a large number of small files, e.g., images, then compress (zip) them together in a single file, before you encrypt them, and then encrypt the compressed archive. The size of the input files must be under 2GB.

There are several ways to specify which files to process in Cr!ptAES:

* Using the add files button ![inline](r/msnet-criptaes/add.gif). It pops up a file open dialog, where one or more files can be selected. You can repeat this action as required to append more files.
* Using the add folder button ![inline](r/msnet-criptaes/adddir.gif). It pops up a folder selection dialog, where one folder can be selected. If you add a folder, then all its files and all file of all its subfolders will be processed.
* You can drag and drop files and folders from Window Explorer to the file list. If you drag a folder, then all its files and all file of all its subfolders will be processed.
* You can copy the files and folders in the Windows Explorer and click in the file list and press the paste button ![inline](r/msnet-criptaes/paste.gif), or Ctrl+V to paste them. If you paste a folder, then all its files and all file of all its sub-folders will be processed.

Each file and folder can be added only once. By default, the files and folders are listed and processed by the order they are added. Click the file list headers to sort the file and folder paths alphabetically, or by the file size.

Files are logically divided into two groups. Encrypted files (those who end in `*.cript`) are shown with a ![inline](r/msnet-criptaes/aes.gif)  icon. The rest of files are supposed to be un-encrypted files ![inline](r/msnet-criptaes/plain.gif). You can rename the encrypted `*.cript` files using any other suffix, and rename them back to `*.cript` before decrypting, or decrypt them explicitly without renaming them (see below).

To remove one more files, first select them with mouse. Hold down the Ctrl key to select more than one file. `Ctrl+A` will select all files (or use the context right-click menu). Then, either press the delete (`Del`) key, or the remove button ![inline](r/msnet-criptaes/remove.gif)  (or use the context right-click menu). To see how many files are there in total, and how many are selected use the information button ![inline](r/msnet-criptaes/info.gif). The result will be shown in the log window. To copy the existing list of paths, or only the selected ones, use the copy button ![inline](r/msnet-criptaes/copy.gif), or press `Ctrl+C` when the input list is focused (or use the context right-click menu).

A double-click on a file or folder in the input file list opens the corresponding folder in the Windows Explorer.

##Output

Cr!ptAES does not change the input files. It creates a new file for each processed input file. When you start processing (encrypting / decrypting) files ![inline](r/msnet-criptaes/start.gif)  you will be prompted for an output folder to put the result files. You cannot use as an output folder, a folder that is a sub-folder of an input folder. Select 'Cancel' on the folder browse dialog, if you want that the output files are created in the same folders as the original input ones. The same folder cannot be used with read-only volumes, such as, CD-ROMs.

* During encryption, the suffix `*.cript` is added to every processed file to create the name of the output file.
* During decryption, the suffix `*.cript` is removed from a file when it is found, otherwise `*.plain` suffix is added to the input file name, in order to obtain the output file name.

If an output file already exists, then Cr!ptAES tries to create a new file that contain the same name, but has an additional increasing number before the first suffix.

Un-encrypted input files must be safely deleted with the wipe option (![inline](r/msnet-criptaes/wipe.gif) see below), or some other safe wipe tool after they are encrypted. Just deleting them with the Window Shell, and removing them from Recycle bin is not safe (Update: This feature has not been tested with all storage types!).

##Operation Modes

Cr!ptAES has several operation modes. Encryption /decryption modes:

* ![inline](r/msnet-criptaes/encrypt.gif) Encrypt - encrypts all input files, regardless of their suffix (even if it is `*.cript`).
* ![inline](r/msnet-criptaes/decrypt.gif) Decrypt - decrypts all input files, regardless of their suffix (even if it is not `*.cript`).
* ![inline](r/msnet-criptaes/auto.gif) Auto - default, decrypts input files ending in `*.cript` and encrypts others. Default auto mode is handy when you open Cr!ptAES with `*.cript` or un-encrypted files and want to just decrypt or encrypt, without specifying the mode.

The suffix (extension) of the files does not matter to Cr!ptAES, so you can give to the encrypted files to any name and suffix you like, but in order for the Auto mode to work, the encrypted files needs to have the `*.cript` suffix (see also the `/u` command-line option below).

Other modes:

*  ![inline](r/msnet-criptaes/crc.gif) Fingerprint - calculates the SHA256 finger print of all files. It reports for each file its SHA256 finger print in hexadecimal. Equal files are also reported. The .NET SH256Managed implementation is used.
*  ![inline](r/msnet-criptaes/wipe.gif) Wipe - Safely deletes all files, by overwriting them before with random data. Use with care, because the deleted files cannot be recovered anymore. You can also run the Windows XP cipher /W tool time after time.
*  ![inline](r/msnet-criptaes/scan.gif) Information - Collects and prints information about the input files and folders, such as, the file extensions, and the empty files.

Two of the toolbar buttons offer additional minor features:

* ![inline](r/msnet-criptaes/mid.gif) Machine ID - shows a SHA256 hash of various hardware parameters that identify your PC. This number is never used for anything else, only shown.
* ![inline](r/msnet-criptaes/info.gif) Input files info - shows how many input files and folders are in the input list.

Password settings are ignored for non-encryption/decryption modes.

##Password

The password can be entered in the text field near the button ![inline](r/msnet-criptaes/pass.gif). The recommended minimum random password lengths to use are 22, 32, 43, and 75 characters, corresponding to the key sizes 128, 192, 256, and 448 bits. To decrypt the files you must know the exact password used to encrypt them. The letters used in the password can be any, but it is recommended that you use only ASCII chars, numbers, and symbols (the same as in automatically generated passwords ![inline](r/msnet-criptaes/pass.gif)), in order to be able to type the password in every Windows machine.

The buttons around the password field have the following functionality:

* ![inline](r/msnet-criptaes/pass.gif) Generate - generates automatically a random password of the recommend size. Of course, a random password makes no sense when decrypting.
* ![inline](r/msnet-criptaes/copy.gif) Copy - copies the password in the system clipbord.
* ![inline](r/msnet-criptaes/clean.gif) Clean - clears the password text and the log field text.

The two checkboxes next to the password field mean:

* ![inline](r/msnet-criptaes/mask.gif) Mask- if not checked the password is visible. If checked the password in not visible, but masked with '*'.
* ![inline](r/msnet-criptaes/keep.gif) Keep - if not checked then the password field will be emptied once the encrypting / decryption start (the password will be remembered internally until it is needed). This option is handy when you want to leave the program encrypt some files, but you do not want that the password be still there while the program is working, or when the program finishes.

The  numeric field enables to change the iteration count. The iteration count tells how many times the password will be hashed with SHA256 before it is used as an AES key. Normally you never need to change the value of this field. This is the reason why the field is disabled by default. To enable it, click on the ![inline](r/msnet-criptaes/ic.gif) image. To set back the default value click again on the  image. If you change the iteration count, the exact value is needed in order to decrypt the files. The default value is 1024, and the custom value should be near this range in order for keys to be secure. You can safely ignore this field and never change it.

### ![inline](r/msnet-criptaes/aesd.gif) Encryption Type

Before you encrypt, or decrypt you need also to select the type of the encryption alogithms (and key size) to use from the ![inline](r/msnet-criptaes/aesd.gif) list. By default, AES with 128 bit keys is used. You can also use AES with 192 bit, or 256 bit keys, or BlowFish with 128, 192, 256, 448 bit keys, or Serpent with 128, 192, 256 bit keys. To get the next encryption type use the combo box, or the next ![inline](r/msnet-criptaes/next.gif)  button. To reset the default encryption type click on  ![inline](r/msnet-criptaes/aesd.gif) image. The bigger the key size is, the safer the encryption is. A big key size makes no sense if you use a short password. Try to use random passwords of the recommend lengths, or longer. If you select another encryption type than the default one (AES 128) then you need to specify it again when you decrypt the files, otherwise the decryption will fail and you will get garbage data.

Which encryption type to choose depends on objective, and subjective factors. As the name Cr!ptAES implies, using AES is recommended. AES is fast, has no weak keys, and has gone under more scrutiny than the other encryption algorithms provided. Of course, subjectivity plays also an important role in (de)en-cryption. Feel free not follow the AES recommendation and use the other types of the encryption algorithms provided. Diversity is always good and this is why Cr!ptAES supports BlowFish, and Serpent, apart of AES. You can also combine them, if you like. For example, encrypt first the files with BlowFish, and then with AES, and so on, you can use any combination, but you have to remember it. Only one encryption pass with one of the supported encryption types is usually enough.

If you forget the password, or the iteration count used (if you change the default one), or the encryption type(s) used, then you cannot decrypt back the data.

##Processing Files

Once the input files are in place, and the operation mode has been selected, and the password data are properly set, you can click the ![inline](r/msnet-criptaes/start.gif)  Cr!pt button to start processing the files. Progress about the process will be shown. To stop the process, click again the ![inline](r/msnet-criptaes/start.gif)  Cr!pt button, whose caption is changed to Stop during the processing of the files. If you stop the process then the last output file in encrypt/decrypt/delete modes will be left unfinished and will contain partial data.

##Command-Line & Shell

Cr!ptAES options and operations can be also specified from the command-line. The command-line is important if you want to:

* Enable the Windows Explorer shell to directly call Cr!ptAES when you double-click a `*.cript` file. To do this, right-click on a `*.cript` file and select 'Open With ...' from the Windows * Explorer shell context menu. Then select a program from the list and browse for Cr!ptAES.exe. Select 'Always use this program to open the file' and then OK. If you create the shortcut manually, then in the shortcut Target you need to specify the full path and any additional options (see below) you may like, and no quotes "" around the options, e.g:
`C:\CriptAES\Cr!ptAES.exe /a AES256`
* Change the default Cr!ptAES settings. For example, to change the AES key size to 256 bit as default, create a shortcut to CriptAES.exe with these parameters: `Cr!ptAES.exe /a AES256`.

The complete Cr!ptAES command-line options follow:


```
Cr!ptAES [/?] [/e | /d | /c | /w | /t] [/p password] [/m] [/k] [/i iterationCount] [/a aesKeySize] [/o outputDir] [/s] [/x] [/u suffix] [/f inputFileList] [files | folders]

Where:

/? - shows the command-line help.
/e - encrypt mode (default auto mode).
/d - decrypt mode (default auto mode).
/c - finger print mode, default auto, /x is ignored\n";
/w - wipe mode, default auto\n";
/t - information mode, default auto, /x is ignored\n";
/p password - the password, the surrounding space, if any, is ignored.
/m - if specified the Mask checkbox will be unchecked.
/k - if specified the Keep checkbox will be unchecked.
/i iterationCount - must be >=1, default 1024
/a aesKeySize - the aesKeySize can be one of:
AES128, AES192, AES256,
BWF128, BWF192, BWF256, BWF448,
SER128, SER192, SER256.
Default is AES128.
/o outputDir - if * then the same folder as input files is used.
/s - start processing directly after starting the program.
/x - stop the program automatically after finishing the first processing. Can be used alone, or combined with /s.
/u suffix - changes the encrypted files suffix for this instance only, default is .cr!pt.
/f inputFileList - read the input file and folder paths from a text inputFileList file. The paths must be one per line inside the inputFileList file.
files and/or folders - input files, or folder paths. For folders, all sub folder files are included. Wildcards are not supported.
```

All command-line switches are optional. If you use automatic start /s and /e (or /d) then you need to specify at least the password and the input files. Example:


```
Cr!ptAES /p test /a AES256 d:\myfile.zip "c:\my dir" /s /x /k /o * /e
```

[Cr!ptAes](#r/msnet-criptaes.md) | [Usage](#r/msnet-criptaes/usage.md) | [Encryption](#r/msnet-criptaes/encryption.md)