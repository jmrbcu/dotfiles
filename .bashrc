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

# my PS1
if [ $(id -u) -eq 0 ]; then
    PS1="[\[\e[1;31m\]\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]][\[\e[1;32m\]\@\[\e[0m\]][\[\e[1;36m\]\w\[\e[0m\]] "
else
	PS1="[\[\e[1;36m\]\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]][\[\e[1;32m\]\@\[\e[0m\]][\[\e[1;36m\]\w\[\e[0m\]] "
    # PS1="[\$(date +%H:%M)] [\[\e[1;32m\]\u\[\e[0m\]@\[\e[1;32m\]\H\[\e[0m\] \[\e[1;1m\]\w\[\e[0m\]] [\!]\[\e[0;32m\]\$\[\e[0m\] "
fi


# my lovely editor
VIM="$(which vim)"
if [ ! -z "$VIM" ] && [ -e "$VIM" ]; then
    export EDITOR="vim -X"
    alias vi='vim -X'
fi


alias h='history | grep $1'
alias du="du -h -s"
alias df="df -h"
alias ..='cd ..'
alias ...='cd ../..'
alias cd..='cd ..'
alias py=ipython
alias py2=python

# PATH
export PATH=~/.local/bin:/usr/local/bin:/usr/local/sbin:$PATH

# virtualenv
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    alias ls='ls -hlaG'

    # browser
    export BROWSER='open'

    # Homebrew support
    export HOMEBREW_GITHUB_API_TOKEN=4b3976b1c6d01d180716cd78c5c730d30be89365

    # java
    export JAVA_HOME="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home"

    # bash completion
    . /usr/local/etc/bash_completion

    # platform dependent paths
    export PATH=~/Applications:/Applications/MPlayerX.app/Contents/Resources/MPlayerX.mplayer.bundle/Contents/Resources/x86_64:/Applications/Android\ Studio.app/sdk/tools:/Applications/Android\ Studio.app/sdk/platform-tools$PATH
else
    # Do something under Linux platform
    alias ls='ls -hla --color=auto'
    if ! shopt -oq posix; then
          if [ -f /usr/share/bash-completion/bash_completion ]; then
              . /usr/share/bash-completion/bash_completion
          elif [ -f /etc/bash_completion ]; then
              . /etc/bash_completion
          fi
    fi
fi
