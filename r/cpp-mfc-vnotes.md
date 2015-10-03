2003

#VNotes

<!--- tags: cpp mfc -->

VNotes is a program for keeping notes. The notes can be organized as a tree with sub notes, regarding a given topic. For each note, the creation and the last modification date are recorded. An additional comment can be added for each note. Notes can be searched based on title contents. The data can be saved as XML files, with each file containing its own trees of notes.

![VNotes](r/cpp-mfc-vnotes/vnotes.gif)

VNotes is written in Visual C++ 6 (MFC). It uses Microsoft.XMLDOM parser. The data are saved in a custom XML format. The code is very clean. A visitor pattern is used several times to process the tree nodes. An interesting use of the visitor pattern in code is to properly the release the XML COM pointers.