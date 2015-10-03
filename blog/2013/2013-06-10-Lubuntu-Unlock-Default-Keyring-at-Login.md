#Lubuntu Unlock Default Keyring at Login

2013-06-10

<!--- tags: linux -->

Lubuntu makes use of GNOME keyring manager to save various program password keys. Somehow the keyring was not unlocked at start up, and I was starting to get used to that, until I stumbled upon [Bug #1034108](https://bugs.launchpad.net/ubuntu/+source/gnome-keyring/+bug/1034108) today.

There is an entry there from last year (from tm-o) that shows how to fix it, by installing first:
```
sudo apt-get install libpam-gnome-keyring
```
Then at the next system login when the keyring unlock dialog is shown next time, it contains an additional checkbox to automatically unlock it at login. Login keyring is then unlocked automatically at login, and it contains the password for the Default keyring (these can be seen installing `seahorse`).

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-06-22-Changing-DNS-Servers-in-Lubuntu.md'>Changing DNS Servers in Lubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-05-25-Liberty-Manipulation-in-Gimp.md'>Liberty Manipulation in Gimp</a></ins>
