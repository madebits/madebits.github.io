#Test Code Coverage As Quality Metric

2015-04-23

<!--- tags: architecture deployment -->

It is often the case that people correlate wrongly a high test code coverage with better software quality. The truth is, there is nothing to suggest the testing code coverage is related in any way to software quality. Consider the divide function `div` below in pseudo-code:

```
function div(a, b) { return (a / b) }
```

And the following unit test written for it:

```
function test_div() { 
 a = 4, b = 2
 r = div(a, b)
 assert(r == 2)
}
```

We do have 100% test code coverage. But what does this mean about the `div` quality?

* We may not need the function `div` at all (it is too simple, used only once, etc).
* It will crash on `b` zero.
* We do not know how `div` works on extremes of its input value ranges, their relative combinations, and so on.
* May be the semantics of `div` are wrong, and so is the unit test (we may be wanted integer division only, and `div` will return floating point too).
* We have no metric that tells us how good the `test_div` is, other than it covers the code 100%.

One can for sure write unit tests to address some of these questions. In practice, the number of unit tests needed to properly cover the semantics of even the most simple function is big and unfeasible to write (some unit tests can be generated automatically). Most developers will routinely stop at and only target some test code coverage metric goal.

A report like *'80% or 100% test code coverage'* means nothing about the software quality. It means:

* Someone took *'80% test code coverage'* goal too seriously and mistakenly thought it mean better software quality.
* Project cost was very likely increased to achieve *'80% test code coverage'*, without any indication on how the test code coverage number really improves product quality.
* As any metric, code coverage reduces reality to a single number, leaving out most of the context details. 

Why do we then write unit tests when we cannot rely on their popular metric of code coverage to deduce anything meaningful to report to the management about them:

* Unit tests test as least one code path. This is better than nothing.
* Unit tests help understand what code does.
* Unit tests save debugging time, on changes or re-factorizations - helping reduce possible side-effect bugs.
* Unit tests can be part of project specific quality planning (but not the only quality aspect).

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-04-29-Google-Apps-Tricks.md'>Google Apps Tricks</a> <a id='fnext' href='#blog/2015/2015-04-21-Devops-and-Modern-Programming.md'>Devops and Modern Programming</a></ins>
