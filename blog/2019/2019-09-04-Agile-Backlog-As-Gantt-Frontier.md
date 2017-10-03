#Agile Backlog As Gantt Frontier

2019-09-04

<!--- tags: agile management -->

In classical project management a [Gantt](https://en.wikipedia.org/wiki/Gantt_chart) chart helps keep track of tasks, time, and critical paths in a project. 

The Gantt chart contains the **work break-down structure** (WBS) on the left as a tree all tasks to be done, plus the **time forecast and the dependencies** between tasks on the right. Task estimates are in intervals *(min, max)* and software usually helps propagate changes in estimates down to the whole Gantt chart graph. Using Gantt chart information, we can easy identify the tasks that can be started next (their predecessor tasks are done or are not existing) and also figure whole project time forecast based on the time of the longest critical path.

The parallel tasks that can be started at a given moment of time (now) form the **frontier** of the Gantt graph. These tasks are from the point of view of team resources all possible to be started. We need to prioritize them by mapping them on available the resources.

A agile [backlog](https://en.wikipedia.org/wiki/Backlog) can be considered a streamlined (incomplete) Gantt chart. The stories on the top of backlog belong the current frontier ordered by priority. Team can select any of these stories for further work. The top stories are followed then followed by stories on the next level of the frontier, and so on. The deeper in the graph, the vaguer the stories are. The very deep frontiers may not be in backlog at all. An agile backlog is alone is a squashed poor man's Gantt. This analogy enables managing agile projects classically. Create a WBS, add the forecasts, create the Gantt and then streamline the frontier as a set of prioritized stories in a backlog.

In IT software projects, however, unless the same team has done same project before (even than), a full-level WBS with time estimates is not possible upfront (it will be anyway wrong). The backlog contains the next few frontiers that are known to start with, with deeper frontiers being vague. Critical-path length is unknown and cannot be estimated by team velocity. Keeping a WBS outside the backlog, even if incomplete, helps to keep a bird-eye view over the project, that maybe missed otherwise by a flat backlog. The ideal agile management tool is a WBS Gantt-like tool with frontiers streamlined ordered into the backlog.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2019/2019-08-30-When-to-use-Vuex.md'>When to use Vuex</a></ins>
