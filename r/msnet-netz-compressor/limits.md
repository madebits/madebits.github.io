#.NETZ: Limitations

[.NETZ](#r/msnet-netz-compressor.md) | [Usage](#r/msnet-netz-compressor/help.md) | [Limitations](#r/msnet-netz-compressor/limits.md) | [Compression](#r/msnet-netz-compressor/compression.md)

Limitations listed below are fundamental for the way .NETZ works. For some possible workarounds check the appropriate .NETZ help sections.

* .NET assemblies that are used directly by the CLR are not supported. These assemblies (EXEs,DLLs) include, but are not limited to:
	* GAC DLLs
	* Default serialization, marshalling (remoting)[1]
	* Web services, IE User Controls, etc
* .NET DLLs that are shared by more than one application, not packed with .NETZ are not supported.
* .NET managed C++ assemblies (EXEs or DLLs) are not directly supported (but you can link them). The Managed C++ compiler optimizes the PE file and the IL metadata in ways that are not understood by the .NET generic Assembly loader methods[2]. See also: Warning 1006.
The assemblies (e.g. DLLs) loaded explicitly using several nested layers of `Assembly.Load*` calls directly, or that load the assembly data from custom locations within the EXE file, may [3] not be always packed with .NETZ.
* .NETZ cannot pack native DLLs within a single EXE. .NET DLLs that use external native functions, or unsafe code are supported. Other tools exist that compress native DLL files. Read more at .NETZ, .NET and Native DLLs.
* .NET Compact Framework (CF) is (can) not supported. The capabilities of .NETZ are not needed for Windows CE applications before CE5, because the CE OS compress all the data by default. This feature was removed in CE5.
* .NETZ does not-in-place decompression of the compressed data. This means that the applications packed with .NETZ require slightly more virtual memory than the original unpacked versions.
* Several people have complained that .NETZ does not support WPF applications (due to reflection usage by WPF to load XAML resources).

[1] This is true only for .NET versions before 2.0. The .NET 2.0 has corrected this bug. For more details, see: GAC, Serialization, Remoting, and Unhandled .NET Assemblies.

[2] Thanks to Klaus Bonadt, Klaus.Bonadt [at] gmx.de, for reminding me to add this point.

[3] Nested load/invoke reflection calls do not always generate `AssemblyResolveEvents` in the current default domain. This was problem with original NET 1.0 and 1.1 versions that seems to have been fixed in the later service packs for these versions and also in the .NET 2.0 release. This is the reason, why .NETZ cannot be used to pack the Lutz Roeder's .NET Reflector.

[.NETZ](#r/msnet-netz-compressor.md) | [Usage](#r/msnet-netz-compressor/help.md) | [Limitations](#r/msnet-netz-compressor/limits.md) | [Compression](#r/msnet-netz-compressor/compression.md)