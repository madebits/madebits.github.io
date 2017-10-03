# Feh Start Script

2021-11-25

<!--- tags: linux -->

The following script start `feh` paused (toggle with `h`) and from a given file or folder:

```bash
#!/bin/bash

cmd="/usr/bin/feh -D -3.0 -Y -Z -.\
 --scale-down -B \"#282a36\" --no-recursive --auto-rotate --sort name --version-sort -g 1920x1040"
path="${1:-.}"
shift

if [ -d "$path" ]; then
    exec $cmd \
    "$path" --info 'echo %wx%h@%z' &2>/dev/null
elif [ -e "$path" ]; then
    file=$(realpath -- "$path")
    dir=$(dirname -- "$file")

    $cmd \
    --start-at "$file" --info 'echo %wx%h@%z' &2>/dev/null
fi
```
<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2021/2021-11-26-Using-brightnessctl.md'>Using brightnessctl</a> <a rel='next' id='fnext' href='#blog/2021/2021-11-24-Extensions.md'>Extensions</a></ins>
