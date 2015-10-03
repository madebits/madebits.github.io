#Encrypting Git Home Folder on Windows

2015-06-09

<!--- tags: git encryption -->

Bash shell that comes with Git (and several Linux originated tools) on Microsoft Windows uses the Windows `%HOME%` environment variable if set. Windows itself does not use use `%HOME%`, but `%HOMEDIR%`. We can use this fact to move the home of Git bash tools outside the Windows user `%HOMEDIR%`. We can also add the Encrypted File System (EFS) attribute to `%HOME%` folder so that the files there are readable only by the current logged Windows user. `HOME` can be set as a per user variable in Windows Environment variable settings.

Having a separate home folder for Git (and other tools) which is also EFS protected is useful because we can store Git user credentials in 'plain' text (they will be EFS protected), removing the need to use any special tools for that on Windows.

```
git config --global credential.helper store
```

That changes `.gitconfig` to contain:

```
[credential]
    helper = store
```

Now Git will keep the credentials in `.git-credentials` file in the `%HOME%` folder (`echo $HOME`). They are conveniently stored as plain text for the current user and as encrypted files for the rest. In the same way, the EFS protected `%HOME%` protects your `.bash_history`, vim, and other configuration files.

<ins class='nfooter'><a id='fprev' href='#blog/2015/2015-06-19-Csharp-Simple-Encryption.md'>Csharp Simple Encryption</a> <a id='fnext' href='#blog/2015/2015-06-03-Naive-Bayes-in-R.md'>Naive Bayes in R</a></ins>
