# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# path
CUSTOM="$HOME/.dotnet/tools $HOME/.local/bin /usr/local/bin /usr/local/sbin"
for P in $CUSTOM; do
    test -d $P && export PATH=$P:$PATH
done

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# append to the history file, don't overwrite it
shopt -s histappend

# do not save empty lines in the history
export HISTCONTROL=ignoreboth

# I want a lot..
export HISTFILESIZE=1000

# Set the default Less options.
export LESS='-c -g -i -M -R -S -w -X -z-4'
command -v source-highlight >/dev/null 2>&1 && export LESSOPEN="| $HOME/.dotfiles/less.sh %s"

# Preferred editor for local and remote sessions, in this order: vim, nano
if command -v vim >/dev/null 2>&1; then 
    export EDITOR='vim'
    export VISUAL='vim'
else
    export EDITOR='nano'
    export VISUAL='nano'
fi

# Preferred editor for local sessions, in this order: code, vim, nano
if [[ -z $SSH_CONNECTION ]]; then
    if command -v code >/dev/null 2>&1; then 
        export EDITOR='code'
        export VISUAL='code'
    fi
fi

# Command Aliases
alias du="du -h -s"
alias df="df -h"
alias py2='echo "ipython for python v2 is not installed"'
command -v ipython2 >/dev/null 2>&1 && alias py2=ipython2

alias py3='echo "ipython for python v3 is not installed"'
command -v ipython3 >/dev/null 2>&1 && alias py3=ipython3


# Utility Functions
# forward local port to a remote port using ssh
function forward() {
    if [ "$#" -eq 2 ]; then
        ssh -L $2 $1
    else
        echo "::: Usage: forward <[user@]host[:port]> <local-port>:<remote-host>:<remote-port>"
        echo ":::     <[user@]host[:port]>: Intermediate host with ssh"
        echo ":::     <local-port>: Port on the local machine we want to forward"
        echo ":::     <remote-host: Remote host where the local port will be forwarded to"
        echo ":::     <remote-port: Port in the remote host where the local port will be forwarded to"
    fi
    
}


# capture traffic from a remote server
function remote-capture() {
    if [ "$#" -eq 2 ]; then
        ssh $1 "tcpdump -i $2 -U -s0 -w -"| wireshark -k -i -;
    elif [ "$#" -eq 3 ]; then
        ssh -p $2 $1 "tcpdump -i $3 -U -s0 -w -"| wireshark -k -i -;
    else
        echo "::: Usage:"
        echo ":::    remote-capture <[user@]host> [ssh-port] <iface>\n"
    fi
}

if [[ "$OSTYPE" == darwin* ]]; then
    # Bash Completion
    [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

    # Command Aliases
    alias rmdd="rm -rf ~/Library/Developer/Xcode/DerivedData/*"
    alias cddd="cd ~/Library/Developer/Xcode/DerivedData/"

    # Use GNU ls instead of BSD ls if available
    alias ls="ls -hlGF"
    alias lsh="ls -hlGFA"
    command -v gls >/dev/null 2>&1 && {
        alias ls="gls -hlF --color=always --group-directories-first"
        alias lsh="gls -hlAF --color=always --group-directories-first"
    }

    # Utility Functions
    # Finder: hide and show hidden files
    function hiddenOn() { defaults write com.apple.Finder AppleShowAllFiles YES ; }
    function hiddenOff() { defaults write com.apple.Finder AppleShowAllFiles NO ; }
else
    # Command Aliases
    alias ls="ls -hlF --color=always --group-directories-first"
    alias lsh="ls -hlAF --color=always --group-directories-first"
fi


# Execute neofetch if available
command -v pfetch >/dev/null 2>&1 && pfetch


# my PS1
if [ $(id -u) -eq 0 ]; then
    PS1="[\[\e[1;31m\]\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]][\[\e[1;32m\]\@\[\e[0m\]][\[\e[1;36m\]\w\[\e[0m\]] "
else
    PS1="[\[\e[1;36m\]\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]][\[\e[1;32m\]\@\[\e[0m\]][\[\e[1;36m\]\w\[\e[0m\]] "
fi
