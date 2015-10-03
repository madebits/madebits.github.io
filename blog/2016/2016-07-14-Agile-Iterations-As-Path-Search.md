#Agile Iterations As Path Search

2016-07-14

<!--- tags: agile -->

I heard about a metaphor of perceiving agile development process as an iterative path search algorithm at an agile training and found the analogy interesting to pursue further. Let suppose, we live in cell-automata's 2D world maze and are at start point $$$A$$$ - the project start state. We want to reach the target destination point $$$B$$$ - the project end state [dealing](https://en.wikipedia.org/wiki/Project_management_triangle) with time, budget, and scope.

##Waterfall as Full-Search for Non-Moving Targets

In the classic [Waterfall model](https://en.wikipedia.org/wiki/Waterfall_model) or its related modifications such as [RUP](https://en.wikipedia.org/wiki/Rational_Unified_Process), most of planning is done up-front.  We are limited on how much time we can plan before we start with the project, but in theory, one can spend enough time planning so that whole directed path graph from $$$A$$$ to $$$B$$$ is searched to identify the shortest weighted path as a *Work Breakdown Structure* (WBS) for the project.

Given enough time planning Waterfall related models can identify the best solution to reach target $$$B$$$. During the project execution, however, there is few time left for planning and to few feedback on target $$$B$$$. If $$$B$$$ is a static state (has well-know properties) - i.e., has a fixed position in our 2D world then the Waterfall model can be used to reach the project goals.

##Agile as Greedy-Search For Moving Targets

When the target $$$B$$$ is not static, that is when its final position in our 2D maze is not known, we can only to a [greedy](https://en.wikipedia.org/wiki/Greedy_algorithm) search towards the most probable position of $$$B$$$ (*prior*). As we move towards $$$B$$$, new *evidence* may point to a new possible location $$$B_1$$$, so we can adapt our agile greedy search direction towards $$$B_1$$$.

In agile software development, new evidence is not considered on every step, but in timed boxes in order to avoid short temporal fluctuations. As we move towards $$$B_1$$$, we periodically pause and reconsider whether $$$B_2$$$ is a better choice for $$$B$$$. We may never reach $$$B$$$, but we do rich $$$B_n$$$ that is a more realistic approximation of our prior $$$B$$$.

The path from $$$A$$$ to $$$B_n$$$ is not the most optimal path (it is more like a [gradient descent](https://en.wikipedia.org/wiki/Gradient_descent)). Had we known $$$B_n$$$ upfront (if all $$$B_i$$$ = $$$B$$$), we could with enough planning find a better path. The actual agile project path from $$$A$$$ towards $$$B_n$$$, is pulled towards all intermediate magnet points: $$$B$$$, $$$B_1$$$, $$$B_2$$$, ..., $$$B_n$$$.

##Project Goal as a Moving Target

Based on the project goal, we identify an actual project end target state $$$B$$$. In waterfall based models, there is a risk that $$$B$$$ state itself becomes the project goal. Only after we reach $$$B$$$, we understand that $$$B$$$ is far from another point $$$C$$$ which would better represent the time evolved project goal. If $$$C$$$ is near $$$B$$$, then waterfall based models when executed right will tend to be optimal. If $$$C$$$ is far from $$$B$$$, the agile greedy approach will bring us to point $$$B_n$$$ that is nearer to updated goal $$$C$$$.

##Warp Drive is Possible with Agility

Doing most of planning around the starting point $$$A$$$ may ignore new possibilities that could become available as we approach $$$B$$$. If we plan as needed while trying to reach the intermediate points $$$B_i$$$, we may be aware of new possibilities that we were not aware when in $$$A$$$.

With agile methodologies moving towards $$$B_i$$$, we may become aware that our 2D world has indeed a third dimension and it may be possible to use the newest [warp drive](https://en.wikipedia.org/wiki/Warp_drive) to jump from $$$B_i$$$ to $$$C$$$. Path optimization based on lean thinking events are more probable in an agile project as the meta-reflection happens more often.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2016/2016-06-27-Agile-Development-Readings.md'>Agile Development Readings</a></ins>
