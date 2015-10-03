#Chrome 55 Moves to Less Secure Flash Handling

2016-12-09

<!--- tags: browser -->

Google Chrome 55 moved to a way of handling adobe Flash that is similar to Firefox, by allowing Flash on a [per site](https://blog.google/products/chrome/flash-and-chrome/) basis. Chrome [uses](https://www.bleepingcomputer.com/news/software/chrome-55-now-blocks-flash-uses-html5-by-default/) user browsing history to enable flash automatically for most visited sites. 

##Little to No Benefit for Ordinary users

Ordinary users could in theory benefit from this change, as Flash will not run in sites visited rarely, though it is not clear to me whether advertising pages showing often for most users would also get good site site-engagement points.

Most visited sites are visible in [chrome://site-engagement](chrome://site-engagement), a URL which is not listed in [chrome://chrome-urls](chrome://chrome-urls). Users that run Chrome always in incognito, will have always to start with a blank site-engagement score. For incognito users, the new Flash feature is completely useless as they will be over-prompted.

##Reopen Security Hole

For the majority of users, Chrome Flash handling change is a security downgrade. Before this release, it was possible to choose configuring *click to play* for plugins, allowing fine grained Flash control over all plugins on a page. 

As a power user, *click to play* for plugins was really useful. Even if I want to use allow Flash temporary to view a video, I in general do not want to allow all Flash instances in that page to run. It also helps to notice hidden invisible Flash tracking plugins in pages.

Such fine Flash control, seems still be there in Chrome 55 in Windows, if you had click to play for plugins configured before. I suspect this is a bug, they may remove that in some future version - it did not work like that for me with [current](https://download-chromium.appspot.com/) Chrome builds (57) on Linux.

##Firefox Leads The Way

With Google being one of main Mozilla sponsors, Google often uses Firefox as playground for (sometimes unpopular) ideas, or to soft-*buy* votes for W3C *standards*. Firefox introduced a similar way of handling Flash some time ago. There are ways, in Firefox to undo that behavior via flags and add-ons, but they are not as safe as browser detecting and blocking Flash. Firefox therefore become a *yes* | *no* switch for Flash, with no safe way in between.

Similarly, in Chrome 55 using [chrome://plugins](chrome://plugins) one can enable Flash, and then use some third-party [extension](https://chrome.google.com/webstore/detail/flashcontrol/mfidmkgnfgnkihnjeklbekckimkipmoe) to achieve 'same' level of control as before, but this will be less secure than using the browser itself to block plugins.

##Flash Killer That Gives New Life to Flash

Flash will not go away by this change (and why should Google [decide](https://docs.google.com/presentation/d/106_KLNJfwb9L-1hVVa4i29aw1YXUy9qFX-Ye4kvJj-4/present?ueb=true&slide=id.p) on that?). On the contrary, by this change, Flash will gain popularity as a tool for exploration of security holes, tracking, and advertising. People will just feel safer. Sites that have Flash will benefit, as once Flash is enabled, they can use it not only for the things the user wants. This move is sold under HTML5 promotion, but what it actually achieves is making web browsing less secure and ensures Flash will be still around for years to come.


<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2016/2016-11-29-From-User-Stories-To-Code.md'>From User Stories To Code</a></ins>
