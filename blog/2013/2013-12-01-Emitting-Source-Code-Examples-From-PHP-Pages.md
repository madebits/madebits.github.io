#Emitting Source Code Examples From PHP Pages

2013-12-01
<!--- tags: php -->

In writing some PHP software, I ran into the problem of outputting source code examples in the pages.

The obvious recommended way to show source code blocks is to use a `<pre>` HTML tag:

```
<pre>
... code block example ...
</pre>
```

The problem with `<pre>` tag is that the text inside it cannot contain characters that are special to HTML, that is, characters like `<` must be HTML escaped as `&lt;`, and so on. Taking care of HTML escaping for code examples manually is tedious and something I wanted to avoid.

```
<pre>
 if($s &lt; 5) { ... }
</pre>
```

 I tried for some time the `XMP` HTML tag. `XMP` is an archaic and deprecated HTML tag, but it works quite well in all browser versions. There is no replacement for it in newer HTML standard versions, so despite being in-official it is ok to use (one cannot have an `XMP` within an `XMP`).

```
<xmp>
 if($s < 5) { ... }
</xmp>
```

I really wanted to use the recommended `<pre>` HTML tag and get away from `<xmp>`. I could create a PHP function to output source code block examples. PHP does not parse the PHP string only if a `nowdoc` style string is used. So I come up with the following helper function to show source code examples:

```
<?php writeCode(<<<'ENDOFCODE'
 if($s < 5)
 {
  echo('"\ttest\n"'); // fake example
 }
ENDOFCODE
); ?>
```

It delivers as output in HTML page:

```
 if($s < 5)
 {
  echo('"\ttest\n"'); // fake example
 }
```

This function fulfills the two requirements I had in mind: a) no manual escape of strings is needed, b) it is easy and convenient to use.

To handle `<pre>` tag HTML escape, I implemented my PHP `writeCode` function as follows, using the PHP built-in `htmlspecialchars` function:

```
function writeCode($text)
{
 echo("<pre>");
 $text = str_replace("\t", " ", $text);
 echo(htmlspecialchars(trim($text, "\n\r\0\x0B")));
 echo("</pre>");
}
```

Of course, I could have used some ready made library for this, but doing it so simple and so good on my own, was much more fun.


<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-12-03-Script-to-Download-Bing-Image.md'>Script to Download Bing Image</a> <a id='fnext' href='#blog/2013/2013-11-28-Getting-Started-with-Sublime-Text.md'>Getting Started with Sublime Text</a></ins>
