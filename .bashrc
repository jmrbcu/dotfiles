# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# append to the history file, don't overwrite it
shopt -s histappend

# do not save empty lines in the history
export HISTCONTROL=ignoreboth

# I want a lot..
export HISTFILESIZE=1000

# make less more friendly for non-text input files, see lesspipe(1)
# [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

##############################################################################
# Platform independent configuration                                         #
##############################################################################

# ssh
export SSH_KEY_PATH="$HOME/.ssh/rsa_id"

# Set the umaks just in case
umask 0022

# Main editor and pager
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

# Set the default Less options.
export LESS='-g -i -M -R -S -w -X -z-4'

# Aliases
alias du="du -h -s"
alias df="df -h"

# Functions
function f() { find . -iname "*$1*" ${@:2}; }
function r() { grep "$1" ${@:2} -R .; }

# Configure virtualenvwrapper if available
command -v virtualenvwrapper.sh >/dev/null 2>&1 && {
    export WORKON_HOME=$HOME/.virtualenvs
    export PROJECT_HOME=$HOME/Development
    source /usr/local/bin/virtualenvwrapper.sh
}

# my PS1
if [ $(id -u) -eq 0 ]; then
    PS1="[\[\e[1;31m\]\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]][\[\e[1;32m\]\@\[\e[0m\]][\[\e[1;36m\]\w\[\e[0m\]] "
else
	PS1="[\[\e[1;36m\]\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]][\[\e[1;32m\]\@\[\e[0m\]][\[\e[1;36m\]\w\[\e[0m\]] "
fi

##############################################################################
# Platform dependent configuration                                           #
##############################################################################
if [[ "$OSTYPE" == darwin* ]]; then
    # path
    export PATH=/usr/local/bin:/usr/local/sbin:$PATH

    # Add /etc/manpaths.d/ files to manpath
    for path_file in /etc/manpaths.d/*; do
        MANPATH=$MANPATH:$(<$path_file)
    done

    # Aliases
    command -v ipython >/dev/null 2>&1 && {
        alias py=ipython
        alias py3=ipython
    }

    command -v /usr/local/opt/ipython@5/bin/ipython >/dev/null 2>&1 && {
        alias py2="/usr/local/opt/ipython@5/bin/ipython"
    }
    
    # Use GNU ls instead of BSD ls
    alias ls="gls -hlF --color=always --group-directories-first"
    alias lsh="gls -hlAF --color=always --group-directories-first"
    command -v gls >/dev/null 2>&1 || {
      echo "gls command from coreutils package is not installed";
      echo "Please, install it with brew, for now using default ls"
      alias ls="ls -hlGF"
      alias lsh="ls -hlAGF"
    }

    # Functions
    function adbGetFile() { adb exec-out run-as $1 cat $2 > `basename $2`; }
    function adbRmFile() { adb exec-out run-as $1 rm $2; }
    function adbLsFiles() { adb exec-out run-as $1 ls -hlAFtr --color=auto $2; }
    function getRealm() { adbGetFile $1 files/$2.realm; }
    function rmRealm() {  adbRmFile $1 files/$2.realm; }

    # Finder: hide and show hidden files
    function hiddenOn() { defaults write com.apple.Finder AppleShowAllFiles YES ; }
    function hiddenOff() { defaults write com.apple.Finder AppleShowAllFiles NO ; }
    function capture() {
        if [ "$#" -eq 2 ]; then
            ssh $1 "tcpdump -i $2 -U -s0 -w -"| wireshark -k -i -;
        fi

        if [ "$#" -eq 3 ]; then
            ssh $1@$2 "tcpdump -i $3 -U -s0 -w -"| wireshark -k -i -;
        fi

        if [ "$#" -eq 4 ]; then
            ssh -p $3 $1@$2 "tcpdump -i $4 -U -s0 -w -"| wireshark -k -i -;
        fi
    }
else
    # Aliases
    alias ls="ls -hlF --color=always --group-directories-first"
    alias lsh="ls -hlAF --color=always --group-directories-first"
fi

# Clear screen
clear

# Execute archey if available
command -v archey >/dev/null 2>&1 && {
    archey -o
}
