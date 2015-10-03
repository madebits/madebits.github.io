# .NETZ: Usage Documentation

[.NETZ](#r/msnet-netz-compressor.md) | [Usage](#r/msnet-netz-compressor/help.md) | [Limitations](#r/msnet-netz-compressor/limits.md) | [Compression](#r/msnet-netz-compressor/compression.md)

<div id='toc'></div>

**.NETZ** can be used to transparently compress .NET standalone EXE files and non-shared DLLs. For best results, download a version of .NETZ compiled for the version of .NET Framework that you are using.

.NETZ is a **command-line** tool. All examples below should be typed in a CMD window (or placed in a batch *.BAT file for your project, that can be run as a post-build step from within Visual Studio IDE). It is recommended to add the directory where `netz.exe` is found to the system path.

Please read the help carefully before spending any effort to extend .NETZ. It is very probably that .NETZ does already everything you want.

In the examples that follow, I supposed that we need to compress an application `app.exe`, which may depend on several libraries: `lib1.dll`, `lib2.dll` and `lib3.dll`.

## Basics

###.NETZ Tool

.NETZ is a command-line tool. To install, download the zip file and unzip it to a folder (e.g.: C:\netz\). To compress your application either run .NETZ using an absolute path from its install location, or add the .NET EXE folder to your Windows system path. For example if your application EXE named `app.exe` is in folder `C:\My Project\bin\Release`, and `netz.exe` (and all its other needed files) is in `C:\netz\`, then you could use:

```nohl
C:>cd "C:\My Project\bin\Release"
C:\My Project\bin\Release>"C:\netz\netz.exe" app.exe
```

In the rest of the examples, the paths are not shown.

.NETZ has a lot of options, but most of the time you will need only few of them:

```nohl
Usage: netz [-s] [-so] [exe file] [[-d] dll file]*
            [-a assemblyAttributes file]
            [-o outPutFolder]
            [-aw] [-p privatePath] [-i win32icon] [-n] [-c | -w] [-mta]
            [-pl platform] [-x86]
            ([-z] [-r compressLib] [-l redistributableCompressLib])
            ([-kf] [-kn] [-kd] | [-ka])
            [-sr] [-srp file]
            [-v] [-b] [-!]
            [-xr] name [[-d] dll file]*
            [-csc] string

 Where:

 -s   single exe, pack dll-s as resources      |
 -so  optimize single exe (valid with -s only) |
 -a   assemblyAttributes file, custom EXE assembly attributes
      in the Visual Studio C# format
 -o   output folder, will be created if not exists,
      default exename.netz
 -aw  warn about unhandled EXE assembly attributes, default ignore
 -p   privatePath, optional private application domain path
 -i   win32icon, optional icon file
 -n   add version info to starter, default no info
 -c   console exe CUI, default is autodetect |
 -w   windows exe GUI, default is autodetect |
 -pl  supports /platform cross-compilation in 64 bit systems |
 -x86 shortcut for -pl x86                                   |
  -mta adds MTAThread attribute to main
 Compress options:

 -r   compressLib, compress provider dll, default defcomp.dll
 -z   pack redistributable compress DLL as resource, ignored if no
      redistributable compress DLL
 -l   redistributableCompressLib, name of the redistributable
      compress DLL, overwrites the one given by the provider

 Strong name (sign) options: (default no sign)

 -kf  keyFile, to use for signing the packed assembly |
 -kn  keyName, to use for signing the packed assembly |
 -kd  set delay sign true, default false              |
 -ka  get keyFile, keyName, delay sign, and algorithmId from EXE
      attributes. The -kf, -kn and -kd are ignored when ka is specified

 Service options:
 -sr  creates a basic NT service from the input exe and dll files |
 -srp file, parameters file for -sr option |

 Debug options:

 -b   batch mode, generates a batch file and source code
 -v   print stack trace if error
 -!   print internal version

 The -xr option:
 -xr  the -xr should be used alone to create external DLL resources

 Other options:
       -csc string passes the string to csc compiler

 Input files:
      At most one EXE file must be specified at [exe file].
      The DLL files can be specified alone or with wildcards.     |
 -d   If use before a DLL file, this option tells .NETZ that      |
      the next DLL will be loaded dynamically by the application. |
```
NETZ does not replace any compiler switches. Raw .NET modules, or resources (image, text, multi-media, etc), can be embedded directly with compiler switches into a .NET application and accessed using ResourceManagers, so there is no need for .NETZ to handle these.

###Packing EXE files

To compress only app.exe use:

```nohl
netz app.exe
```

It will create a directory `app.exe.netz` with the packed application. The `zip.dll` coming with .NETZ must be copied into the same folder as the packed EXE for it to run properly!

In order to embed the default zip.dll into the packed EXE, add the -z option, so no external DLLs are required:

```nohl
netz -z app.exe
```

The output folder for a packed EXE is by default a sub-folder in the directory where the original input EXE file is found, and it is named the same as the EXE file name with '.netz' appended to it. If you want another output folder, use the -o option. The folder must be different that the folder where the original EXE is found (because the outputted EXE file name is same, and the original EXE is not overwritten).

```nohl
netz -z app.exe -o c:\test
```

Optionally, to add the .NETZ version information to the packed EXE, use additionally the `-n` option.

By default a `[STAThread]` application is generated. To generate a `[MTAThread]` application add `-mta` option to the command-line.

No ready-made unpack option is provided.

###Packing DLL Files

To compress all or some of the managed DLL files that a .NETZ packed application uses try:
```nohl
netz app.exe lib1.dll lib2.dll
```
The respective packed files lib1z.dll and lib2z.dll will be placed in the original DLL directories. Copy them as necessary to the packed app.exe folder. A BATCH file can help to automate the process. The original DLLs are not deleted to avoid any errors and because they are still needed by the uncompressed version.

If you have already packed app.exe then you can pack additional the DLL files:
```nohl
netz lib3.dll
```
Wildcards in the DLL file names are accepted:
```nohl
netz .\bin\lib*.dll
```
DLLs packed with .NETZ can be used only with EXE files packed also with .NETZ.

###Creating a Single EXE File

Most people use .NETZ to combine the EXE and all its used .NET DLLs into a single file. To pack some or all of the managed DLL-s as resources in a single compressed standalone .NET EXE file use:
```
netz -s app.exe lib1.dll lib2.dll
```
The lib1z.dll and lib2z.dll will now be packed inside the compressed app.exe as resources.

`-s` option is valid only when an EXE file is specified. The names of the DLL files need not to be unique, but the DLL assemblies themselves must be unique. Embedded DLL files are identified (only) by their full assembly name. In practical terms, this means that resource DLLs for different cultures (DLLs with the same name, but under different culture subdirectories) can be safely embedded in the single EXE. Just specify the path to each resource DLL that you want to include.

You could also pack zip.dll (or any other custom compression provider re-distributable DLL file) as part of the packed application by using the -z option.

####Optional

If the single EXE file has no DLL compressed with .NETZ apart of the ones that are embedded with the -s option (and -z) and the -p option is not used, then you can use the -so option to remove the functionality of loading *z.dll files from the packed application. The -so option could save around 4KB of size.

```
netz -s -z app.exe lib1.dll -so
```

or even if you have no DLLs:
```
netz -s -z app.exe -so
```

####Packing Dynamically Loaded Assemblies

By default, .NETZ uses the full assembly name of a DLL to pack it as a resource within the EXE file. This means that if your application dynamically loads assemblies, using code, such as:
```csharp
Assembly assembly = Assembly.Load("lib2");
```
Then .NETZ cannot find the packed lib2.dll.

To remedy this, you have the option to tell .NETZ to use the assembly file name when packing, by using the -d option (-d stands for dynamic) before all the assemblies that you load dynamically and want to pack with .NETZ. For example:
```
netz -s -z -so app.exe lib1.dll -d lib2.dll lib3.dll
```
In this case .NETZ will not use the full assembly name (and will not mangle it) for the lib2.dll, and can find lib2 when you load it dynamically with code as above.

Wildcards cannot be used for DLLs files specified with -d option, and only file names without spaces are supported.

`-d` option uses the DLL file name to name the packed resource. If you want another name you can specify it using ':' after the -d option, for example:
```
netz -s -z -so app.exe lib1.dll -d:mydynamiclib lib2.dll
```
You can now use Assembly.Load("mydynamiclib") in your code to load lib2.dll. Only names without spaces are supported.

The -d option has also two special forms:

* `-d:@` uses the full internal assembly name
* `-d:#` uses the short internal assembly name

To see the names used for packed resources use the -v option. It will report, among the other stuff, the resource IDs as RID: string after every packed file.

The resource names must be unique. The default naming schema of .NETZ ensures strong linking of DLLs, including the version and the culture information. The -d option skips this check. Do not change a DLL resource name with -d, unless you really need to.

###Handling Localized Resource DLLs

For .NET 1.0 and .NET 1.1, there is nothing special to do about localized resource DLLs. Treat them as normal DLLs. For example, to pack the .NET SDK sample **WorldCalc** and its language resource DLLs use:
```
netz -z -s worldcalc.exe .\de\WorldCalc.Resources.Dll
.\de-ch\WorldCalc.Resources.Dll
```
To test, run the packed *worldcalc.exe*:
```
worldcalc.exe
worldcalc.exe de-ch
```
The title of the window will be different in the two cases.

For more details see the:
*.NET SDK \Samples\Tutorials\resourcesandlocalization\worldcalc*

.NET 2.0 cannot be supported. The ResourceManager was rewritten for .NET 2.0 and it does not raise the AssemblyResolve and ResourceResolve events properly from the new code (the programmer forgot about this?). Instead, .NET2.0 looks by default into the main assembly only. Using `[assembly: Neutral Resources Language Attribute( "en" , Ultimate Resource Fallback Location . Satellite )]` attribute will throw a `Missing Satellite Assembly Exception` and after this point there is nothing that can done. You can help by writing an email to Microsoft .NET team asking to have this .NET 2.0 bug fixed.

A workaround for .NET 2.0, suggested by *A. Ripault, ar_world2005 **[ at ]** yahoo.fr*, is to use the .NETZ -p option to specify a private directory path where you list the unpacked localization resource DLLs. The folder structure should look as follows:
```
app.exe.netz\
  app.exe
  lang\
    fr\
      app.resources.dll
    en\
      ...
```

This way you can pack all the other assemblies with .NETZ, and have a single sub-folder for all unpacked resource DLLs.

##Intermediate

###EXE Assembly Attributes

The custom attributes explained in the section affect only the main EXE file, not the DLLs. .NETZ processes automatically the following attributes for the main assembly (EXE file) and copies their values to the packed EXE:

```
System.Reflection.AssemblyCompanyAttribute
System.Reflection.AssemblyConfigurationAttribute
System.Reflection.AssemblyCopyrightAttribute
System.Reflection.AssemblyCultureAttribute
System.Reflection.AssemblyDescriptionAttribute
System.Reflection.AssemblyProductAttribute
System.Reflection.AssemblyTitleAttribute
System.Reflection.AssemblyTrademarkAttribute
System.Reflection.AssemblyVersionAttribute
```

Unhandled attributes can be usually safely ignored. To see the attributes that are not processed by .NETZ use the -aw flag. In this case a warning will be reported for every non processed attribute.

`System.Windows.Forms.Application.ProductName` has some undocumented behavior. Normally, it should return the value set in the `AssemblyProductAttribute`. When this attribute is not set, the `System.Windows.Forms.Application.ProductName` will return the start up namespace name. .NETZ changes the start up namespace to "netz". If this is a problem (reported by *Hadob&aacute;s Attila, attila **[at]** hadobas.com*), then make sure you explicitly set the `AssemblyProductAttribute` in your application. For example, in C#, one could use:

```
using System.Reflection;
using System.Runtime.CompilerServices;
[assembly: AssemblyProduct("MyApplication")]
```

Then compile your application as usual and compress it with .NETZ. .NETZ will not change the AssemblyProductAttribute value.

If your main (EXE) assembly uses (custom) attributes other than the ones in the list above (usually set in the `AssemblyInfo.cs` in the Visual Studio generated projects) then you need to set these attributes manually.

Other custom attributes can be specified in a text file and passed to .NETZ using the -a option (using -a you cannot replace the standard attributes listed above, such as AssemblyVersion, that .NETZ copies from the original exe, you can only add new ones). The syntax should be similar to the one Visual Studio uses for AssemblyInfo.cs file in C# applications, e.g.,
`[assembly: AssemblyDelaySign(true)]`.

Another way to specify custom attributes is to use the -b option. It will generate an AssemblyInfo.cs file in Visual Studio format that you can modify to place any custom attributes for the main assembly.

In order to handle the following strong-name related attributes, see Signing the Packed EXE File:

```
System.Reflection.AssemblyKeyFileAttribute
System.Reflection.AssemblyKeyNameAttribute
System.Reflection.AssemblyDelaySign
```

###DLL Private Paths

If app.exe makes use of private paths and expects for example that lib2.dll be inside a subdirectory called 'bin', then you can simply place the packed version of lib2.dll, that is lib2z.dll in the same folder. The .NETZ starter code can find zipped DLL-s in private paths in the same way as .NET does. .NETZ also supports cultures.

If app.exe does not use private paths, but you would like to use them with the packed version then you can specify them with the -p option:
```
netz app.exe lib2.dll -p bin
```
You have to create the 'bin' directory manually and place any *z.dll files that you like there. All private paths will be searched. To specify more than one private path, separate them by ;:
```
netz app.exe lib2.dll -p bin1;bin2
```
Private paths are relative to the directory where app.exe is found. Absolute paths are not accepted. You have to place the *z.dll or *.dll files manually in the intended private path directories.

If you pack the DLL files inside the EXE file with the -s option, there is no need to set this option, unless you have other unpacked DLLs that use it. (Even if you set private paths when you do not use them, it is not an error.)

The way that the .NETZ handles private paths was deprecated in .NET 2.0 (CS0618), however it still works ok.

###Compression Provider Options

The following options -r, -z, and -l are used with compression providers. The -z and -l serve to fine tune the way the redistributable decompression DLLs (if any) are handled.

####The -r Option

The -r option allows to select another compression provider. Default is **defcomp.dll**. Example:
```
netz -r net20comp.dll app.exe lib1.dll
```
This command tells .NETZ to use the .NET2 2.0 compression provider that requires no redistributable DLL file (no zip.dll is needed).  **net20comp.dll** provider is valid only for .NET 2.0 and has a lower compression ratio than the default provider.

####The -z Option

In general, a compression provider may require that you distribute a decompression DLL with the packed applications. For example, by default .NETZ uses the defcomp.dll to compress the files. The defcomp.dll requires that you redistribute the zip.dll file with the packed applications.

Not all compression providers may require that you redistribute a decompression DLL. For example, net20comp.dll does not add any additional DLL to the packed applications (.NET 2.0 only).

If a compression provider has a redistributable DLL, as it is the case with zip.dll for defcomp.dll, then the redistributable DLL (zip.dll file) cannot be compressed. It can be packed using the -z option. This option is ignored in the provider does not specify a redistributable DLL and no -l option is present. For example:
```
netz -z -s app.exe lib1.zip
```
The -z option is valid only when an EXE file is specified and when the compression provider has specified a redistributable compression DLL file name. The default compression provider specifies zip.dll file (a recompilation of #ZipLib).

The -z option packs the redistributable compression DLL file (default zip.dll) as a resource of the EXE file, so you do not have to distribute it separately with compressed app.exe. The redistributable compression DLL file (zip.dll) file is not compressed, so this option does not make the overall size smaller. It is provided only as a convenience. The zip.dll assembly is strongly named.

####The -l Option

The -l option overwrites the name of the redistributable compression DLL file returned by the compression provider, if any, (default zip.dll) with a custom name. The given DLL with the new name must exist.

For example, one should not use the name "zip.dll" for another application DLL file, when the default compression provider is used (defcomp.dll) as this is used by .NETZ. You can rename zip.dll to a new name (and reuse "zip.dll" for your DLL files). If you want to use another file name ( name) then use the -l option to tell it to .NETZ:
```
netz app.exe -l ICSharpCode.SharpZipLib.dll
```
.NETZ will now use the ICSharpCode.SharpZipLib.dll instead of zip.dll. The specified #ZipLib ICSharpCode.SharpZipLib.dll file must exist. The default value is zip.dll.

Note: If your original application uses #ZipLib then you do not need to distribute zip.dll when using defcomp.dll. You need to link the starter with #ZipLib's original DLL file (ICSharpCode.SharpZipLib.dll), not with zip.dll. Use the -l option to name ICSharpCode.SharpZipLib.dll as the default ZIP library for this purpose.

Do not specify -l, when the compression provider has no redistributable DLL file, as is the case with the net20comp.dll.

###Licensed Components and Controls

.NETZ handles automatically EXE files that contain .NET licensed components information (generated with lc.exe), by automatically processing app.exe.licenses data when found. There is no need for any special user interaction.

If for any reason, you find that .NETZ fails to set the license information properly, then use the -b option to provide this information manually (using `/res:app.exe.licenses`).

###Signing the Packed EXE File

.NETZ works transparently either with signed (strong named assemblies), or unsigned assemblies. By default, the packed EXE file is not strongly named. If strongly named assembly EXE file is packed, it is preserved as strong named and will run as such.

.NETZ offers several options to sign the packed EXE (-kf, -kn, -kd, -ka). These options mimic the use of the following attributes:
```
System.Reflection.AssemblyKeyFileAttribute
System.Reflection.AssemblyKeyNameAttribute
System.Reflection.AssemblyDelaySign
```
The -kf, -kn, -kd options only set the above final assembly attributes. The compiler then uses these attributes to sign the exe. For example, to specify a key file app.snk to use to sign the packed EXE for app.exe use:
```
 netz app.exe -kf app.snk
```
This will set: `[assembly: AssemblyKeyFile("app.snk")]`. Only the packed EXE is signed, not the original app.exe. Similarly you can use the -kn keyName option to specify a key name. See the .NET documentation for details what a key name or a key file are and how a key name or key file is resolved. To delay sign specify the additional option -kd.

You could also reuse the original key file, or key name information found inside a signed app.exe. This was the default behavior of .NETZ before version 0.2.8. To achieve this, use the -ka option:
```
 netz app.exe -ka
```
In this case, .NETZ will check the app.exe for the above attributes, and for the System. Reflection. AssemblyAlgorithmIdAttribute, and reuse them for the packed EXE. Another way to explicitly set the System. Reflection. AssemblyAlgorithmIdAttribute attribute is to use the -a option. Often the file specified in the AssemblyKeyFileAttribute uses a relative path. For this reason, make sure this path can be reached exactly from the folder where you are running .NETZ. For example, if app.exe is created in Visual Studio and uses `app.snk` found in the project directory (.), then the path used for the key file in AssemblyKeyFileAttribute will be `@".\.\app.snk"`. This means that you can safely run .NETZ with -kf from the `.\bin\Release` or the `.\bin\Debug` folder, because the path depth matches. If in doubt, use the -b option.

If -ka is specified, then -kf and -kn are ignored, unless no key file, or key name attributes are found in the app.exe. Check the .NET documentation for the requirements of the linked assemblies before you sign the packed EXE. The redistributable zip.dll file that comes with .NETZ is strongly named and can be safely used with signed EXEs.

###Service Support (-sr, -srp)

.NETZ offers some very basic support to create NT services from arbitrary EXEs (thanks to *Marc Clifton, marc.clifton **[at]** gmail.com*). To turn any console EXE to a Windows service append -sr to the usually .NETZ path:
```
netz -s -z app.exe lib1.dll -sr
```
It will create a Windows service from the non-service app.exe. The original app.exe will be run inside a Windows service thread, so you do not need to run a thread on your own. The original app.exe can run a loop inside its Main method where it does the work. Any command-line arguments will be passed to its Main() method. A sample app.exe may look as follows:
```
using System;
class MyService {
  public static void Main(string[] args) {
    // process args
    while(true) {
    // do something
    System.Threading.Thread.Sleep(...);
    }
  }
}
```
By default, the services are named `netz service timestamp`. To specify another name and other parameters, use the -srp option. The -srp should point to a text file where the parameters are found. The format of the file is parameterId=paramterValue. The strings should not be put in quotes. For example:
```
 netz -s -z app.exe lib1.dll -sr -srp service.txt
```
Where the service.txt may look as follows:
```
#password=
#userName=
helpText=Netz service help text. Help must be one line. No quotes.
displayName=Netz Service
serviceName=Name must be unique!
#startType=System.ServiceProcess.ServiceStartMode.Automatic
```

Lines starting with `#` in service.txt are ignored. By default password and username are `null`.

The services support is very basic. To get an idea what kind of service code is generated, use the -b option and have a look at the generated code. The code generated with the -b option can also serve as a starting point for custom modifications of the service code.

To install the .NETZ generated service use the `installutil.exe` from the .NET SDK:
```
 installutil app.exe
```
To start the service use:
```
 net start "your service name"
```
To stop the service use:
```
 net stop "your service name"
```
To uninstall the service use:
```
 installutil /u app.exe
```

##Advanced

###Platforms - 32bit, 64bit (-pl, -x86)

.NETZ may need a recompile if used in x64 machines. See also Compiling .NETZ section. (SET NCSC=csc /platform:x86).

To cross-compile with .NETZ in a 64-bit platform use version of .NETZ compiled with .NET 2.0 and the `-pl string` option of .NETZ. The -pl option is equal to the `/platform:string` of the .NET CSC compiler. The string values passed to -pl are the same as the string values that are valid for the .NET CSC `/platform:string` compiler option: x86, x64, Itanium, and anycpu. Default is 'anycpu'. The -pl strings are passed directly to the .NET CSC compiler by using the `/platform` option. For example, to cross-compile for 32-bit in a 64-bit platform, append -pl x86 to the rest of .NETZ command-line options (valid only with .NET 2.0+).
```
netz -pl x86 -s -so -z app.exe l*.dll
```
.NETZ `-x86` option is provided as a shortcut for `-pl x86`.

.NETZ has been test with .NET 1.0, 1.1, and 2.0 in most Win32-bit platforms. The .NET 2.0 pre-compiled binary of .NETZ found in downloads will work ok in 64-bit systems (or you can try to compile the .NETZ source-code with the version of .NET Framework that you are using). The native 32-bit subsys.dll component of .NETZ can correctly parse both the 32-bit and the 64-bit CLR PE files.

###Batch Option (-b)

The -b option is useful to debug .NETZ starter code or, in general, to customize it. With the -b option, .NETZ will generate source code instead of compiling the starter application directly. A **makefile.bat** is generated to enable manually compiling the starter application. Append the -b option to all the other options that you use in your project with netz.exe. For example if your command-line is:
```
netz -s -so -z app.exe *.dll
```
Then use just add -b as follows:
```
netz -s -so -z -b app.exe *.dll
```
If you are using keyfiles (-kf) you may need to copy them explicitly to the folder generated by -b.

This option comes often handy when you are unsure what .NETZ does. Rather than looking at the .NETZ source code, you can look at the output generated code. While it is easy to customize the start code directly, this is not recommended for your final version. Modify the starter code on your own risk. Custom starter code is not supported. The start code may change in different version of .NETZ, and you will have to maintain it manually all the time. If you find problem, or want a customization that in not already available through the .NETZ command-line options, then please report it, and it will be very probably included as an option in the newer .NETZ version.

###-csc Option
Passes an arbitrary string to the CSC compiler used to compile the packed EXE. If you are unsure how the string is passed use the -b option and look at *makefile.bat*.
```
netz -s -so -z app.exe *.dll -csc "/win32manifest:""C:\my dir\manifest.xml"""
```
Escape inner quotes `"` with themselves `""`.

.NETZ already sets several compiler options by itself. Such options cannot be overwriten with -csc. The -csc string is just appended to end of options .NETZ sets. The -csc string can contain more than one option.

Some files, such as Vista manifest files, are better packed by special tools. For example, according to KB944276 manifest files are added as resources. Such files are easier to do pack via other tools. You can use those tools to append the manifest to the packed EXE file that .NETZ produces.

###Grouping DLLs in External Resources (-xr)

The -xr option enables packing a set of .NET DLLs used by the application, not inside a single EXE as the -s option does, but in a separate external resource file. The -xr should be used alone and as the first argument. For example, to pack lib2.dll and lib3.dll with -xr use:
```
netz -xr test lib2.dll lib3.dll
```
Only the -r and -d options can be used with -xr (after -xr).

The -xr command above will create a file named test-netz.resources. The file name ending *-netz.resources cannot be changed. The .resources is required by default .NET resource manager and while it is possible to create a custom resource manager, it would add size to the packed EXEs. The "-netz" part of the name is used by .NETZ started to find such resource files. The culture of packed resource DLLs is neutral.

Then you can pack app.exe with .NETZ as with any other application:
```
netz -s -z app.exe
```
or if you have DLLs to embed use:
```
netz -s -z app.exe lib1.dll
```
The -s is required, and -so should not be used. After this you can distribute the packed app.exe and test-netz.resources. When the packed app.exe is run, it will find lib1.dll in its internal resources, but it will find lib2.dll and lib3.dll in the external test-netz.resources file.

You can create as many resource files as you like. The only requirement is that they should be placed in the same folder as app.exe. They are searched in alphabetic order, and before the internal resources (so you have a possibility to easily replace a previously embedded DLL).

External resource DLLs are useful if you plan to distribute later on a new set of DLLs for an existing application. For example, if you have a plugin.dll that depends on lib2.dll and lib3.dll, you need only to distribute, plugin.dll (or the packed pluginz.dll) and plugin-netz.resources. You can also pack all plugin.dll, lib2.dll and lib3.dll, in the same external resource file plugin-netz.resources, and use the names of external resource file to identify available plugins.

###GAC, Serialization, Remoting, and Unhandled .NET Assemblies

.NETZ tool has some [limitations](#r/msnet-netz-compressor/limits.md). This section gives details about a few of them:

* **GAC, shared DLLs** .NETZ can compress non-shared .NET DLL and assembly files (no native DLLs). That is, .NETZ can compress almost all .NET DLL files that are used by a single application and that are not placed in GAC. If a DLL, e.g., lib1.dll file is shared by more than one application, e.g., app1.exe and app2.exe, then you can still compress lib1.dll to lib1z.dll if you compress both app1.exe and app2.exe with the .NETZ tool.

* **Serialization, Remoting** Some non-shared .NET assemblies, cannot be compressed by .NETZ. These assemblies are directly accessed by .NET CLR, or by .NET libraries. For example, applications that use .NET serialization or remoting (marshaling) are accessed by the built-in .NET serialization logic to generate the serialization code. During serialization the assembly information is added to the serialized data. During deserialization, a problem will show as the .NET will try to access the assembly directly to interpret the data (using Assembly.Load or Assembly.LoadWithPartialName). The details are different in different .NET versions. For example, the XML Serialization generates AssemblyResolveEvents in .NET 2.0, when an assembly is not found by the Load methods, but it does not generate such events in .NET 1.1 ([reference](http://msdn.microsoft.com/netframework/programming/breakingchanges/runtime/xmlserial.aspx)). These applications will fail when compressed with .NETZ, and when run under .NET run-time versions lower than .NET 2.0 (*Ludwig Stuyck (ludwig.stuyck **[ at ]** ctg.com*) reported that serialization of generics in .NET 2.0 is still problematic with regard of this issue). .NETZ relies on the availability of the AssemblyResolveEvents to provide assemblies (for .NET 2.0, the serialization code will work fine with .NETZ, if placed in a separate packed DLL, but not inside an EXE file.). Because, serialization and marshalling are also used by the .NET remoting, the remoting applications could also fail.

There is a simple workaround that can be used in general for all these types of applications (e.g., serialization before .NET 2.0). You have to place all types shared by remoting (or in general needed directly by the .NET CLR) in a separate DLL file that is not compressed with .NETZ. You can then compress the rest of EXEs and DLLs with .NETZ. For example, suppose you have two applications server.exe and client.exe. The client.exe uses some form of .NET remoting to call access objects of server.exe ([example](r/msnet-netz-compressor/serialization.zip)). The definitions of all interfaces and types used by both the server, or the client application to connect to the server via .NET remoting should be placed in one or more separate DLL files, e.g. shared.dll. If you do not want to place too much code in the shared DLL file, use interfaces of types that contain only data, but not functionality.

###Handling New / Different .NET Versions

.NETZ compiles the starter application using the default .NET version, under which the .NETZ is being run. There can be occasionally problems if the version/platform of .NET run-time used by .NETZ does not mach the one used to compile the application, that is, when you have more than one .NET run-time installed.

* If .NETZ uses a lower .NET run-time that the one used by the application, then the packed application will be linked against the lower version and in run-time types of the new .NET run-time may not be found. For example, this [screenshot](r/msnet-netz-compressor/error.JPG	) reported by a user, shows an error that has resulted from packing a NET 1.1 application that uses `System.Windows.Forms.FolderBrowserDialog`, against the .NET 1.0 ( with a .NETZ version compiled for .NET 1.0). This process is known as [assembly unification](http://msdn2.microsoft.com/en-us/library/db7849ey.aspx).

	To ease finding such bugs, .NETZ now reports properly the .NET run-time used to pack the application and the .NET run-time the application is running under, if such an error dialog is shown.

	To see the current version of the .NET run-time, and the version of .NET run-time used to compile .NETZ binary you are using, try the -! option. See also the .NET documentation on MSDN for details on how to configure the exact .NET run time by creating an .NET 1.0 style [netz.exe.config](r/msnet-netz-compressor/netz.exe.config.zip) XML file for netz.exe.

	For best results, use a version of .NETZ compiled with the version/platform .NET Framework that you are using for your application.

* The managed EXE or DLL assembly files could belong to newer, or different .NET versions. For example, the .NET 2.0 assemblies may not be parsed by a binary version of .NETZ compiled for .NET 1.0. In this case, the warning 1001 is issued. This warning usually means that there is a version/platform mismatch between the .NET runtime used by .NETZ, and the one used to compile the input EXE or DLL files.

	The solution for this problem is to recompile .NETZ source code with the version of .NET that you are using (or download a ready compiled .NETZ version for your version of the .NET run-time). See: Compiling .NETZ.

* Given the non-compatible resource managers in different versions of .NET, the string resources used by .NETZ and the .NETZ compression providers must be carefully created. The .NETZ embedded resources must also match the .NET version used. The solution for this problem is to properly recompile .NETZ source code with the version of .NET that you are using (or download a ready compiled .NETZ version for your version of the .NET run-time). See: Compiling .NETZ.

To get more details about a .NETZ error, or warning use the -v option.

###Compiling .NETZ

.NETZ compilation is made simple to easy handle new / different .NET versions. To recompile .NETZ for a given .NET version, you need to have the corresponding .NET SDK. No Visual Studio is needed. Even if you have Visual Studio, use the build.bat file that comes with the .NETZ source code to properly compile .NETZ.

To recompile .NETZ follow these steps:

* Download the latest source code from this web site and unzip it in a folder.
* Open a .NET SDK command-line window (with .NET environment variables properly set) and go (using CD) to the unzipped folder of .NETZ, where the .NETZ source code is found.
* Type csc and Enter in the command-line to verify the version of the C# compiler and the .NET run-time that you are using.
* Run the **build.bat** file from within the directory where it is found. The .NETZ compiled binaries will be placed in a new folder named netz-bin. Ignore any compiler [errors / warnings](r/msnet-netz-compressor/errors.zip) shown during the build, as .NETZ contains code that targets different .NET versions.
* If you want to run .NETZ in a x64 machine, uncomment **REM SET NCSC=csc /platform:x86** line in build.bat (remove REM). NETZ should be compiled only for x86 as it uses 32bit libraries. .NETZ can pack any .NET platform application.
* Note on resources: During the .NETZ build process, the .NETZ resource creator tool (makeres.exe) is also recompiled with the current .NET version used. Furthermore, a small tool called setdotnetver.exe is called to hardwire the .NET version that makeres.exe uses. If you need to specify a different .NET run-time version for makeres.exe, comment (with REM) the line in build.bat that calls setdotnetver.exe and modify makeres.exe.config file manually.

It is recommended NOT to modify the starter template code that comes with .NETZ source code (despite this being easy), unless you have a strong reason to do so. A modified starter template needs to be maintained explicitly, when a new .NETZ version comes out. .NETZ may be updated at any time and there is no warranty that the modified custom starter templates will be compatible with the new version. Custom modifications of the starter template are NOT supported, so modify it on your own risk. If you want to modify the compression related code, use the compression provider interface, which is supported. Use the -b (batch) option if you need to modify the starter code only for your solution.

##Troubleshooting

.NETZ issues (a) errors and warnings during packing and (b) a run-time message box (error message in command-line apps) if the packed application fails to start.

###Pack-Time Troubles

At pack time, .NETZ can issue errors and warnings if something goes wrong:

* **Errors** are issued when something critical happens, for example, an input file passed to .NETZ is missing, or a compilation error happens. Most the errors result from wrong input passed to .NETZ by the user and can be prevented by reading the on-line help. Other errors, such as compilation ones may reflect internal .NETZ problems (if any) and should be reported.

* **Warnings** issued by .NETZ are also very important. They usually show failure of pre-conditions that must hold for the .NET assemblies, so that they could be packed by .NETZ. .NETZ warnings are numbered for easy reference. This section lists all current .NETZ warnings, explaining the ones that can safely ignored, and the ones that are usually important to be ignored. Workarounds are provided when possible.
Append the -v option to your .NETZ command-line to get a stack trace of the error, or more information about an warning.

####NETZ Warnings List

* Warning 1001 - Cannot process assembly metadata

	The .NET runtime version used to compile a given EXE/DLL is not supported (version mismatch), or the file is not a .NET assembly. For workarounds in the case of wrong .NET version, see Handling New/Different .NET Versions.

	The warning 1001 (and 1005) denote a .NET version mismatch between the .NET version/platform used to compile the .NETZ tool you are using and the one used to compile your application. .NET reflection code (that is used inside .NETZ tool) cannot read your assembly properly! Compile .NETZ in the same way as you compile your assembly (.NET version/platform). Despite 1001 being a warning, some packed assemblies may not work properly if you see it.
* Warning 1002 - Icon
	The EXE icon resource of the EXE cannot be found. Most of the time this means that there is really no icon in the EXE and this warning can be safely ignored. It is usually reported for console EXEs. If the EXE has really an icon, but .NETZ cannot find it, or finds it wrongly, then as a workaround you can specify an icon with the -i option:
	```
	netz app.exe -i app.ico
```
	.NETZ uses currently a code from vbaccelerator.com to extract icons. This code may fail at some cases (PNG icons are not supported and skipped).
	
* Warning 1003 - Unhandled main assembly attribute
	.NETZ handles some common EXE assembly attributes, but not all. Most of the time it makes no sense to copy and attribute of the original assembly (which is still preserved unchanged, and it is run as such), to the wrapper assembly. Depending on the use case, some attributes of the original assembly may need to be repeated also to the wrapper assembly. If you see this warning, then decide if you really need to copy these attributes. Most of the time, you do not need to copy them, or do anything. If you really need to copy them, there are several ways to do so, as explained in EXE Assembly Attributes.
	
* Warning 1004 - Cannot determine EXE's subsystem
	.NETZ can handle Windows desktop console and GUI .NET applications. .NETZ can detect the EXE subsystem and properly generate an appropriate wrapper. If you try to pack other types of EXE with .NETZ, you will get this warning. If you see it, then the packed application is likely not to run, because this type of EXE is not supported by .NETZ.

	To overwrite the .NETZ auto detect use the -c option for CUI, or the -w option for GUI subsystem. For example, if app.exe is a console application then use the -c option:
	```
	netz -c app.exe
	```
* Warning 1005 - Cannot process assembly license information
	See Licensed Components and Controls. If some error happens during processing the assembly license information, this warning is shown. It could also be related to Warning 1001. See also: Handling New / Different .NET Versions.
	
* Warning 1006 - Assembly load test failed
	.NETZ tests an assembly if it can be loaded dynamically at run-time, using the same method the .NETZ packed EXE uses at run-time. If the test fails, warning 1006 is reported. The warning means that assembly cannot be packed with .NETZ, even thought it could be a valid .NET assembly. Most of the time this is the case with .NET managed C++ assemblies. There are usually two types of errors that you may encounter, reported as part of this warning:

	* `System.BadImageFormatException` - If you using a .NET managed C++ assembly then you can try to compile it using the `/link /fixed:no` option of cl.exe, but it could still fail with the next type of exception.
	* `System.IO.FileLoadException` - The main reason for this exception is a .NET managed C++ assembly optimized for direct execution by the C++ linker. There is no workaround for this at the moment. Other causes can be that the System. Security. Policy. Evidence information supplied by the assembly is not enough to allow the run-time to load it. This type of error is less likely to happen with .NETZ packed binaries.
	
	To get more details about an warning use the -v option.
	
###Execution-Time Troubles

####E01: Unhandled Application Exceptions

The following application fails when executed. If not packed with .NETz, the default system failure dialog box will show (it may look different, depending on the JIT debugger).

```
using System;
using System.Windows.Forms;

class MyForm : Form {
  public MyForm() {
    throw new Exception();
  }
}

class FailingApp {
  public static void Main(string[] args) {
    Application.Run(new MyForm());
  }
}
```

If this application is packed with .NETZ and executed, an error dialog will show (for console EXEs similar information is printed in stdout). The lines marked in red show the application error part.

To avoid seeing such crash dialogs: (a) put the code inside your Main function into a try/catch block show a custom crash dialog, (b) add an unhandled exception handler.
```
class FailingApp {
  public static void Main(string[] args) {
   try {
     Application.Run(new MyForm());
   } catch(Exception ex)
   { MessageBox.Show(null, ex.Message, "Error"); }
   catch
   { MessageBox.Show(null, "Application error!", "Error"); }
  }
}
```
The .NETZ error dialog shows also information about the .NET run-time used to pack the application and the one used to run it. This can be important for the next problem.

####E02: .NET Run-Time Version Mismatch

This [screenshot](r/msnet-netz-compressor/error.JPG) reported by a user, shows an error that has resulted from packing a NET 1.1 application that uses a .NET 1.1 specific class System. Windows. Forms. FolderBrowserDialog, against the .NET 1.0 ( with a .NETZ version compiled for .NET 1.0). For more information see Handling New / Different .NET Versions.

####E03: Assumption Errors
The following code when executed for a single assembly EXE, returns the path of the EXE in asm.Location:
```
Assembly asm = Assembly.GetExecutingAssembly();
FileVersionInfo fileInfo =
  FileVersionInfo.GetVersionInfo(asm.Location);
```
When packed with .NETZ, there is more than one assembly in the EXE and a packed `asm.Location` returns an empty string. This causes FileVersionInfo. GetVersionInfo to throw an exception, that is not thrown from the original EXE.

In this case, the original application made the assumption that `asm.Location` returns always the EXE path, which is not true. If left unhandled, such code gives out at best case E01 errors (see above).

In this particular example, the following code does not make this assumption and is thus more resistant:
```
FileVersionInfo.GetVersionInfo(Application.ExecutablePath);
```
There is no magic-bullet general solution for such assumption errors, but proper exception handling with error reporting helps finding them and reviewing the original application code.

####E04: False Virus Alert for Packed EXE

.NETZ packed applications are sometimes detected as possible viruses by anti-virus software, while the original ones not. These are all false positives and can be safely ignored. For various valid reasons people want that their end-consumer business software passes the anti-virus checks.

To address this problem, you have to understand why it appears. Anti-virus software tries detecting common code or data patterns in the applications, or rely on hashes of these. Based on these pattern / hashes, anti-virus software programs flag applications as possible viruses when they match their virus pattern database entries (this does not mean that the found pattern per se is malware, it only means some malware had once such a pattern).

Having same pattern means nothing per se, and hashes could fall to the same pigeonhole, so they can also fail. This often leads anti-virus software programs into reporting false positives. .NETZ (downloaded from this web site!) generated wrapper is not malware, and very likely your application is not too. Malware programs have often compressed code / data segments. The anti-virus patterns match thus often over compressed byte sequences, which increases the risk of false positive for .NETZ packed applications (which contain also compressed data), over the unpacked ones.

The following general techniques may help to overcome such anti-virus checks, no matter if your application is real malware, or not (flagging something as malware is subjective anyway :)

* Simply recompile once the original application (this has worked for .NETZ zip.dll).
* Reorder some code in the original application.
* Change some of resource bytes (e.g., change a pixel in a bitmap resource).
* If anti-virus software is not speculative and reports what patterns it found where (dream on), then you can focus on that part of the application and change it. Otherwise try to feel creative - any computer program's perceptions can be tricked at any time by a wise programmer :).
* Implement your own .NETZ compression provider, that simply modifies the compressed bytes in a recoverable way back and forth, just to change the patterns.

[.NETZ](#r/msnet-netz-compressor.md) | [Usage](#r/msnet-netz-compressor/help.md) | [Limitations](#r/msnet-netz-compressor/limits.md) | [Compression](#r/msnet-netz-compressor/compression.md)


