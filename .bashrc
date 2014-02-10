#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# be paranoid
if [ $(id -u) != 0 ]; then
    umask 0077
else
    umask 0022
fi


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
export PATH=~/.local/bin:/usr/local/bin:$PATH

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    alias ls='ls -hlaG'

    # Homebrew support 
    export HOMEBREW_GITHUB_API_TOKEN=4b3976b1c6d01d180716cd78c5c730d30be89365

    # PHP Support
    export PATH="$(brew --prefix josegonzalez/php/php55)/bin:$PATH"

    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
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
