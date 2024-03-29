#!/usr/bin/env bash
# documentation for bash: http://wiki.bash-hackers.org/commands/classictest

set -eE

# move to script directory so all relative paths work
cd "$(dirname "$0" 2>/dev/null)"

# initialize the terminal with color support
if [[ -t 1 ]]; then
  # see if it supports colors...
  ncolors=$(tput colors)

  if [[ -n "$ncolors" && $ncolors -ge 8 ]]; then
    normal="$(tput sgr0)"
    red="$(tput setaf 1)"
    green="$(tput setaf 2)"
    yellow="$(tput setaf 3)"
    blue="$(tput setaf 4)"
    magenta="$(tput setaf 5)"
    cyan="$(tput setaf 6)"
    ul="$(tput smul)"
  fi
fi

info() {
  printf "$yellow$1$normal\n"
}

abort() {
  printf "$red$1$normal\n"
  exit 1
}

usage() {
  info "::: Description:"
  info ":::   Installs base system for TotalTrack"
  info "::: "
  info "::: Supported systems:"
  info ":::   Debian, Ubuntu, CentOS and RedHat."
  info "::: "
  info "::: Usage:"
  info ":::   install.sh [-h|--help] | [configs | vim | zsh | apps | all]"
  info "::: "
  info ":::   -h|--help: show this message"
  info ":::   configs: Install only the config files (dot files)"
  info ":::   vim: Install and configure vim"
  info ":::   zsh: Install and configure zsh"
  info ":::   apps: Install console and UI apps"
  info ":::   all: Install the whole shebang"
  info ":::"
  info "::: Ej."
  info ":::   # install the whole shebang"
  info ":::   install.sh all"
  info ":::"
  info ":::   # install only vim"
  info ":::   install.sh vim"
  info "::: "
}

system-detect() {
  # This function will set the following enviroment variables:
  # OS: Operation system, Ej: Darwin, Linux
  # KERNEL: Kervel version, Ej: 2.6.32-696.30.1.el6.x86_64
  # ARCH: System architecture, Ej: x86_64
  # DIST: Distibution ID, Ej: debian, ubuntu, centos, redhat
  # VER: Distribution version: Ej: 18.04, 9.6
  OS=$(uname | tr '[:upper:]' '[:lower:]')
  KERNEL=$(uname -r | tr '[:upper:]' '[:lower:]')
  ARCH=$(uname -m | tr '[:upper:]' '[:lower:]')
  BASE_DIST=""
  DIST=""
  VER=""

  if [[ "$OS" == "darwin" ]]; then # OSX
    BASE_DIST="macos"
    DIST="macos"
    VER=$(sw_vers -productVersion | tr '[:upper:]' '[:lower:]')
  else # Linux
    if [ -f /etc/os-release ]; then
      BASE_DIST=$(cat /etc/os-release | sed -rn 's/^ID_LIKE="?(\w+)"?.*/\1/p' | tr '[:upper:]' '[:lower:]')
      DIST=$(cat /etc/os-release | sed -rn 's/^ID="?(\w+)"?.*/\1/p' | tr '[:upper:]' '[:lower:]')
      VER=$(cat /etc/os-release | sed -rn 's/^VERSION_ID="?([0-9\.]+)"?.*/\1/p' | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/redhat-release ]; then
      BASE_DIST="redhat"
      DIST=$(sed -rn 's/^(\w+).*/\1/p' /etc/redhat-release | tr '[:upper:]' '[:lower:]')
      VER=$(sed -rn 's/.*([0-9]+\.[0-9]+).*/\1/p' /etc/redhat-release | tr '[:upper:]' '[:lower:]')
    fi

    if [[ "$DIST" == "debian" || "$DIST" == "ubuntu" ]]; then
      BASE_DIST=debian
    elif [[ "$DIST" == "centos" || "$DIST" == "redhat" || "$DIST" == "redhatenterpriseserver" ]]; then
      BASE_DIST=redhat
    fi

  fi
}

install-homebrew() {
  if [[ "$BASE_DIST" != "macos" ]]; then
    return
  fi

  command -v brew >/dev/null 2>&1 || {
    info "::: Installing Homebrew ...\n"

    # install xcode command line tools, needed for homebrew
    if ! xcode-select -p >/dev/null 2>&1; then
      xcode-select --install
    fi

    # install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    printf "\n\n"
  }
}

