#Bash Cycle Through Autocomplete Options

2014-01-30

<!--- tags: linux -->

Bash default behavior for auto-complete on `Tab` key is nice, but it forces you to think what key to press next, even when there few choices to go through.

To address this, I followed first the [advice](http://superuser.com/questions/59175/is-there-a-way-to-make-bash-more-tab-friendly) to make `Tab` key cycle thought the options (similar to `cmd.exe`), by adding to `~/.bashrc` the following line:

```
[[ $- = *i* ]] && bind TAB:menu-complete
```
This seems to work ok, but then I saw another [post](http://superuser.com/questions/418718/bash-tab-autocomplete-feature) that suggest keeping the default behavior same, and instead creating a `~/.inputrc` file with this content:

```
# cycle forward
Control-k: menu-complete
# cycle backward
Control-j: menu-complete-backward

# display one column with Tab matches
set completion-display-width 1
```

The last line modifies how `Tab` key options are listed.

I find this second option better, as Tab behaves as before, and `Ctrl-j` and `Ctrl-k` are easy to remember as related to `vim` `j` and `k` keys.

**Update**: This works fine, but it breaks [SublimeREPL](https://github.com/wuub/SublimeREPL) for some reason (similar to [this bug](https://github.com/wuub/SublimeREPL/issues/322), but affects all REPL processes that use GNU readline). I have to choose between this or [SublimeREPL](https://github.com/wuub/SublimeREPL).

<ins class='nfooter'><a id='fprev' href='#blog/2014/2014-02-04-Using-i3wm-on-Lubuntu.md'>Using i3wm on Lubuntu</a> <a id='fnext' href='#blog/2014/2014-01-26-Shutdown-Ubuntu-Every-Night.md'>Shutdown Ubuntu Every Night</a></ins>
