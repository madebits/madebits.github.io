2004

#Same File Created Watcher for .NET

<!--- tags: csharp -->

Being able to observe the file system events in real-time sounds great, but there is few that can be done with it apart of logging the events, or alerting if something of interest happens. Almost every such tool around only list the events, or at most filters them. The program shown here goes a step further. It tries to use the file system events in real-time to figure out (at almost real-time) whether a new file created into a directory is the same as an existing file. If so the program logs a warning, and optionally tried to move the repeated file to a quarantine sub-folder.

The reason why almost no other program uses the file system events to do something useful is not because the programmers are that lazy, but because it is very difficult, and sometimes impossible, to predict what is exactly happening based only on these events. The tool shown here tries its best to guess what is happening. As this is a prototype, the user interface lacks sophistication, but it is still complete.

Same File Watcher watches a directory for changes and finds the files that are the same (same SHA1 hash). When such a similar file is created the program can do several things:

* its name could be logged,
* the user could be notified with a pop up dialog
* it could be moved to a subdir (_DSWRCOPY).

![](r/msnet-samefile-watcher/filesystemwatcher.gif)

When a directory is watched an index of its files is build first. You can export the index and import it latter. This enables watching a directory without building its file index again as it can be imported it at any time. You can import also indices of unrelated directories. To the FileWatcher it will look like these files (virtual entries) are in the directory being watched. This way you can also monitor for files that are not currently on the hard drive. The index menu operations are valid only after you start watching a directory.

File index of a directory is kept non-optimized in memory. It consumes as much as ~0.6Kb (virtual entry) to ~1Kb (real entry) for every file. As a consequence, for directories with many entries you can run out of memory in some old systems. Zero length files are not included in the watch events, but they are part of the index.

File system events are captured as soon as they arrive. They are processed latter in the order they arrive (they cannot be processed in parallel). This means that if a file create event and a delete event were both received, then it may happen that the file create is processed, when the file may have been already deleted. In this case, an error message 'file cannot be found' will be logged. These error messages can be usually ignored.

In the case of directory changes, directories are re-indexed. This may take some time for big directories.

Screen logging is limited in length (10Mb). Log to file (dswlog.txt in dsw.exe dir) if you want to preserve all logs. Logs are appended to the log file so its length can grow large.