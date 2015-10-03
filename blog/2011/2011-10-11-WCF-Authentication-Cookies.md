#WCF: Using a Custom Authentication Cookie with WCF

2011-10-11

<!--- tags: csharp wcf -->

I show here how to automatically transmit a custom authentication cookie in all .NET Windows Communication Foundation (WCF) operations. There are several ways to do this. We will rely only on WCF DTO serialization events. This method works for cookies of limited size, and maintains the cookie across WCF service boundaries for same client.

##A Generic Base Dto

We will transmit the cookie via DTOs and for these we need some extra space available on all of them. We will start with having a generic base DTO. It contains an object dictionary to keep our own extra data. Objects can be used is DTOs as long as WCF known how serialize / deserialize their types on both sides. We use `object` to denote that user should not care about the data there. The helper [index] property can be used to access the data.

```
public Dictionary<string, object> BaseData { get; set; }

 public object this[string id]
 {
  get
  {
   if (BaseData == null)
   {
    return null;
   }
   if (BaseData.ContainsKey(id))
   {
    return BaseData[id];
   }
   return null;
  }
  set
  {
   if (BaseData == null)
   {
    BaseData = new Dictionary<string, object>();
   }
   BaseData[id] = value;
  }
 }

#endregion basedata

}
```

To pass out-of-band data via WCF, we will use here `BaseData` we added before, along with DTO serialization events. To achieve this goal in a generic way, we extended our `DtoBase` with some member events being called as needed:
```
 public event Action<DtoBase> Preprocess;
 public static event Action<DtoBase> PreprocessGlobal;
 public event Action<DtoBase> Postprocess;
 public static event Action<DtoBase> PostprocessGlobal;
```
And then call these if set from WCF serialization events of `DtoBase` class (WCF calls these methods as needed when DTOs are transmitted):

```
[OnSerializing]
  private void OnSerializing(StreamingContext ctx)
  {
   if (this.BaseData == null) 
   {
    this.BaseData = new Dictionary<string, object>();
   }
   if (Preprocess != null) 
   {
    Preprocess(this);
   }
   if (PreprocessGlobal != null) 
   {
    PreprocessGlobal(this);
   }
  }

  [OnDeserialized]
  private void OnDeserialized(StreamingContext ctx)
  {
   if (this.BaseData == null)
   {
    this.BaseData = new Dictionary<string, object>();
   }
   if (Postprocess != null)
   {
    Postprocess(this);
   }
   if (PostprocessGlobal != null)
   {
    PostprocessGlobal(this);
   }
  }
```
`DtoBase` is now complete. As next step we define two optional, but good practice classes inheriting for it:
```
[DataContract]
public class Request : DtoBase
{
}

[DataContract]
public class Response : DtoBase
{
}
```
We will require that all WCF operations are of form:
```
[OperationContract]
ClassDerivedFromResponse WcfOperationMethod(ClassDerivedFromRequest request)
```
This is a good practice as we have only one request / response (thought not strictly required for the WCF cookie). The Request and Response DTOs can contain as members other DTOs that do not need to inherit from DTO base, but the top classes must.

Not all WCF operations can be modeled as shown above. Some of them could be one way without return value. The only limitation of this method is that in order to send back the authentication cookie to client, we need that the client calls first an operation that has a response (any method will do).

##Handling Authentication on Client

Let us start with a `Credential` class to make it easy for client to specify the needed authentication data. We can transmit any data with it. We will use here only a `User` and `Password`.
```
public class Credentials
{
 public string User { get; set; }
 public string Password { get; set; }

 internal IDictionary<string, object> GetData() 
 {
  var data = new Dictionary<string, object>();
  data.Add(UserKey, this.User);
  data.Add(PasswordKey, this.Password);
  return data;
 }

 public const string UserKey = "sec.user";
 public const string PasswordKey = "sec.user.pass";
}//EOC
```
This class has a helper `GetData` method, that return the data in the format needed by `DtoBase.BaseData`. Then will define a helper class to handle authentication in client per .NET app domain (we will use static variables, and they are visible across the application domain). This class has one static method Set that does all the magic. `Set` method returns a GUID session key that identifies the client section on server. This session key can be used if needed to keep authentication state and across-WCF services without explicitly using state-full WCF servers.

