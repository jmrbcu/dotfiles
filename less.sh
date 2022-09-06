#!/usr/bin/env bash

LESSPIPE=$(command -v src-hilite-lesspipe.sh)
if [[ -z "$LESSPIPE" && -f /usr/share/source-highlight/src-hilite-lesspipe.sh ]]; then
  LESSPIPE=/usr/share/source-highlight/src-hilite-lesspipe.sh
else
  LESSPIPE=cat
fi

if [[ -z "$1" ]]; then
  exit
fi

if (( `stat -f %z $1` > `expr 10*1024*1024` )); then
  LESSPIPE=cat
fi

$LESSPIPE "$1"