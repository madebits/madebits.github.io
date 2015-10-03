#Using Git with TFS

2013-01-02

<!--- tags: git -->

I wrote this small guide on using Git with TFS some time ago as a quick reference for myself. I am pasting it here to have a backup copy.

##Minimal Setup

Get Git from http://code.google.com/p/msysgit/downloads/list (get the Git-* packages, not msysGit ones).

Install a three-way merge tool. Example of using Kdiff3 follows. Other alternatives are: diffmerge, p4merge. [Configure](http://davesquared.net/2010/03/easier-way-to-set-up-diff-and-merge.html) Git to use your tool (.gitconfig is found in your windows user folder):

```
[diff]
tool = kdiff3

[merge]
	tool = kdiff3
[difftool]
    prompt = false

[mergetool "kdiff3"]
	path = C:/Program Files/KDiff3/kdiff3.exe
	keepBackup = false
	trustExitCode = false
````

##Extended Setup

Install Git Extensions (Git is included, it will also find it if you have installed it manually before as shown in the minimal install) http://code.google.com/p/gitextensions/. Close Visual Studio while you do this installation.

Install http://gitscc.codeplex.com/, as explained here. In Visual Studio, go to Tools / Options... | Source Control | Plug-In Selection and select as Current source control plug-in: Git Source Control Provider. You can switch back to Tfs | Git as needed using same method.

See also this [accepted answer](http://stackoverflow.com/questions/261525/how-does-visual-studios-source-control-integration-work-with-perforce). VS integration using gitssc slows a bit VS, but if you are fun of doing stuff via gui commands, it could be worth it.

##Install Git-Tfs

Use latest version if possible

* Get Git-Tfs compressed binary package from https://github.com/git-tfs/git-tfs.
* Unzip to a folder and add this folder your system %PATH% (for current user is enough). (The default folder has the version number, which can be removed if wished.)
* Verify that Git has recognized Git-Tfs, in Git bash type:
```
git tfs
```
You should see some help being printed.

There is also an alternate way of installing Git-Tfs mentioned in their web site.

##Create Git-Tfs Repository

`cd` to a folder of choice, run in Git bash:
```
git tfs quick-clone http://tfs.ert.com:8080/tfs/src/ $/MyProject/Server/v1.x/v1.0.x/Dev myserverdev
```
You can omit the name, to use the Dev as name. You can create a repository for any sub-folder of interest separately, or for the whole root `$/MyProject/`

Using `git tfs clone` is same, but will get the TFS history to your Git repository, and depending on Tfs branch, this may need one day or more to complete. Normally, that history is not needed.

Verify that there is folder `.git` in your new created local repository.

##Working Unconnected to Tfs

You can directly work in your newly created Git repository. Open the solution project in Visual Studio. Visual Studio will show two complain dialogs. The first one says "The solution appears to be under source control, but its binding information cannot be found. ...". Press OK to continue. The second one (bring it to front) says: "Source Control - Unable to Access Database". Accept the defaults (Temporary work uncontrolled), and press OK again. This two OK clicks (Enter) are the only inconvenience when opening the project.

There is a Visual Studio extension [GoOffline](http://visualstudiogallery.msdn.microsoft.com/425f09d8-d070-4ab1-84c1-68fa326190f4?SRC=Home) that could be of help. Use it before opening the project.

While tempting, do NOT remove TFS information from your Visual Studio project files. It actually possible to change VS project use Git bindings, by using a separate git working branch. If you do that, make sure to NEVER check source control binding changes of Visual Studio projects in TFS. VS stores the source control bindings in all project files of a solution.

##Ignoring Visual Studio Specific Files

Do a build of TFS code to make sure everything is ok. Use git status after the build to see what files / folders you have to ignore.

Do not create a local `.gitignore` file, as it will be added to the repository and will end up in TFS. Use the `.gitinfoexclude` file instead. See Git help for more details. If you are using Git Extensions, it can fill `.gitingore` automatically for Visual Studio, copy it to `.gitinfoexclude` or global `.gitignore` (and remove local `.gitignore` file).

##Using Git-Tfs

Restrict yourself to a minimum of Git-Tfs interaction. The Tfs is not a remote Git repository. Git-Tfs makes it easy to get / send changes to Tfs, but the remote is not a Git repository and cannot behave as such. The git branch used to do tfs pull / push should be clean and it needs a working tree.

To get latest commits from TFS use `git tfs pull`. It works only if there no pending changes in git branch. If automatic merge fails, use `git tfs fetch` and then `git merge`. To send changes in Tfs use `git tfs ct` (see below) - it will squash all your git branch merges.

In case or errors, use `-d` after `git tfs` commands to get verbose information.

##Minimal Git-Tfs WorkFlow

You can work directly under the Git-Tfs master branch.
```
git tfs pull
...
git commit -am "some work"
...
git tfs pull
# if pull gives merge errors use:
# git tfs fetch
# git merge
git tfs ct -w 44180 --build-default-comment
```

`git tfs ct` opens the Tfs gui checkin tool. `-w` and `--build-default-comment `are optional. `-w` associates the change list with work item 44180 (example id), and `--build-default-comment` generates the Tfs checkin comment from (last) `git commit` comment.

Do **not** uncheck any files in the Tfs gui checkin tool (local changes to them will be lost).

Other possible ways to checkin to Tfs are: (a) `git tfs checkin` - which is same as above, but shows no Tfs gui. Normally getting to see Tfs gui is more useful that checkin; (b) use `git tfs rcheckin` - this preserves the individual Git commits, but it is also more prone to error, and has some problematic use cases (see Git-Tfs wiki for more info).

##Normal Git-Tfs Workflow

Not much to say here:
```
git tfs pull
git checkout -b worktodo
...
git commit -am "work"
...
git checkout master
git tfs pull
git checkout worktodo
git merge master
# or use: git rebase master
...
git tfs ct -w 44180 --build-default-comment
git checkout master
git branch -d worktodo
```
See also: http://lostechies.com/jimmybogard/2011/09/20/git-workflows-with-git-tfs/

You can use many git branches, with different state. The branch used to invoke `git tfs ct`, usually the `master` branch (it can also be another one if master is messed up), should be clean.

##Sharing Git-Tfs Repositories

A Git-Tfs repository cannot be a `bare` repository as Git-Tfs needs to do merges. This being said, it is possible to have a variety of git and git-tfs repository configurations (may be more on this another time).

If git-tfs repository is cloned (git clone, or manual copy) and want it to serve also as a git-tfs repository, run `git tfs bootstrap`.


<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-03-01-DNS-Caching-and-VPN.md'>DNS Caching and VPN</a> <a id='fnext' href='#blog/2012/2012-11-01-Back-to-Classic-Desktop.md'>Back to Classic Desktop</a></ins>