```
public static class AppDomainCredentials
{
 private static bool active = false;
 private static object lockObj = new object();
 private static IDictionary<string, object> data = null;
 
 public static Guid Set(Credentials credentials) 
  {
   lock (lockObj) 
   {
    data = credentials.GetData();
    data.Add(ClientSessionKey, Guid.NewGuid());
    if (!active)
    {
     active = true;
     DtoBase.PreprocessGlobal += (dto) => 
     {
      lock (AppDomainCredentials.lockObj)
      {
       if (AppDomainCredentials.data == null) 
        return;
       foreach (var key in AppDomainCredentials.data.Keys)
       {
        dto[key] = AppDomainCredentials.data[key];
       }
      }
     };
     DtoBase.PostprocessGlobal += (dto) =>
     {
      if ((dto.BaseData != null)
       && dto.BaseData.ContainsKey(ClientSessionCookie))
      {
       var cookie = (string)dto.BaseData[ClientSessionCookie];
       if (!string.IsNullOrEmpty(cookie))
       {
        lock (AppDomainCredentials.lockObj)
        {
         if (AppDomainCredentials.data != null)
         {
          AppDomainCredentials.data[ClientSessionCookie]
           = cookie;
         }
        }
       }
      }
     };
    }
    return (Guid)data[ClientSessionKey];
   }
  }

  public static string ClientSessionKey = "client.session";
  public static string ClientSessionCookie = "client.session.cookie";
 }//EOC
```

This class basically remembers (caches) authentication data set globally. It also appends to a client session GUID id, for later usage, if needed. Then the class hooks itself on the serialization events of `DtoBase` we defined before. On every client request it copies the cached data in the request `BaseData` and on every server response it copies back if set some cookie data to the cache. If set, the cookie becomes part of cached data and it is send then back to server with next request again. The code is implemented inline and protected with locks to be thread-safe. When WFC uses any classes derived from `DtoBase` as operation DTOs, it will call their serialization event on send and their deserialization event on receive. This class hooks safely globally to these, and transmits the out of band extra data that we need to maintain an authentication session. To set up authentication, all the client needs to do is to call once for app domain:
```
var clientId = AppDomainCredentials.Set(new Credentials{...});
```
Normally, client does not need session clientId, but it may log it if needed. After this, client can use any WCF service and its methods normally, without any other hurdle or extra effort, as many times as needed, as shown in the next fake example:
```
using (var v = new ChannelFactory<ISomeWcfService>("endpoint"))
{
 var c = v.CreateChannel();
 var res = c.SomeOperation(data); // res, data are DtoBase derived classes
}
```
Authentication will be handled automatically for all such requests. The only requirement is, as stated before, that all WCF operation should have request / response DTOs deriving from `DtoBase`. If client and server use WCF over SSL then there is no need to explicitly encrypt password.

##Handling Authentication on Server

Client authentication is a cross-cutting concern needed for every client method call and we will handle it with an aspect. There many ways to implement an aspect. They all share the property that the aspect should normally be invisible to developer for all practical purposes. We will use only build-in .NET functionality to come as near as possible to the aim of achieving an almost invisible client authentication aspect. Let suppose, we have a simple WCF service:
```
[ServiceContract]
 public interface ITestService
 {
  [OperationContract]
  TestResponse Test(TestRequest r);
 }
```
Which we implement in a class (the `ServiceBehaviour` does not really matter for this example):
```
 public class TestService : ITestService
 {
  public TestResponse Test(TestRequest r)
  {
   return MethodRunner.Run(() =>
   {
    ...
    return new TestResponse { ... };
   }, r);
  }
 }
```
The interesting part is the implementation of `Test` method. We make use of the aspect there, which is implemented as a static method `MethodRunner.Run` that takes as input the code of the method. The code inside the aspect can do anything. When done the code returns a `DtoBase` derived response. The magic of handling authentication details in handled within `MethodRunner.Run`.

