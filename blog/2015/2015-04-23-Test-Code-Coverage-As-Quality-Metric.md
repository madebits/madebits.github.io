#Test Code Coverage As Quality Metric

2015-04-23

<!--- tags: architecture deployment -->

It is often the case that people correlate 100% test code coverage with better software quality. There is, however, nothing to suggest the testing code coverage is related to software quality. Consider this divide function in pseudo-code:

```
function div(a, b) { return (a / b) }
```

And the following unit test for it:

```
function test_div() { 
 a = 4, b = 2
 r = div(a, b)
 assert(r == 2)
}
```

We do have 100% test code coverage. But what does this mean about the `div` code quality?

* We may not need the function `div` at all (it is too simple, used only once, etc).
* It will crash on `b` zero.
* We do not know how `div` works on extremes of its input value ranges, their relative combinations, and so on.
* May be the semantics of `div` are wrong, and so is the unit test (we may be wanted integer division only, and `div` will return floating point too).
* We have no metric that tells us how good the `test_div` is, other than it covers the code 100%.

One can for sure write unit tests to address most of these questions. In practice, the number of unit tests needed to properly cover the semantics of even the most simple function is big and unfeasible to write, unless unit tests are generated automatically. Most developers will routinely stop at (or only target) 100% test code coverage.

A report like *'100% test code coverage'* means nothing about the software quality. It means:

* Someone took *'100% test code coverage'* too seriously and mistakenly thought it mean better software quality.
* Project cost was very likely increased to achieve *'100% test code coverage'*, without any indication on how the test code coverage number really improves product quality.

How much to test, how to test, and what to test, should be part of project specific quality planning. No programming methodology (and its related metrics) are a replacement for that.

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-04-29-Google-Apps-Tricks.md'>Google Apps Tricks</a> <a id='fnext' href='#blog/2015/2015-04-21-Devops-and-Modern-Programming.md'>Devops and Modern Programming</a></ins>
