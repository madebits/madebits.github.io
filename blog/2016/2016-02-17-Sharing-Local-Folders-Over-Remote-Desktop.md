#Sharing Local Folders Over Remote Desktop

2016-02-17

<!--- tags: windows -->

Remote Desktop Connection application in Windows (`mstsc.exe`) [supports](https://support.microsoft.com/en-us/kb/313292) sharing local drives with the remote machine (via `drivestoredirect` setting in a `.rdp` file). Some RDP clients support sharing also folders, but with `mstsc.exe` only local drives can be shared. Sharing a whole existing local drive is relatively risky. It is preferable to share only a specific local folder.

The solution is to [map](http://superuser.com/questions/644684/mapping-drive-letters-to-local-folders) a local *folder* as a local *drive*, best, by permanently mapping it in Window Registry. In *HKEY_LOCAL_MACHINE \ SYSTEM \ CurrentControlSet \ Control \ Session Manager \ DOS Devices* create a string (REG_SZ) value named with the desired drive name, for example `X:`, and with value pointing to the local folder: `\DosDevices\C:\Folder\Example`. A restart is required for the drive to show up in the Windows Explorer.

We can select to share drive `X:` in Remote Desktop options and this will expose only the `C:\Folder\Example` local folder to the remote machine.

<ins class='nfooter'><a id='fnext' href='#blog/2016/2016-02-12-Using-Autofac-to-Organize-CSharp-Code.md'>Using Autofac to Organize CSharp Code</a></ins>
