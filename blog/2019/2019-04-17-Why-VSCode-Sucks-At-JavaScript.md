# Why VSCode Sucks At JavaScript

2019-04-17

<!--- tags: javascript -->

I like [VSCode](https://code.visualstudio.com) and use it often to program JavaScript, but VSCode sucks at JavaScript. I would really like VSCode could support JavaScript same good as [WebStorm](https://www.jetbrains.com/webstorm/) does.

| Criteria |Sublime Text|VSCode|WebStrom|
|----------|-------|--------|------|
|<span class="text-muted">JavaScript support</span>|<span class="text-danger">+</span>|<span class="text-warning">++</span>|<span class="text-success">+++</span>|
|<span class="text-muted">Speed</span>|<span class="text-success">+++</span>|<span class="text-warning">++</span>|<span class="text-danger">+</span>|
|<span class="text-muted">Cost</span>|<span class="text-warning">++</span>|<span class="text-success">+++</span>|<span class="text-danger">+</span>|

Why does VSCode sucks at JavaScript? 

> Because VSCode team use [TypeScript](https://www.typescriptlang.org/). They only care about JavaScript as an afterthought - TypeScript works great, JavaScript kind of works too. They use their TypeScript tools for JavaScript.

Have a look at https://code.visualstudio.com/docs/languages/javascript and some of its highlights:

* In the very introduction, they explain: *"Most of these features just work out of the box, while some may require basic configuration ..."*. This means, we do not really care to make it easy and comfortable to use JavaScript out of the box.

* *VSCode provides IntelliSense within your JavaScript projects; for many npm libraries such as ...*, basically, for all those libraries that come with TypeScript information.

* *`jsconfig.json` files are not required ...*, but the TypeScript compiler uses them and while you do not want to use TypeScript, take over its ugly parts. TypeScript developers are used to that, JavaScript people can get used to that too.

* *Go to Definition* - most of the time will not work in JavaScript projects, unless you write JavaScript code that looks like TypeScript. Better map F12 to plain text search.

* To take over the experience of TypeScript into JavaScript decorate files with `//@ts-check`. Do they really expect people to decorate each file in a code-base like that? Anyway, every time I tried that, it made the whole error checking experience worse and had to remove those comments again. VSCode will think code is TypeScript and will report non-sense. Not sure if VSCode developers have ever tried programming JavaScript for more than demo with this comment on.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2019/2019-04-16-SFTP-With-Shared-Access.md'>SFTP With Shared Access</a></ins>
