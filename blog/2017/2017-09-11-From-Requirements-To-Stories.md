#From Requirements To Stories

2017-09-11

<!--- tags: agile management -->

In Agile-Drive Software Development new features are presented as **Epic** level requirements and are implemented as **Stories**.

##Simple Workflow

Most teams that start with agile will follow an ad hoc based **simple workflow** to process requirements. Assuming team creates Epics, Stories are taken into Sprints without much preparation. Requirements are refined as Sprint work goes on. Story is then modified to reflect partial work done in end of Sprint. Remaining open work is moved to a new Story, or sometimes same Story is kept around in more than one Sprint.

![](blog/images/req/feat-simple.png)

Simple workflow is easy to get started as it matches the normal ad hoc way of working and requires not too much upfront thinking. Simple work
is prone to some risks to be aware of:

*Team may implement more details than are needed. It is hard to prevent unimportant features from being implemented.
*Global view is harder to keep in mind. Team may implement first the less relevant parts in very details and leave few to no time for more important things.
*Code may need to be re-implement more often when team figures out they do not work as though first, resulting in increased overall development and testing time.
*More regression testing is needed.
*Forecasts are hard to impossible. Teams only stop something, when something more urgent comes in.


#Complete Workflow

Complete workflow makes proper use of backlog grooming to remedy the risks of the simple workflow. While some teams do backlog grooming meetings they still lack the level of refinement of the complete workflow and are practically nearer to the simple one.

![](blog/images/req/feat.png)

Complete workflow is for more mature, industrial teams. A lot of thinking and work goes on before code can be written. Risk are clarified and INVEST principles are checked for Stories.

A team used to ad hoc simple workflow may find complete workflow as a time burden and find themselves being ineffective initially. This is a sign that either problems of simple workflow are not present or very likely not understood by the team.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2017/2017-08-10-Product-Definition-Life-Cycle.md'>Product Definition Life Cycle</a></ins>
