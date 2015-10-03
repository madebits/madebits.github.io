#WCF: A plain REST WCF Service

2011-10-12

<!--- tags: csharp wcf -->

I will show here how to create a full plain XML REST service in pure WCF. No IIS is required.

The first thing to do is to define the REST WCF service. As the clients will never access it via the methods, the interface and implementation can be in same DLL is server. The example service below has only one REST API method, just to illustrate the points, but more can be added as needed.
```
[ServiceContract]
public interface IRestService
{
 [OperationContract]
 [WebGet(UriTemplate = "/data{id}")]
 Stream GetData(string id);
}

public class RestService : IRestService 
{
 public Stream GetData(string id)
 {
  return Runner.Run("dataxslt", () => { return DataProvider.GetData(id); });
 }
}
```
The reason why we return a `System.IO.Stream` and not something else will become obvious later on. The service end-point can be registered as needed in `app.config`:

```
<system.serviceModel>
 <services>
  <service name="Rest.RestService ">
   <endpoint
    name="RestService"
    address="http://localhost:8081/rest"
    binding="webHttpBinding"
    contract="Rest.IRestService"/>
  </service>
```

Some boilerplate `ServiceHost` code (not shown) can be use to self-host the service. No IIS is needed, but you may need to [reserve](http://msdn.microsoft.com/en-us/library/ms733768.aspx) the `http://+:8081/rest` namespace.

The REST service implementation is simple. It just delegates to a helper method `DataProvider.GetData` where the business logic resides. The `Runner.Run` is a 'magic' wrapper around any such business logic call. The duty of the `Runner.Run` is to map the data returned by business logic to pure REST XML. We will see the `Runner.Run` details later, but first let us see how `DataProvider.GetData` may look like.

Based on the `string` id we return a list of data item records from `DataProvider.GetData`. We can model the data as plain object DTOs (example):
```
public class DataItem 
 {
  public string Name { get; set; }
  public string Data { get; set; }
 }

 [CollectionDataContract]
 public class DataItems : List<DataItem>
 {
  public DataItems() { }
  public DataItems(List<DataItem> s) : base(s) { }
 }
```
`DataItem` uses no special attributes. The list of data items uses only `System.Runtime.Serialization.CollectionDataContract` attribute. This enables serializing it as a XML element called `DataItems` made of DataItem(s) rather than a plain list. This in enough to model any plain XML document with any level of element nesting (`DataItem` can be a property of a more complex DTO and so on).

Implementation of `DataProvider.GetData` looks as follows:
```
public static DataItems GetData(string id)
{
 //1. get data by id
 //2. map to DataItems
 var data = ...;
 //3. return list
 return new DataItems(data.ToList());
}
```
There is nothing special in this code that makes it WCF or REST specific. It is returning data is plain DTOs.

The job of converting the data from such simple DTOs to REST XML is left to `Runner.Run`. WCF REST API serializes results of REST service methods on its own, but the end XML is often not what you may want. To take full control over serialization, we return a `System.IO.Stream` from all REST methods. This tells WCF do not interpret or transform the content we are sending back in any way.

`Runner.Run` takes two arguments. The first is an optional stylesheet string id we may want to associate by default with the XML data. Modern browsers can use it to show the data as HTML without any more special web pages. The second parameter is the function to run:
```
public static Stream Run<TResult>(
    string xslt,
    Func<TResult> action,
    params object[] args)
  {
   try
   {
    TResult res = action();
    if (res is Stream)
    {
     return res as Stream;
    }
    return PostProcess(res, xslt);
   }
   catch (Exception ex)
   {
    return OnError(ex);
   }
  }
```
`Run` method runs the user code and checks whether the result is already a `System.IO.Stream`. If so it returns it as it is (we can return binary data, such images like that), otherwise it applies `PostProcess` to it. Additional code (not shown) can be added to process errors and other state in a central way. `PostProcess` method adds first the XSLT if specified to the output, then in appends the explicitly serialized DTOs.
```
private static Stream PostProcess(object result, string xslt)
{
var ms = new MemoryStream();
// add XML definition
 var data = Encoding.UTF8.GetBytes("<?xml version=\"1.0\" encoding=\"utf-8\" ?>" + Environment.NewLine);
 ms.Write(data, 0, data.Length);
 // add XSLT
 if (!string.IsNullOrEmpty(xslt))
 {
  var file = Xslt.MapToFile(xslt);
  var prefix = OperationContext.Current.Channel.LocalAddress.Uri.PathAndQuery;
  data = Encoding.UTF8.GetBytes("<?xml-stylesheet type=\"text/xsl\" href=\"" + prefix + "/xslt/" + xslt + "\" ?>" + Environment.NewLine);
  ms.Write(data, 0, data.Length);
 }
 // serialize
var xw = new NoNamespaceXmlWriter(ms);
 var ds = new DataContractSerializer(result.GetType());
 ds.WriteObject(xw, result);
 xw.Flush();
 ms.Seek(0, SeekOrigin.Begin);
WebOperationContext.Current.OutgoingResponse.ContentType = "text/xml";
 return ms;
}
```
You may need to know the `IRestService` URL prefix (rest part of) `http://localhost:8081/rest` to prepend it to the output XSLT link. As we want plain simple XML we use a plain XML writer (I found the following on StackOverflow):

```
public class NoNamespaceXmlWriter : XmlTextWriter
 {
  public NoNamespaceXmlWriter(Stream w)
   : base(w, Encoding.UTF8)
  {
   Formatting = System.Xml.Formatting.Indented;
  }

  public NoNamespaceXmlWriter(System.IO.TextWriter output)
   : base(output)
  { 
   Formatting = System.Xml.Formatting.Indented;
  }
  
  public override void WriteStartDocument() { }

  public override void WriteStartElement(string prefix, string localName, string ns)
  {
   base.WriteStartElement("", localName, "");
  }
 } 
```
We set also the content type explicitly:
```
WebOperationContext.Current.OutgoingResponse.ContentType = "text/xml";
```
To make the REST service XSLT support complete, we need to methods to get XSLT (and CSS if it is used there):
```
[OperationContract]
[WebGet(UriTemplate = "/xslt/{name}")]
Stream GetXslt(string name);

[OperationContract]
[WebGet(UriTemplate = "/css/{name}")]
Stream GetCssByName(string name);
```
Their implementation is similar:
```
public Stream GetXslt(string name)
  {
   return Runner.Run(null, () =>
   {
    WebOperationContext.Current.OutgoingResponse.ContentType = "text/xsl";
    return Xslt.Get(name);
   });
  }

  public Stream GetCss(string name)
  {
   return Runner.Run(null, () =>
   {
    WebOperationContext.Current.OutgoingResponse.ContentType = "text/css";
    return Xslt.GetCss(name);

   });
  }
```
`Xslt` helper class returns the XSLT or CSS text content based on name as `System.IO.Stream`. One extra thing to consider is that inside XSLT, CSS templates we refer to other content by relative paths, that the `IRestService` URL prefix (rest part of) `http://localhost:8081/rest` is not known there. To fix this, we may agree to some `##SITE##` prefix to be used for all relative references, and we replace it with the actual prefix as we load the XLST, CSS text before we return it back as Stream.

We built like this a self-hosted (no IIS) plain XML REST service based on WCF. We styled the pages with XSLT (XML to HTML) so that they show as web pages by default on a web browser.


<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2011/2011-10-13-WCF-Thread-Context.md'>WCF Thread Context</a> <a rel='next' id='fnext' href='#blog/2011/2011-10-11-WCF-Authentication-Cookies.md'>WCF Authentication Cookies</a></ins>
