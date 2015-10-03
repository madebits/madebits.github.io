2004

#.NETZ - .NET EXEcutables Compressor & Packer

<!--- tags: csharp -->

[.NETZ](#r/msnet-netz-compressor.md) | [Usage](#r/msnet-netz-compressor/help.md) | [Limitations](#r/msnet-netz-compressor/limits.md) | [Compression](#r/msnet-netz-compressor/compression.md)

.NETZ is an open source tool that compresses and packs the Microsoft .NET Framework executable (EXE, DLL) files in order to make them smaller. Smaller executables consume less disk space and load faster because of fewer disk accesses.

Unlike other portable executable (PE) packers, .NETZ uses a pure .NET solution and it is written in C#. .NETZ can be used to pack .NET executables written in almost every .NET language. .NETZ supports both .NET EXE and non-shared DLL files. .NETZ is intended to pack .NET desktop applications and it is tested to work for console and Windows Forms applications. .NETZ compressed applications can be used in the same way as the uncompressed ones, transparently to the end user.

.NETZ does not pack the .NET run-time. A proper installed .NET run-time must be present in the machine where you run the packed applications. The technique that .NETZ uses is not supported by .NET Compact Framework.

##Related Readings

.NETZ tool has been described in several articles. The information in these articles may be out of date. Check out the .NETZ documentation for updated [documentation](#r/msnet-netz-compressor/help.md) information.

* [Using NetZ with Dynamically Loaded Assemblies](http://www.codeproject.com/useritems/NetzDynamicAssemblies.asp), by Marc Clifton in CodeProject, July 2006.
This article is a user contribution that shows how to find out at run-time, whether an application is being launched from within .NETZ, and how to customize assembly resolving in presence of .NETZ. For .NETZ versions > 0.3.4, the dynamically loaded assemblies can be handled by using the -d option.

* [Using Reflection to Reduce the Size of .NET Executables](http://www.jot.fm/issues/issue_2005_09/article1), Journal of Object Technology, Sep/Oct 2005 issue.
This article reflects some of the latest improvements and changes of .NETZ, and targets a more academically oriented audience, explaining the reasons for some of the decisions taken during the design of .NETZ. It has also statistics about the .NETZ performance and discusses .NETZ in a wider context.

* [Reducing the Size of .NET Applications](http://www.ddj.com/documents/ddj0503m/), Dr. Dobb's Journal, March 2005 issue.
This article is basically an updated and corrected version of the CodeProject article. It was published to Dr. Dobb's Journal to get the attention of professional developers and because of the interest from the editor. The copyright of the original article was handled to the Dr. Dobb's Journal.

* [Reducing the Size of .NET Applications](http://www.codeproject.com/dotnet/ReduceDotNetSize.asp), in CodeProject.com, June 2004
This is the original article about the .NETZ tool, which describes the idea. The article was written before .NETZ tool was developed. It was updated only once after .NETZ tool was created, but is currently not up to date. Nevertheless, this article served as a push to develop .NETZ, and it has generated feedback. Most of the people that get .NETZ are redirected from this site. A less generic tool than .NETZ was used privately for more than one year and a half before this article was first published.


##History

I have stopped maintaining and supporting .NETZ in 2011. The source, the binaries, and the documentation here should be enough to deal with it on your own. Please try not to contact me about it.

* 23-Apr-2011 - Version 0.4.8 - stable
Fixed a bug in -o option (reported by Barry Cantore techstuffbc [at] gmail.com ).
* 15-Dec-2010 - Version 0.4.7 - stable
Added -o option to specify output folder.
* 27-Oct-2009 - Version 0.4.6 - stable
Added -mta option (reported by Ignacio Soler nacho.soler [at] sipro.es). Netz EXE returns now 1 when fails and 0 on success (reported by Mario Turk" mario.turk [at] gmail.com).
* 11-Jun-2009 - Version 0.4.5 - stable
Added -csc option.
* 24-Mar-2009 - Version 0.4.4 - stable
.NETZ crashed while trying to extract some 32bit color icons. Thanks to Alan Ingleby, alan.ingleby [at] gmail.com, for reporting the issue and providing a hotfix that prevents crash by skipping the problematic icon. See also: -i option.
* 09-Nov-2008 - Version 0.4.3 - stable
-xr option was not working on non-English machines. Thanks to Ralf Westphal, ralfw [at] ralfw.de, for reporting the issue.
* 08-Nov-2008 - Version 0.4.2 - stable
Fixed a bug caused by -xr option changes when packed EXE was run over intranet. Thanks to Randy Diller, randy.diller [at] wyandotsnacks.com for reporting it. By chance, this fixes also a problem with -xr option itself when packed EXE was run over UNC intranet paths.
* 29-Mar-2008 - Version 0.4.1 - stable
Added the some basic service support, via the -sr option. Thanks to Marc Clifton, marc.clifton [at] gmail.com for providing the initial code.
* 01-Jul-2007 - Version 0.4.0 - stable
Just recompiled zip.dll after several complains.
* 20-May-2007 - Version 0.3.9 - stable
Added the -xr option.
* 06-Mar-2007 - Version 0.3.8 - stable
Fixed a bug in loading dynamic assemblies that are not packed within a single EXE. Reported by Bj&ouml;rn Lechmann.
* 26-Oct-2006 - Version 0.3.7 - stable
Improved detection for unsupported assemblies and improved error reporting.
Added the Warning 1006 to report problems with C++ assemblies.
Documentation updated.
* 11-Sep-2006
Added the -pl option.
* 10-Sep-2006
Added the -x86 option to support 32-bit cross-compilation in 64-bit platforms. Suggested by dino.nuhagic [at] gmail.com
Documentation updated.
* 01-Aug-2006 - Version 0.3.6 - stable
Starter code returns now the exit code of the application, if any. Thanks to Aron van Ammers, aron [at] i-dt.nl, for submitting the code.
* 24-Jul-2006 - Version 0.3.5 - stable
Extended the -d option support and fixed some minor bugs.
-v option lists now the packed resource IDs.
* 22-Jul-2006 - Version 0.3.4 - stable
Added the -d option to support packing dynamically loaded assemblies. Thanks to Marc Clifton, marc.clifton [at] gmail.com, for letting me know about his article.
The support for dynamically loaded assemblies was dropped by mistake as a side-effect of changes done in version 0.2.7 of .NETZ. A test case has been added now at the 'test/dynamic' folder of the source code.
Documentation updated on how to use -d.
* 03-Jul-2006
Documentation on packing localization resources updated.
* 27-May-2006 - Version 0.3.3 - stable
Fixed a bug regarding the use of newline in assembly string attributes. Thanks to Adam Greene, agreene [at] professionalopensource.ca, for reporting out the bug.
* 31-Dec-2005
Fixed a bug in the -r option. Thanks to Steve Maier, steve [at] ysgard.com, for reporting the bug and for figuring out the fix.
Minor changes in error reporting (the -v option implies now the -! option).
* 30-Dec-2005 - Version 0.3.2 - stable
Fixed a bug that prevented .NETZ from finding embedded culture-based DLL assembly resources. Reported by margiex.cai [at] gmail.com.
Minor changes in error reporting.
* 11-Dec-2005 - Version 0.3.1 - stable
Added -so option.
Documentation updated.
* 09-Dec-2005 - Version 0.3.0 - stable
Added SHA1 finger prints for the inner default templates (used to identify errors).
Added -kd option.
License changed.
Documentation updated.
* 23-Nov-2005 - Version 0.2.9 - stable
Changed EXE attribute support (-aw added).
Improved build process, to take care of the resources version.
Documentation updated.
* 21-Nov-2005 - Version 0.2.8 - stable
Improved support for strong named packed EXE files (-kf, -kn, -ka, added)
Documentation updated.
* 18-Nov-2005
Documentation updated.
* 11-Nov-2005 - Version 0.2.7 - stable
Removed the flat namespace restriction for embedded DLL file names (-s).
DLLs now report warning 1001, when the .NET version does not mach.
Added full support for licensed controls.
A build.bat file added to source (since the last update of 0.2.6) to facilitate the build process under any .NET version, without having to go through Visual Studio.
Packed applications starter errors show now information about the .NET run time version.
Documentation updated.
* 03-Nov-2005
Added a compression provider for .NET 2.0 (net20comp.dll, packed inside the 0.2.6 version downloads).
More documentation updates.
* 02-Nov-2005 - Version 0.2.6 - stable
A bug in the starter template corrected. Reported by Manfred Jaider mannij [at] sbox.tugraz.at.
Fixed a bug in finding the path of the default compression provider.
Warnings are numbered. A new warning for non parsable EXEs is added and the on-line help is updated.
* 01-Nov-2005 - Version 0.2.5 - stable
Fixed a bug with signed assemblies that prevented them from being processed. The zip.dll is now strongly named. The bug was reported by Rod Evans, rod.evans [at] dsl.pipex.com, on 2005-10-12.
Fixed a bug in the third-party icon extraction library that prevented 256 colors icons from showing properly. The bug was reported by Miguel Santos, miguel [at] duodata.pt, on 2005-10-13.
-a option is added and the -! option is documented.
Support for custom compression providers is added.
Support for two new assembly attributes is added.
After receiving a lot of interest, .NETZ has now finally its new web site.
Parts of the documentation are updated.
* 08-Sep-2005 - Version 0.2.4 - stable
Minor changes.
* 01-Sep-2005 - Version 0.2.3 - stable
Improved the EXE custom attribute support.
* 29-Aug-2005 - Version 0.2.2 - stable
Added support to autodetect the PE subsystem (-c and -w are now optional).
* 21-Jul-2005 - Version 0.2.1 - stable
Fixed a bug that prevented .NETZ to find the icon resource of an EXE file in some systems. The bug does not affect the applications packed with .NETZ, only the .NETZ tool.
The bug was in one of the third-party libraries that .NETZ uses (IconEx from vbAccelerator.com). For some reason IconEx code formatted the numeric resource IDs before passing them to the Win32 FindResource function using the .NET String.Format("#{0:N0}", resourceId) call, which is some systems inserts a decimal comma every three digits. The documentation of FindResource in Win32 SDK does not say anything about commas. The bug shows only in the Windows systems that have the thousands precision specifier on in the locale.
* 17-Jun-2005 - Version 0.2.0 - stable
Fixed a bug regarding loading assemblies with many dependencies. Loaded assemblies are now cached. It is strongly recommended to upgrade any packed applications with older versions, using this new version. Thanks to Taylor Brown, tbrown [at] ncsoft.com, for reporting the bug and suggesting the solution.
* 13-Oct-2004 - Version 0.1.8 - stable
Changed the way the zipping is done. Now the streams are compressed directly. .NETZ binary size is now smaller.
* 02-Sep-2004 - Version 0.1.7 - stable
A bug in finding 'zip.dll' path fixed.
* 17-Aug-2004 - Version 0.1.6 - stable
A bug in input validation fixed.
Changed how output directories are handled.
Wildcards are accepted in DLL file names.
* 09-Aug-2004 - Version 0.1.5
[STAThread] attribute added to starter's Main.
A bug in the batch code icon path removed.
Added the -n option.
Minor code factorizations.
* 06-Aug-2004 - Version 0.1.4
Finally added full EXE icon support.
Minor code factorizations.
* 05-Aug-2004
Added the -l option.
* 04-Aug-2004 - Version 0.1.3
Added the -z option. Suggested by Mike Kr&uuml;ger.
* 02-Aug-2004 - Version 0.1.2
A bug in the compilation versioning code fixed.
Search path for zipped DLL-s compatible with .NET defaults. Assembly culture is taken into account.
Empty resource files are not written.
zip.dll is now copied to the output dir.
The -p option added.
* 30-Jul-2004
A bug in the output directory name fixed.
* 29-Jul-2004 - Version 0.1.1
A serious bug in the starter template fixed.
Output file now is named after the application's EXE file.
.NETZ is used to pack itself :o).
* 24-Jul-2004 - Version 0.1.0 released.
* Feb-2003 - the first version of .NETZ was created for personal use, featuring also DES encryption with RSA based key distribution.

*From April 2008 to November 2014 .NETZ had around 55000 downloads.* For best results, compile .NETZ for the version of .NET framework you are using.

[.NETZ](#r/msnet-netz-compressor.md) | [Usage](#r/msnet-netz-compressor/help.md) | [Limitations](#r/msnet-netz-compressor/limits.md) | [Compression](#r/msnet-netz-compressor/compression.md)
