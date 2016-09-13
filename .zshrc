# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"
# ZSH_THEME="gianu"
# ZSH_THEME="afowler"

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
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

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

if [[ "$OSTYPE" == darwin* ]]; then
    plugins=(
        adb brew colored-man-pages cp dircycle
        extract fabric git gitfast jsontools
        history-substring-search nmap osx python
        pip django rsync supervisor systemadmin
        thefuck virtualenvwrapper themes docker
    )
else
    plugins=(
        colored-man-pages cp dircycle extract fabric
        git gitfast jsontools history-substring-search
        nmap python pip django rsync supervisor systemadmin
        virtualenvwrapper themes
    )
fi


# User configuration
source $ZSH/oh-my-zsh.sh

# make globbing work like in bash
setopt nonomatch

# set the umaks just in case
umask 0022

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# ls
export LSCOLORS=ExFxBxDxCxegedabagacad

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Aliases
unalias ping
alias rm="rm -f"
alias du="du -h -s"
alias df="df -h"
alias py=ipython

# Functions
function f() { find . -iname "*$1*" ${@:2} }
function r() { grep "$1" ${@:2} -R . }

# Platform dependent config
if [[ "$OSTYPE" == darwin* ]]; then
    export EDITOR='vim'
    export VISUAL='subl'
    export PAGER='less'
    export BROWSER='open'

    path=(
        /usr/local/{bin,sbin}
        ~/.local/bin
        /Users/jmrbcu/Development/android-sdk/tools
        /Users/jmrbcu/Development/android-sdk/platform-tools
        /{bin,sbin}
        /usr/{bin,sbin}
        /usr/local/opt/coreutils/libexec/gnubin
        /opt/X11/bin
        $path
    )

    manpath=(
        /usr/local/opt/coreutils/libexec/gnuman
        $manpath
    )
    for path_file in /etc/manpaths.d/*(.N); do
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

    path=(
        /usr/local/{bin,sbin}
        ~/.local/bin
        /{bin,sbin}
        /usr/{bin,sbin}
        $path
    )
    # Aliases
    alias ls="ls -hlAF --color=always --group-directories-first"
fi

