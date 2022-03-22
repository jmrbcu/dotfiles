# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="afowler"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git colored-man-pages jsontools python pyenv nmap httpie themes urltools vagrant)
if [[ "$OSTYPE" == darwin* ]]; then
    plugins+=(macos xcode)
fi

# HACK FOR ZSH COMPLETIONS
ZSH_DISABLE_COMPFIX=true

source $ZSH/oh-my-zsh.sh

##############################################################################
# User configuration                                                         #
##############################################################################

# path
custom=($HOME/.dotnet/tools $HOME/.local/bin /usr/local/bin /usr/local/sbin /usr/local/opt/ruby/bin /usr/local/lib/ruby/gems/3.0.0/bin)
for p in $custom; do
    test -d $p && path=($p $path)
done

# Make globbing work like in bash, if it fails, then pass the original glob to as argument to the program
setopt nonomatch

# Disable asking confirmation for rm
setopt rm_star_silent

# Make zsh know about hosts already accessed by SSH
# zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

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

# creates a local socks proxy using the remote server as exit point
function proxy() {
    if [ "$#" -eq 2 ]; then
        echo "::: Listening in: localhost:$2"
        ssh -D $2 -q -C -N $1
    else
        echo "::: Usage: proxy <[user@]host[:port]> <local-port>"
        echo ":::     <[user@]host[:port]>: exit point host"
        echo ":::     <local-port>: Port on the local machine we want to forward"
    fi
}

# forward local port to a remote port using ssh
function forward() {
    if [ "$#" -ge 2  ]; then
        for arg in "${@:2}"; do
            params="-L $arg $params"
        done
        echo "$params $1"
        eval "ssh -q -N -C $params $1"
        unset params
    else
        echo "::: Usage: forward <[user@]host[:port]> <local-port>:<remote-host>:<remote-port> ... <local-port>:<remote-host>:<remote-port>"
        echo ":::     <[user@]host[:port]>: Intermediate host with ssh"
        echo ":::     <local-port>: Port on the local machine we want to forward"
        echo ":::     <remote-host: Remote host where the local port will be forwarded to"
        echo ":::     <remote-port: Port in the remote host where the local port will be forwarded to"
    fi
}


# capture traffic from a remote server
function remote-capture() {
    if [ "$#" -eq 2 ]; then
        ssh -q -N -C $1 "tcpdump -i $2 -U -s0 -w -"| wireshark -k -i -;
    elif [ "$#" -eq 3 ]; then
        ssh -q -N -C -p $2 $1 "tcpdump -i $3 -U -s0 -w -"| wireshark -k -i -;
    else
        echo "::: Usage:"
        echo ":::    remote-capture <[user@]host> [ssh-port] <iface>\n"
    fi
}


if [[ "$OSTYPE" == darwin* ]]; then
    # Use GNU ls instead of BSD ls if available
    alias ls="ls -hlGF"
    alias lsh="ls -hlGFA"
    command -v gls >/dev/null 2>&1 && {
        alias ls="gls -hlF --color=always --group-directories-first"
        alias lsh="gls -hlAF --color=always --group-directories-first"
    }

    command -v greadlink >/dev/null 2>&1 && {
        alias readlink=greadlink
    }

    command -v gtar >/dev/null 2>&1 && {
        alias tar=gtar
    }
else
    # Command Aliases
    alias ls="ls -hlF --color=always --group-directories-first"
    alias lsh="ls -hlAF --color=always --group-directories-first"
fi


# Enable zsh autosuggestions: fish like sugestions.
# Also, take a look at: FZF at: https://github.com/junegunn/fzf
if [[ -e /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -e /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -e ~/.zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source ~/.zsh-autosuggestions/zsh-autosuggestions.zsh
else
    echo 'Install "zsh-autosuggestions" in order to use zsh autosuggestions'
fi

# Enable zsh syntax highlighting
if [[ -e /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -e /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -e ~/.zsh-syntax-highlighting ]]; then
    source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
    echo 'Install "zsh-syntax-highlighting" in order to use zsh syntax highlighting'
fi

# enable completions
if type brew &>/dev/null; then
    fpath=(/usr/local/share/zsh-completions $fpath)
elif type yum &>/dev/null || type apt &>/dev/null; then
    fpath=(~/.zsh-completions/src $fpath)
fi
autoload -Uz compinit
compinit


# Execute neofetch if available
command -v pfetch >/dev/null 2>&1 && pfetch

# activate pyenv-virtualenv
command -v pyenv-virtualenv-init > /dev/null && eval "$(pyenv virtualenv-init -)"
