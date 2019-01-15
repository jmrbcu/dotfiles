# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="afowler"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

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
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    colored-man-pages cp dircycle extract fabric gitfast jsontools
    history-substring-search nmap python pip django pyenv rsync systemadmin
    themes gradle httpie
)

if [[ "$OSTYPE" == darwin* ]]; then
    plugins+=(osx xcode)
fi

source $ZSH/oh-my-zsh.sh


# User configuration

##############################################################################
# Platform independent configuration                                         #
##############################################################################

# path
custom=(/usr/local/{bin,sbin} $HOME/.local/bin)
for p in $custom; do
    if [[ -d $p ]]; then
        path=($p $path)
    fi
done

# ssh
export SSH_KEY_PATH="$HOME/.ssh/rsa_id"

# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# Make globbing work like in bash
setopt nonomatch

# Disable asking confirmation for rm
setopt rm_star_silent

# Set the umask just in case
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
function f() { find . -iname "*$1*" ${@:2} }
function r() { grep "$1" ${@:2} -R . }

##############################################################################
# Platform dependent configuration                                           #
##############################################################################
if [[ "$OSTYPE" == darwin* ]]; then
    # test if ruby gem directory exists
    if [[ -d /usr/local/lib/ruby/gems/2.6.0/bin ]]; then
        path=(/usr/local/lib/ruby/gems/2.6.0/bin $path)
    fi

    # test if android SDK exits and add the platform tools to the path
    ANDROID_SDK=~/Development/Mobile/Android/SDK/platform-tools
    if [[ -d $ANDROID_SDK ]]; then
        path=($ANDROID_SDK $path)
    fi

    # test if we have the google cloud sdk and the binaries to the path
    if [ -f ~/Development/google-cloud-sdk/path.zsh.inc ]; then 
        . ~/Development/google-cloud-sdk/path.zsh.inc; 
    fi

    # test if we have the google cloud sdk and the completions to zsh
    if [ -f ~/Development/google-cloud-sdk/completion.zsh.inc ]; then 
        . ~/Development/google-cloud-sdk/completion.zsh.inc; 
    fi

    # Add more zsh completions (brew install zsh-completions)
    fpath=(/usr/local/share/zsh-completions $fpath)

    # Add /etc/manpaths.d/ files to manpath
    for path_file in /etc/manpaths.d/*(.N); do
        manpath+=($(<$path_file))
    done
    unset path_file

    # Aliases
    unalias ping
    alias rmdd="rm -rf ~/Library/Developer/Xcode/DerivedData/*"
    alias cddd="cd ~/Library/Developer/Xcode/DerivedData/"

    alias py='echo "ipython for python v3 is not installed, please install ipython with the following command: brew install ipython"'
    command -v ipython >/dev/null 2>&1 && {
        alias py=ipython
    }

    alias py2='echo "ipython for python v2 is not installed, please install ipython@5 with the following command: brew install ipython@5"'
    command -v /usr/local/opt/ipython@5/bin/ipython >/dev/null 2>&1 && {
        alias py2="/usr/local/opt/ipython@5/bin/ipython"
    }
    
    # Use GNU ls instead of BSD ls
    alias ls="gls -hlF --color=always --group-directories-first"
    alias lsh="gls -hlAF --color=always --group-directories-first"
    command -v gls >/dev/null 2>&1 || {
      echo "gls command from coreutils package is not installed, using default ls for now, please, install it with: brew install coreutils";
      alias ls="ls -hlGF"
      alias lsh="ls -hlAGF"
    }

    # Configure virtualenvwrapper if available
    command -v virtualenvwrapper.sh >/dev/null 2>&1 && {
        export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
        export WORKON_HOME=$HOME/.virtualenvs
        export PROJECT_HOME=$HOME/Development
        source /usr/local/bin/virtualenvwrapper.sh
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

# Execute neofetch if available
command -v neofetch >/dev/null 2>&1 && {
    neofetch
}

