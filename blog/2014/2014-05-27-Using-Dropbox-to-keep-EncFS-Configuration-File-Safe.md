#Using Dropbox to keep EncFS Configuration File Safe

2014-05-27

<!--- tags: linux -->

When using `encfs` with Dropbox encrypted folders we want to keep `.encfs6.xml` file outside of the Dropbox to be safer (due to encfs design issues). This is not convenient as we have to share .encfs6.xml all machines that use Dropbox manually.

We can encrypt .encfs6.xml and place it in a non-encrypted folder within Dropbox. For example, within Dropbox we can have a folder called `Data` without encfs, and a folder called `Protected` with enfs. The `.encfs6.xml` of `Dropbox/Protected` folder we encrypt (outside Dropbox) for example as `edata.bin` and store it in `Dropbox/Data`. I am using my cross-platform [aes](#r/cpp-aes-tool.md) tool to encrypt it (note the space before the command, so that the password is not saved in bash history):

```
$  aes -a -k 256 -p password -e -i .encfs6.xml -o edata.bin
```

Now, we rely on Dropbox to have a safe encrypted copy of `.encfs6.xml` for `Dropbox/Protected` replicated to all client machines. To use it we get it in machine, decrypt it outside Dropbox and specify the decrypted copy via `ENCFS6_CONFIG` to encfs:
```
$  aes -a -k 256 -p password -i data.bin -d -o efile
$ ENCFS6_CONFIG="$HOME/efile" encfs $HOME/Dropbox/Protected/ $HOME/DropboxSafe/
```
If you do not want to keep efile decrypted all time, we can use a named pipe:
```
$ mkfifo efile
$  aes -a -k 256 -p password -i data.bin -d -o efile &
$ ENCFS6_CONFIG="$HOME/efile" encfs $HOME/Dropbox/Protected/ $HOME/DropboxSafe/
```
Once encfs is initialized it read the data from the efile pipe, so the data are no more there. To be really safe we can create the pipe to some tmpfs folder.

You can create a bash script encfsm.sh to handle this:
```
#!/bin/bash

esrc=$1
edst=$2
edata=$3
efile=$4

read -s -p "Enter Password: " mypassword

mkfifo "$efile"
 aes -a -k 256 -p "$mypassword" -i "$edata" -d -o "$efile" &
echo "$mypassword" | ENCFS6_CONFIG="$efile" encfs -S "$esrc" "$edst"
rm "$efile"
```

Here I assume the password of `edata.bin` and encfs folder is same and that it is read by asking the user. You can call the script as shown:
```
$ encfsm.sh $HOME/Dropbox/Protected/ $HOME/DropboxSafe/ $HOME/Dropbox/Data/efile.bin /tmp/efile
```

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2014/2014-05-29-Zenity-GUI-Script-For-TcPlay.md'>Zenity GUI Script For TcPlay</a> <a rel='next' id='fnext' href='#blog/2014/2014-05-22-Changing-Lubuntu-Logout-Window-Message.md'>Changing Lubuntu Logout Window Message</a></ins>
