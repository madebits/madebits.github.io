#WCF: Global per-thread Application Context

2011-10-13

<!--- tags: csharp wcf -->

In WCF based applications, there is an `OperationContext.Current` object available within a WCF method context. `OperationContext.Current` can be extended with custom state if needed (inheriting from `IExtension`).

`OperationContext.Current` is not very useful if we want to access central state from business logic, as we do not want to have any dependencies on WCF. An alternative is to create an own business level context and initialize it part of WCF calls. The own context, let us call it `RunContext.Current`, can then initialized as part of top level WCF method calls (or inner threads) and be used in same way as `OperationContext.Current`. The `RunContext.Current` object is per thread. It contains objects we may need to access in context of a thread.

I have shown before that the preferred way to implement WCF operations is to use a one-time aspect wrapper around them:

```
public TestResponse Test(TestRequest r)
{
 return MethodRunner.Run(() =>
 {
  ...
  return new TestResponse{...};
 }, r);
}
```
`MethodRunner.Run` can handle in a centralized way common functionality, such as, authentication, error handling, and any custom context initialization:
```
try
{
 InitRunContext(); // calls RunContext.Current
 return action(r);
}
finally
{
 RunContext.Current.UnInit();
}
```
`InitRunContext` calls `RunContext.Current` passing to it WCF data if needed, for example, user credentianls, etc. It also uses `RunContext` functionality (shown next) to initialize needed objects we need in this thread. `MethodRunner.Run` takes care finally to call `RunContext.Current.UnInit` before exit. This is important to free any resources put in `RunContext.Current` (as well as not to leak sensitive data to other code that may use this thread from the system thread-pool).

We can implement `RunContext.Current` using standard thread local storage (TLS) code. An almost complete implementation is shown next:

```
public class RunContext : IDisposable
{
 private IContainer container = null; 
 
 private RunContext() { }
 ~RunContext() { Dispose(); }

 public void UnInit()
 {
  Dispose();
  Register(null);
 }
  
 public void Dispose()
 {
  if (container != null)
  {
   container.Dispose();
   container = null;
  }
 }

 public static RunContext Current
 {
  get
  {
   var slot = GetSlot();
   var data = Thread.GetData(slot) as RunContext;
   if (data == null)
   {
    data = new RunContext();
    Register(data);
    data.Init(null);
   }
   return data;
  }
 }

 public IContainer Container
 {
  get
  {
   if (container == null)
   {
    container = new Container();
   }
   return container;
  }
 }

 private static void Register(RunContext ctx)
 {
  var slot = GetSlot();
  var data = Thread.GetData(slot) as RunContext;
  if (data != null)
  {
   data.Dispose();
   data = null;
  }
  Thread.SetData(slot, ctx);
 }

 private static LocalDataStoreSlot GetSlot()
 {
  var slot = Thread.GetNamedDataSlot("app.threadspecific.context");
  return slot;
 }

}//EOC
```

`RunContext` class keeps the data inside a dependency inversion `IContainer`. This is basically a *(type, object)* dictionary. It will not be shown here, but the idea we can store any data in it, and the rest of code accessed them though `RunContext.Current.Container`. Shortcuts extension methods to common Container data can also be provided (not shown as needed) to make access comfortable.

`RunContext.Current` property is implemented using TSL. The implementation should be obvious. There is a separate context intance per thread.

Additional data can be passed to the `RunContext` via some `InitRunContext` method before the context is used. Each business logic DLL can have a static `InitRunContext` method, where it adds data to context (IContainer). The `UnInit` method is then used to free any state. In our code it calls `Dispose`, that in end calls `Dispose` on `IContainer`. Other data can be destroyed in a similar way.

`MethodRunner.Run` calls `InitRunContext`. It gets some data from WCF (e.g., user crendentials) and adds them to `RunContext.Current`. Additionally, the code may call some static InitRunContext methods from business logic DLLs that adds additional data to `RunContext.Current.Container`, such as, data base connections, etc. The init code contains a list of `RunContext.Current.Container.Register` calls to register interfaces and objects to `Container`. After the call to `InitRunContext`, any code in any layer can use `RunContext.Current` to access the content data and use them as needed.

There could be business layers where we do not want to have a direct DLL dependency to `RunContext` (e.g., some layer near the data access). In these cases, we may provide a callback and initialize it as part of InitRunContext to obtain the data as needed from `RunContext.Current`.

A complex application contains more than WCF services. It may have also long-running threads. Each thread does first something similar as `MethodRunner.Run`, it has a `try / finally` block to Init / UnInit `RunContext.Current` data use by the rest of code inside the block (thread logic).

We have now a WCF-independent thread context available application wide.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2012/2012-06-02-Asus-EeePC-X101-as-Ebook-Reader.md'>Asus EeePC X101 as Ebook Reader</a> <a rel='next' id='fnext' href='#blog/2011/2011-10-12-WCF-REST-Service.md'>WCF REST Service</a></ins>
