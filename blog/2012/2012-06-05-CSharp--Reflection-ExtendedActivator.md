#C\# Reflection ExtendedActivator

2012-06-05

<!--- tags: csharp -->

.NET framework `Activator.CreateInstance` static method is useful to create objects at run-time without having to write explicitly reflection code. `Activator.CreateInstance` has not been updated to support optional constructor arguments and you have to pass all constructor arguments all the time.

I found some [code](https://gist.github.com/454424) that shows how to call a constructor with default arguments using reflection. This gave me the idea to write an `ExtendedActivator` class, that similarly to `Activator.CreateInstance` detects automatically the best constructor to call based on parameters passed, but additionally it takes care to recognize optional parameters.

```
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Reflection;

namespace Utils
{
 public static class ExtendedActivator
 {
   public static T CreateInstance<T>(object[] args)
   {
     var t = typeof(T);
     return (T)CreateInstance(t, args);
   }

   public static object CreateInstance(Type t, object[] args)
   {
     if (args == null) args = new object[] { };
     // if any is null, we cannot do default params matching
     if (args.Any(a => a == null))
     {
          return Activator.CreateInstance(t, args);
     }
     var tArgs = (from a in args select a.GetType()).ToArray();
     var ctor = t.GetConstructor(tArgs);
     if (ctor != null)
     {
       return ctor.Invoke(args);
     }

     var ctors = t.GetConstructors();
     foreach (var ci in ctors)
     {
       var pm = ci.GetParameters();
       if (StartsWith(pm, tArgs) && AllDefaults(pm, tArgs.Length))
       {
         var data = new object[pm.Length];
         Array.Copy(args, 0, data, 0, args.Length);
         for (var i = tArgs.Length; i < pm.Length; i++)
         {
           data[i] = pm[i].DefaultValue;
         }
         return ci.Invoke(data);
       }
     }

     throw new InvalidOperationException("Cannot create instance: "
     	+ t.Name);
   }

   private static bool StartsWith(ParameterInfo[] array, Type[] prefix)
   {
     if (array.Length < prefix.Length) return false;
     for (var i = 0; i < prefix.Length; i++)
     {
       if (!array[i].ParameterType.Equals(prefix[i])) return false;
     }
     return true;
   }

   private static bool AllDefaults(ParameterInfo[] p, int startIndex = 0)
   {
     for (var i = startIndex; i < p.Length; i++)
     {
       if (!(p[i].GetCustomAttributes(typeof(OptionalAttribute), false)).Any())
       {
        return false;
       }
     }
     return true;
   }
 }
}
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2012/2012-06-06-Software-to-Install-on-Lubuntu.md'>Software to Install on Lubuntu</a> <a rel='next' id='fnext' href='#blog/2012/2012-06-04-Lubuntu-on-Asus-EeePC-X101.md'>Lubuntu on Asus EeePC X101</a></ins>
