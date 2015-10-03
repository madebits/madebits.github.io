#Tmux on Lubuntu

2013-09-28

<!--- tags: linux -->

[tmux](http://manpages.ubuntu.com/manpages/precise/man1/tmux.1.html) is terminal based window and session manager. To install tmux use: `sudo apt-get install tmux`. tmux can manage many open sessions at the same time.

Within tmux, the tmux specific commands are used by a **prefix** (default is `Ctrl+b`). To change the prefix, for example, to `Ctrl-a`, create a text file in home directory, called `.tmux.conf`, and write:

```
unbind C-b
set -g prefix C-a
bind C-a send-prefix
```

By default, you type first the prefix, then release the keys and then press the tmux command. The commands will be shown here from now on as: *prefix commandKeys*. tmux uses by default emacs like commands (after prefix).

My starting `.tmux.conf` file for tmux in Lubuntu set up from various sources looks as follows:

```
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# http://jasonwryan.com/blog/2011/06/07/copy-and-paste-in-tmux/
# :prefix: Escape to enter copy mode, v to start selection, y to copy, <prefix> p to paste
setw -g mode-keys vi
unbind [
bind Escape copy-mode
unbind p
bind p paste-buffer
bind-key -t vi-copy 'v' begin-selection
bind-key -t vi-copy 'y' copy-selection

set -g history-limit 3000
setw -g monitor-activity on
set -g visual-activity on

# required to prevent garbage in lxterminal
set-option -g set-clipboard off

# http://wiki.ubuntuusers.de/tmux
# damit xclip lokal arbeiten kann
set-environment -g DISPLAY :0.0
# paste-buffer in die X11 selection: :prefix: Ctrl+c
bind C-c run "tmux show-buffer | xclip -i -selection clipboard"
# X11 selection in den tmux paste-buffer: :prefix: Ctrl+v
bind C-v run "tmux set-buffer -- \"$(xclip -o -selection clipboard)\"; tmux paste-buffer"

# http://tangledhelix.com/blog/2012/07/16/tmux-and-mouse-mode/
### Mouse On/Off ### {{{
## Mouse On by default
set -g mode-mouse on
set -g mouse-resize-pane on
set -g mouse-select-pane on
set -g mouse-select-window on

##Toggle mouse on with prefix m
bind m \
        set -g mode-mouse on \;\
        set -g mouse-resize-pane on \;\
        set -g mouse-select-pane on \;\
        set -g mouse-select-window on \;\
        display 'Mouse: ON'

## Toggle mouse off with prefix M
bind M \
        set -g mode-mouse off \;\
        set -g mouse-resize-pane off \;\
        set -g mouse-select-pane off \;\
        set -g mouse-select-window off \;\
        display 'Mouse: OFF'
### End Mouse On/Off ### }}}
```

tmux reads bash config from `.bash_profile` file in home folder. To reuse `.bashrc` contents for it, write in `.bash_profile`:
```
source ~/.bashrc
```

To start a new tmux session, use any of:
```
tmux
tmux new-session
```

To detach from the session use: `prefix d`

To list sessions use:
```
tmux list-sessions
```
To attach to a session use:
```
tmux attach -t sessionName
```

tmux uses the smallest window size if session is shared, and adds a pane with dots. To [fix](http://www.mail-archive.com/tmux-users@lists.sourceforge.net/msg04967.html) this either use `tmux attach -d` (to detach previous clients), use try setting `aggressive-resize`.

Usually, you only use one session, so `tmux` starts it, `prefix d` detaches, and `tmux attach` reconnects to it.

I find useful these `.bashrc` aliases (there is more than one way to achieve this):

```
alias mux='tmux attach -d || tmux new-session \; set-option default-path "$PWD" \; split-window -h -p 40 \; select-pane -t 1 \; split-window -v \; select-pane -t 0'
alias kmux='tmux kill-server ; tmux new-session \; set-option default-path "$PWD" \; split-window -h -p 40 \; select-pane -t 1 \; split-window -v \; select-pane -t 0'
```

The first (`mux`) start or attaches to an existing tmux with a default set of panes. The second (`kmux`) kills any previous tmux sessions, and starts a new one. The layout used is:

```
---------
|    |  |
|    |__|
|    |  |
---------
```

Same aliases with an alternative layout to try out:

```
alias mux='tmux attach -d || tmux new-session \; set-option default-path "$PWD" \; split-window -v -p 20\; select-pane -t 0 \; split-window -h -p 40 \; select-pane -t 0'
alias kmux='tmux kill-server ; tmux new-session \; set-option default-path "$PWD" \; split-window -v -p 20\; select-pane -t 0 \; split-window -h -p 40 \; select-pane -t 0'
```

```
---------
|    |  |
|    |  |
---------
|       |
---------
```

The key bindings in tmux can be configured at will, some default ones I found useful to learn are:

* `prefix arrow` - moves to next pane on arrow direction
* `prefix (keep pressed) arrow` - resizes pane on arrow direction
* This is default copy: `prefix [` or `prefix PageUp/PageDown` enters copy mode, use `Ctrl+Space` to mark text selection begin, arrow keys to select, and `Alt-w` to copy the selection, then `prefix ]` to paste. To copy to system clipboard with `.tmux.conf` hacks above (needs `xclip`), replace `Alt-w `with `prefix Ctrl-c`.
* To copy when using vi keys as above: `prefix Escape`, `v` start selection, `y `copy (or `q` to cancel), then `prefix p` to paste. To copy to X clipboard with `.tmux.conf` hacks above (needs `xclip`), use `Ctrl-c` after `y` above.
* `q` key exit copy mode, or any tmux shown text
* `prefix :` enables running tmux commands (such as kill-server, or kill-window, or split-window) if you have no key bindings for them
* `prefix Ctrl-c` creates a new window (like a tab). `prefix Ctrl-p` and `prefix Ctrl-n` move to previous / next window.
`prefix %` splits the x asix and `prefix "` splits the y axis.

There is more to tmux. The [manual](http://manpages.ubuntu.com/manpages/precise/man1/tmux.1.html) page has more details.



<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-09-29-Tilda-in-Lubuntu.md'>Tilda in Lubuntu</a> <a rel='next' id='fnext' href='#blog/2013/2013-09-07-Encrypted-Containers-with-Cryptsetup.md'>Encrypted Containers with Cryptsetup</a></ins>
