#Test Code Coverage As Quality Metric

2015-04-23

<!--- tags: architecture deployment -->

There is nothing to suggest that **unit test** code coverage metric is related in any way to software quality, thought some people tend believe there is a positive correlation. As a counter example, consider the following function `foo` (in pseudo-code):

```
function foo(a, b) { return (a / b) }
```

And the following unit test written for it:

```
function test_foo() { 
 a = 4, b = 2
 r = foo(a, b)
 assert(r == 2)
}
```

We do have 100% test code coverage. But what does this mean about the `foo` quality (and purpose)?

* We may not need the function `foo` at all (it is too simple, used only once, etc).
* It will crash on `b` zero.
* We do not know how `foo` works on extremes of its input value ranges, wrong input types, and so on.
* May be the semantics of `foo` are wrong, and so is the unit test (we may be wanted integer division only, and `foo` will return floating point too).
* We have no metric that tells us how good the `test_foo` is, other than it covers the code 100%.

We could write additional unit tests to address some of these questions. In practice, the number of unit tests needed to properly cover the semantics of even the most simple function is big and unfeasible to write (some unit tests can be generated automatically). If coverage metric is used as quality goal, developers will routinely stop at and only target the code coverage metric goal. A report like *'xx% test code coverage'* tells nothing about the software quality:

* Someone took *'xx% test code coverage'* too seriously and mistakenly thought it mean better software quality and made it a development goal.
* Project cost was very likely increased to achieve *'xx% test code coverage'*, without any indication on how the test code coverage number really improves product quality.
* As any metric, code coverage reduces reality to a single number, leaving out most of the context details, and it is more misleading than useful if reported outside development scope.
* Code coverage is of use mainly to the developers to check some test they write whether it covers what they think it does. 

Why do we then write unit tests when we cannot rely on their popular metric of code coverage to deduce anything meaningful to report to the management about them:

* Unit tests test as least one code path. This is better than nothing. They do not tell anything quality of the software, but they tell us that at least some code path works as developer thought it would.
* Unit tests help understand what code does. They are a form of compiler checked documentation. Comments in code may get out of sync with what the code does. Unit tests on the other side, have to maintained if the affected code changes.
* Unit tests save debugging time during initial development, as well as during code changes or re-factorizations. Unit help reduce possible side-effect bugs as we change code. The time to verify unit test run is shorter than re-debug  the affected code.
* Unit tests can be part work done, as part of project specific quality planning (but code coverage cannot be used as quality metric).

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-04-29-Google-Apps-Tricks.md'>Google Apps Tricks</a> <a id='fnext' href='#blog/2015/2015-04-21-Devops-and-Modern-Programming.md'>Devops and Modern Programming</a></ins>
