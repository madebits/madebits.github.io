#Versioning Home Configuration Files with Git and DropBox

2014-03-22

<!--- tags: linux git -->

There are several ways to version configuration files under home directory. This tutorial describes using git with DropBox. We can have a normal local git repository in DropBox and then rely on the DropBox client to synchronize the files across machines (so we do not need to use a central a bare git remote). I have the DropBox client synchronized in `~/DropBox` folder.

##Setting Up Git on Lubuntu

To install and [configure](http://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration) `git` source control software I used:

```
sudo apt-get install git gitk git-gui
sudo apt-get install kdiff3-qt

git config --global user.name "user"
git config --global user.email "user@example.com"
git config --global color.ui auto
git config --global diff.tool kdiff3
git config --global difftool.kdiff3.cmd '/usr/bin/kdiff3 "$LOCAL" "$REMOTE"'
git config --global difftool.kdiff3.trustExitCode false
git config --global difftool.prompt false
git config --global merge.tool kdiff3
git config --global mergetool.kdiff3.cmd '/usr/bin/kdiff3 "$BASE" "$LOCAL" "$REMOTE" -o "$MERGED"'
git config --global mergetool.kdiff3.trustExitCode false
git config --global mergetool.keepBackup false
git config --global mergetool.prompt false
```

These commands install a minimal usable git and git gui setup along with a gui diff tool (kdiff3). You can replace user with your user name, or leave it generic as shown. The user name and email do not need to real. A hidden file `~/.gifconfig` contains the global git configuration settings. You should not delete it. The diff and merge tool config there should look as follows:

```nohl
[merge]
	tool = kdiff3
[mergetool "kdiff3"]
	cmd = /usr/bin/kdiff3 \"$BASE\" \"$LOCAL\" \"$REMOTE\" -o \"$MERGED\"
	trustExitCode = false
[diff]
	tool = kdiff3
[difftool "kdiff3"]
	cmd = /usr/bin/kdiff3 \"$LOCAL\" \"$REMOTE\"
	trustExitCode = false
[mergetool]
	keepBackup = false
	prompt = false
[difftool]
	prompt = false
```

Additionally, adding this alias (use as git vlog), provides a better formatted change log summary:

```
git config --global alias.vlog 'log --graph --pretty=format:"%h%x09%an%x09%ad%x09%s" --date=short'
```

##Creating the Repository

There is more than one [way](https://www.digitalocean.com/community/articles/how-to-use-git-to-manage-your-user-configuration-files-on-a-linux-vps) to set up a git repository for the home folder. I do not like to use symbolic links, so I decided to have the git repository in my DropBox folder, but move the repository working tree root to my home folder.
```
mkdir -p ~/DropBox/git/home
cd ~/DropBox/git/home
git init --shared=everybody
git config core.worktree "../../../../"
```

The last command moves the working tree root of the repository. You can use either a relative, or an absolute path. The relative path is better if you want to share the repository via DropBox between different machines (assuming you have same `~/DropBox` folder on every machine). `../../../../` relative path is from within `.git` folder in the repository.

Now the repository knows where the root is, but we have to configure also the root in the home folder:

```
cd ~
echo "gitdir: $HOME/DropBox/git/home/.git" > .git
```

This creates a hidden `~/.git` file in `$HOME` folder that tells `git` where to find the repository.

Git tracks every files by default, but this is not what I want for the home folder, so I configured the reverse to be the default, so that git ignores all files, by using:
```
cd ~
echo "*" > .gitignore
```

If I use `git status`, I do not see any non tracked files. To explicitly track the files and folders I need use `-f` option from `$HOME` folder:

```
cd ~
git add -f .vimrc
git add -f .vim/
git add -f .bash_aliases
git add -f .tmux.conf
git add -f .gnupg/
# and so on, add all files and folders you want to track and commit those, best is you have an encrypted DropBox folder
```

We have now a `git` repository on home folder that only tracks files and folders we want and ignores the rest. Because the repository is in the DropBox folder is it synchronized automatically across machines. We just need to create the `.git` and `.gitignore` files on each other machine.

**Update:** I found a slight [alternative](https://news.ycombinator.com/item?id=11070797) based on same idea. Instead of using git config `core.worktree` to specify the working directly an alias is used, and instead of using gitignore with '*', `status.showUntrackedFiles` is used:

```
git init --bare $HOME/.myconf --shared=everybody
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
config config status.showUntrackedFiles no

# usage
config status
config add .vimrc
config commit -m "Add vimrc"
config push
```

The problem here is where to store the `alias`. The alternative with relative paths in `core.worktree` better for that.

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-03-26-Chrome-Browser-PDF-Viewer-Jump-to-Page.md'>Chrome Browser PDF Viewer Jump to Page</a> <a id='fnext' href='#blog/2014/2014-03-17-Custom-PcManFM-Context-Menu-Actions.md'>Custom PcManFM Context Menu Actions</a></ins>
