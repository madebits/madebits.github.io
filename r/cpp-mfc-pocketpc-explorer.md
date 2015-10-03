2005

#Process Explorer for PocketPC and WindowsCE

<!--- tags: cpp wince mfc -->

Process Explorer for PocketPC and WindowsCE is a tool based on *toolhelp.dll* that reports various data about processed running on the device. Process Explorer has been mentioned also in [book](r/cpp-mfc-pocketpc-explorer/book.png). 

![](r/cpp-mfc-pocketpc-explorer/CEZoom2.gif)

When the Process Explorer is started, a list of all running processes is shown. Click the 'Refresh' button to update the list. The following information is reported for each process:
* The icon (if found)
* The process name
* The process id
* The number of threads
* The base address of the process
* The path to the EXE file

Clicking on a process name opens the context menu. The first four items of this menu show further information about the selected process. The last three entries show system wide information.

![](r/cpp-mfc-pocketpc-explorer/CEZoom3.gif)

'Modules' menu lists modules (DLLs) used by the selected process. For each module the following data are reported:

* The module icon (if found)
* The module name
* The base address of the module in the process
* The module local / system wide usage count
* The size in bytes of the module
* The path to the module's file

Click the 'Back' button to go the refreshed process list.

![](r/cpp-mfc-pocketpc-explorer/CEZoom4.gif)

'Memory' menu shows the heap memory map for the selected process. It lists the following data for each block of heap used by the process:

* The address of the heap block
* The size in bytes of the block
* The lock count of the block
* The status of the block
* The total size of heap blocks in bytes is reported after the item count (the number of heap blocks in this case).

![](r/cpp-mfc-pocketpc-explorer/CEZoom5.gif)

'Kill' menu terminates the selected process. Some processes used by the OS core cannot be killed. Given that Windows CE does not protect the system processes, most of the processes can be killed. **Use this feature only if you know what you are doing.** The data could be lost, or corrupted, or the device must be reset if you kill the system processes.

![](r/cpp-mfc-pocketpc-explorer/CEZoom6.gif)

'Windows' menu lists the process ('All Windows' list all system wide top windows) top level application windows. You are offered the option to list only visible windows, or all windows. The following data are reported for each window:

* The icon of the process (if found)
* The title of window (or <?> if none)
* The status of window (visible or hidden)
* The class of the window
* The handle of the window
* The size of the window as width x height in pixels
* The id of the process that owns the window
* The full path to the process
* If you click on a window name, you are offered the option to jump to the corresponding process of this window, in the process list.

![](r/cpp-mfc-pocketpc-explorer/CEZoom7.gif)

'All Threads' menu lists all running system threads. The following data are reported for each thread:

* The icon of the original process that started the thread (if found)
* The name of the original process that started the thread
* The thread ID
* The usage count
* The current process name where the thread is running. A '!' is added before name if this process is different from the original process.
* The thread priority (0-255).

![](r/cpp-mfc-pocketpc-explorer/CEZoom8.gif)

'System Memory' menu reports the total memory usage in the device.

##Troubleshooting

Toolhelp.dll file must be present in the device. It can be found usually in the `\Windows\` system folder in the PPC device. If toolhelp.dll is NOT in the device, please contact the manufacturer of the device, or try to download it from below. Toolhelp.dll from another device may also work well for the same OS version.

If the correct `toolhelp.dll` is in the device and you have still problems, then it could be a bug. A know issue with toolhelp.dll is that in some devices it fails when there is not enough storage. In this case the application will show the error message "Cannot get process information!". This error is likely because of the Windows CE error code 8 - "Not enough storage is available to process this command.". Usually a soft reset, or closing some of the running applications if you have too many running, or adjusting the device memory, may help in this case.

`pe-ce.zip` contains several compiled EXEs for PocketPC-ARMV4 (runs on PC 2003 and PDA with CE4, CE5 - WindowsMobile 2005, CE6), and for WindowsCE-ARMV4I (runs on almost all WindowsCE ARMV4I PNA devices). Older compilations with same functionality are provided for PockecPC.

