# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"
#ZSH_THEME="steeef"
#ZSH_THEME="gianu"
ZSH_THEME="afowler"

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
ENABLE_CORRECTION="false"

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
        virtualenvwrapper themes docker
    )
else
    plugins=(
        colored-man-pages cp dircycle extract fabric
        git gitfast jsontools history-substring-search
        nmap python pip django rsync supervisor systemadmin
        virtualenvwrapper themes
    )
fi

source $ZSH/oh-my-zsh.sh

# User configuration

# virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Development
source /usr/local/bin/virtualenvwrapper.sh



# make globbing work like in bash
setopt nonomatch

# set the umaks just in case
umask 0022

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# ls
#export LSCOLORS=ExFxBxDxCxegedabagacad
LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS

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

