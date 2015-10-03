#Emitting Source Code Examples From PHP Pages

2013-12-01
<!--- tags: php -->

The obvious recommended way to show source code blocks is to use a `<pre>` HTML tag:

```
<pre>
... code block example ...
</pre>
```

The problem with `<pre>` tag is that the text inside it cannot contain characters that are special to HTML, that is, characters like `<` must be HTML escaped as `&lt;`, and so on. Using the PHP built-in `htmlspecialchars` function handles that:

```
function writeCode($text)
{
 echo("<pre>");
 $text = str_replace("\t", " ", $text);
 echo(htmlspecialchars(trim($text, "\n\r\0\x0B")));
 echo("</pre>");
}
```

To actually  embed code sample inside PHP pages, one can use `nowdoc` strings. PHP does not parse the PHP string only if a `nowdoc` style string is used. The following helper function can be used to show source code examples:

```
<?php writeCode(<<<'ENDOFCODE'
 if($s < 5)
 {
  echo('"\ttest\n"'); // fake example
 }
ENDOFCODE
); ?>
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-12-03-Script-to-Download-Bing-Image.md'>Script to Download Bing Image</a> <a rel='next' id='fnext' href='#blog/2013/2013-11-28-Getting-Started-with-Sublime-Text.md'>Getting Started with Sublime Text</a></ins>
