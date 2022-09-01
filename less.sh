#!/usr/bin/env bash
set -eE

LESSPIPE=$(command -v src-hilite-lesspipe.sh)
if [[ -z "$LESSPIPE" && -f /usr/share/source-highlight/src-hilite-lesspipe.sh ]]; then
    LESSPIPE=/usr/share/source-highlight/src-hilite-lesspipe.sh
fi

if (( `stat -f %z $1` < `expr 10*1024*1024` )); then
  test -n "$LESSPIPE" && $LESSPIPE "$1" || cat "$1"
else
  cat $1
fi