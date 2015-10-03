#From User Stories To Code

2016-11-29

<!--- tags: agile -->

It is important for an agile team to share same understanding of a user story and behavior-driven development ([BDD](https://en.wikipedia.org/wiki/Behavior-driven_development)) is the process to help achieve that. Ideally, stories content results from a [domain-driven](https://en.wikipedia.org/wiki/Domain-driven_design) design on the top-level epics. A vertical chunk of work is then represented as a story or product backlog item (PBI) to work on within a sprint.

##Behavior-Driven Development

Behavioral specifications start with story title, its description, and the acceptance criteria and work backwards, top-down, to a hierarchical nested set of behaviors describing the story and its implementation. In lower-levels, the detailed implementation behaviors can then be directly re-presented as unit-tests, while the top-level behaviors can form the basic of integration and acceptance testing. Several, unit testing frameworks, such as [Jasmine](https://jasmine.github.io/) have support for organizing tests in a BDD hierarchy. Often, agile teams are heterogeneous and so is the technology used. BDD helps have a common process to tackle a complex story and bring it within the team reach.

<center><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="403px" height="143px" version="1.1"><defs/><g transform="translate(0.5,0.5)"><path d="M 121 31 L 141 31 L 121 31 L 134.63 31" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"/><path d="M 139.88 31 L 132.88 34.5 L 134.63 31 L 132.88 27.5 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"/><rect x="1" y="1" width="120" height="60" rx="9" ry="9" fill="#fff2cc" stroke="#d6b656" pointer-events="none"/><g transform="translate(2.5,17.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="116" height="26" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 116px; white-space: normal; word-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">Domain-Driven Design</div></div></foreignObject><text x="58" y="19" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">Domain-Driven Design</text></switch></g><path d="M 261 31 L 274.63 31" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"/><path d="M 279.88 31 L 272.88 34.5 L 274.63 31 L 272.88 27.5 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"/><rect x="141" y="1" width="120" height="60" rx="9" ry="9" fill="#f5f5f5" stroke="#666666" pointer-events="none"/><g transform="translate(185.5,24.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="30" height="12" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 30px; white-space: nowrap; word-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">Epics</div></div></foreignObject><text x="15" y="12" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">Epics</text></switch></g><path d="M 341 61 L 341 74.63" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"/><path d="M 341 79.88 L 337.5 72.88 L 341 74.63 L 344.5 72.88 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"/><rect x="281" y="1" width="120" height="60" rx="9" ry="9" fill="#f5f5f5" stroke="#666666" pointer-events="none"/><g transform="translate(321.5,24.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="38" height="12" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 38px; white-space: nowrap; word-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">Stories</div></div></foreignObject><text x="19" y="12" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">Stories</text></switch></g><path d="M 281 111 L 267.37 111" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"/><path d="M 262.12 111 L 269.12 107.5 L 267.37 111 L 269.12 114.5 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"/><rect x="281" y="81" width="120" height="60" rx="9" ry="9" fill="#d5e8d4" stroke="#82b366" pointer-events="none"/><g transform="translate(282.5,97.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="116" height="26" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 116px; white-space: normal; word-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">Behavior-Driven Development</div></div></foreignObject><text x="58" y="19" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">Behavior-Driven Development</text></switch></g><path d="M 141 111 L 121 111 L 141 111 L 127.37 111" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"/><path d="M 122.12 111 L 129.12 107.5 L 127.37 111 L 129.12 114.5 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"/><rect x="141" y="81" width="120" height="60" rx="9" ry="9" fill="#f5f5f5" stroke="#666666" pointer-events="none"/><g transform="translate(186.5,104.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="28" height="12" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 29px; white-space: nowrap; word-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">Tests</div></div></foreignObject><text x="14" y="12" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">Tests</text></switch></g><rect x="1" y="81" width="120" height="60" rx="9" ry="9" fill="#fff2cc" stroke="#d6b656" pointer-events="none"/><g transform="translate(45.5,104.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="31" height="12" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 32px; white-space: nowrap; word-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">Tasks</div></div></foreignObject><text x="16" y="12" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">Tasks</text></switch></g></g></svg></center>


##Benefits for Agile Teams

Using behavior-driven development to analyses stories top-down helps the agile team:

* Have a common understanding of the story and its its impact on the development process. While different people on the team may work on different parts of the story, such as, coding on various layers, testing, and documentation writing, starting with a top-down BDD breaking of the story, helps all people know the context where their work fits.
* BDD help reduce testing overlap. In a ideal testing pyramid, most of tests are unit tests, followed by automated integration tests, and then few manual tests. It is often the case, tests of different levels are written by different people on the team. To reduce costs of test overlapping by different team members, BDD serves as start point to decide what kind of tests will cover what, at what level of testing, by whom.
* BDD helps team keep the focus and work on the story. It is easy for people to get lost in tasks that are very interesting in short term and not contribute to finishing a story in time. BDD view of the work to be done for a story guides the team to have their daily tasks match the BDD structure. Individuals can then not only better know where their own work fits in, but can also ask better other team members what their work is contributing.
* BDD helps with the traceability of code and test to stories and acceptance criteria. As code is added and tested it is organized to fit in the BDD hierarchy, so it is easier to go bottom up and trace code to the requirements.

##Task Planning

BDD belongs to best-development practices and it is crucial in keeping an agile team focused and delivering quality work that matches the story criteria. High-level BDD review of stories is part of task planning for the team. As a rule of thumb, to parallelize team work, one or two members can be responsible to break down a story into BDD criteria, explain it to the team, and then have all team together review it, and decide on the next individuals task that result from BDD.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2016/2016-11-13-Lubuntu-on-Lenovo-u41-70.md'>Lubuntu on Lenovo u41 70</a></ins>