2005

Numeric String Sort in C#
=====

<!--- tags: csharp -->

This is an improved and updated version of a [featured](r/msnet-numeric-sort/cp2008-10-08.png) CodeProject [article](http://www.codeproject.com/cs/algorithms/csnsort.asp).

<div id='toc'></div>

This article explains how to sort strings, such as file names, in the natural numeric order. The .NET `System.IO.Directory` class returns file and directory names ordered in alphabetic order (Win32 API functions for dealing with files order the strings alphabetically), whereas Windows Explorer shows them in natural numeric order. The table below shows the difference between these two orderings:

|Alphabetic sort (DOS)|Natural numeric sort (Windows Explorer) |
|-|-|
|1.txt|1.txt|
|10.txt|3.txt|
|3.txt|10.txt|

In the alphabetic order '3.txt' comes before '10.txt' whereas in the natural numeric order '10.txt' comes after '3.txt', which is what we would expect. Windows Explorer uses the natural numeric order for files. This article shows, how numerical sort can be done in C#.

##Compatibility

Windows implements numerical sort inside a function in `shlwapi.dll`, called `StrCmpLogicalW`. This function is used by Windows Explorer and works only in XP and above.

The implementation given here is not compatible with `StrCmpLogicalW`. It gives the same results as `StrCmpLogicalW` for the numeric sort, with the exception of the strings containing non-alphanumeric ASCII characters.

The code given will order files that start with special characters based on the code table order. Windows Explorer uses another order. For example:

|Windows Explorer|This code|
|-|-|
|(1.txt, [1.txt, _1.txt, =1.txt|(1.txt, =1.txt, [1.txt, _1.txt|

The code given here relies on the current locale to find the order of the characters. Unlike `StrCmpLogicalW`, the code given here works with any .NET version in any version of Windows.

##Usage

The natural numeric order comparer for strings is defined in a class named `ns.StringLogicalComparer : IComparer` and can be found in the source code of this article. Sever examples will be given next how to use `StringLogicalComparer` class in code.

###Example 1 - Ordering an Array of Strings

This example shows how to use the `StringLogicalComparer` class to order strings. Let us suppose, the strings are in a `string[]` array as shown next:

```csharp
string[] files = System.IO.Directory.GetFiles();

Array.Sort(files, ns.StringLogicalComparer.Default);

// files will now sorted in the numeric order
// we can do the same for directories

string[] dirs = System.IO.Directory.GetDirectories();
Array.Sort(dirs, ns.StringLogicalComparer.Default);
```

###Example 2 - Ordering Items in a ListView Control

There are several ways to order elements in a `ListView` control. The example will show only how to order the elements responding to a column head click. To define a generic custom way to order rows of a `ListView` control, when one clicks the `ListView` headers, we need to respond to the `ColumnClick` event and set the `ListViewItemSorter` property of the `ListView` control to a class that implements `IComparer`. The custom `ListComparer` comparer will usually take other arguments in the constructor, e.g. the column header being clicked that will serve as the index for sorting the `ListView` elements, as demonstrated by the code snippet below:

```csharp
private void lstFiles_ColumnClick(object sender,
              System.Windows.Forms.ColumnClickEventArgs e)
{
    ...
    ListComparer lc = new ListComparer(e.Column, ...);
    lstFiles.ListViewItemSorter = lc;
    ...
}
```

Inside the custom `ListComparer`, we will have code to order the `ListView` elements depending on the clicked column header. If we suppose the first column (index 0) contains the strings that need to be ordered in the natural numeric order, then we can use the `StringLogicalComparer` directly inside `ListComparer` as follows (the code is simplified and has no error checking):

```csharp
internal class ListComparer : IComparer
{
    ...

    public int Compare(object x, object y)
    {
        ListViewItem lx = (ListViewItem)x;
        ListViewItem ly = (ListViewItem)y;

        switch(column) // set in the constructor
        {
            case 0: // first column
            int c = ns.StringLogicalComparer.Compare(lx.SubItems[0].Text,
                                                 ly.SubItems[0].Text);
            // take care of the other columns if needed
            // modify c to respond to ascending
            // or descending order, as needed
            ...
            return c;
            ...
        }
    }
}
```

The strings (file names) in the first column of the `ListView` control will now be in the natural numeric order.

###Example 3 - Ordering Dictionary Entries

Sometimes we need to associate a data object with a key string and we may need to order the string keys and then access the data objects ordered by the keys.

If the keys are unique, we can use a `Hashtable` to keep them and the associated data objects. .NET offers the possibility to order the keys of a `Hashtable` and then retrieve the data objects with it:

```csharp
Hashtable hash = new Hashtable();
// fill with data string key, object data
...
hash.Add(key, data); // key must be unique
...

// numeric sort
SortedList list =
  new SortedList(hash,
      ns.StringLogicalComparer.Default);
// now use the sorted list
foreach(DictionaryEntry de in list)
{
    // use de.Key and de.Value
    ...
}
```

A more interesting situation arises when the keys are not unique, that is when we can have different data objects that map to the same key. In this case, we have two choices.

1. We can keep the data objects as `ArrayLists` associated with the string keys in a `Hashtable`. The order of data objects inside the `ArrayLists` does not matter because they have the same key.

2. We can build a simple data structure to keep the key and the value data objects or we can use a `System.Collections.DictionaryEntry` structure. We can now store our data as `DictionaryEntry` elements of an `ArrayList`:

```csharp
ArrayList list = new ArrayList();

// populate the list, possibly from
// some other structure as part of a loop
...
list.Add(new DictionaryEntry(fileName, data));
```

To order the elements in this case, we need also to create a custom (generic) comparer:

```csharp
public class DictionaryEntryComparer : IComparer
{
    private IComparer nc = null;

    public DictionaryEntryComparer(IComparer nc)
    {
        if(nc == null) throw new Exception("null IComparer");
        this.nc = nc;
    }

    public int Compare(object x, object y)
    {
        if((x is DictionaryEntry) && (y is DictionaryEntry))
        {
            return nc.Compare(((DictionaryEntry)x).Key,
                              ((DictionaryEntry)y).Key);
        }
        return -1;
    }
}
```

We can now order the items of list according to the keys, in the natural numeric order, using:

```csharp
list.Sort(new DictionaryEntryComparer(
   ns.StringLogicalComparer.Default));
```

Of course, we can use any other `IComparer` with the `DictionaryEntryComparer` class we created.

###Example 4 - Ordering Full path Files from Different Folders

Example 1 showed how to use the `StringLogicalComparer` class to numerically sort an array of strings. In the Example 1 the array of strings happen to be file names. The example will work fine as long as all the files belong to the same folder and have the same directory path.

When the list of files to be ordered belong to different folders, a new technique is required to group files first based on the folder and then based on the file name for files within a folder. The example code below shows a new class `FullpathComparer`, based on `StringLogicalComparer` that does exactly this. It assumes all file strings are absolute paths. If this is not the case use `System.IO.Path.GetFullPath()` before.

```csharp
using System;
using System.Collections;
using System.IO;

namespace ns
{
  public class FullpathComparer : IComparer
  {
    private static readonly IComparer
      _default = new FullpathComparer();
    private bool alphaSort = false;

    private FullpathComparer()
    { }

    public static IComparer Default
    {
      get { return _default; }
    }

    public bool AlphaSort
    {
      get { return alphaSort; }
      set { alphaSort = value; }
    }

    public int Compare(object x, object y)
    {
      if((x is string) && (y is string))
      {
        string sx = (string)x;
        string sy = (string)y;
        string dx = Path.GetDirectoryName(sx);
        string dy = Path.GetDirectoryName(sy);
        if((dx == null)
          || (dy == null)
          || dx.Equals(string.Empty)
          || dy.Equals(string.Empty))
        {
          return SCompare(sx, sy);
        }
        int r = SCompare(dx, dy);
        if(r != 0) return r;
        dx = Path.GetFileName(sx);
        dy = Path.GetFileName(sy);
        return SCompare(dx, dy);
      }
      return Comparer.Default.Compare(x, y);
    }

    private int SCompare(string sx, string sy)
    {
      if(alphaSort)
      {
        return String.Compare(sx, sy, true);
      }
      return StringLogicalComparer.Compare(sx, sy);
    }
  }//EOC
}
```

###Example 5 - Zeros

Strings that contain numbers with zeros in the front of them are ordered by default in the same way as in Windows Explorer:

```
001
01
1
002
02
2
...
```

Sometimes another logical order may be desired:

```
001
002
01
02
1
2
...
```

To achieve this use `ns.StringLogicalComparer.DefaultZeroesFirst` comparer. For example:

```csharp
Array.Sort(files, ns.StringLogicalComparer.DefaultZeroesFirst);
```

##Implementation

When a list of N items is sorted using quick sort then the Compare function will be called more than N times which means that it would be nice to optimize the implementation if any. There are several ways to order strings in the numeric natural order:

* A simple technique is to use padding with a special character '/'. This character has several nice properties. It is not used in file paths in Windows and its ASCII code is smaller than the one for digits. It can be used to pad the numeric parts of two strings so that they have the same length. Example: a10.txt and a1.txt will become a10.txt and a/1.txt. Then the alphabetical order can be used and a/1.txt will be smaller than a10.txt. Finally the '/' padding needs to be removed. This method works, but has some serious limitations. The '/' can be used only for file paths in Windows. If the strings contain '/', this method will not work. This method requires also too many passes over the string and cannot be implemented with fixed char arrays. The method treats numbers somehow uniformly and is different from the rest so it is interesting per se.

* Two strings to be compared are split into lists with alphabetical and numeric parts, the parts are then compared one by one. One optimization of this technique would be to remember the split in parts (cache it in a `Hashtable`). Numeric parts can be converted to numbers and compared. The number conversions can also be cached.
The implementation is slower than `StrCmpLogicalW` despite the caching (it would be even slower without dynamic programming). The technique is naive for two reasons. First, it does eager evaluation. Splitting of the strings is complete and so is the numeric conversion. When two strings are compared the comparison will be often interrupted before all parts are needed. So the eager evaluation consumes a lot of time. The second problem is that numeric parts are explicitly converted to numbers (`long`). This not only consumes time, it also is an error-prone method because numeric parts that are longer than a `long` number will throw an exception.

* One solution to the problems above is that numeric parts should be compared as special strings not as numbers. Second, using lazy evaluation would also remove the cost of over splitting. The lazy evaluation code for splitting can, however, be complicated.

* Full parsing is rarely needed so we can be optimistic and avoid caching. This is similar to using `StrCmpLogicalW`. The current implementation of `StringLogicalComparer` only parses the two strings at the same time and stops parsing at the moment the result of the comparison in known. The technique is also very fast because it works using fixed-size char arrays. The only look-ahead is to find the end index of the current numerical parts in both strings.

Complete code can be found in file `StringLogicalComparer.cs` in the source code.
