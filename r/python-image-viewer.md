2012

#Python Image Viewer

<!--- tags: python -->

Simple image viewer in Python with Tk/Tcl based GUI. Runs on Linux and Windows. Tested with Python 2.7 and 3.3.

By design, this image viewer can only zoom fit images or show them at original size (100%). Other than that, this is a fully featured light-weight fast image viewer, may be better that what you use right now :). I used it for some time as default image viewer in Lubuntu.

![](r/python-image-viewer/miv.png)

The program runs full-screen by default. Use `Escape` key to quit it. Press `h` key for help on supported commands.

##Main features:

* Shows all images in a folder
* Navigate next / previous (using keyboard, or mouse wheel)
* Switch zoom fit / 100%, drag to pan (or (Shift) mouse wheel to pan)
* Rotate image, delete file
* Auto slide show
* Run user defined commands on current file
* Gray filter

##Requirements

* Python (with IDLE) to get Tk/Tcl
* Python Imaging Library

On Windows:

* Install Python (with IDLE) to get Tk/Tcl ([Python 3.3](http://www.python.org/getit/releases/3.3.0/))
* Install Python Imaging Library ([PIL](http://www.pythonware.com/products/pil/))

On Linux:

Normally installing the following packages first will do (tested on Ubuntu 12.04 and 12.10):
```
sudo apt-get install python-tk python-imaging python-imaging-tk
```

This will try to get PIL via `python-imaging` package. If that does not work (you get jpeg decoder errors), build PIL on your own - I had to do this on Lubuntu 12.04 as the above did not work:

```
pip uninstall PIL
sudo apt-get install libjpeg8-dev
pip install PIL
```

Make `miv.pyw` executable, and create a `miv.desktop` file shortcut for it in your applications (replace user with your user name), I modified the following from a copy of eog.desktop:
```
[Desktop Entry]
Name=Miv
Icon=eog
GenericName=Miv
Exec=/home/user/bin/miv.pyw -c /home/user/bin/miv.txt %U
Terminal=false
Type=Application
Categories=GNOME;GTK;Graphics;Viewer;
```
`miv.txt` file does not need to exist, you can add it later if you need to run custom commands.



