#Moving From EF5 Database First to EF6 Code First

2014-12-16

<!--- tags: csharp -->

To move an project from *Entity Framework 5 Database First* to *Entity Framework 6 Code First*, I first followed the steps listed in [Upgrading to EF6](http://msdn.microsoft.com/en-us/data/upgradeef6.aspx). I swapped EDMX model to use EF 6.x code generation and that worked ok for my existing DB first model. One thing not listed in [Upgrading to EF6](http://msdn.microsoft.com/en-us/data/upgradeef6.aspx) is the namespace changes for `SqlFunctions`. They are no more in `System.Data.Objects.SqlClient` namespace, but in `System.Data.Entity.SqlServer`.

Once my EF6 Database First worked, I moved the project to Code First. I installed [Entity Framework Power Tools](http://msdn.microsoft.com/en-us/data/jj593170) (beta 4 at this time). And the used [Entity Framework / Reverser Engineer Code First] context menu in Visual Studio. I followed the steps there to speficy my SQL server DB, and ended up with a `Models` folder that contains the POCO entities, and a `Mapping` sub-folder using the code first [fluent API](http://msdn.microsoft.com/en-us/data/jj591620) to specify how the POCO entities map to DB tables. I checked that the generated POCO entities were same as the ones I had generated from EDMX model imported from DB. They were all same, apart of one entity that has had two foreign keys to the same table. I had to [manually](http://stackoverflow.com/questions/5559043/entity-framework-code-first-two-foreign-keys-from-same-table) modify the related POCOs and DB mapping. I added also `.WillCascadeOnDelete(false);` as needed to the relationships.

Then I deleted my old EDMX model and all the classes it has generated. I had some change done to my derived `DbContext` (lest call it `MyDbContext : DbContext` here) in a partial class which I kept. EF power tools used a `*.Db.Models` namespace. You can either keep it, or rename it to match the previous one. I tested my code worked with the generated code first entities. I had to update the connection string in my `web.config` to match to the new plain connection string. When I used the EDMX model code generation, my connection string was starting with `metadata=res://...` and now with code first it can be just a plain `Data Source=...` SQL Server connection string. I had to add `<connectionStrings><clear />` before the connection string, as for some reason EF was [complaining](http://stackoverflow.com/questions/22777039/the-entry-has-already-been-added) the connection string was added twice.

Once the code was working, I enabled code first [migrations](http://www.asp.net/mvc/overview/getting-started/getting-started-with-ef-using-mvc/migrations-and-deployment-with-the-entity-framework-in-an-asp-net-mvc-application), using in NuGet Package Management Console: `enable-migrations` and then `add-migration Initial` (you can use any name in place of `Initial`). This generates a new folder called `Migrations` with a `Configuration.cs` file and a migration file with a timestamp (there are some more files generated, you can see in VS, if you expand the `*_Initial.cs` file). Make sure `AutomaticMigrationsEnabled = false;` in `Configuration.cs` file. To make Code First migrations work, I modified my `DbContext` derived class static constructor:

```
public partial class MyDbContext : DbContext {
  static MyDbContext() {
    Database.SetInitializer(new MigrateDatabaseToLatestVersion<MyDbContext, global::MyDb.Db.Migrations.Configuration>());
    //Database.SetInitializer<MyDbContext>(null);
  }
...
```

This ensures the DB will be updated to the latest changes when the code first accessed the DB. Then I changed the DB name in my connection string to a new one, to test that the DB was indeed created on the fly and compared it to the old DB to make sure it was same.

To tested DB updates, I did some minor changes in some tables in the `Models\Mapping\*.cs` files. I ran again `add-migration Update1` (you can use any name for `Update1`). It generates a new `Migrations\*__Update1.cs` file with the changes for both `Up`(grade) and `Down`(grade). It works only if you application compiles. I verified `Migrations\*__Update1.cs` was correct (you may need to modify it manually depending on the changes). Then I started my application again and checked the DB to see that the changes were indeed applied. EF6 keeps the version in a `__MigrationHistory` table in your DB. If you have an older version of the application and ran it on an updated DB from a newer version older application will fail as expected. I tested this to be sure this is the case.

EF code first works fine and removes the need to maintain a separate DB project and update it via DACPACK. The tasks of maintaining the DB via code is different than via DB First EDMX model. There are some [quirks](http://elegantcode.com/2012/04/12/entity-framework-migrations-tips/) you may have to be aware. The code first is more fragile to specific code errors you can introduce when modifying the EF [fluent API](http://msdn.microsoft.com/en-us/data/jj591620) and you may need several trials and errors  with some test DB before you get it right. You can still do the changed in DB, and use the EF power tools to reverse engineer to code first in a temporary location and then merge manually the changes in the actual code first code as needed.

EF6 `*Async` methods for all Linq operations (such as `FirstOrDefaultAsync`, or `ForEachAsync`) are accessible by including `System.Data.Entity` name space. While EF6 runs in older .NET versions, if you rely on `TransactionScope` you need .NET >= 4.5.1 where `TransactionScopeAsyncFlowOption.Enabled` constructor option is supported. DbContext is, however, [not](http://mehdi.me/ambient-dbcontext-in-ef6/) thread safe. All asynchronous calls on same DbContext objects must be synchronized (and therefore are serialized) with `await`. I found it useful to make a `NoCtx()` alias the longer `ConfigureAwait(false)` to suppress [context](http://blogs.msdn.com/b/pfxteam/archive/2012/06/15/executioncontext-vs-synchronizationcontext.aspx) (to avoid potential [deadlocks](http://blog.stephencleary.com/2012/07/dont-block-on-async-code.html)):

```
static class TaskEx {
 public static ConfiguredTaskAwaitable<TResult> NoCtx<TResult>(this Task<TResult> task) {
  return task.ConfigureAwait(false);
 }
...
```

One thing that changes with async code is the use of the Thread Local Storage (TLS). TLS used to me my preferred way of propagating out of band data across methods and relied on it to implement some form of container context. [CallContext.LogicalGet/SetData](http://blog.stephencleary.com/2013/04/implicit-async-context-asynclocal.html) can now be used as a replacement for that.

If you use Oracle you are out of luck. Oracle .NET provider does not work at this time with EF6. The only choices you have is too wait until they fix it, or isolate the Oracle code with EF5 to run either is separate appdomain or as a WCF service - both are slower (as data needs to be serialized).


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2014/2014-12-19-Content-Security-Policy.md'>Content Security Policy</a> <a rel='next' id='fnext' href='#blog/2014/2014-12-12-Using-DNSCrypt-on-Ubuntu-14.04.md'>Using DNSCrypt on Ubuntu 14.04</a></ins>
