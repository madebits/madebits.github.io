#Addressing Cross-Cutting Concerns Evolution

2017-04-27

<!--- tags: architecture -->

Cross-cutting Concerns ([CCC](https://en.wikipedia.org/wiki/Cross-cutting_concern)) are non-functional concerns that have to be addressed in a software application. CCC are present in a single application, for example, logging, exception handling, security, and they are present in sets of similar applications (e.g. [SOA](https://en.wikipedia.org/wiki/Service-oriented_architecture)), for example, logging, monitoring, network management, role-based access.

##CCC in Single Applications

On single application CCC are handled on each application separately.

![](blog/images/ccc/ccc1.png)

Developers aware of CCC write some code, via [OO](https://en.wikipedia.org/wiki/Object-oriented_programming) mechanisms (limited for addressing CCC), or using some form of static or dynamic code generation to address the CCC in a central location.

##CCC in Product-Lines

When several applications share same set of CCC, software containers can be used with help of some form of [DI](https://en.wikipedia.org/wiki/Dependency_injection) to provide similar applications with common CCC functionality. 

![](blog/images/ccc/ccc2.png)

Because of DI, the technology used in this model (such as [Java EE](https://en.wikipedia.org/wiki/Java_Platform,_Enterprise_Edition)) is homogeneous. The applications are written on same technology (or wrapped).


##CCC in Modern SOA

With the better SOA movement via [micro-services](https://en.wikipedia.org/wiki/Microservices), CCC are handled in several levels.

![](blog/images/ccc/ccc3.png)

* Applications use heterogeneous technology, so we accept some of CCC are re-handled per each application, even if that mean code duplication.
*  Ideally, we want that applications do not to know in code about how the platform context (e.g. [K8s](https://kubernetes.io/)) handles CCC. For [example](https://12factor.net/), an application may log to console only and we then process console logs of application instances automatically without the applications ever being aware what technology we use for that. Network management is another example of such CCC.
*  If an application, need to use directly some CCC provided by the platform, then we want some loose coupling, e.g, via [REST](https://en.wikipedia.org/wiki/Representational_state_transfer).
    * REST is easy if CCC provider is in same physical machine (node). This is the preferred approach. We delegate the tasks of dealing with a distributed system to the platform context. CCC provide can be seen as a transparent proxy service provide by the platform on each node.
    * If the CCC provider is reachable over network, then we have distributed computing and all its problems, and have to deal in each application with common distributed communication [patterns](https://docs.microsoft.com/en-us/azure/architecture/patterns/), such as, circuit-breaker, or compensating transactions.


<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2017/2017-03-22-User-Driven-Password-Policy.md'>User Driven Password Policy</a></ins>
