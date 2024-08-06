# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# homebrew completions
if [[ "$OSTYPE" == darwin* ]]; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
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
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(gitfast history-substring-search colored-man-pages colorize pyenv nmap httpie vagrant zsh-interactive-cd zsh-syntax-highlighting zsh-autosuggestions)
if [[ "$OSTYPE" == darwin* ]]; then
    plugins+=(brew gnu-utils macos xcode)
fi

# HACK FOR ZSH COMPLETIONS
# ZSH_DISABLE_COMPFIX=true

source $ZSH/oh-my-zsh.sh

# User configuration                                                         #

# Make globbing work like in bash, if it fails, then pass the original glob to as argument to the program
setopt nonomatch 

# tell zsh to split words separated by spaces
setopt shwordsplit

# Disable asking confirmation for rm
setopt rm_star_silent

# adds commands as they are typed, not at shell exit
setopt inc_append_history

# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# automatically complete newly installed commands 
#zstyle ':completion:*' rehash true
zstyle ":completion:*:commands" rehash 1

# enable completions
# autoload -Uz compinit
# compinit

# Set the default Less options.
export LESS='-c -g -i -M -R -S -w -X -z-4'
# command -v source-highlight >/dev/null 2>&1 && export LESSOPEN="| $HOME/.dotfiles/less.sh %s"

# Preferred editor for local and remote sessions, in this order: vim, nano
EDITOR="$(command -v vim 2>/dev/null || command -v nano)"

alias du="du -h -s"
alias df="df -h"
alias py=ipython
alias mc="mc -u"

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
  if [ "$#" -ge 2 ]; then
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
    ssh -q $1 "dumpcap -w - -i $2 -f 'not port 22 and not port 1194'" | wireshark -k -i -
  elif [ "$#" -eq 3 ]; then
    # ssh -q -N -C -p $2 $1 "tcpdump -i $3 -U -s0 -w -" | wireshark -k -i -
    ssh -q $1 -p $2 "dumpcap -w - -i $2 -f 'not port 22 and not port 1194'" | wireshark -k -i -
  else
    echo "::: Usage:"
    echo ":::    remote-capture <[user@]host> [ssh-port] <iface>\n"
  fi
}

if [[ "$OSTYPE" == darwin* ]]; then
  # Use GNU ls instead of BSD ls if available
  alias ls="ls -hlGF"
  alias la="ls -hlGFA"

  if command -v eza >/dev/null; then
    alias ls="eza -hl --group-directories-first --git"
    alias la="eza -hla --group-directories-first --git"
  elif command -v gls >/dev/null; then
    alias ls="gls -hlF --color=always --group-directories-first"
    alias la="gls -hlAF --color=always --group-directories-first"
  fi
else
  # Command Aliases
  alias ls="ls -hlF --color=always --group-directories-first"
  alias la="ls -hlAF --color=always --group-directories-first"

  if $(command -v eza >/dev/null 2>&1); then
    alias ls="eza -hl --group-directories-first --git"
    alias la="eza -hla --group-directories-first --git"
  fi
fi
