#Content Security Policy

2014-12-19

<!--- tags: javascript -->

Reading about Google was [making](http://gmailblog.blogspot.de/2014/12/reject-unexpected-content-security.html) Gmail more secure with [Content Security Policy](http://www.w3.org/TR/CSP/) (CSP), I decided to try it also on this web site. I use some Google services, such as AdSense or Analytics in this site, and I had to find the correct CSP setting by trial and error. To use these services I had to allow:

```
default-src 'self' www.google-analytics.com ; script-src 'unsafe-eval' 'unsafe-inline' 'self' pagead2.googlesyndication.com www.gstatic.com www.google-analytics.com; img-src 'self' data: www.google-analytics.com stats.g.doubleclick.net; frame-src googleads.g.doubleclick.net;
```

One thing Google Analytics uses that I do not allow is `data:application/javascript`. In CSP one can only allows `data:` over all sites (which makes sense). So even if Google Analytics needs it, it is too risky to run on. I am not sure how this affects Google Analytics, because it seems to kind of work.

I had to repeat same for all third-party APIs I use, such as [Disqus](https://disqus.com/) one that I use for comments here. Most of the REST APIs, such as GitHub one, where you only call something are simple to handle via CSP, but those that add content to the page on their own (AdSense, Disqus) are a pain to handle with CSP.

CSP kind of works as specified on the browsers that support it, but it has currently some problems:

1. Most third-party services do not publish their CSP settings. You have to reverse-engineer them by trial and error. The services that add content to the page are especially problematic, when they use multiple undocumented domains.
1. Related to above, you have to rely not only a the published third-party API, but you have to also to rely on some of the inner workings of that third-party API. Google and Disqus may change these internal implementation site URLs at any time without any prior notice and this will break my site.

Lesson learned: If you are about to offer some services over the web, make sure you document your CSP settings along with your API. If you want you API to work good with CSP do not use eval or data URLs. If you use a third-party service with unspecified CSP, then better do not use CSP at all, unless it is not so problematic for you, if the third-party service stops working at some point.

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-01-07-ASP.NET-vNext-in-Ubuntu-14.04-LTS.md'>ASP.NET vNext in Ubuntu 14.04 LTS</a> <a id='fnext' href='#blog/2014/2014-12-16-Moving-From-EF5-Database-First-to-EF6-Code-First.md'>Moving From EF5 Database First to EF6 Code First</a></ins>
