#Getting Started with Qt and PySide on Ubuntu

2013-11-14

<!--- tags: linux python qt -->

This tutorial shows how to start programing Qt via its [PySide](http://qt-project.org/wiki/PySideDocumentation) Python binding on Ubuntu. The mentioned steps have been tested in Lubuntu 13.10 with Python 3. There are two Python Qt bindings [PyQt](http://www.riverbankcomputing.com/software/pyqt/intro) and [PySide](http://qt-project.org/wiki/PySideDocumentation). They are mostly compatible with each-other. PySide is newer and with a more permissive license. Qt is complete framework with helper classes which can be used to build both GUI and non GUI applications. PySide exposes most of Qt classes to Python code.

<div id='toc'></div>

##Installing and Testing PySide

To install PySide on Ubuntu use:
```
sudo apt-get install python3-pyside
```

PySide can also be installed via `sudo pip install pyside`, but pip will build PySide locally and you need to install a lot of dependencies first to get it work. `apt-get` method shown above is better to get started quickly, as it installs precompiled binaries, which you can also reference later when you distribute the application. If you want to distribute PySide applications, you need `python3-pyside` as dependency.

To test that pyside works, create a file named `ps-example.py` with this content:
```python
import sys
from PySide import QtGui

app = QtGui.QApplication(sys.argv)
wid = QtGui.QWidget()
wid.show()
sys.exit(app.exec_())
```
Run the created file from command-line via: `python3 ps-example.py`. You should see now an empty Qt window on the screen. This example, creates a `QApplication` passing to it any command-line arguments given, creates a UI widget and shows it. We exit with `app.exec_()` that blocks the application and runs the UI event loop until the QWidget window is closed by user.

##Installing PyCharm IDE

The simple Python examples shown in this tutorial can be typed in using cat, vim, or IDLE as Python editor. There is also a free to use IDE - JetBrain [PyCharm Community Edition](http://www.jetbrains.com/pycharm/download/). PyCharm IDE needs Java to run. Install Java first (if not already installed) by using:
```
sudo apt-get install default-jdk
```
Download JetBrain PyCharm Community Edition for Linux, unzip it, for example to a newly created `~/opt` folder, and then run from its bin folder `./pycharm.sh`. PyCharm will prompt whether to create an menu entry when first started and it is a good idea accept that.

Create a Python project in PyCharm and select for it as interpreter `/usr/bin/python3.3m` (in later Lubuntu versions use `/usr/bin/python`). I found this path using `whereis python3` in command line - it is the first listed path there. You have to use this interpreter path in order to be able to find the globally installed `pyside`. Create a `ps-example.py` file with same content as above. Test that it runs, same as before - now via PyCharm.

##Installing and Using Qt Designer

To get a bit more serious with Qt lets install also the Qt IDE via:
```
sudo apt-get install qtcreator
```
**QtCreator** will be available under Programs menu and it is the Qt C++ IDE. We will not program Qt in C++ here (you can if you want to - it is same as easy as in Python :). We will use the QtCreator IDE to generate Qt user interface (UI) forms.

When you open QtCreator, the welcome page may fail to load, and it will look like broken (you will see the desktop content below it). If this is the case, go to [Tools / Options] menu, and then to the [Help / Documentation] tab select [Add] button, and specify as path `/usr/share/qtcreator/doc/qtcreator.qch` for QtCreator to be able to find documentation. Restart QtCreator after this, and the welcome page should show up property.

In QtCreator choose [File / New File Or Project] menu. Then in [Files and Classes] section, select Qt and [Qt Designer Form] from the available options. Choose [Main Window] from the available Qt Designer Form templates in the next step (selecting a Dialog is also ok). Leave the defaults in all the next steps of the wizard (including the default `mainwindow.ui` name for the file). Take care not adding `mainwindow.ui` to git when asked in the end step of the wizard (in case git is locally installed). The ui files are XML files. They can be conveniently edited via QtCreator Designer.

![](blog/2013/pyside/qtcreator.png)

Add (drag & drop from the tool box) two Line Edit controls from [Input Widget] and name them `lineEdit1` and `lineEdit2`. Add also a Push Button and name it `pushButton` from [Buttons] and save the `*.ui` file. Hint: To name the added widgets as suggested above edit the value of their `objectName` property.

##Using Qt UI Files

Locate the saved `mainwindow.ui` file that we created in qtcreator and copy its contents as a new file under the PyCharm project on same location as `ps-example.py`, preserving its `mainwindow.ui` file name. PyCharm will detect the `*.ui` files, but will not open them. To be able to view `*.ui` files as XML in PyCharm go to [File / Settings] menu and then to File Types section add `*.ui` pattern to the XML file type. Change `ps-example.py` so that it looks as follows:

```python
import sys
from PySide import QtCore, QtGui, QtUiTools

class QtExample:

    def __init__(self):

        loader = QtUiTools.QUiLoader()
        file = QtCore.QFile("mainwindow.ui")
        file.open(QtCore.QFile.ReadOnly)
        #: :type: QtGui.QMainWindow
        self.wid = loader.load(file, None)
        file.close()
        #: :type: QtGui.QPushButton
        button = self.wid.findChild(QtGui.QPushButton,  "pushButton")
        button.clicked.connect(self.showText)
        self.wid.show()

    def showText(self):
        #: :type: QtGui.QLineEdit
        txt1 = self.wid.findChild(QtGui.QLineEdit,  "lineEdit1")
        #: :type: QtGui.QLineEdit
        txt2 = self.wid.findChild(QtGui.QLineEdit,  "lineEdit2")
        try:
            res = str(float(txt1.text()) + float(txt2.text()))
            QtGui.QMessageBox.information(self.wid, 'Sum', res)
        except:
            QtGui.QMessageBox.critical(self.wid, 'Error', str(sys.exc_info()))


def main():
    app = QtGui.QApplication(sys.argv)
    ex = QtExample()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
``` 

When run via PyCharm the program will show a window on the screen where you can enter two numbers and press the Add button to have their sum pop up.

![](blog/2013/pyside/pycharm.png)

The example code creates a python QtExample class and sets up the GUI in the class constructor. It loads the `mainwindow.ui` and creates a widget from it using `QUiLoader`. The code then finds child controls by the names set before in the QtCreator designer and connects the `clicked` event of the button (called a **signal**) to invoke the `showText` event handler method (called a **slot**). It this example, the signal and slot are connected in the code, as this is what is needed more often in real programs. Simple connections of signals and slots can be done also via QtCreator by selecting [Edit Signal / Slots] in the QtCreator Designer, and then click and drag and drop to connect signal to slots of items visible in designer. By default, when used as shown the signal connects are thread-safe, that is, the event handler can update the UI safely from another thread if needed.

##PyCharm Code Auto-completion Hints

There are some strange Python comments containing `:type` in the example code that was shown above. They help PyCharm to know what type the assigned variable is, so that the code auto-completion works. If you load ui elements dynamically, you need to define the type hints manually to help the PyCharm IDE. PyCharm does not know about inheritance, so if you want to use `wid` variable above as a `QtGui.QWidget`, you would have to use:

```python
#: :type: QtGui.QWidget
self.wid = loader.load(file, None)
```
It seems, there is no way to define a variable to be of multiple types at once. Check PyCharm [documentation](http://www.jetbrains.com/pycharm/webhelp/type-hinting-in-pycharm.html) for other ways to help with autocompletion (such as, using `assert isinstance(self.wid, QtGui.QWidget)` in code).

##Generating Static UI Python Classes

The above shown example loaded the `*.ui` file dynamically via QUiLoader as this is more flexible. PySide offers also tools to statically convert a `*.ui` file to a Python class and to either use it directly or to derive from it. To install PySide tools use:
```
sudo apt-get install pyside-tools
```
After installing `pyside-tools`, use `pyside-uic mainwindow.ui -o ui_mainwindow.py` to generate a Python class `Ui_MainWindow` in `ui_mainwindow.py`. The generated `Ui_MainWindow` class contains Python code that is equivalent of the ui xml we created in designer. You can either use ui file as shown above in code, or import `ui_mainwindow.py` file in project and then derive the QtExample class from `Ui_MainWindow` as shown next:

```python
import sys
from PySide import QtCore, QtGui, QtUiTools

import ui_mainwindow

class QtExample(QtGui.QMainWindow, ui_mainwindow.Ui_MainWindow):
    def __init__(self):
        QtGui.QMainWindow.__init__(self)
        self.setupUi(self)

        self.pushButton.clicked.connect(self.showText)

    def showText(self):
        print("called")
        pass

app = QtGui.QApplication(sys.argv)
ex = QtExample()
ex.show()
sys.exit(app.exec_())
```

If interested, explore this alternative further on your own. PyCharm IDE provides better code competition for this case.

##PySide Application Localization

The trivial application we just created above will be so popular that natives from other tribes may want to use it. Lets see how to localize it. First, install some helper tools:
```
sudo apt-get install qttools5-dev-tools
```
We have two kind of strings, those in `mainwindow.ui` and those in the `ps-example.py`. For the `ps-example.py` python code strings to be localized, we have to use a special function called `tr()` that is part of all PySide objects. We will change QtExample to be a `QtCore.QObject` (you will very likely have some `QMainWindow` in a real application), and will change the code to use `self.tr()` for the two strings we have, as shown:
```python
...
    class QtExample(QtCore.QObject):
   
    def __init__(self):
        QtCore.QObject.__init__(self)
        ...
            QtGui.QMessageBox.information(self.wid, self.tr('Sum'), res);
        except:
            QtGui.QMessageBox.critical(self.wid, self.tr('Error'), str(sys.exc_info()));
    ...
```

Then extract the strings to localize from one or files using:

```
pyside-lupdate ps-example.py mainwindow.ui -ts de_DE.ts
```

`pyside-lupdate` expects python files to end in `py` - the rest it treats as ui files. The above command will create a new TS file, that we named `de_DE.ts` to denote that it will be localized file for German language. To translate `de_DE.ts` in German run:
```
linguist de_DE.ts
```
When Qt linguist opens select as Target language German. Click on each string and enter its German translation. Click `?` icon next to string name to change it to an ok check icon in order to tell that it is completed. Then select [File / Release] menu to create a `de_DE.qm` file on the same folder. Alternatively, you can use `lrelease de_DE.ts` when done in command-line to create the `de_DE.qm` file.

![](blog/2013/pyside/linguist.png)

Now change the `main` function in code to:
```python
def main():
    translator = QtCore.QTranslator()
    locale = QtCore.QLocale.system()
    print(locale.name()) #de_DE
    app = QtGui.QApplication(sys.argv)
    if translator.load(locale.name()):
        app.installTranslator(translator)
    ex = QtExample()
    sys.exit(app.exec_())
```

We read the system locale at startup and try to load the file with that name (`.qm` suffix does not need to be specified, but it is ok if you add it too). If the system locale is set as `de_DE` our application will be in German. If not, the default English strings will still show up. To see locales Qt supports for its own strings have a look at `/usr/share/qt5/translations/` folder in your system. PySide supports also having [arguments](http://qt-project.org/forums/viewthread/5928) in code strings, for example: `self.tr("Hello {0}").format("User")`, will combine User to the whole string at `{0}` placeholder.

##Using Qt PySide Resources

Now that we have a working world-ready PySide application, we will make it self-contained using embedded Qt resources. Organize the files in folders for our sample application as shown (create an empty file named `resources.qrc` in same location as `ps-example.py`):
```
./
  ps-example.py
  resources.qrc
  resources/
    forms/
      mainwindow.ui
    translations/
      de_DE.qm
```      
We will manually edit the Qt resource description file `resources.qrc` content to be:

```xml
<!DOCTYPE RCC><RCC version="1.0">
<qresource>
    <file>resources/forms/mainwindow.ui</file>
    <file>resources/translations/de_DE.qm</file>
</qresource>
</RCC>
```
You can also use qtcreator to create the `resources.qrc` file (but you have to create a Qt C++ project there first), or just create a script to iterate thought the resource folders and files and create the XML file as shown. Lets compile the created resource file next using:

```
pyside-rcc -py3 resources.qrc -o resources.py
```

This will create `resources.py` file is the same location as `resources.qrc`. The `resources.py` is a Python file that contains the above resources compressed and embedded binary in the code. We need to `import resources.py` in our application and change the way we read `mainwindow.ui` and the locale file from direct disk paths, to resource `":/*"` ones:

```python
import sys
from PySide import QtCore, QtGui, QtUiTools
import resources

class QtExample(QtCore.QObject):

    def __init__(self):
        QtCore.QObject.__init__(self)
        loader = QtUiTools.QUiLoader()
        file = QtCore.QFile(":/resources/forms/mainwindow.ui")
        file.open(QtCore.QFile.ReadOnly)
        self.wid = loader.load(file, None)
        file.close()
        button = self.wid.findChild(QtGui.QPushButton,  "pushButton");
        button.clicked.connect(self.showText)
        self.wid.show()

    def showText(self):
        txt1 = self.wid.findChild(QtGui.QLineEdit,  "lineEdit1");
        txt2 = self.wid.findChild(QtGui.QLineEdit,  "lineEdit2");
        try:
            res = str(float(txt1.text()) + float(txt2.text()))
            QtGui.QMessageBox.information(self.wid, self.tr('Sum'), res);
        except:
            QtGui.QMessageBox.critical(self.wid, self.tr('Error'), str(sys.exc_info()));

def main():
    translator = QtCore.QTranslator()
    locale = QtCore.QLocale.system()
    print(locale.name()) #de_DE
    app = QtGui.QApplication(sys.argv)
    if translator.load(":/resources/translations/" + locale.name()):
        app.installTranslator(translator)
        print("found")
    ex = QtExample()
    sys.exit(app.exec_())

if __name__ == '__main__':
    main()
```

Now, we only need to distribute `ps-example.py` and `resources.py` files (in same folder) and we can run the application as `python3 ps-example.py`.

##Starting the Application Directly

Lets make `ps-example.py` executable by renaming it first to `ps-example`:

```
mv ps-example.py ps-example
chmod +x ps-example
```
For this to work, edit `ps-example` so that it starts with:
```python
#!/usr/bin/env python3

import sys
...
```

Now we can run `./ps-example` application on its own, without having to specify `python3` in command-line before it.

##Packing a PySide Application As Debian Package

We want to make our `ps-example` application easy for other people to get and install on Ubuntu as a `.deb` package. Lets create a folder called package where we will work and copy there the application files. The rest of commands will be run from within the created package folder.
```
mkdir package
cp ps-example package/
cp resources.py package/
cd package
```
To create a Debian package, we have to create first its folder structure. We will install our example application files in `/opt/psexample_1.0.0` folder in the user system and will have an application shortcut for it in `/usr/share/applications` folder.

```
mkdir -p psexample_1.0.0-1/opt/psexample_1.0.0
cp * -p psexample_1.0.0-1/opt/psexample_1.0.0
# cp: omitting directory ‘psexample_1.0.0-1’ - this error is ok, we want to copy only two files here
mkdir -p psexample_1.0.0-1/usr/share/applications
touch psexample_1.0.0-1/usr/share/applications/psexample.desktop
```

In `psexample_1.0.0-1/usr/share/applications` folder create a simple `psexample.desktop` file with this content:

```
[Desktop Entry]
Name=PsExample
Exec=/opt/psexample_1.0.0/ps-example
Terminal=false
Type=Application
Categories=Application;Utility;
```

Next lets create the additional minimal Debian package structure needed:

```
mkdir psexample_1.0.0-1/DEBIAN
touch psexample_1.0.0-1/DEBIAN/control
```

Edit the `control` text file to be exactly as shown. The empty line in the end is needed. We declared our application dependencies to `python3` and `python3-pyside` packages from the Ubuntu repositories.

```
Package: psexample
Version: 1.0.0
Architecture: all
Maintainer: Vasian 
Section: python
Priority: optional
Depends: python3 (>= 3.3.2), python3-pyside (>= 1.1.2)
Homepage: http://somehomepage
Description: PySide Example
 Simple example.
```

Do not forget to make `root` user own the created files and folders. This is needed for the package deployment to succeed later:

```
sudo chown -R root psexample_1.0.0-1
sudo chgrp -R root psexample_1.0.0-1
```

Finally, create the deb package with:

```
dpkg-deb --build psexample_1.0.0-1
```
A file named `psexample_1.0.0-1.deb` is created in the folder. If you like to make sure the package is ok, install `lintian` and verify the created package (optional):

```
sudo apt-get install lintian
lintian psexample_1.0.0-1.deb
E: psexample: changelog-file-missing-in-native-package
E: psexample: no-copyright-file
E: psexample: dir-or-file-in-opt opt/psexample_1.0.0/
E: psexample: dir-or-file-in-opt opt/psexample_1.0.0/resources.py
E: psexample: dir-or-file-in-opt opt/psexample_1.0.0/ps-example
```

Errors shown here are fully ok for this example.

![](blog/2013/pyside/gdebi.png)

We are now ready to share `psexample_1.0.0-1.deb` with other people (that trust us) and want to install it using either `dpkg -i psexample_1.0.0-1.deb`, or graphically by using `gdebi-gtk`. Once installed, you should see a application entry called PsExample in your system menu that starts the test application. Use `dpkg -r` or `gdebi-gtk` to remove the sample package once happy with the test results. [Download](blog/2013/pyside/psexample_1.0.0-1.deb) the full example.

##What's Next

The next step is to read PySide and Qt documentation and get to know what widgets and framework helper classes are available and build a cool application :).

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-11-25-Changing-SSH-Port-on-Lubuntu.md'>Changing SSH Port on Lubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-11-13-German-Umlauts-on-US-Keyboard-on-Lubuntu.md'>German Umlauts on US Keyboard on Lubuntu</a></ins>
