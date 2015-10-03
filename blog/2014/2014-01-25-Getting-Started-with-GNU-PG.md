#Getting Started with GNU PG (gpg)

2014-01-25

<!--- tags: linux encryption -->

GNU PG ([gpg](http://www.gnupg.org/gph/en/manual.html)) is a free cross-platform program to protect access to digital content via encryption. Gpg can be used to encrypt your own data, or to safely exchange data with parties you know.

Gpg does two main things:

* Manages a local key database (key access is protected with a password, key listing not)
* Uses the local key database to encrypt (protect) and decrypt (unprotect) documents

Gpg keeps the keys information (the local key database and its configuration) in a folder named `.gnupg` in your home directory. Backup this folder every time you do manage (change) gpg keys you use. If `.gnupg` folder does not exist, you have to create it manually.

Managing Keys

Generating your own key:
```
gpg --gen-key
```
You will be asked a series of questions:

* Key type use: RSA and RSA
* Keysize use at least: 4096
* Real name: this does not need to your real name, but it should be a name people you plan to exchange files with know you of
* Email address: this does not need to be a real email address, but it should be something unique, so people you plan to exchange files with can identify you

This command generates a private and public key pair for own use. You will be asked for a pass-phrase (password) to protect the key. You have to re-enter this pass-phrase every time you want to use this key (its private part).

To view your public keys use:
```
gpg --list-keys
```
Example output:
```
pub   4096R/FA1320B6 2014-01-25
uid                  SomeName <someone@noemail.none>
```
`uid` of the key is the name and email address you specified. Any unique sub-part of `uid` text can be used to identify a key locally in the rest of gpg commands. Alternatively the key can identified by its number `FA1320B6` in the command. I will refer to this as **keyid** in the examples here. So every time you see keyid in examples below, it means you can either use `FA1320B6`, or any unique sub-part of `uid` text, such as, `SomeName` or `someone@noemail`.

To view your private keys use:
```
gpg --list-secret-keys
```
To view your public keys and their identifying finger prints use:
```
gpg --fingerprint
```
A key fingerprint may looks as follows and it is used to uniquely identify a key globally (in all world):
```
Key fingerprint = DA9F 920A E9C7 C59A AD07  93EF A4FF 4096 FA13 20B6
```
To identify a key locally for use with `gpg` commands you can use the **keyid** described above. To identify a key globally, for example, that it is really the key you got from someone, you have to use the **fingerprint**.

You can export a key (the public part of it) from you local gpg key database to some file `somekey.txt` using:
```
gpg --export --armor keyid > somekey.txt
```
This exports the public part of the key which you can share with others publicly (you can publish your public key in your web site, in a public pgp key server, or in your email signature), in case you want other people send to you protected stuff that only you can read. You can have of course more than one private/public key pair in use for different groups of people (and generate new ones as needed for each discussion topic).

To import a public key from someone else use:
```
gpg --import somekey.txt
```
Once you import a key it must be verified before you use it:
```
gpg --edit-key keyid
>fpr
>lsign
>check
>save
>quit
```
To verify a key fingerprint (shown by `fpr` command above) either meet in person with the one the key belongs, or call the person on the phone, speak a bit to make sure she is ok, and then read aloud the fingerprint to her so that she can look up her own one and verify they match. Never use a key from someone else whose fingerprint is not verified using another communication channel type.

Gpg support local sign (`lsign`) of keys or global sign (`sign`). Normally using `lsign` is preferred, as global signing makes your key revel your social connections (web of trust).

Sometimes you may want to export and import your private key across different machines you use. For this you can use similar to above: `gpg --export-secret-key --armor keyid > private.key` (the exported key is still protected with the passphrase) and `gpg --allow-secret-key-import --import private.key` (after you import a private key, use `gpg --edit-key keyid` as above with `trust` command to trust it).

To delete a public key use `gpg --delete-key keyid` and to delete a private key use `gpg --delete-secret-key keyid`.

To change the passphrase (password) used to protect a private key use:
```
gpg --edit-key
>passwd
>save
>quit
```
##Encrypting and Decrypting

When you encrypt data, you need to specify which people (keyid) can decrypt them repeating `-r` option as needed (`-r` is a shortcut for `--recipient`). Add you own `-r keyid` to the list if you want also to decrypt the data on your own:
```
gpg --encrypt --sign --armor -r keyid -r yourkeyid somefile
```
This creates the encrypted `somefile.asc` text file. Use `--output filename` before other options to use a different output file name; `-o` is a shortcut for `--output`. To remove the original file safely in linux use `shred` command.

If you have more than one own key, you can use append `-u keyid` to the above command, to let gpg know which of your own keys to use (to sign the file). If you do not want to sign the file remove `--sign` option, but then the recipients cannot tell for sure from whom the file comes.

Gpg by default uses no compression, you can turn it on either per key using (`--edit-key` and `setpref` command, see the gpg manual), or on case by case, using (use `gpg --version` for a list of compression algorithm options):
```
gpg --compress-algo zip -z 9 --encrypt --sign --armor -r keyid -r yourkeyid somefile
```
If you omit the `--armor` option, then the encrypted file is named `somefile.gpg` and is no more text, but binary (smaller, but not visible in a text editor) (use `--output` filename before other options to use a different output file name). The `--armor` encrypted text is useful when you want to paste the encrypted data as text in an email body.

A shortcut for `--encrypt --sign --armor` is `-e -s -a` or `-esa` (omit `-a` for binary output).

To decrypt data use (the file name and suffix do not matter, you can rename files as you like):
```
gpg somefile.asc
```
This creates a new decrypted file named `somefile` (use `--output filename` before other options to use a different output file name). You can decrypt a file only if your key was specified with `-r` option when file was encrypted.

You can also read text from stdin and encrypt to stdout without using a file as follows:
```
gpg -esa -r keyid
```
Press on a new line `Ctrl+D` (unix) or `Ctrl+Z Enter` (Windows) when done.

This is best combined with copying output to clipboard (in Windows use `| clip`), the example here works for Lubuntu:
```
gpg -esa -r keyid | xclip -i -selection clipboard
```
In same way, you can decrypt stdin data to stdout, using only gpg (and paste the data - if using a GUI terminal).

##Grouping Encryption Recipients

To group several recipients (`-r` option) to an alias edit `.gnupg/gpg.conf` file and add one or more groups (one line per group):
```
group friends=keyid1 keyid2 keyid3
```
Now when using `gpg -esa -r friends`, it is same as explicitly listing with `-r` the three keyids above.

##Symmetric Encryption

Gpg public encryption is best suited to encrypt data you want to share with others initially. If you just want to encrypt data for your own (of after you have exchanged a secret key using public encryption), gpg supports also symmetric encryption mode that does not need any key management. For example, to encrypt a file called `somefile` using a password you can use:
```
gpg --compress-algo zip -z 9 -c --cipher-algo AES256 -a somefile
```
You will be asked for the password to use. Use `--output` filename before other options to use a different output file name.

Decryption is same as on private/public key case using: `gpg somefile.acs`

##Signing Documents

To sign a file named somefile use:
```
gpg --armor --detach-sig somefile
```
This creates `somefile.asc` file with the `somefile` signature. Use `--output` filename before other options to use a different output file name.

To verify a signature (that the document is not modified since signed) use:
```
gpg --verify somefile.asc somefile
```
##Using Gpg with Vim

First, make sure `vim` leaks no data, using `set viminfo=` and `set noswapfile`.

While there are some Vim plugins for this, you can use `gpg` directly from `vim` as follows:

* To encrypt current buffer: `:% ! gpg -esa -r keyid 2> /dev/null`
* To decrypt current buffer: `:% ! gpg 2> /dev/null`

You may need to use `Ctrl+L` after you run these commands to refresh the `vim` screen.

`%` in commands above is the whole buffer text. You can replace it with any sub-range, e.g., `2,10` to only process text between (including) lines 2 and 10.

`2> /dev/null` skips the stderr data. If you remove those, to see any issues, then you have to delete the boilerplate stderr message lines of gpg on your own in vim.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2014/2014-01-26-Shutdown-Ubuntu-Every-Night.md'>Shutdown Ubuntu Every Night</a> <a rel='next' id='fnext' href='#blog/2014/2014-01-06-xdg-open-Failing-on-Folders-on-Lubuntu.md'>xdg open Failing on Folders on Lubuntu</a></ins>
