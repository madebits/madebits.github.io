#Using Autofac to Organize C\# Code

2016-02-12

<!--- tags: csharp architecture -->

In programming languages with mainly static types, such as C\#, [dependency injection](https://en.wikipedia.org/wiki/Dependency_injection) (**DI**) plays an important role into making the code testable. Code in languages, such as C\#, is not easy testable without writing it specially for that. One has to prefer interface inheritance to classes without interfaces, and object instances to static classes. While DI was originally motivated by separation of cross cutting concern, DI helps in C\# code to manage the increased code bloat needed to support unit testing.

##Autofac to The Rescue

[Autofac](http://autofac.org/) is a [DI framework](http://www.hanselman.com/blog/ListOfNETDependencyInjectionContainersIOC.aspx) for .NET. There is more than one way to use Autofac in code and almost every scenario and subjective preference is covered. I will rely here almost exclusively in constructor dependency injection. Containers can be used also as [service locators](https://en.wikipedia.org/wiki/Service_locator_pattern).  Service locator adds a direct dependency to the container instance, which some people consider as an anti-pattern. Service locator is for sure problematic when it comes to unit testing and code modularization. Constructor injection has the benefit or not having any direct dependency to container, making the code testable without having to stub the container. The main drawback of constructor injection is the bloated constructors, as we have to list every used interface there. We will see how this can be dealt with for unit tests. Using constructor injection in code is also less intrusive and more uniform than any alternatives.

##Creating The Container Instance

Autofac code to create the container instance and its lifetime scope are put in the entry point of the application. I am illustrating this with the `Main()` method (Autofac can be used also in other scenarios, such as ASP .NET):

```cs
using Autofac;
...

public static int Main(string[] args) {
...
    var builder = new ContainerBuilder();
    builder.RegisterModule(new ContainerModule());
    var container = builder.Build();
    using (var scope = container.BeginLifetimeScope()) {
        var entryObject = scope.Resolve<IMyEntry>();
        ...
    }
...
}
...
```

Autofac uses lifetime scopes to auto manage `IDisposable` object instances it selfs creates. The container instance is used the very first time as a *service locator* to get a custom `entryObject` of some custom `IMyEntry` interface. This is the only place where we use Autofac as a service locator. The rest of code will rely only on *constructor injection*. 

##Constructor Injection

An hypothetical example, of how the implementation of `IMyEntry` above could look in case of constructor injection is shown next:

```cs
class MyEntry : IMyEntry {

    public MyEntry(
        IMyService1 s1,
        IMyService2 s2,
        IMyService3 s3) {
        Service1 = s1;
        Service1 = s2;
        Service1 = s3;
        ...
    }

    IMyService1 Service1 {get; private set; }
    IMyService2 Service2 {get; private set; }
    IMyService3 Service3 {get; private set; }
    ...
}
``` 

This is fully boiler plate code and it is the only drawback of the constructor injection method in C\#. There is currently no way to shorten such code in C\# (one can think of possible syntactic sugar). As a consolidation, we have to write this code once and extended it as we need. The implementation of `IMyService*` classes follows same pattern.

Neither `MyEntry` class, nor the implementation of other services it uses are depended directly on the container scope instance. This makes it easy to mock and unit test `MyEntry` class in isolation.

Autofac recognizes the fact as may need to access the container instance in case of constructor injection, for example, with resolving named objects. The preferred way to do that is *first*, to isolate such code in as few places as possible, and *second*, to expect Autofac instance via constructor injection too, as illustrated in the next example:

```cs
class MyService1 : IMyService1 {
    public MyService1(
        IComponentContext ctx,
        IMyService4 s4) {
            ctx = ctx;
            Service4 = s4;
    }

    IComponentContext Ctx { get; private set; }
    IMyService4 Service4 {get; private set; }
    ...

    public SomeMethod() {
        var name = ...;
        return Ctx.ResolveNamed<ICommand>(name);
    }
}
```


This code is depended on the container via `IComponentContext`, but it is only depended on the interface and not on the actual container instance. This makes it still mocking easier compared to having to mock the full container instance. Check Autofac documentation for other such container interfaces (such as `ILifetimeScope`) to use.

##Modularization

Usually, C\# project code is organized in several assemblies (DLLs). We would prefer using the same Autofac instance across all of them, but still be not depended on that. Autofac *modules* address this problem nicely. The module is the only place in a dependent assembly were we need to know about the Autofac. While the module knows about Autofac types, it still does not know about the Autofac container instance:

```cs
using Autofac;
...

public class SomeAssemblyModule : Module {
    protected override void Load(ContainerBuilder builder) {
        base.Load(builder);
        builder.RegisterType<SomeService1>().As<ISomeService1>();
        builder.RegisterType<SomeService1>().As<ISomeService2>();
        ...
    }
}
```

We can use various Autofac methods to register how we obtain the object instances from the interface of interest that the assembly exposes to the rest of world. The rest of the assembly code does not know about Autofac and uses constructor injection same as before. 

If we need to use this assembly types into another assembly, we just let Autofac know about it by calling `RegisterModule`, in the corresponding Autofac module on the other assembly:

```cs
using Autofac;
...

public class ContainerModule : Module {
    protected override void Load(ContainerBuilder builder) {
        base.Load(builder);
        builder.RegisterType<MyService1>().As<IMyService1>();
        ...
        builder.RegisterModule(new SomeAssemblyModule()); //here
        ...
    }
}
```

Finally, if you remember from the very first code snippet, we close the module chain by registering the *top* most module to the container builder we use to build the container instance. The relevant code example lines are repeated next:

```cs
...
public static int Main(string[] args) {
...
    var builder = new ContainerBuilder();
    builder.RegisterModule(new ContainerModule());
    ...
```

The single container instance is what keeps all actual component objects together at run-time in the application. The code in any module does not know about the container and can be tested fully in isolation.

##Unit Testing with AutoFixture

All the effort invested on interfaces and all the boiler plate code we added was made to justify having the ability to be able to easy unit test each code component in isolation. There is, however, one small catch. 

As the code involves, we need to append additional interfaces to existing component constructors. If we write a unit test for `MyEntry` class, we need to mock three interfaces at first. At the moment we add a fourth interface, then we have to go over all existing unit tests and adapt them to also create the newly added interface, which is a lot of work. One way to solve this problem, is to use *property injection* in place of constructor injection. Property injection helps avoid some of the constructor injection boiler plate code, but it is not so clear from looking at such code what comes from the container. 

Fortunately, several mock libraries such as, [AutoFixture](https://github.com/AutoFixture/AutoFixture), help address the container injection common problem. If we use AutoFixture (along with `AutoFixture.AutoMoq` support), we can create classes without having to explicitly mock their constructor interfaces. We can selectively mock only the interfaces of interest for a given unit test and let AutoFixture create the rest automatically. As our classes evolve and we new interfaces to their constructors, we do not need to review the existing unit tests code (unless we indeed want to test the new added interfaces). Usually, we can put common unit testing code in a `TestBase` class:

```cs
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Ploeh.AutoFixture;
...

[TestClass]
public class TestBase {
    public Fixture AF {get; private set; }

    [TestInitialize]
    public void BaseBeforeEachTest() {
        AF = new Fixture();
        //AF.Customize(new AutoConfiguredMoqCustomization());
        AF.Customize(new AutoMoqCustomization());
    }
}

[TestClass]
public class TestMyEntry : TestBase {

    [TestMethod]
    public void Client_Run() {
        var serviceMock = AF.Freeze<Mock<IMyService1>>();
        var someMock = AF.Freeze<Mock<ISomething>>();
        someMock.Setup(_ => _.Boo(It.IsAny<string>())).Returns(1);
        serviceMock.Setup(_ => _.Process(It.IsAny<string[]>()))
            .Returns(someMock.Object);

        var entry = AF.Create<MyEntry>();
        var data = AF.CreateMany<string>().ToArray();
        var res = entry.Foo(data);

        Assert.AreEqual(res, CommandExitCode.Success);
        seriveMock.Verify(_ => _.Process(data));
        someMock.Verify(_ => _.Boo(It.IsAny<string>()));
    }
    ...
}
```

This looks like a lot of code for a unit test and somehow it is, but it also does a lot in order to demonstrate some of the main concepts involved. We verify that calling `MyEntry.Foo` method with `data`, invokes `IMyService1.Process` and that in-between `ISomething.Boo` was called. Important to observe is that this unit code ignores any other interfaces needed to create the objects. Adding new interfaces in the tested class constructors does not affect this unit test code.

##Summary

Enabling isolated unit testing in C\# code requires uniformly caring about that form the start. DI with constructor injection offers a nice way to manage C\# limitations for mocking static types. Autofac, AutoFixture, and Moq libraries help realize isolated unit testing.


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-02-17-Sharing-Local-Folders-Over-Remote-Desktop.md'>Sharing Local Folders Over Remote Desktop</a> <a rel='next' id='fnext' href='#blog/2016/2016-02-07-Upgrading-To-Windows-10.md'>Upgrading To Windows 10</a></ins>