The method just shown is a convenient way to implement **aspects** in pure .NET (and especially WCF) that relies only on .NET build functionality. The only inconvenience is to remember using those required two lines of code on every method on the WFC service. The rest is same. This small inconvenience opens the possibilities for a lot in automatic conveniences when executing the inner code. There are other ways on WCF achieve same effect, but they are more evolved. The method above can be applied if needed to both WCF / non-WCF code. Now that we have shown how to use the aspect on the server side (and that is all a server developer has to do to benefit from it), we can start showing how the aspect implementation could look like. We have two overloads, one for an operation with result, and one for one without result to make it easier to use for rare cases where we have one way operations.

The implementation of `MethodRunner` invokes the action given after validating the request. The validation cookie is then copied to result before the result is returned to client.

```
public class MethodRunner
 {
  [System.Diagnostics.DebuggerStepThrough]
  public static TResult Run<TResult>(
   Func<TResult> action,
   params object[] args)
  {
   var cookie = Validate(args);
   var res = action();
   res.BaseData[AppDomainCredentials.ClientSessionCookie] = cookie;
   return res;
  }

  [System.Diagnostics.DebuggerStepThrough]
  public static void Run(
   Action action,
   params object[] args)
  {
   Validate(args);
   action();
  }
}
```
We can now start adding more logic to this implementation as needed inside Validate. I will show only example code below simplified from real code:
```
var string Validate(DtoBase dto)
{
 var credentials = new Credentials{ 
  User = dto[Credentials.UserKey],
  Password = dto[Credentials.PasswordKey]
 };
 var cookieDataRaw = dto[AppDomainCredentials.ClientSessionCookie];
 var cookie = string.IsNullOrEmpty(cookieDataRaw) 
  ? new Cookie() 
  : new Cookie(Decrypt(cookieDataRaw));
 if(!cookie.IsValid(credentials))
 {
  var authenticationData = Authenticate(user, path);
  cookie = new Cookie(credentials, authenticationData);
 }
 return Encrypt(cookie.ToString());
}
```
Basically, we get the authentication credentials and the existing cookie if any from the request DTO, verify them and return the cookie back. I have shown `Decrypt` and `Encrypt` of the cookie explicitly, just to make it obvious that the cookie data are encrypted and decrypted by server (using symmetric encryption) so that the clients cannot forge the cookie in any way.

`cookie.IsValid` method checks whether the decrypted data of the cookie match the credentials of the client. The code additionally checks (not shown) whether some time to live lease inside the cookie is still valid. If everything is ok, the authentication is accepted and we do not use a more costly authentication. If not we use the costly authentication. It may return extra data, such as user roles, which we may append to the cookie. The encrypted cookie data are then returned to the client. The client code shown earlier will then send them back to the server on next request.

In a similar fashion we can check more stuff in a centralized way, such as client id, or we can do something central to log and handle all errors inside `MethodRuner.Run` (not shown in examples). The technique is general and be used with minimal WCF specific code pollution. We are keeping here small chunks of state safely in client reliving the server from having to implement stateful WCF services only for this purpose. It works also across all the WCF service instances same client uses on same .NET app domain.


<ins class='nfooter'><a id='fprev' href='#blog/2011/2011-10-12-WCF-REST-Service.md'>WCF REST Service</a> <a id='fnext' href='#blog/2010/2010-11-02-Speed-Based-Volume-Adaption-for-Navigation.md'>Speed Based Volume Adaption for Navigation</a></ins>
