#Encrypting Internet Explorer Temporary Files Folder

2010-09-20

<!--- tags: browser encryption -->

Windows Encrypted File System (**EFS**) offers some degree of protection by encrypting file contents with a key derived from  current user logging password. EFS can be used among other to encrypt temporary files folder where Windows and Internet Explorer keep temporary history data. While not very secure (better is not to write data in hard-disk), this method gives some privacy against casual people that may want to view files without knowing current user password.

Window does not allow directly encrypting *Temporary Internet Files* folder with EFS. A workaround is to create first a folder somewhere in hard-disk and apply EFS attribute to it (Properties / Advanced / Encrypt contents to secure data). Then open Internet Explorer options and move Temporary Internet Files folder to the newly created EFS folder. Log out and log in again and from now on Temporary Internet Files will be encrypted.

![](blog/2010/nav/ietemp.png)

There are some drawbacks to encrypting Temporary Internet Files folder with EFS. All downloaded files will have EFS attribute set. Internet Explorer downloads files first in Temporary Internet Files, and copies them when done to destination folder where user expects it. This can be sometimes annoying.

Several other system folders such as recent files etc, can be encrypted either directly with EFS, or by using the method above. Normal Windows Temp(orary) folder must not be encrypted with EFS, because Windows may fail to start as some (installation) programs write files in there to be executed during system start-up, while user is not yet logged, which causes an error. As a rule of thumb, do not apply EFS to system wide folders and files used by Windows (such as Windows folder).
<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2010/2010-10-10-CSharp-ListView-VirtualMode-Selection.md'>CSharp ListView VirtualMode Selection</a> </ins>
