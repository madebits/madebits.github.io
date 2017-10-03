# Vim For The Casual User

2019-03-04

<!--- tags: linux -->

I wanted to write an own [Vim](https://www.vim.org/) text editor tutorial that I have around for a quick reference.

## Starting and Stopping

If you learn Vim, learn it without any customizations. In your own machine, you can use some other editor or IDE, or even some heavily [customized](https://github.com/xmementoit/vim-ide) Vim. It is when you are in some other machine or non-UI server that you really need to use Vim. And this the reason for the first command to learn:

```bash
# start vim without any customization (do not load ~/.vimrc)
vim -u NONE
```

Anecdotally, a friend following that advice found once himself once a broken Linux server having only `ed` command available and no network. The advice is still sound, thought the level you need to apply it may vary.

If you panic when starting `vim`, press *Esc* key one more times (so that Vim enters *command-mode*) and then press `:q!`. This will quit Vim without saving your changes. By chance, the reverse `q:` is the *raise panic level* command; it re-shows your panic keys. If `:q!` does not work to exit then `:qa!` will.

I will write here Vim commands as `:q!`, which implies entering **command-mode** first by pressing *Esc* key and then pressing `:q!` (where `:` enters the *ex-mode*). `Ctrl+d` and `Tab` can be used to auto-complete commands after `:`. Wherever possible, I write control combinations using lowercase key as in `Ctrl+d` (and not `Ctrl+D` as they are written in Vim documentation).

Vim assumes you own the machine and its disk is encrypted, leaving generous usage traces by default. If that is not the case, use `vim -u NONE -i NONE -n` to start Vim in a mode where it does not leak usage information (`-i` means no *.viminfo* file and `-n` means no *swap* temporary file). If you forget any of this, use `vim --help` in shell to get a list of command-line options.

Another occasionally useful command-line option is `vim -R file.txt` to open a file read-only (or `set ro` from within Vim).

## Pre-Basics

If you started Vim without a filename, you can open a file from within Vim using `:edit filename` (or `:e`). *Tab* key can be used for auto-completion on file names.

The fastest way to produce text in Vim is to write it in some other editor and save it as some file `text.txt`. Start `vim` and use `:r text.txt` to read it and put its text under the cursor position. File name completion should work after `:r` same as in shell using *Tab* key. This is also the best way to bring some existing pieces of text within a file in Vim (if you have no clipboard).

There are several ways to save the text:

* `:w somefilename` will save current text buffer in *somefilename*.
* `:saveas somefilename` will save current text buffer in *somefilename* and use it for follow-up saves.
* `:w` will save current text buffer in current file (either open via `vim somefilename`, or set via first `w somefilename`). `:wa` save all buffers.
* `:wq` save and quit (or `ZZ` or `:x`).
* `w!` force write read-only file.
* `w !sudo tee % > /dev/null` yes, no one remembers this one, but it will force write some file open without `sudo` as `sudo` (basically this means write buffer and pipe it via *sudo* using *tee* to filename).
    - If you can plan in advance, use `SUDO_EDITOR=vim sudo -e somefile` to edit a file as *sudo* using Vim.
* As noted before, `:q!` will not save your text and exit (you still have the nice memory of writing it) and `:qa!` will exit even if you have more than buffer.

A few quirks:

* If you pressed *Ctrl+z* by mistake while in Vim, use `fg` in bash shell to get back to Vim. 
* If pressing [Ctrl+s](https://en.wikipedia.org/wiki/Software_flow_control) by mistake in terminal within Vim, press *Ctrl+q* to resume flow.

## Vim Help

To get help from within Vim use any of `:help`, `:h`, or *F1* key. Help opens in a separate *read-only* text buffer and you can close it using `:q` or `:close`. Use `Ctrl+w Ctrl+w` to jump between window buffers.

If you scroll down in help page (or press `/quick`) , you will find a link to *quickref*. Move cursor over and press `Ctrl+]` to open it. You can open it also directly using `: h quickref`. Quick reference contains most commands you will ever use (`:h text` will search help for *text*).

## Main Modes

In Vim there are two main modes:

* **command-mode** (aka: **normal-mode**) is reachable by pressing *Esc* key or if that is broken *Ctrl+[*. *Ctrl+c* works too and it is the best to use in non-ANSI keyboards.
    * In most terminals, *Alt+normal mode command key* will work form within *insert-mode*. 
    * *Ctrl+o normal mode command* works also from within *insert-mode*.
* **insert-mode** is reachable from command-mode by initiating some text edit command.

## Basic Vim

There is no basic Vim. You need to learn upfront enough commands to move around and edit text. Commands are usually are made of multiple keys of the [form](https://danielmiessler.com/study/vim/#language): *operator (verb)* *modifier (scope)* *noun (motion)* and can be combined creatively given enough time. The best way to learn the most basic commands is to use `vimtutor` as often as everything there becomes a habit.

Common movement commands (in *command-mode*):

* `Ctrl+g` shows current line position in file. `:set ruler` will show bottom status if not already visible.
* `j` - down, `k` - up, `h` left, `l` -right (arrow keys also work) (can be combined also with numbers, e.g: `4j`).
    * appending `g` in front of `jkhl` will allow moving around display lines (`g` can be used same with `0^$`).
* `0` - move to beginning of line, `^` first not blank char on line, `$` - end of line, `g_` last non-blank char on line.
* `fc` - *find* next char *c* and move cursor to it, `tc` find next char c and move cursor *to* it. `Fx`, `Tx` work same but jump to previous occurrence of *c*. All these commands work on current line only.
  * `;` repeats last `ftFT` forward, `,` repeats last `ftFT` backward
* `/text` - find *text*. `n` moves to next occurrence, `N` to previous one. Use `set hls` to highlight matches and `:noh` to temporary disable search highlight. `?text` is same, but searches backward.
* `*` and `#` find next and previous occurrence of word under cursor (`n` and `N` and highlight work same as for `/`).
* `Ctrl+i` - jump to previous location, `Ctrl+o` jump back. `gi` moves to last node in edit tree.
* `H` move to top, `M` move to middle, `L` move to bottom of screen
* `Ctrl+d` - move half-page down, `Ctrl+u` move half-page up; `Ctrl+f` move down a page, `Ctrl+b` move up a page.
* `zz` (not `ZZ`) will center cursor line on screen. `Ctrl+y` scroll one line down, `Ctrl+e` scroll one line up, while keeping cursor in current line.
* `:number` or `numberG`- go to line number, `:+number` - go number lines down, `:-number` go number lines up.
  * It may help to run `:set number` (or `:set nu`) before to show line numbers. For extra Zen use `:set rnu` (or `:set relativenumber`) for relative numbers. Using both also works. Using `no` before removes them (e.g. `:set nonumber`).
* `gg` - go to top of file, `G` go end of file.
* `w` move one word forward, `b` move one word backward, `e` move to end of word; `W`, `B`, `E` work same but consider punctuation as part of words.
* `%` move to matching char (`()`, `{}`, `[]`).
* Usually combined with other commands: `)` or `s` move one sentence; `}` or `p` move one paragraph, `t` move one tag; `b` more one code block; all these can get confused in some source code files (in default configuration).
* `gg=G` format whole text, where `=` is [format](https://www.cs.swarthmore.edu/oldhelp/vim/reformatting.html) command. `<` and `>` indent left or right.

Common edit commands (in *command-mode*):

* `i` insert before cursor, `a` append after cursor.
* `I` insert beginning of line, `A` append at end of line.
* `o` insert in new line after current, `O` insert in new line before current.


* `r` replace char under cursor; `s` is similar to `r` but remains in insert mode afterwards.
    * `R` replaces more than one char at a time. `S` replaces whole line and remains in insert mode. 
* `c` change *motion* (using any motion command from above: `c5w`).
    * `C` change current line.
* `~` toggle case under cursor. `gu` lowercase `gU` uppercase.
* `J` join current line with next one.
* `Ctrl+a` increment, `Ctrl+x` decrement.


* `y` copy (yank) *motion* (using any motion command from above: `y5w`). (`"*y` to copy to *X11* clipboard, same for paste `"*p`, where `"*` means register `*` the clipboard).
* `yy` copy current line.
* `p` paste (put) text after cursor; `P` paste before cursor. These commands can be combined, e.g.: `ddp` to swap lines.


* `x` delete char under cursor; `X` delete char before cursor.
* `d` delete (cut) *motion* (using any motion command from above: `d5w`).
* `dd` delete (cut) current line (`ddp` swap two lines).
* `D` delete (cut) to end of line.


* `u` undo; `Ctrl+r` redo, `U` undo whole line changes.
* `.` repeat last action sequence (`number.` repeat last command sequence *number* times).
* `:edit!` undo all unsaved changes in buffer.

Edit commands can be combined with **i**nside or **a**round *text-object* bound options:

* `ciw` - change inside word, `caw` - change inside word. Mounded motions include: `w` word, `s` sentence, `p` paragraph, `t` tag, `'` single quote, `"` double quote, and  `(`, `[`, `{` stand per their own.

While in *insert-mode*: 

* `Ctrl+r 0` will paste text without having leave that mode, where `0` is register name (see `:h i_ctrl-r`). 
* `Ctrl+o` will allow running a single command and coming back to insert-mode (e.g.: `Ctrl+o D` to deleted to end of line). 
* `Ctrl+h` will delete previous char (same as *Backspace*) and `Ctrl+w` will delete previous word, while `Ctrl+u` will delete to start of line.
* `Ctrl+j` same as *Enter* key.
* `Ctrl+t` indent line, `Ctrl+d` un-indent line.
* `Ctrl+n` and `Ctrl+p` enable auto-completion from words found in open buffers.
* `Ctrl+x s` spell check (use `:set spell` before)

Vim has also a **visual-mode** entered by any of: `v` char selection, `V` line selection, `Ctrl+v` block selection. Arrow keys expand selection (on which side can be toggled with `o`) and `gv` re-selects. In visual-mode, you select first the text and then run any command on it. Pressing `:` allows running ex commands in selection, such as, `normal i#` to comment lines (for `V`).

## Casual Zen

Macros (`:h @`):

* `qa` record macro in register *a* (a-z). Type commands here. `qA` appends to macro *a*.
* `q` stop recording
* `@a` play back macro in register *a*, `@@` replays last macro, `number@a` play *a* *number* times, and `number@@` replays last macro *number* times.
* `:registers` will show all registers, including the macro ones.
* `"ap` paste register *a* (to edit as needed, *^[* is Esc key in a macro body)
* `0"ay$` copy macro (or `v` to enter visual mode, select, then `"ay`)
* `:help q` for more details

Replacing text:

* `:%s/foo/bar/g` replace `foo` with `bar` globally, add `c` after `g` to confirm every replacement
    - use `:set ic` to ignore case
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

* `ma` mark current position with *a* (`a-z` same file, `A-Z` to mark between open files)
* `'a` move to mark *a* line, or `d'a` delete from current potion to mark *a*

Integrated spell checker can be activated via `:set spell`:

* `z=` show lists of suggestions. Type *number* *Enter* to replace word.
* `[s` next, `s]` previous suggestion.
* `zg` add / `zw` remove word from dictionary.
* `Ctrl+x s` spell from within *insert mode*.

Running external commands:

* To open shell without having to exit Vim use `:shell` or `:sh`. Run `exit` to return back from shell. 
* Using `:!sh` or `:!cmd` can be also used to run the shell (or run a command, such as `!ls`).
    * Use `!cmd %` for to replace `%` with current file name if you need it. 
* To read and append output of command as text in current buffer use `:r !cmd`.

Using external commands to filter buffer text (think of `!` as pipe `|`):

* `range!cmd` where range is `%` all text, `.` current line, `m,n` lines *m,n*

To encrypt current buffer text:

* `%!gpg -ca --compress-algo zip -z 9 --cipher-algo AES256`
    * `%!gpg --pinentry-mode loopback --passphrase "password" -ca --compress-algo zip -z 9 --cipher-algo AES256` - same as above but you can pass password directly

To decrypt current GPG text (`Ctrl+L` to refresh screen):

* `%!gpg -d 2> /dev/null`

To encrypt a file with Vim's build-in encryption, open or create a file then:

* In normal mode enter `:setlocal cm=blowfish2` and then `:X` and enter the password twice and then save file `:wq`. 

## Readings

I found myself last reading [Practical Vim](http://vimcasts.org/publications/) and would recommend it once you are familiar with the Vim basics above.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2019/2019-03-10-How-To-Speak-Like-A-Leader.md'>How To Speak Like A Leader</a> <a rel='next' id='fnext' href='#blog/2019/2019-01-24-Docker-s-Blackhole-Like-Behavior.md'>Docker s Blackhole Like Behavior</a></ins>
