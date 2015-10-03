2004

##.NET Attribute Dependency Checker Prototype

<!--- tags: csharp -->

Checking attribute dependency is a common task when implementing attribute-driven transformers. Instead on repeating the same code with every implementation, it can be factored out in general tool (ADC) that:

* Supports defining of dependency relations declaratively. No need to write any code.
* Transparently integrates the dependency relation as an additional attribute used to annotate custom attribute declarations.
* Is extensible to be used for any kind of structural element of any structural tree depth.
* Supports full dependency, children can declare dependency requirement for parent attributes, while parents can declare dependency requirements for attributes the children must have.

ADC prototype is implemented as a post-processor tool that checks dependencies after the code has been compiled using the .NET Reflection API. The ideas behind ADC prototype have been explained in detail in the following paper:

*V. Cepa and M. Mezini, Declaring and Enforcing Dependencies Between .NET Custom Attributes, In Proc. of the Third International Conference on Generative Programming and Component Engineering, 2004 (GPCE'04)*

##Usage

The `DependencyAttribute` is defined as follows:

```csharp
[AttributeUsage(AttributeTargets.Class)]
public class DependencyAttribute : System.Attribute
{
public DependencyAttribute() {...}
public Type[] RequiredAssemblyAttributes {...}
public Type[] DisallowedAssemblyAttributes {...}
public Type[] RequiredClassAttributes {...}
public Type[] DisallowedClassAttributes {...}
public Type[] RequiredMethodAttributes {...}
public Type[] DisallowedMethodAttributes {...}
}
```

Using `DependencyAttribute` to declaratively specify relations between custom attributes:

```csharp
[Depedency(RequiredMethodAttributes(new Type[]{typeof(WebMethod)})]
[AttributeUsage(AttributeTargets.Class)]
class WebService : System.Attribute { ... }

[Depedency(RequiredClassAttributes(new Type[]{typeof(WebService)})]
[AttributeUsage(AttributeTargets.Method)]
class WebMethod : System.Attribute { ... }
```

An attribute dependency example:

```csharp
[WebService]
class WebService1 : System.Web.WebService
{
   ...
   [WebMethod]
   public void Method1(){...}
   ...
}
```

ADC tool could then be used to check dependencies and report the errors, for example:

```
Required CLASS attribute missing:
rtadctests.CA01Attribute @ rtadctests->rtadctests.nunit.TDependencyUtils
```

##Implementation

Main modules that make up the run-time dependency checker:

![](r/msnet-attribute-dependency-checker/impl.gif)

Dependency checker can also be used directly in code:

```csharp
Assembly a = ...; // obtain an assembly
RTADCAssembly c = new RTADCAssembly();
c.Filter = ...;
c.Logger = ...;
c.Check(a);
if(c.errors.HasWarnings())
{ // process: c.errors.GetWarnings() ... }
if(c.errors.HasErrors())
{ // process: c.errors.GetErrors()   ... }
```

TODO:

* Write more test cases
* Implement the tool using .NET CodeDom API