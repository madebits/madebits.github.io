#C\# Adding Custom XML to app.config

2014-02-05 

<!--- tags: csharp -->

To add a custom chunk of XML to `app.config` in a .NET application, without having to implement a typed custom config handler, we first define the XML element and its handler in `app.config`:

```
<?xml version="1.0" encoding="utf-8" ?>
 <configuration>
  <configSections>
   <section
    name="myXml"
    type="SomeNamespace.XmlChunkHandler, SomeAssemblyName"
    allowLocation="true"
    allowDefinition="Everywhere"
   />
  </configSections>
  ...
  <myXml>
   <!-- add any XML in here -->
  </myXml>
  ...
 </configuration>
```

In the code of `SomeAssemblyName` we add a class `SomeNamespace.XmlChunkHandler`. This handler is generic it can be used for more than one such XML chunk section:
```
namespace SomeNamespace {
 public class XmlChunkHandler : IConfigurationSectionHandler {
  object IConfigurationSectionHandler.Create(
   object parent, object configContext, XmlNode section) {
    return section.InnerXml;
  }
 }
}
```

Finally, we can read the inner XML string (without the ) as:

```
var xmlString = (string)ConfigurationManager.GetSection("myXml");
```

We can then do whatever we want with this raw chunk of XML text in code.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2014/2014-02-06-Browsing-Using-Keyboard-in-Google-Chrome-Browser.md'>Browsing Using Keyboard in Google Chrome Browser</a> <a rel='next' id='fnext' href='#blog/2014/2014-02-04-Using-i3wm-on-Lubuntu.md'>Using i3wm on Lubuntu</a></ins>
