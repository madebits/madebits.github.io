#Test Code Coverage As Quality Metric

2015-04-23

<!--- tags: architecture agile deployment -->

Often **unit test** code coverage is used as a quality metric, the higher, the better. However, there is nothing to suggest that unit test code coverage metric is related to software quality. Code coverage is an indication, how much of the software code is unit tested, but the effort to achieve 100% unit test code coverage, is not related to achieving comparable high software quality.

##A Counter Example

As a counter example, consider the following function `foo` (in pseudo-code):

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

We could write additional unit tests to address some of these questions. The number of unit tests needed to properly cover all the semantics of even the most simple function is big and unfeasible to write (some unit tests can be generated automatically). We have 100% code coverage and we still cannot say anything about the quality of the code.

##Code Coverage Is the Wrong Metric for a Quality Goal

If coverage metric is used as a quality goal, developers will routinely stop at it and only target the code coverage metric goal. *'xx% test code coverage'* tells nothing about the software quality:

* Someone took *'xx% test code coverage'* too seriously and mistakenly thought it mean better software quality and made it a development goal.
* Project cost was very likely increased to achieve *'xx% test code coverage'*, without any indication on how the test code coverage number really improved product quality.
* As any metric, code coverage reduces reality to a single number, leaving out most of the context details, and it is more misleading than useful if reported outside development scope.

Code coverage is an absolute context independent metric. It is useful for developers to know how much code is tested in specific modules. The value of code coverage metric that is useful for a given software module is context depended. 100% code coverage may make sense for some generic purpose utility library or framework, but most parts everything over 70% is quite good, and for UI parts even less. Code coverage is a compromise, done by the developers on a case by case basis, between having unit tests and spending a lot of time just to please some metric. Code coverage is an indication of the amount of unit testing for a module and not a quality indicator.
 

##Unit Tests are Useful not the Code Coverage Metric

Why do we then write unit tests when we cannot rely on their popular metric of code coverage to deduce anything meaningful to report to the management about product quality:

* Unit tests test as least one code path. This is better than nothing. They do not tell anything quality of the software, but they tell us that at least some code path works as developer thought it would.
* Unit tests help understand what code does. They are a form of compiler checked documentation. Comments in code may get out of sync with what the code does. Unit tests on the other side, have to be maintained if the affected code changes.
* Unit tests save debugging time during initial development, as well as during code changes or re-factorizations. Unit help reduce possible side-effect bugs as we change code. The time required to verify unit test run is shorter than to find and re-debug the affected code. Unit test are automated debugging.
* The classic case of having bugs be first turned on unit tests and then fixed.
* Unit tests can be part work done, as part of project specific quality planning, but code coverage cannot be used as quality metric.

##Testing Pyramid

Recommended **testing pyramid** for a software project looks as follows (the more stars \* the more of such tests (cover) we would like to have in a project):

```
*** (automated unit tests, U)
**  (automated integration tests, I)
*   (manual tests, M)
```

Without setting code coverage as goal, we want to maximize the number of automated unit tests we have and what they cover. The more automated unit tests we have, the less of other types of tests we need. If the number of (repeated) manual integration tests is large, we convert them to automated integration tests. Manual tests can be add hoc, but to maintain statistics often *test scripts* are used. Automated integration test are more costly to write and more fragile to maintain that unit tests, therefore if something can be tested with unit tests, they are preferable and cheaper that the other types of tests. The assumption here is that if something can be tested with unit tests (cheaper), there is no need to repetitively test it with other types of tests (more expensive) when the software is modified.

For completes, one can imagine how the test pyramid may look like in a project with hard to maintain quality - it will be the reverse of the recommended pyramid above. In this example, there are mostly manual tests. The majority of automated tests are integration ones. We have very few or no unit tests.

```
*   (automated unit tests, U)
**  (automated integration tests, I)
*** (manual tests, M)
```

As a third case, the testing pyramid can have more or less same coverage in all layers:

```
*** (automated unit tests, U)
*** (automated integration tests, I)
*** (manual tests, M)
```

This is an indication of lack of coordination between different testing teams and inefficient resource usage.

##Testing Pyramid as a Better Overall Quality Indicator

Relative cover ratio(s) between the types of tests if the testing pyramid of project can give a better indication of long term maintenance quality of the software. Actual ratio values can be project specific. Testing pyramid ratio metrics can be collected and compared against similar previous projects, and against same self metrics over project time.

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-04-29-Google-Apps-Tricks.md'>Google Apps Tricks</a> <a id='fnext' href='#blog/2015/2015-04-21-Devops-and-Modern-Programming.md'>Devops and Modern Programming</a></ins>
