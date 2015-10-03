2013

Dependency Resolver in C#
======

<!--- tags: csharp -->

Dependencies between items place a weak ordering between them. The provided dependency resolver in C# can:

* Detect any loops in dependencies as errors (using a path finder algorithm)
* Order items based on dependencies (using a topological sort algorithm)

##Usage

To use the code, first declare dependencies between items. I am using int here as item type, the code is using generics and works with any type. For each item, the code declares the other items that are before and after the given item. For example, for item 5 we have: {2, 1} <~ 5 <~ { 9, 7}.

```csharp
using DependecyResolver;
...
var dependencies = new List<Dependency<int>> {
 new Dependency<int> { 
  Current = 5,  Before = { 2, 1 }, After = { 9, 7 } },
 new Dependency<int> { 
  Current = 2,  Before = { 3 }, After = { 9, 7 } },
 new Dependency<int> { 
  Current = 7,  Before = { 2, 1 }, After = { 9 } },
 new Dependency<int> { 
  Current = 9,  Before = { 2, 1 }, After = { } },
 };
```

I did not declare item number `3` explicitly above. This is same as declaring it with empty before and after dependencies.

Then call `Resolve` to obtain the partial ordering of items according to the declared dependencies above:

```csharp
var result = Resolver.Resolve (
 dependencies,
 (a, b) => { return a == b; });
```

The result is ordered list of current items (whatever their type is) based on their dependencies.

`DependecyResolver.Resolver.Resolve` needs as second argument a function that returns true if two items `(a, b)` are equal. This function has to be provided - no default is used.