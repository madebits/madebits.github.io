#.NETZ: Compression Providers

[.NETZ](#r/msnet-netz-compressor.md) | [Usage](#r/msnet-netz-compressor/help.md) | [Limitations](#r/msnet-netz-compressor/limits.md) | [Compression](#r/msnet-netz-compressor/compression.md)

<div id='toc'></div>

.NETZ supports different compression libraries (providers). A compression provider is implemented as a .NET DLL file. Users can also define their own custom compression providers. By default the **defcomp.dll** compression provider is used. To specify a different compression provider use the -r option, or rename the provider's DLL to defcomp.dll.

Some providers may need that you distribute an additional DLL file with the packed application (e.g., the defcomp.dll uses zip.dll). Check out .NETZ usage help for the -z and -l options, to respectively pack or rename the provider's redistributable DLL (if any).

##Default Compression Provider (defcomp.dll)

Default compression provider **defcomp.dll** that comes with .NETZ, relies on the open source #ZipLib compression library for .NET to compress the executable data.

`#ZipLib` (Default) compression provider uses ZIP compression for EXE files and achieves about 60% size reduction. The provider needs to distribute a reduced version of #ZipLib (zip.dll) with the packed applications. The #ZipLib license allows you to distribute zip.dll with closed-source commercial applications packed with .NETZ. 

Size of zip.dll is about 65KB. This means that it makes no sense to try to pack with the default compression provider applications smaller than 150KB. Use the default compression provider of .NETZ only for applications bigger than 150KB.

You have to distribute the zip.dll file that comes with .NETZ with the packed version of the application that uses the default provider. You cannot compress the zip.dll file, but you can pack it with the -z option.

The (default) #ZipLib compression provider works with any .NET version.

##.NET 2.0 Compression Provider (net20comp.dll)

.NET 2.0 compression provider (**net20comp.dll**) that comes with .NETZ, uses the .NET 2.0 `System.IO.Compression.DeflateStream` class. It cannot be used for .NET applications compiled with older versions of .NET.

This provider does not require that you redistribute any DLL file with the packed applications, so you do not need to use the .NETZ -z and -l options for it.

.NET 2.0 compression has a worse compression level (3), than the default #ZipLib compression provider (9).

Use .NETZ -! option to find out the .NET runtime version under which .NETZ is being run.

##Custom Compression Providers

You may need to create a custom compression provider when:

* You have a compression library, that does better than the compression providers that come with .NETZ.
* You want to do some custom processing of the data apart of compression. For example, you may encrypt the data when you compress them and decrypt them at run time. .NETZ offers no default schema for the protection of data. You can implement your own schema by implementing a custom compression provider.

###Compression Provider Implementation Details

For a complete example, on how to implement a compression provider, see the source code for the defcomp.dll and net20comp.dll in the .NETZ source distribution.

A .NETZ compression provider is a .NET DLL that contains a class type that implements the `netz.compress.ICompress` interface, shown below. Being .NET DLLs, the compression providers can be implemented in any .NET language (apart of MC++). The templates discussed below must be in C#.

```
namespace netz.compress
{
 public interface ICompress
 {
  long Compress(string src, string dst);
  string GetRedistributableDLLPath();
  string GetHeadTemplate();
  string GetBodyTemplate();
 }//EOI
}
```

`netz.compress.ICompress` interface definition is found inside the netz.exe file, so if you plan to create your own provider, link the compression provider DLL with netz.exe. The methods of this interface are called by the .NETZ tool. The compression provider class should have also a default constructor with no parameters.

A short description of the ICompress interface follows:

* `Compress()` method compresses the source (src) file to a destination (dst) file. This method will be used by .NETZ to compress an EXE or DLL to a temporary file. The length of the compressed file (dest) in bytes must be returned.
* `GetRedistributableDLLPath()` method returns the name of the decompression DLL file that .NETZ may need to redistribute with the packed application. For #ZipLib, this file is named zip.dll. Not every provider may have a redistributable DLL. In this case this method should return null. The .NETZ -l option overwrites the strings returned by this method. The .NETZ -z option, embeds the redistributable DLL (if any) as resource in the packed application. The redistributable DLL should be as small as possible. It should contain only the functionality required by the decompression code (see `GetBodyTemplate()`).
* .NETZ starter code for the packed application decompresses the data. The starter code is actually a C# source code template, re-compiled by .NETZ for every packed application. The decompression code must be specified, thus, as C# code by the `GetBodyTemplate()` method. The code must be the implementation of this method:
```
 private static MemoryStream UnZip(byte[] data)
 {
//#ZIPBODY
 }
```
That is, a compressed `byte[]` vector data, should be decompressed into a `System.IO.MemoryStream` object and this object should be returned.

* If additional namespaces, apart of the following:

	```
	using System;
	using System.IO;
	using System.Resources;
	using System.Reflection;
	using System.Collections.Specialized;
	```

	are needed by the code inside the body template returned by the `GetBodyTemplate()` method, then these namespace usage sentences, must be specified in C# syntax (similar to the example above), by the `GetHeadTemplate()` method.

C# templates returned by the `GetBodyTemplate()` and the `GetHeadTemplate()` methods, can be packed as string resources in the compression provider DLL. See the implementation of defcomp.dll for an example.

##Memory Usage

.NETZ does not-in-place decompression of the compressed data. This means that the applications packed with .NETZ require slightly more virtual memory than the original unpacked versions. This is usually not a problem, because .NET frees the memory lazily as needed.

##.NETZ Encryption and Assembly Protection

.NETZ does not offer any protection against reverse-engineering.

.NETZ does not support any out-of-the-box method for encrypting, or protecting the compressed assemblies. .NETZ offers a generic interface to implement custom compression providers that could be used to implement encryption, or other protection related functionality.

.NETZ does not offer any out-of-the-box protection because theoretically it is impossible to do safe decryption in an unsafe environment (thanks to Dr. Ulrike Meyer for explaining this). All the tools that pretend to offer such methods, only try to make it hard to guess what is going on, but cannot warranty protection, despite any other casual claims.

If .NETZ were to offer a generic protection mechanism, it is very likely that it would attract attention and would be soon broken. Custom solutions tend to last longer, because they contain features fitted to each special case, but can be sometimes expensive to develop.

If you decide to build your own protection schema, then start with the default compression provider source code and add various security checks to the files. Partial assembly encryption based on DES, combined with RSA for the key distribution (for unique client IDs) has been tested to work fine and without any noticeable time and performance delays with .NETZ.

##Native DLL Files

.NETZ cannot handle native DLL files. There are two aspects with regard to the native DLLs: (a) compressing, and (b) packing them to a single EXE. .NETZ supports native DLLs compressed with other tools, but cannot pack native DLLs.

###Compressing

This is not a problem. .NETZ does not compress native DLL files, but other free tools, such as, [UPX](http://upx.sourceforge.net), can be used to compress native DLLs. The compressed native DLLs can be used in the same way the normal uncompressed native DLLs with the .NET programs. The .NET programs that use native DLLs can be compressed with .NETZ.

For example, create a simple `testdll.c` file containing:

```
#include <windows.h>
#include <tchar.h>

#define DllExport   __declspec( dllexport )

DllExport BOOL WINAPI DllMain (
	HANDLE h,
	DWORD d,
	LPVOID r){
	return TRUE;
}

DllExport int test()
{
	return 3;
}
```

Create a DLL testdll.dll from the code above, and call the `test()` function from a test C# program:</p>

```
using System;
using System.Runtime.InteropServices;

public class Test
{
	[DllImport("testdll")]
	public static extern int test();

	public static void Main(string[] args)
	{
		try
		{
			Console.WriteLine(test());
		}
		catch(Exception ex)
		{
			Console.WriteLine(ex.Message + ex.StackTrace);
		}
	}
}
```

Place both the test.exe and the testdll.dll in the same folder and test it. Then compress testdll.dll using UPX:

```
upx testdll.dll
```

Run test.exe again to verify that it works. Then compress test.exe to test with .NETZ:</p>

```
netz -z test.exe
```

Copy the compressed testdll.dll in the same folder as the compressed test.exe and run <i>test.exe</i>. Again, test.exe can use the compressed native DLL.

###Packing

.NETZ cannot handle packing native DLLs into a single EXE. There are two ways to use DLLs in a native (unmanaged) application: either link them statically (load-time dynamic linking) using a `*.lib` file, or load them dynamically (run-time dynamic linking) by using the `::LoadLibrary(Ex)` API function(s) (refer to MSDN for more information).

.NET CLR does only run-time dynamic linking and relies also on the `LoadLibrary(Ex)` function to load native DLLs. When a method decorated with the `System. Runtime. InteropServices. DllImportAttribute` is found in code, the .NET compiler generates a special empty IL method body to hint the .NET run-time where to find the DLL and what method to call:


```
.method public hidebysig static pinvokeimpl("testdll" winapi)
	int32 test() cil managed preservesig {}
```

When a .NET program is executed and a native method is called for the first time, the CLR loads the corresponding DLL using `::LoadLibrary(Ex)` and then locates the `test()` function using `::GetProcAddress`. The documentation of `::LoadLibrary(Ex)` contains details where it looks for the DLL file. It is unclear when CLR calls `::FreeLibrary`, to remove the DLL from the process space, if it does it ever, but it is possible that it uses some heuristics at run-time to do so.

Because of `::LoadLibrary(Ex)`, it is not possible to pack the native DLL with .NETZ. `::LoadLibrary(Ex)` cannot use a HANDLE to an embedded resource, or a pointer to a memory location to load a DLL. All other functions that use DLLs, such as, `::GetModuleHandleEx`, rely that that DLL has been properly loaded into the process at some point by using `::LoadLibrary(Ex)`. If a native DLL is packed, it has to be written at some point into the file system before it can be loaded. .NETZ does not consider creating temporary files in the file system for several side-effects ranging from permissions, space, and read-only volumes, code to clean up the temporary file in case of crash, being only a few. Because of this, .NETZ does not pack native DLLs.

There are two main ways to trick the OS to load packed DLLs from in-memory data (thanks to Adam Byrne, *abyrne [**at**] inpute.com*, for mentioning some tools that rely on such techniques - Thinstall, Molebox, WinLicense's XBundler plugin):

* Create and install a virtual file system driver that could map some region of RAM and present it as a logical volume.
* Instrument an EXE to redirect `::LoadLibrary(Ex)` calls to some special crafted run-time and/or write an low-level OS driver that processes these calls (for .NET, the CLR run-time needs to be instrumented).

Both these options require installing native system drivers in the user machine, just to run an application, and are not suitable for .NETZ.

If temporary native DLLs file are ok, then the .NET CLR can be tricked to load a DLL at a given point of time of choice, by calling explicitly the `::LoadLibrary(Ex)`. For example, lets put the testdll.dll not in same folder as the <i>text.exe</i> .NET program, but in a sub-folder named `.\test\`. When test.exe is run, the CLR will call `::LoadLibrary(Ex)`, which has no way to know that testdll.dll is in the `.\test\` sub-folder, so it will fail, and a `System. DllNotFoundException` will be thrown by the CLR:

```
Unable to load DLL (testdll).
```

`::LoadLibrary(Ex)` loads a DLL only once in the process memory. Calling `::LoadLibrary(Ex)` a second time will only increment the call count. This behavior can be used to load the native testdll.dll at a point before the `test()` function is called, usually at the very start up. The `test.cs` example has been modified to do this:

```
using System;
using System.Runtime.InteropServices;

public class Test
{
	[DllImport("testdll")]
	public static extern int test();

	[DllImport("kernel32.dll")]
	public static extern IntPtr LoadLibrary(string lpFileName);

	public static void Main(string[] args)
	{
		try
		{
			LoadLibrary(@"test\testdll");
			Console.WriteLine(test());
		}
		catch(Exception ex)
		{
			Console.WriteLine(ex.Message + ex.StackTrace);
		}
	}
}
```


This way the testdll.dll is loaded explicitly by using `LoadLibrary(@"test\testdll")`. After this point when CLR `::LoadLibrary(Ex)` checks for testdll.dll, it is already loaded and it will not attempt to reload it. This technique can be used to preload the native DLLs from arbitrary file system locations, but in terms of packing without creating file system files it is not useful, and .NETZ does not use it.


[.NETZ](#r/msnet-netz-compressor.md) | [Usage](#r/msnet-netz-compressor/help.md) | [Limitations](#r/msnet-netz-compressor/limits.md) | [Compression](#r/msnet-netz-compressor/compression.md)