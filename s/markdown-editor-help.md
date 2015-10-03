#[Markdown Editor](#s/markdown-editor.html) Help

<div id='toc'></div>

MadeBits [Markdown Editor](#s/markdown-editor.html) is powered by [marked](https://github.com/chjj/marked). Markdown text is edited locally in your browser. No data are sent to any server. The following sections describe MadeBits specific behavior.

##General Behavior

You can directly write markdown text in the editor, or you can *Open* a local file to edit and *Save (as)* the text to a local file. If you edit an opened file externally, you can reload it. Refreshing browser page, or switching pages within MadeBits preserves the markdown text (last open file information is lost). Selected part of markup document is previewed directly below the editor.

##Images

Markdown documents rendered in this site, use special CSS styles, so care must be taken to specify what is needed. Images whose *alt* text contains  `@inline@`, e.g., `![@inline@](url)` are put inline, and the rest are styled as full line responsive images. Images using `data:` URLs that are not inline or whose *alt* text does not contain `@nosave@` (e.g., `![@nosave@](url)`), get a *Save As* button by default.

##Table of Contents

To generate a TOC for all headers  as a list use `<div id='toc'></div>`.

##Lists

First list after every `<div class="mb-ulgroup"></div>` is styled as a list group.

```
<div class="mb-ulgroup"></div>

* 1
* 2


* 1
* 2
```

<div class="mb-ulgroup"></div>

* 1
* 2


* 1
* 2

##Math Notation

[Math](http://www.mathjax.org/) is supported via `$$` (block) and `$$$` (inline). Escape `_`  (and other markdown special character, such as `*`) in a math formula using `\_`.

```
$$
c\_i = \frac{a\_i}{b\_i}
$$
```

$$
c\_i = \frac{a\_i}{b\_i}
$$

##HTML and JavaScript

HTML and JavaScript elements within marked render as expected. Due to *Content Security Policy* applied to MadeBits web pages, you can only load external scripts from a limited number of domains, such as, `cdnjs.cloudflare.com`.  External scripts are loaded asynchronously so in order to use objects from them, you have to use a special `madebits.defer` function, as shown in the next example:

```
<div id="draw"></div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script>
<script>
madebits.defer([[null, 'd3']], function (){

d3.select("#draw").append("svg")
.attr("width", 40).attr("height", 40)
.append("circle")
.attr("cy", 20).attr("cx", 20)
.attr("r", 10)
.attr("stroke", "#000000").attr("fill", "#C3D9FF");

});
</script>
```

First element of `madebits.defer` array has to be `null`. The rest can be any objects from loaded scripts that are needed to be available before your script can run.

<div id="draw"></div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js"></script>
<script>
madebits.defer([[null, 'd3']], function () {

d3.select("#draw").append("svg")
.attr('width', 40).attr('height', 40)
.append("circle")
.attr("cy", 20).attr("cx", 20)
.attr("r", 10)
.attr("stroke", "#000000").attr("fill", "#C3D9FF");
});
</script>

##Encryption

Markup documents can be encrypted with a password and hosted and loaded encrypted (decrypted in client browser) using `.dx` extension. [crypto.js](https://code.google.com/p/crypto-js/) with AES256 CBC is used. To generate encryption passwords use something like: `head -c 45 /dev/urandom | base64`. 
Write you markdown text as normal, then select *Encrypt* button and provide the password. Save encrypted text as a `.dx` file.  To edit an encrypted document load in the [Markdown Editor](#s/markdown-editor.html) and use the *Decrypt* button to specify the password. Embedded images with `data:` URLs are supported, but you are limited by the amount of memory you browser can handle.

##External Markdown Preview

MadeBits web site is a markdown previewer. You can preview markup documents from other allowed sites using something like `madebits.com/#http://somesite/path/doc.md` (use `.dx` documents for encrypted markdown). Due to *Content Security Policy* applied to MadeBits web pages, you can only use CORS content from publicly shared `dl.dropboxusercontent.com`.

---

[Back to Markdown Editor](#s/markdown-editor.html)