install-git() {
  info ":::  Installing Git ...\n"

  if [[ "$BASE_DIST" = "macos" ]]; then
    brew install git
  elif [[ "$BASE_DIST" = "redhat" ]]; then
    sudo yum -y install git
  elif [[ "$BASE_DIST" = "debian" ]]; then
    sudo apt-get -y install git
  else
    abort "::: Unsupported OS: $BASE_DIST"
  fi

  printf "\n\n"
}

install-configs() {
  info "::: Installing configs ...\n"

  # diable login messages
  info "::: Disabling SSH welcome message"
  touch $HOME/.hushlogin

  CWD=$(pwd)
  for conf in .common.sh .profile .bashrc .dircolors .inputrc .Xdefaults .gitconfig .gitignore .nanorc; do
    test -f $HOME/$conf && {
      info "::: Backing up: $HOME/$conf => $HOME/$conf.bak"
      mv $HOME/$conf $HOME/$conf.bak
    }

    info "::: Installing config link: $HOME/$conf => $CWD/$conf"
    ln -sf $CWD/$conf $HOME/$conf

    printf "\n"
  done

  info "::: Installing MC config file: $HOME/.config/mc/ini"
  mkdir -p $HOME/.config/mc && cp mc.ini $HOME/.config/mc/ini

  if [[ "$BASE_DIST" = "macos" ]]; then
    info "::: Restoring Finder configs" && defaults import com.apple.finder osx/finder/com.apple.finder.plist
    info "::: Restoring iTerm2 configs" && defaults import com.googlecode.iterm2 osx/iterm2/com.googlecode.iterm2.plist

    # dock
    info "::: Configuring OSX Dock"
    defaults write com.apple.dock minimize-to-application -bool true
    defaults write com.apple.dock show-recents -bool false
    defaults write com.apple.dock magnification -bool true

    # disable sudo password for admins
    if [[ ! -f /etc/sudoers.d/nopasswd ]]; then
      info "::: Disabling SUDO password for admin users"
      echo "%admin ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/nopasswd >/dev/null
    fi

    # restart dock and finder
    killall Dock Finder
  fi

  printf "\n\n"
}

install-apps() {
  info "::: Installing Apps ...\n"
  if [[ "$BASE_DIST" = "macos" ]]; then
    brew upgrade
    brew install bash-completion wget curl htop mc cabextract p7zip xz zlib rpm dpkg pfetch vim \
      pyenv pyenv-virtualenv subversion gnu-tar sox mariadb freetds coreutils openssl readline sqlite3 watch \
      ruby telnet nmap httpie squashfs fzf

    brew install --cask -f appcleaner acorn anydesk adobe-acrobat-reader google-chrome microsoft-word microsoft-excel \
      microsoft-powerpoint the-unarchiver google-drive wireshark slack 4k-video-downloader 4k-youtube-to-mp3 vlc \
      whatsapp messenger jetbrains-toolbox virtualbox virtualbox-extension-pack handbrake mpv inkscape visual-studio-code \
      viscosity purevpn skype spotify "local" webtorrent transmission balenaetcher vagrant gfxcardstatus

    info "Download and install by hand: CleanMyDrive, Amphetamine, Logitech Options, Magnet\n\n"
  elif [[ "$BASE_DIST" = "redhat" ]]; then
    sudo yum -y install redhat-lsb-core cabextract p7zip p7zip-plugins unrar xz mc htop bash-completion ctags \
      elinks curl wget coreutils telnet nmap net-tools bind-utils rpm-build
  elif [[ "$BASE_DIST" = "debian" ]]; then
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y install lsb-release cabextract p7zip-full xz-utils rpm mc htop bash-completion exuberant-ctags \
      elinks curl wget coreutils telnet nmap net-tools dnsutils psmisc fzf
  else
    abort "::: Unsupported OS"
  fi

  printf "\n\n"
}

