2014

# madebits@github

https://madebits.github.io/

This web site is implemented as a single page application (SPA) with JavaScript dynamic content and client-side routing, making use of several third-party JavaScript libraries.

![](r/madebits.github.io/m.png)

## How this Site Works and Why

Back in 2014, I run through a thought experiment on how to build this web site hosted on GitHub pages.

* Markdown
> As this site is hosted in GitHub pages, it was important for me the content remains as text files in *Git* without any much formating (no HTML). Markdown was the easy choice. Almost all content in this site is markdown text.

* No Jekyll
> This was the hardest decision. I wanted to be able to generate the site easy on every machine, be it work or home, Windows or Linux, without having to install anything (other than the obvious *Git* required for GitHub). Jekyll needs Ruby and that alone made it unattractive. Python and Node.js based site generators were out of question for same reasons. What could work everywhere was *bash* (it comes with *Git*).

* JavaScript
> I did not want to write a static site generator in *bash*. I could, but it is more work that I was willing to spend and if you use *bash* for something that complex, better not use *bash*. So I left content as markdown and wanted to have a dynamic JavaScript site (as *single page application* - SPA) render pages on the fly (using `marked` library). As a drawback, the site thought having only static content, needs JavaScript to run. Given raw page text is still in GitHub public, I decided it was an acceptable compromise.
> Bash is still used thought. There are some things I cannot easy do dynamically using JavaScript, such as know what next file is, or have a list of contents with tags for JavaScript-based site search. A few minimal bash scripts handle that. After I add a new markdown page, I need to run a small *bash* script in the repo to update index file and then commit and push to Github (via another bash script). The rest runs as SPA using JavaScript. 

* Single Page Application (SPA)
> It may look like I replaced one problem with another. It was not easy to make a JavaScript SPA even back in 2014. I did not want to be dependent on Node.js, nor did I want to use any SPA framework (their versions come and die without notice). I decided to be very conservative on what I would use. I took *jQuery* for portable DOM manipulation, *sammy.js* for a small client-side router and *marked.js* for markdown conversion (I added a few more small libs since then, but that is all). All JavaScript libs used comes as files committed in the repo. I wrote some code to make out my SPA tailored for this site. The code gets its job done and needs no almost no maintenance.

* (No) Google or Ads
> I followed the Google wave over the Internet as everybody else for a while, but no more. No Google or other ads or analytics are used anymore on this site. I block Google via *robots.txt*. The public raw content on GitHub is still searchable by Google.



