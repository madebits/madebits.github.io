#Vim For The Casual User

2019-03-04

<!--- tags: linux -->

I always wanted to write an own [Vim](https://www.vim.org/) text editor tutorial that I have around and can return to for a quick reference. There is no reason for me to use Vim extensively nowadays, but there are always plenty of chances to use it.

##Starting and Stopping

If you learn Vim, learn it without customizations. In your own machine, you can use some other editor or IDE, or even some heavily [customized](https://github.com/xmementoit/vim-ide) Vim. It is only when you are in some other machine that you really need to use Vim. And this the reason for the first command to learn:

```
# start vim without any customizations (do not load ~/.vimrc)
vim -u NONE
```

Anecdotally, a friend following that advice found once himself once a broken Linux server having only `ed` command available. The advice is still sound, thought the level you need to apply it may vary.

If you panic when starting `vim`, press *Esc* key one more times (so that Vim enters *command-mode*) and then press `:q!`. This will quit Vim without saving your changes. Note that by chance, the reverse `q:` is the *raise panic level* command; it re-shows your panic keys. I will write here commands as `:q!`, which implies entering **command-mode** first by pressing *Esc* key and then pressing `:q!` (where `:` enters the *ex-mode*). If `:q!` does not work then `:qa!` will.

Vim assumes you own the machine and its disk is encrypted, leaving generous usage traces by default. If that is not the case, use `vim -u NONE -i NONE -n` to start Vim in a mode where it does not leak usage information (`-i` means no *.viminfo* file and `-n` means no *swap* temporary file). If you forget any of this, use `vim --help` in shell to get a list of command-line options.

Another occasionally useful command-line option is `vim -R file.txt` to open a file read-only (or `set ro` from within Vim).

##Pre-Basics

If you started Vim without a filename, you can open a file from within Vim using `:edit filename` (or `:e`). *Tab* key can be used for auto-completion.

The fastest way to produce text in Vim is to write it in some other editor and save as some file `text.txt`. Start `vim` and use `:r text.txt` to read it and put its text under the cursor position. File name completion should work after `:r` same as in shell using *Tab* key. This is also the best way to bring some existing pieces of text within a file in Vim (if you have no GUI clipboard).

Move the cursor (in *command-mode*) using `j` - down, `k` - up, `h` - left, `l` - right. *Arrow* keys work most of the time out the box too.

To get help from within Vim use any of `:help`, `:h`, or *F1* key. Help opens in a separate *read-only* text buffer and you can close it using `:q` or `:close`. If you scroll down in help page (or press `/quick`) , you will find a link to *quickref*. Move cursor over and press `Ctrl+]` to open it. You can open it also directly using `: h quickref`. Quick reference contains most commands you will ever use (`:h text` will search help for *text*).

To open shell without having to exit Vim use `:shell` or `:sh`. Run `exit` to return back from shell. If you pressed *Ctrl+z* by mistake while in Vim, use `fg` in shell to get back to Vim. Using `:!sh` or `:!cmd` can be also used to run the shell (or run a command, use `!cmd %` for to replace `%` with current file name if you need it).

There are several ways to save the text:

* `:w somefilename` will save current text buffer in *somefilename*.
* `:saveas somefilename` will save current text buffer in *somefilename* and use it for follow-up saves.
* `:w` will save current text buffer in current file (either open via `vim somefilename`, or set via first `w somefilename`).
* `:wq` save and quit (or `ZZ` or `:x`).
* `w!` force write read-only file.
* `w !sudo tee % > /dev/null` yes, no one remembers this one, but it will force write some file open without `sudo` as `sudo` (basically this means write buffer and pipe it via *sudo* using *tee* to filename).
* As noted before, `:q!` will not save your text and exit (you still have the nice memory of writing it) and `:qa!` will exit even if you have more than buffer.

##Basic Vim

As many have noted, there is no basic Vim. You need to learn upfront enough commands to move around and edit text. In Vim there are two main modes:

* **command-mode** (normal-mode) is reachable by pressing *Esc* key or if that is broken *Ctrl+[*.
* **insert-mode** is reachable from command-mode by initiating some text edit command

Commands are usually are made of multiple key of the [form](https://danielmiessler.com/study/vim/#language): *operator (verb)* *modifier (scope)* *noun (motion)* and can be combined creatively given enough time.

Common movement commands (in *command-mode*):

* `j` - down, `k` - up, `h` left, `l` -right (or arrow keys will mostly work) (can be combined also with numbers, e.g: `4j`); appending `g` in front of `jkhl` will allow moving around display lines (`g` can be used same with `0^$`).
* `0` - beginning of line, `^` first not blank char on line, `$` - end of line, `g_` last non-blank char on line.
* `fc` - *find* next char *c* and move cursor to it, `tc` find next char c and move cursor *to* it. `Fx`, `Tx` work same but jump to previous occurrence of *c*.
    * `;` repeat last `ftFT` forward, `,` repeat last `ftFT` backward, or just use `.`
* `/text` - find *text*. `n` moves to next occurrence, `N` to previous one. Use `set hls` to highlight matches. `?text` is same, but searches backward.
* `*` find next occurrence of work under cursor (`n` and `N` and highlight work same as for `/`).
* `Ctrl+i` - jump to previous location, `Ctrl+o` jump back
* `M` move to middle of screen, `L` move to bottom of screen; `Ctrl+D` - move half-page down, `Ctrl+U` move half-page up; `Ctrl+F` move down a page, `Ctrl+B` move up a page.
* `zz` (not `ZZ`) will center cursor line on screen.  `Ctrl+y` scroll one line down, `Ctrl+e` scroll one line up, while keeping cursor in current line.
* `:number` or `numberG`- go to line number, `:+number` - go number lines down, `:-number` go number lines up. 
    * It may help to run `:set number` (or `:set nu`) before to show line numbers. For extra Zen use `:set rnu` (or `:set relativenumber`) for relative numbers. Using both also works. Using `no` before removes them (e.g. `:set nonumber`).
* `gg` - got top of file, `GG` go end of file.
* `w` move one word forward, `b` move one word backward, `e` move to end of word; `W`, `B`, `E` work same but consider punctuations as part of words.
* `%` move to matching char (`()`, `{}`, `[]`).
* Usually combined with other commands: `)` or `s` move one sentence; `}` or `p` move one paragraph, `t` move one tag; `b` more one code block; all these can get confused in some source code files (in default configuration).
* `gg=G` format whole text, where `=` is [format](https://www.cs.swarthmore.edu/oldhelp/vim/reformatting.html) command. `<` and `>` indent left or right. 

Common edit commands (in *command-mode*):

* `i` insert before cursor, `a` append after cursor.
* `I` insert beginning of line, `A` append at end of line.
* `o` insert in new line after current, `O` insert in new line before current.


* `r` replace char under cursor; `R` or `s` are same as `r` and enter insert mode afterwards.
* `c` change *motion* (using any motion command from above: `c5w`).
* `C` change current line.
* `~` toggle case under cursor. `gu` lowercase `gU` uppercase.
* `J` join current line with next one.


* `y` copy (yank) *motion* (using any motion command from above: `y5w`). (`"*y` to copy to *X11* clipboard, same for paste `"*p`, where `"*` means register `*` the clipboard).
* `yy` copy current line.
* `p` paste (put) text after cursor; `P` paste before cursor. These commands can be combined, e.g.: `ddp` to swap lines.


* `x` delete char under cursor; `X` delete char before cursor.
* `d` delete (cut) *motion* (using any motion command from above: `d5w`).
* `dd` delete (cut) current line.
* `D` delete (cut) to end of line.


* `u` undo; `Ctrl+r` redo
* `.` repeat last action sequence (`number.` repeat last command sequence *number* times)

Edit commands can be combined with **i**nside or **a**round *text-object* bound options:

* `ciw` - change inside word, `caw` - change inside word. Mounded motions include: `w` word, `s` sentence, `p` paragraph, `t` tag, `'` single quote, `"` double quote, and  `(`, `[`, `{` stand per their own.

While in *insert-mode*, `Ctrl+R 0` will paste text without having leave that mode (see `:h i_ctrl-r`). `Ctrl+o` will allow running a single command and coming back to insert-mode. `Ctrl+h` will delete previous char (same as *Backspace*) and `Ctrl+w` will delete previous word, while `Ctrl+u` will delete to start of line. `Ctrl+n` and `Ctrl+p` enable auto-completion from words found in open buffers.

Vim has also a **visual-mode**, entered by any of: `v` char selection, `V` line selection, `Ctrl+V` block selection. Arrow keys expand selection (on whihc side can be toggled with `o`) and `gv` reselects. In visual-mode, you select first the text and then run any command on it.

##Casual Zen

Macros (`:h @`):

* `qa` record macro in register *a* (a-z). Type command here.
* `q` stop recording
* `@a` play back macro in register *a*, `@@` replays last macro, and `number@@` replays last macro *number* times.
* `:registers` will show all registers, include macro ones.
* `"ap` paste register *a* (to edit as needed)
* `0"ay$` copy macro (or `v` to enter visual mode, select, then `"ay`)
* `:help q` for more details

Replacing text (do not bother more that this with substitute command, unless you have no other use for your life, better use macros):

* `:s%/foo/bar/g` replace `foo` with `bar` globally
* `:s/foo/bar/g` replace `foo` with `bar` in current line

Using file explorer:

* `:Explore` or `:E` or `:e.` opens file explorer (`F1` for help within it)
* `Ctrl+6` (`^`) switches back and forth from open file to explorer on same window 

Using tabs:

* `:tabnew` create new tab
* `:tabedit file` open *file* to edit in a new tab
* `:tabclose` close current tab; `:tabclose number` close tab *number*
* `:tabonly` close all other tabs
* `:tabs` list tabs, tabs numbers start from *1*
* `gt`, `gT` go to next, previous tab (or `:tabn`, `:tabp`)
* `numbergt` go to tab *number*

Marking text positions:

* `ma` mark current potion with *a* (`a-z` same file, `A-Z` to mark between open files)
* `'a` move to mark *a*, or `d'a` delete from current potion to mark *a*

Using external commands to filter buffer text:

* `range!cmd` where range is `%`` all text, `.`` current line, `m,n` lines *m,n*

To encrypt current buffer text:

* `%!gpg -ca --compress-algo zip -z 9 --cipher-algo AES256`
* `%!gpg --pinentry-mode loopback --passphrase "password" -ca --compress-algo zip -z 9 --cipher-algo AES256` - same but you can pass password directly

To decrypt current GPG text (`Ctrl+L` to refresh screen):

* `%!gpg -d 2> /dev/null`

##Readings

I found myself last reading [Practical Vim](http://vimcasts.org/publications/) and would recommend it after you are familiar with the basics above.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2019/2019-01-24-Docker-s-Blackhole-Like-Behavior.md'>Docker Blackhole Like Behavior</a></ins>
