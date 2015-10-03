2012

XPath Namespaces Extension for Linq to Xml
=====

<!--- tags: csharp -->

Using XPath with Linq to Xml is possible out of the box, by using the extension methods from .NET System.Xml.XPath, such as, XPathEvaluate. There is almost no reason to use XPath with Linq to Xml unless the criteria for data selection needs to read from somewhere else as a string.

XPath does not support Xml namespaces. While XPath is declarative, it is not complete, as namespace mapping has to be done in code. Every library implementing XPath, such the .NET framework one, has its own way to resolve Xml namespaces for XPath expressions.

##What is provided

Linq to Xml faces same problem with normal Xml and solves it nicely using a `XName` that contains the `XNamespace`. The best thing `XName` provides is that both name its namespace can be specified both together as a fully qualified name string in form `XName name = "{namespace}name";` This fully qualified name is not part of Xml, but a extension notation provided by Linq to Xml.

XPath support for Linq to Xml lacks this level of sophistication. To use XPath and namespaces with Linq to Xml one has to write some code, such as:

```csharp
var nsMgr = new XmlNamespaceManager(new NameTable());
nsMgr.AddNamespace("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
nsMgr.AddNamespace("dc", "http://purl.org/dc/elements/1.1/");
nsMgr.AddNamespace("rss", "http://purl.org/rss/1.0/");
var doc = XDocument.Load(@"D:\Temp\test.xml");
var data = (IEnumerable<object>)doc.XPathEvaluate(
 "/rdf:RDF/rss:channel/@rdf:about", nsMgr);
```

This example is based on the Rss Xml example found at http://weblogs.asp.net/wallen/archive/2003/04/02/4725.aspx.

Using XPath and namespaces with Linq to Xml is inconvenient when XPath string need to read from somewhere else (configuration) - as the Xml namespaces have to be mapped before the Xpath expression can be used.

##A better way

The code that will be shown next uses the new XPathEvaluateEx method and makes the namespace mapping part of the XPath notation. The code is inspired by the way Linq to Xml uses the `{namespace}name` notation.

```csharp
using LinqXPathEx;
...
var doc = XDocument.Load(@"D:\Temp\test.xml");
var data = (IEnumerable<object>)doc.XPathEvaluateEx("{rdf,http://www.w3.org/1999/02/22-rdf-syntax-ns#,dc,http://purl.org/dc/elements/1.1/,rss,http://purl.org/rss/1.0/}/rdf:RDF/rss:channel/@rdf:about");
```

The example uses a custom XPath expression `{prefix,namespace,...}xpath`. This full XPath string can now be stored as it is in the resources or configuration and read from there. The code enables also using XPath namespaces similar to Linq `XName` and `XNamespace` objects:

```csharp
XPathNamespaces xns = "rdf,http://www.w3.org/1999/02/22-rdf-syntax-ns#,dc,http://purl.org/dc/elements/1.1/,rss,http://purl.org/rss/1.0/";
XPathEx xpath = xns + "/rdf:RDF/rss:channel/@rdf:about";
...doc.XPathEvaluateEx(xpath);
```

The provided code removed spaces and new lines from namespaces automatically, so it is also possible to use a multiline string (@) for namespaces:

```csharp
XPathNamespaces xns = @"
 rdf,http://www.w3.org/1999/02/22-rdf-syntax-ns#,
 dc,http://purl.org/dc/elements/1.1/,
 rss,http://purl.org/rss/1.0/
 ";

XPathEx xpath = xns + "/rdf:RDF/rss:channel/@rdf:about";
... doc.XPathEvaluateEx(xpath);
```