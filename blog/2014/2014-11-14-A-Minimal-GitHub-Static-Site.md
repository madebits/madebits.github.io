#A Minimal GitHub Static Site

2014-11-14

I decided to move my free content to GitHub. My main goal was to back-port some of my old and articles and code to GitHub to save them from being lost. 

##Using GiHub

GitHub affects dependency, price, and openness: 

* Dependency on third-party services is more visible and more distributed. No one really cares nowadays to hide their "*.github.io" domain (thought it is possible to do so). Trust on cloud service quality is proportional to how popular the service is. Trust aside, GitHub makes it easy to have own backups of the stuff put there. There is a REST API to use to list repositories (that I used) and then you can backup all stuff using just git. I hope the GitHub REST API parts, I am using, will remain stable.

* GitHub is free, at least the basic plan I use. The crowd brings people, looking for something *"free"* and in-between, also those few willing to pay for the rest. If GitHub ever changes its free policy, I can always move to somewhere else.

* GitHub content is public, and at least this is how most people generally perceive it when hearing "I am on GitHub". Interestingly, GitHub makes its money by selling private plans where the stuff is not public, so there is still value on having some things private. Given the full openness of GitHub's free plan, I do not like listing on GitHub all side-projects I start. Most of them are rubbish to test something that I never finish. Having a cloud service to share work between my machines still helps even at that stage. I use [BitBucket](https://bitbucket.org/) for my private stuff - it is free even for private repositories. BitBucket also supports having repositories public at wish, but GitHub is more popular for that.

##Minimizing Exposure

One side-effect of using GitHub is that it leaks data, such as time information, that can be sensitive depending on the context. While I avoid accessing my GiHub account during my working hours, the myriad of work related laws for time management is not trivial. There are some measures one can take to avoid some of that:

* I have wrapped Git commands I use for GiHub in `bash` scripts that set always same time stamp for commits and tags. The drawback is my repository reported activity is somehow artificial (timestamps and commit messages are same). The benefits of not having public activity time series outweigh the drawback at the moment for me. 

* While, I would normally configure Git on the server to not allow forced pushes, I find the ability to do a force push and remove my commit history useful for GitHub. For this site as commits add up, their history has no value for me, and I can reset the repository history time after time.

* My repositories do not to have issues and wikis. I lack the time to track these. 

##A Self-Made CMS

GitHub supports hosting static web pages and offers a tool (*jekyll*) to generate GitHub pages from markdown content. I did not want to use *jekyll* as I do not want to install *Ruby* everywhere, but I still wanted a minimal generated GitHub site that was easy to maintain. My web site design goals were:

* I should be able to host my site at GitHub pages for free (obvious) with as few dependencies as needed, but no more. Minimizing dependencies is still a design factor nowadays, thought not as important as it used to be. I rely now on Git (Bash) and several JavaScript libraries.

* I wanted to use [markdown](http://daringfireball.net/projects/markdown/). I can write easily HTML manually, but Markdown makes the formating noise less visible and let me focus better on content. Markdown text can be read easy alone without needing to convert it to HTML. I cannot handle everything for this site in Markdown, but the bulk of the text content will be in Markdown.

* I do not want to convert the site locally and store it as HTML in GitHub. I decided to convert markdown documents in client using JavaScript. There is only a single entry page *index.html*. Client-side routing is used to navigate to a markdown page, load it via jQuery and parse to HTML. One thing JavaScript code cannot handle (in client) is to generate some sort of navigation over markdown files. I decided to solve this problem i) by convention and ii) by a *bash* script - given that Bash along with minimal GNU tools is available whenever *Git* is. The convention I follow is to name pages as *YYYY-MM-DD title.md*. They can be put in any sub-folder under the *content* folder. The script has to be run locally after adding a new post file, or when a post is updated.

* It should be a combination of a blog-like site along with additional permanent content. I can have any combination of *.md* and plain *.html* files. I created a simple, but full featured, on-line markdown editor to help me edit markdown files and preview them in real-time in browser. To run and test the whole site [locally](http://127.0.0.1:12345), I can use any web server, for example: `python -m http.server -b 127.0.0.1 12345` or `php -S 127.0.0.1:12345`. To test the pages on low bandwidth (32KB/s) I used:
		sudo apt-get install trickle
		trickle -d 32 -u 16 firefox

The result of my effort is some bash scripts and around < 2000 lines of JavaScript code, that created a client-side markdown based single page application for my site content.

##Search Engines

One drawback of my approach is that it is hard to impossible for a search engine to [scan](https://developers.google.com/webmasters/ajax-crawling/) the content of this site (thought Google is [doing](http://googlewebmastercentral.blogspot.ca/2014/05/understanding-web-pages-better.html) that.). While my site does not follow the book to be search engine friendly, I still make it possible to find content automatically. I link GitHub and the plain *.md* files are there. In general, this site's content is not easy to be found via search engines, which is fully ok for me.

##Moving My Content 

I managed to port back most of my stuff I can publicly share that I could find. This is only a small part of code and content I have ever created. Some stuff, I considered as not worth enough to be open is left out and will eventually get lost. The code is not particularly good and may not have any particular value to anyone, but it has at least some historical value for me. Not all code shares same level of quality - most of it was never intended to be shown to anyone, just to do something quickly. Code reflects the motivation and the time spent of it. I evolve, my existing code (and the challenges to write new code) remain same.

##Using Git for Uploads

A benefit of hosting pages to GitHub (if that works for you) is *Git*. With most classic web hosting providers, what you get is space and a way to copy up and down files (FTP, SFTP, etc). Unless you pay for some VPS, you cannot run `rsync` or something similar, and you end up transferring more data than needed. With GitHub pages, Git is used as deployment tool. This is perfect for static files, as only the difference is transmitted. The source control is integrated on same place and tool as deployment. By the way Git itself works, a complete, up-to-date, local backup is always available.


##Git Resources

* https://git-scm.com/book
* https://jwiegley.github.io/git-from-the-bottom-up/
* http://www.sbf5.com/~cduan/technical/git/
* https://wildlyinaccurate.com/a-hackers-guide-to-git/
* https://codewords.recurse.com/issues/two/git-from-the-inside-out
* http://tom.preston-werner.com/2009/05/19/the-git-parable.html
* https://www.youtube.com/watch?v=MYP56QJpDr4
* https://www.youtube.com/watch?v=sevc6668cQ0
* https://www.youtube.com/watch?v=-kVzV6m5_Qg
* https://medium.com/@pierreda/understanding-git-for-real-by-exploring-the-git-directory-1e079c15b807

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-12-12-Using-DNSCrypt-on-Ubuntu-14.04.md'>Using DNSCrypt on Ubuntu 14.04</a> <a id='fnext' href='#blog/2014/2014-11-08-Moving-Ubuntu-Hard-Disk-to-a-New-Machine.md'>Moving Ubuntu Hard Disk to a New Machine</a></ins>
