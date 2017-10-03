# Why VSCode Sucks At JavaScript

2019-04-17

<!--- tags: javascript -->

I like [VSCode](https://code.visualstudio.com) and use it often to program a lot of JavaScript, but VSCode sucks at JavaScript. I would really like VSCode could support JavaScript same good as [WebStorm](https://www.jetbrains.com/webstorm/) does.

Why does VSCode sucks at JavaScript? 

> Because VSCode developers use [TypeScript](https://www.typescriptlang.org/). They only care about JavaScript as an afterthought - TypeScript works great, JavaScript kind of works too.

Have a look at https://code.visualstudio.com/docs/languages/javascript and let me explain some of its highlights:

* In the very introduction, they explain: *"Most of these features just work out of the box, while some may require basic configuration to get the best experience."*. This means, we do not really care to make it easy and comfortable to use JavaScript out of the box in VSCode.

* *VS Code provides IntelliSense within your JavaScript projects; for many npm libraries such as ...*, basically, for all those libraries that come with TypeScript information.

* *`jsconfig.json` files are not required ...*, but the TypeScript compiler uses them and while you do not want to use TypeScript, then at least take over its bad parts. TypeScript developers are used to that, JavaScript people can get used to that pain too.

* *Go to Definition* - most of the time will not work, unless you use write JavaScript code that looks like TypeScript, better map F12 to plain text search.

* To take over the terrible programming experience of TypeScript to JavaScript decorate files with `//@ts-check`. Who do they expect to decorate each file in a code-base like that? Anyway, every time I tried that, it make the whole error checking experience terrible and had to turn it off. VSCode will think code is TypeScript and will report non-sense. Not sure if VSCode developers have ever tried programming JavaScript for more than demo with it on.

How can VSCode be better at JavaScript? 

> Force VSCode developers to do maintain some JavaScript project in parallel using VSCode. The older the code base, the better.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2019/2019-04-16-SFTP-With-Shared-Access.md'>SFTP With Shared Access</a></ins>
