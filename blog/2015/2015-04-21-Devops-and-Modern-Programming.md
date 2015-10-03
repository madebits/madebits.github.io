#Devops and Modern Programming

2015-04-21

<!--- tags: architecture deployment -->

I found [modern extreme programming](http://benjiweber.co.uk/blog/2015/04/17/modern-extreme-programming/) a good read with subtle irony which is not so far from the truth.

There is contemporary trend to speak about **devops** instead of developers, where devops implies operational developers that take care about deployment and monitoring of software in production, a job that normally has been under the IT domain. There are benefits on extending role of developers to devops wished and promoted by management because they have already the best knowledge to deal with production system issues, faster and more agile. This extends the role traditional developer role that cares only about turning specification to code, to an additional operator that takes care also about software deployment and monitoring issues.

```
traditional developer role --> devops
```

What the [modern extreme programming](http://benjiweber.co.uk/blog/2015/04/17/modern-extreme-programming/) post discusses can be seen as the side effects of the devops approach.
If developers become devops they will naturally tend to apply their experience to deployment and production release life-cycle. 

* If developers need to care about monitoring then the **"monitoring driven development"** (MDD) becomes reality. Developers will program for monitoring either consciously or unconsciously.

* If developers needs to care how good a product goes they will not only be devops as wished by management, they will have to care also about the other direction and take over the management roles - be also, lets coin a new term - **devmans**. This is because decisions made in this level affect directly what a devop should do. Unlike in the traditional developer role, a devop needs to be also a devman to better control risk of his job.

	```
	devmans <-- traditional developer role --> devops
	```

	Developers need to take over (may be to the dismay of the management that is pushing only devops trend) also the traditional management role of "product planning, coding, and keeping the product running in production"  (quoted text is from the original article). As a result, there is less time left for a developer to actually write code.

* A traditional project management cares about a project, and a product manager cares about a product. Both of this are isolated in space and time with projects generally being shorter. As devop becomes devman too, she cares also about the long term product lifetime as it is part of her job risks. "The team is aware of the high level business goals, but it is up to the team, with embedded customer to develop their own plans to transform that thought into action."

* As each developer needs to care both about the product and its lifetime, then "mob programming" becomes a necessity. This increases the cost of software, but without this action it is impossible to fulfill the devops role. This goes against human nature and it is doomed to fail. Collective ownership of code is no ownership. This has been tried before and has failed in large scale in communism. Collective ownership of software code is the communism of software development.

* A developer will tend to automate and it is natural that developers want to see any change they make as fast as possible in production. "Not just build but deploy to production in under ten minutes". The automated monitoring and self testing will normally tend to part of the software. It will be no more handled by cheap IT people and testers, it will be programmed as a vital part of the system during the most costly development phase.

* To cope up with the larger set of domains they need to cover, developers need definitively to spend more time learning. An IT degree is no more enough to cover all aspect of product creation, lifetime support, and customer interaction. Developers will be devops and devmans -> or **devalls**, Jacks of all trades. They need to master all these and keep up with the constantly changing technology somehow. The cost of developer training increases as does the time that need to be devoted to that.

The challenges put into the business translate into challenges to the business software. These translate on challenges to developers to grow out of their traditional role. If the current trend keeps up, the death of IT is to be followed by death of management as we know it, and replaced by the devall role. I am not sure how the reduced time of developers to focus on the specific harder technology parts will effect the software quality and who will do that hard programming.

```
devalls
```

Most problems of software are directly management related. Each generation of management goes over same processes to try and learn on its own. Management is hard. It tends to focus on shorter term goals more than in long term ones. Despite being called science, there is no formal method to evaluate the expected error of a management decision in advance to it being applied, one can only experiment and see in small loops (cybernetics). Devalls fit into this management model and we will very likely see this promoted more (via devops), not only in small startups, but also in bigger corporations.

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-04-23-Test-Code-Coverage-As-Quality-Metric.md'>Test Code Coverage As Quality Metric</a> <a id='fnext' href='#blog/2015/2015-04-16-Invoking-Custom-.NET-Plugins.md'>Invoking Custom .NET Plugins</a></ins>
