#C\# Obtaining Method Parameter Names via Expressions

2013-08-02

<!--- tags: csharp -->

In C#, it is not possible to get current method argument names via reflection. This leads usually to code like the one that follows when one needs to verify method input variables:
```
void SomeMethod(string name, Dto request)
{
  if(string.IsNullOrEmpty(name))
    throw new ArgumentNullException("name");
  if(request == null) 
    throw new ArgumentNullException("request");
  if(request.Message == null)
    throw new ArgumentNullException("Message");
...
}
```
The above code uses strings to name variables in errors and is hard to write and maintain. The compiler cannot check the strings used.

Using .NET Contracts remedies the problem of having to use strings, but using Contracts only for this is purpose heavy. A more lightweight approach it to use Expressions and lambdas, as shown in the example:
```
void SomeMethod(string name, Dto request)
{
  ArgumentExceptionEx.IfEmpty(name, x => name);
  ArgumentExceptionEx.IfNull(request, x => request);
  ArgumentExceptionEx.IfNull(request.Message, x => request.Message);
...
}
```

A possible implementation of the helper class ArgumentExceptionEx is shown next:
```
public class ArgumentExceptionEx : ArgumentException
{
  public ArgumentExceptionEx(Expression<Func<object, object>> data) 
    : this(null, data)
  {  
  }

  public ArgumentExceptionEx(string message, Expression<Func<object, object>> data)
    : base((message ?? "Invalid argument") + ": " + GetName(data))
  {
  }

  public static string GetName(Expression<Func<object, object>> data)
  {
    if (data == null) return "?";
    var member = (data.Body as MemberExpression).Member;
    return member != null ? member.Name : "?";
  }

  public static void If(bool ok, Expression<Func<object, object>> data, string message = null)
  {
    if (ok)
    {
    throw new ArgumentExceptionEx(message, data);
    }
  }

  public static void IfNot(bool ok, Expression<Func<object, object>> data, string message = null)
  {
    If(!ok, data);
  }
  
  public static void IfNull(object o, Expression<Func<object, object>> data, string message = null)
  {
    If(o == null, data);
  }

  public static void IfEmpty(string o, Expression<Func<object, object>> data, string message = null)
  {
    If(string.IsNullOrEmpty(o), data);
  }

}//EOC
```

More `If`-like methods can be added as needed.

Update: In C# 6.0, the new `nameof` operator can be used to achieve same.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-08-02-Pairing-Logitech-Touchpad-and-Mouse-on-Lubuntu.md'>Pairing Logitech Touchpad and Mouse on Lubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-07-27-Plustek-OpticSlim-2400-Scanner-in-Lubuntu.md'>Plustek OpticSlim 2400 Scanner in Lubuntu</a></ins>