install-vim() {
  info "::: Installing vim ...\n"

  if [[ "$BASE_DIST" = "macos" ]]; then
    brew install vim
  elif [[ "$BASE_DIST" = "redhat" ]]; then
    sudo yum -y install vim
  elif [[ "$BASE_DIST" = "debian" ]]; then
    sudo apt-get -y install vim
  else
    abort "::: Unsupported OS: $BASE_DIST"
  fi

  # backup old vim directories
  test -d ~/.vim && {
    rm -rf ~/.vim.bak && mv ~/.vim ~/.vim.bak
  }

  test -f ~/.vimrc && {
    rm -rf .vimrc.bak && mv ~/.vimrc ~/.vimrc.bak
  }

  if [[ ! -d ~/.vim_runtime ]]; then
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
  else
    git -C ~/.vim_runtime reset --hard
    git -C ~/.vim_runtime clean -d --force
    git -C ~/.vim_runtime pull --rebase

    python3  ~/.vim_runtime/update_plugins.py 2> /dev/null || {
      python2  ~/.vim_runtime/update_plugins.py 2> /dev/null || { 
        /usr/local/totaltrack/bin/python2.7 ~/.vim_runtime/update_plugins.py 2> /dev/null || {
          echo "Automatic Python detection failed, run this by hand: <python>  ~/.vim_runtime/update_plugins.py"
        }
      }
    }
  fi
  

  printf "\n\n"
}

install-zsh() {
  info "::: Installing zsh ...\n"

  if [[ "$BASE_DIST" = "macos" ]]; then
    brew install zsh
  elif [[ "$BASE_DIST" = "redhat" ]]; then
    sudo yum -y install zsh
  elif [[ "$BASE_DIST" = "debian" ]]; then
    sudo apt-get -y install zsh
  else
    abort "::: Unsupported OS: $BASE_DIST"
  fi

  # install oh-my-zsh, not using its regular install script
  if [[ ! -d ~/.oh-my-zsh ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  # powerline10k theme
  if [[ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  else
    git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull
  fi

  # install zsh-syntax-highlighting
  if [[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  else
    git -C ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting pull
  fi

  # install zsh-autosuggestions
  if [[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  else
    git -C ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions pull
  fi

  # oh-my-zsh installation overwrote our .zshrc, put it back
  test -f ~/.zshrc && mv ~/.zshrc ~/.zshrc.bak
  ln -sf $(pwd)/.zshrc ~/.zshrc

  # link our p10k config
  test -f ~/.p10k.zsh && mv ~/.p10k.zsh ~/.p10k.zsh.bak
  ln -sf $(pwd)/.p10k.zsh ~/.p10k.zsh

  # change the shell if is not already "zsh"
  TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
  if [[ "$TEST_CURRENT_SHELL" != "zsh" ]]; then
    sudo chsh -s $(grep /zsh$ /etc/shells | tail -1) $USER
  fi

  printf "\n"
  info "::: Remember to run: rm -f ~/.zcompdump; compinit when finished inside zsh shell"
  info "::: If you are getting permissions problems on OSX, run this: compaudit | xargs chmod g-w"
  printf "\n\n"
}

main() {
  CMDS=()
  if [[ "$1" = "configs" ]]; then
    CMDS=(install-configs)
  elif [[ "$1" = "vim" ]]; then
    CMDS=(install-git install-vim)
  elif [[ "$1" = "zsh" ]]; then
    CMDS=(install-git install-zsh)
  elif [[ "$1" = "apps" ]]; then
    CMDS=(install-git install-apps)
  elif [[ "$1" = "all" ]]; then
    CMDS=(install-git install-apps install-vim install-zsh install-configs)
  else
    abort "::: Invalid arguments, check the help: install.sh -h"
  fi

  system-detect
  if [[ "$1" != "configs" && "$BASE_DIST" = "macos" ]]; then
    install-homebrew
  fi

  for CMD in ${CMDS[*]}; do
    $CMD
  done

  info "Finished, log out and log back in, enjoy!"
}

# parameter check
if [[ $# = 0 ]]; then
  usage
elif [[ $# = 1 ]]; then
  if [[ "$1" = "-h" || "$1" = "--help" ]]; then
    usage
  else
    main $1
  fi
else
  abort "::: Invalid arguments, check the help: install.sh -h"
fi
