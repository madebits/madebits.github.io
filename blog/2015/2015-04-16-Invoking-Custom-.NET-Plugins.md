# Invoking Custom .NET Plugins on their own Application Domain

2015-04-16

<!--- tags: csharp -->

The following code shows how to run a .NET assembly as a plugin on its own application domain. The plugin assembly can be local or located in a network share. There is no requirement that the assembly is under the application folder. The plugin and the main application share some assemblies where the common interfaces are found (that is both plugin and the main application have a copy of same *shared assemblies* in their folders).


```cs
var trustedLoadFromRemoteSourceGrantSet = new PermissionSet(PermissionState.Unrestricted);
var info = new AppDomainSetup();
info.ApplicationBase = Path.GetDirectoryName(assemblyPath);
//info.ApplicationBase = AppDomain.CurrentDomain.BaseDirectory;
info.PrivateBinPath = Path.GetDirectoryName(assemblyPath);
info.ConfigurationFile = GetConfigFileName(assemblyPath);
domain = AppDomain.CreateDomain(
	Guid.NewGuid().ToString(),
	AppDomain.CurrentDomain.Evidence, // same trust
	info, 
	trustedLoadFromRemoteSourceGrantSet);
domain.UnhandledException += (s, e) => { ... };
domain.InitializeLifetimeService();
loader =
	(PluginLoader)domain.CreateInstanceAndUnwrap(
		typeof(PluginLoader).Assembly.FullName,
		typeof(PluginLoader).FullName);
loader.Load(assemblyPath);
```

The code starts by creating an unrestricted `PermissionSet` to enable execution over the network. Application base is located where the plugin assembly is found, not where the application is found. `GetConfigFileName` is a helper function that allows the assembly by convention to optionally use its own fully separate `*.dll.config` file as application configuration file:

```cs
private static string GetConfigFileName(string assemblyName)
{
	var configFile = assemblyName + ".config";
	if (File.Exists(configFile)) return configFile;
	configFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "EmptyPlugin.config");
	if (!File.Exists(configFile))
	{
		using (var s = File.Create(configFile)) { }
	}
	return configFile;
	//return AppDomain.CurrentDomain.SetupInformation.ConfigurationFile;
}
```

`PluginLoader` is a helper class found in the *shared assemblies*. We create an instance of `PluginLoader` and run it in the newly created application domain. Once we have a handle to the `loader` object running in the newly created app domain, we use it to load via `loader.Load` the plugin assembly. We keep the `domain` and the `loader` instances, so that we can unload the plugin later as needed (one can also cache and reuse the `domain` and the `loader` instances):

```cs
if (loader != null) 
{
	loader.Dispose();
	loader = null;
}
if (domain != null)
{
	AppDomain.Unload(domain);
	domain = null;
}
```

To invoke the plugin to do its intended work we use the `loader` instance:

```cs
loader.Run(ctx); // IContext
```

`IContext` interface is in *shared assemblies* and its `ctx` object passes data between the app domains to the plugin. `ctx` should either be serializable, or implement `MarshalByRefObject` (same as `PluginLoader`, shown next).

`PluginLoader` looks as follows (some of error checks have been omitted to keep code simple):

```cs
class PluginLoader : MarshalByRefObject, IDisposable
{
	private Type addinClass = null;

	public void Load(string assemblyPath) 
	{
		var assemblyName = System.IO.Path.GetFileNameWithoutExtension(assemblyPath);
		var addinAssembly = Assembly.Load(assemblyName);
		Load(addinAssembly, assemblyPath);
	}

	private void Load(Assembly addinAssembly, string assemblyPath) 
	{
		var types = addinAssembly.GetExportedTypes();
		// iterate types and find the one implementing the entry plugin interface: IPlugin
		// or fail if not found
		...
		addinClass = type;
	}

	public IRunResult Run(IContext ctx) 
	{
		// create IPlugin object and invoke the first method on it
		// change as needed
		var classMethod = (from interfaceType in addinClass.GetInterfaces()
        	where interfaceType.Equals(typeof(IPlugin))
            select addinClass.GetInterfaceMap(interfaceType).TargetMethods).First();
		var ctor = addinClass.GetConstructor(new Type[] { });
		var obj = ctor.Invoke(new object[] { });
		object res = null;
		try
		{
			res = classMethods.Invoke(obj, BindingFlags.InvokeMethod, null, new object[] { ctx }, null); 
		}
		catch (Exception ex) 
		{
			... // handle (non-serializable) exceptions
		}
		return (IRunResult)res;
	}

	public override object InitializeLifetimeService()
	{
		return null;
	}

	~PluginLoader() 
	{
		Dispose();
	}

	public void Dispose()
	{
		this.addinClass = null;
	}
}
```

We create always a new `IPlugin` object in the `Run` method, but depending on the use case you may cache and reuse them. `IPlugin` interface here has only one method `Run`. If you have more methods they can be called in a similar way. 

Exceptions are passed between application domains if they are serializable. This is the case with .NET framework own exceptions, but it is often not the case with custom exceptions found in plugins. This is the reason we capture the `Exception` in the `Run` method. In the case it is not serializable, we convert it to a generic custom serializable Exception containing most of the original exception information (including inner exceptions) (code is omitted from example).

`IContext` object comes from the main domain and it is moved by .NET to the plugin app domain. This works only if `IContext` implementation is either serializable or implements `MarshalByRefObject`. If you implement `MarshalByRefObject` for cross app domain objects then you have to take care of `InitializeLifetimeService` as shown. Taking explicit control over `InitializeLifetimeService` ensures the objects do not time out.

The plugin assembly and the main assembly share some types like `PluginLoader`, `IPlugin`, and the implementation of `IContext`, `IRunResult` and generic `Exception` type. While this is not a lot of code, it is still code that can change. It changes however not so often as the rest of plugin specific code.

As long as we keep shared interfaces same, we can update shared code referenced by the plugin assembly without affecting the plugin (set link specific version false in visual studio). The right point of time to do this is before we create the plugin application domain. At this point, we can copy the latest shared assemblies (DLLs) from the main application to the plugin folder (has to be done thread safe). This ensures that the plugin and the host share always same version of the latest shared assemblies. Replacing shared assemblies works only when shared assemblies contain only backward compatible interfaces.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2015/2015-04-21-Devops-and-Modern-Programming.md'>Devops and Modern Programming</a> <a rel='next' id='fnext' href='#blog/2015/2015-04-15-Micro-Libraries.md'>Micro Libraries</a></ins>
