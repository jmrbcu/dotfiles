# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# set the umaks just in case
umask 0022


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return
fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# append to the history file, don't overwrite it
shopt -s histappend

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# do not save empty lines in the history
export HISTCONTROL=ignoreboth

# I want a lot..
export HISTFILESIZE=1000

# Nice colors for ls
export LSCOLORS=ExFxBxDxCxegedabagacad

# my PS1
if [ $(id -u) -eq 0 ]; then
    PS1="[\[\e[1;31m\]\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]][\[\e[1;32m\]\@\[\e[0m\]][\[\e[1;36m\]\w\[\e[0m\]] "
else
	PS1="[\[\e[1;36m\]\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]][\[\e[1;32m\]\@\[\e[0m\]][\[\e[1;36m\]\w\[\e[0m\]] "
    # PS1="[\$(date +%H:%M)] [\[\e[1;32m\]\u\[\e[0m\]@\[\e[1;32m\]\H\[\e[0m\] \[\e[1;1m\]\w\[\e[0m\]] [\!]\[\e[0;32m\]\$\[\e[0m\] "
fi

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Aliases
alias rm="rm -f"
alias du="du -h -s"
alias df="df -h"
alias ..='cd ..'
alias ...='cd ../..'
alias cd..='cd ..'
alias py=ipython

# virtualenv
export WORKON_HOME=$HOME/.virtualenvs
source `which virtualenvwrapper.sh`

# Platform dependent config
if [[ "$OSTYPE" == darwin* ]]; then
    export EDITOR='vim'
    export VISUAL='subl'
    export PAGER='less'
    export BROWSER='open'

    path="
        /usr/local/bin:
        /usr/local/sbin:
        ~/.local/bin:
        /Users/jmrbcu/Development/android-sdk/tools:
        /Users/jmrbcu/Development/android-sdk/platform-tools:
        /{bin,sbin}:
        /usr/{bin,sbin}:
        /usr/local/opt/coreutils/libexec/gnubin:
        /opt/X11/bin:
        $path
    "

    manpath="
        /usr/local/opt/coreutils/libexec/gnuman:
        $manpath
    "
    for path_file in /etc/manpaths.d/*; do
      manpath+=($(<$path_file))
    done
    unset path_file

    # Aliases
    alias ls="gls -hlAF --color=always --group-directories-first"
    command -v gls >/dev/null 2>&1 || {
      echo "gls command from coreutils package is not installed";
      echo "Please, install it with brew, for now using default ls"
      alias ls="ls -hlAGF"
    }

    # Finder
    function hiddenOn() { defaults write com.apple.Finder AppleShowAllFiles YES ; }
    function hiddenOff() { defaults write com.apple.Finder AppleShowAllFiles NO ; }

    # Preferred editor for local and remote sessions
    if [[ -n $SSH_CONNECTION ]]; then
      export EDITOR='vim'
    else
      export EDITOR='subl'
    fi
else
    export EDITOR='vim'
    export VISUAL='vim'
    export PAGER='less'

    path="
        /usr/local/{bin,sbin}:
        ~/.local/bin:
        /{bin,sbin}:
        /usr/{bin,sbin}:
        $path
    "

    # Aliases
    alias ls="ls -hlAF --color=always --group-directories-first"

    if ! shopt -oq posix; then
        if [ -f /usr/share/bash-completion/bash_completion ]; then
          . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
          . /etc/bash_completion
        fi
    fi
fi
