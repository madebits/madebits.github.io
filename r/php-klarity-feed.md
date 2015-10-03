2009

#Klarity RSS1+2 / ATOM PHP Script

<!--- tags: php -->

Klarity is a ready to use PHP script that parses RSS1.0, RSS2.0 and ATOM news feeds and outputs HTML.

|Features|Limits|
|-|-|
|Parses RSS1.0, RSS2.0 and ATOM.|Supports only a subset of RSS1.0, RSS2.0 and ATOM features and ignores the rest.|
|Automatically detects RSS1.0, RSS2.0 and ATOM document types.|Uses minimal heuristics to determine the feed type. These heuristics may fail at cases.|
|HTML output is made of DIV and SPAN elements with no default styles and with class names. These elements can be styled and positioned and customized as wished using CSS.|Outputs hardcoded (but CSS customizable) HTML.|
|Generates no Javascript. Output can be seen on any browser.|No AJAX. The parsing is done in server. The feed files are small, so this should not be a problem.|
|Small and self contained.||
|Free to use on both commercial and free web sites. If you want to modify the code, it is released under GPL.||

##Philosophy

Different publishers of news feed make available different types of specialized content in their web sites. Specialized web sites combine the feeds from different publishers into customized news profiles. Users browse the news profiles in specialized web sites and read the news in the publisher web sites.

![](r/php-klarity-feed/news.gif)

For such a combination to work, it should be easy for specialized web sites to combine and to represent news feeds. Klarity makes the news integration process easy and it is free.

##Usage

To use Klarity in your PHP enabled web pages you need to create a object of the Klarity_Class and call showFile(...) with the URL of a news feed:

```
require('klarity.php');
try
{
 $klarity = new Klarity_Class();
 $klarity.showFile('http://digg.com/rss/index.xml');
}
catch (Exception $e)
{
 // ...
}
```

News feeds usually contain UTF8 data. It is recommended you use UTF8 encoding in the output HTML file head:

```
<meta http-equiv="Content-Type"
 content="text/html;charset=utf-8" >
```

##Styling Klarity

By default, the Klarity output HTML is not styled and it may look not so nice. You can fully customize the output look and feel using CSS. All HTML elements output by Klarity have predefined CSS classes.

```
<!--  Klarity outputs the following: -->

<div class ="klarity_feed" >
  <div class ="klarity_head" >
    <span class='klarity_head_image_span'>...</span>
    <span class='klarity_head_title_span'>...</span>
  </div>
  <div class ="klarity_content" >
    <div class ="klarity_item" >
      <div class="klarity_item_title" >...</div>
      <div class="klarity_item_description">...</div>
      <div class="klarity_item_date">...</div>
    </div>
    ...
  </div>
  <div class='klarity_powered'>...</div>
</div>
```

For more details see the reference and the included klarity.css file in the source bundle.

##Reference

Klarity methods / properties / CSS classes reference:

|Method|Description|
|-|-|
|`showFile($file)`|Parses a feed `$file` URL and outputs feed as HTML. It opens by default only XML mime types (configurable via showFileMimeCheck property). If you need more control, use `showString($data)`.|
|`showString($data)`|Parses a feed string `$data` and outputs feed as HTML.|

|Property|Description|
|-|-|
|linkTarget|By default, news links are opened in a new page. Set "_self" to open to current page. Set a HTML frame name to open them in a specific frame.|
|showFeedHead|Set to false not to show feed channel information. By default true.|
|showFeedHeadTitle|If head is shown, set to false not to show feed title (if available). By default true.|
|showFeedHeadImage|If head is shown, set to false not to show feed logo image (if available). By default true.|
|showFeedHeadLinks|If head is shown, set to false not to show feed head title/image links. By default true.|
|showFeedHeadDescription|If head is shown, set to false not to show feed head sub title (if available). By default true.|
|showDates|Set to false not to show item dates (when available). By default true.|
|showPowered|Show 'Powered by Klarity' link.|
|userAgent|The user agent string is used only when `showFile($file)` method is used. By default it is IE7.|
|showFileMimeCheck|True by default. Check the remote file mime type before reading the file in `showFile($file)` method. If you want to disable mime checks, set it to false.|
|oldFix|This option exists only as a workaround for an old SimpleXML bug in PHP. It is not sure when this bug is fixed, but PHP 5.2.5 does not have it and, for example, PHP 5.0.4 has it. By default, this option is set to false, but if you find that the script is not working in PHP versions before 5.2.5, try to set this option to true.|
|version|Klarity script version number as string.|

|CSS Class|Description|
|-|-|
|.klarity_feed|Main feed DIV element class.|
|.klarity_head|Head (channel info) DIV element class.|
|.klarity_head_title_span|Head title SPAN element class.|
|.klarity_head_title_link|Head title A element class.|
|.klarity_head_subtitle|Head description (subtitle) DIV element class.|
|.klarity_head_image_span|Head image SPAN element class.|
|.klarity_head_image_img|Head image IMG element class.|
|.klarity_head_image_link|Head image A element class.|
|.klarity_content|Content DIV element class, contains all feed items, apart of channel head.|
|.klarity_item|News item DIV element class.|
|.klarity_item_link|News item title A element class.|
|.klarity_item_title|News item title DIV element class.|
|.klarity_item_description|News item description DIV element class.|
|.klarity_link|News item description A element class.|
|.klarity_item_date|News item date DIV element class.|
|.klarity_powered|Klarity powered DIV element class.|
