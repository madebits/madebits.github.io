2011

ColorMatrix Image Hue Saturation Contrast Brightness in C# .NET GDI+
=============

<!--- tags: csharp gdi -->

This is a port in C# from C++ of [QColorMatrix](http://www.codeguru.com/Cpp/G-M/gdi/gdi/article.php/c3667).

.NET GDI+ enables using a `ColorMatrix` to modify image colors via `ImageAttributes` as shown next:

```csharp
ImageAttributes imageAttr = new ImageAttributes();
ColorMatrix m = new ColorMatrix();
m.Matrix00 = -1;
imageAttr.SetColorMatrix(m);
using (Graphics g = Graphics.FromImage(b))
{
 Rectangle r = new Rectangle(0, 0, b.Width, b.Height);
 g.DrawImage(bmp, r, 0, 0, bmp.Width, bmp.Height, GraphicsUnit.Pixel, imageAttr);
}
```

The main motivation for the `QColorMatrix` port was to be able to easy modify image hue in C# via `ColorMatrix`. I am not sure how correct the `QColorMatrix` hue modification is, but it somehow works. So if you want to change image hue, saturation, brightness, contrast, rotate / shear / translate colors etc, in C# for GDI+, this `QColorMatrix` port has the code ready.

![](r/msnet-colormatrix-hue-saturation/colormatrix.jpg)

In .NET, the `ColorMatrix` class is **sealed** and cannot be inherited, so I offer methods to convert back and forth from a `ColorMatrix` to `QColorMatrix` as needed. You can freely mix the two (start with any them and convert to the other). To use `QColorMatrix` instead of `ColorMatrix` in the example above, call `ToColorMatrix()` method.

This is **not** a one-to-one port of the original `QColorMatrix` C++ code. I took the freedom to make minor changes and fixed for C# a bug in color translation (it only showed if you wanted to use weight). The credit for the `QColorMatrix` goes to the original author Sjaak Priester. My credit is only the C# port and the small C# demo.

You can use the `ColorMatrix` without needing to understand what it does, and the above GDI+ code with `ImageAttributes` makes it look kind of magic. To remove a bit of the magic, I provide a very slow alternative code in the C# demo for demonstration purposes:

```csharp
Img.QColorMatrix qm = new Img.QColorMatrix();
qm.RotateHue(45);
for (int i = 0; i < b.Width; i++)
{
 for (int j = 0; j < b.Height; j++)
 {
  Color c = b.GetPixel(i, j);
  c = Img.QColorMatrix.Vector2Color(
   qm.TransformVector(Img.QColorMatrix.Color2Vector(c), true));
  b.SetPixel(i, j, c);
 }
}
```

This code is more or less same as what the GDI+ does internally when calling `Graphics.DrawImage` with `ImageAttributes`. It is slow, but it demonstrates the `ColorMatrix` logic and it works same.

The source contains also a modified version of the `QColorMatrix` C++ code. I cleaned it up from GDI+ and Win32 API code, so it could be used also in other platforms.