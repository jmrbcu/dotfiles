# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

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
plugins=(git colored-man-pages jsontools python nmap fabric httpie themes urltools virtualenvwrapper)
if [[ "$OSTYPE" == darwin* ]]; then
    plugins+=(osx xcode)
fi

source $ZSH/oh-my-zsh.sh

##############################################################################
# User configuration                                                         #
##############################################################################

# Execute neofetch if available
command -v neofetch >/dev/null 2>&1 && neofetch

# Make globbing work like in bash
setopt nonomatch

# Disable asking confirmation for rm
setopt rm_star_silent

# path
custom=($HOME/.local/bin)
for p in $custom; do
    if [[ -d $p ]]; then
        path=($p $path)
    fi
done

# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Preferred editor for local and remote sessions
export EDITOR='vim'
export VISUAL='vim'
if [[ -z $SSH_CONNECTION ]]; then
    # use VS Code if available in local sessions only
    command -v code >/dev/null 2>&1 && export EDITOR='code' && export VISUAL='code'
fi

# Aliases
alias du="du -h -s"
alias df="df -h"

if [[ "$OSTYPE" == darwin* ]]; then
    # zsh autosuggestions
    if [[ -e /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
        source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    else
        echo 'Install "zsh-autosuggestions" (brew install zsh-autosuggestions) in order to use zsh autosuggestions'
    fi

    # test if android SDK exits and add the platform tools to the path
    if [[ -d ~/Development/Mobile/Android/SDK/platform-tools ]]; then
        path=(~/Development/Mobile/Android/SDK/platform-tools $path)
    fi

    # Aliases
    alias rmdd="rm -rf ~/Library/Developer/Xcode/DerivedData/*"
    alias cddd="cd ~/Library/Developer/Xcode/DerivedData/"

    alias py='echo "ipython for python v3 is not installed, please install ipython with the following command: brew install ipython"'
    command -v ipython >/dev/null 2>&1 && alias py=ipython

    alias py2='echo "ipython for python v2 is not installed, please install ipython@5 with the following command: brew install ipython@5"'
    command -v /usr/local/opt/ipython@5/bin/ipython >/dev/null 2>&1 && alias py2="/usr/local/opt/ipython@5/bin/ipython"
    
    # Use GNU ls instead of BSD ls
    alias ls="gls -hlF --color=always --group-directories-first"
    alias lsh="gls -hlAF --color=always --group-directories-first"
    command -v gls >/dev/null 2>&1 || {
      echo "gls command from coreutils package is not installed, using default ls for now, please, install it with: brew install coreutils";
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