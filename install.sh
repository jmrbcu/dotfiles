#!/usr/bin/env bash
# documentation for bash: http://wiki.bash-hackers.org/commands/classictest

set -eE

# error handler
trap 'abort "Unexpected error on line: $LINENO: ${BASH_COMMAND}"' ERR

# move to script directory so all relative paths work
cd "$(dirname "$0" 2>/dev/null)"

OS=$(uname | tr '[:upper:]' '[:lower:]')

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

install_system() {
  if [[ "$OS" = "darwin" ]]; then
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
  fi

  info "::: Installing Apps ...\n"
  if command -v brew >/dev/null; then
    brew update
    brew upgrade
    brew install git zsh bash-completion wget curl htop btop mc cabextract p7zip xz zlib rpm dpkg vim \
      pyenv pyenv-virtualenv gnu-tar coreutils telnet nmap httpie fzf

    brew install appcleaner anydesk adobe-acrobat-reader google-chrome the-unarchiver google-drive wireshark slack \
      whatsapp jetbrains-toolbox virtualbox virtualbox-extension-pack vagrant visual-studio-code \
      viscosity spotify local logi-options-plus logitune

    info "\nDownload and install by hand: CleanMyDrive, Amphetamine, Magnet\n\n"
  elif command -v apt-get >/dev/null; then
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y install git zsh bash-completion wget curl htop btop mc cabextract p7zip-full xz-utils rpm vim \
      coreutils telnet nmap net-tools dnsutils psmisc fzf lsb-release

    printf "\n\n"
  else
    abort "::: Unsupported OS"
  fi

  info "::: Installing Oh My ZSH ...\n"

  # install oh-my-zsh, not using its regular install script
  if [[ ! -d ~/.oh-my-zsh ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  # install zsh-syntax-highlighting
  if [[ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
  else
    git -C "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting pull
  fi

  # install zsh-autosuggestions
  if [[ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
  else
    git -C "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions pull
  fi

  # change the shell if is not already "zsh"
  TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
  if [[ "$TEST_CURRENT_SHELL" != "zsh" ]]; then
    sudo chsh -s "$(grep /zsh$ /etc/shells | tail -1)" "$USER"
  fi
  printf "\n\n"

  info "::: Installing config files ...\n"

  # remove p10k (unsupported)
  test -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" && rm -rf "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
  test -f "$HOME/.p10k.zsh" && rm -f "$HOME/.p10k.zsh"

  # disable sudo password for admins
  if [[ ! -f /etc/sudoers.d/nopasswd ]]; then
    echo "%admin ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/nopasswd >/dev/null
  fi

  # install our config files
  touch "$HOME/.hushlogin"
  mkdir -p "$HOME/.config/mc"
  test -f "$HOME/.config/mc/ini" && {
    info "Backing up '"$HOME/.config/mc/ini"' -> '"$HOME/.config/mc/ini".bak'"
    mv "$HOME/.config/mc/ini" "$HOME/.config/mc/ini.bak"
  }

  info "Installing '$HOME/.config/mc/ini'"
  cp mc.ini "$HOME/.config/mc/ini"

  for conf in .zshrc .bashrc .dircolors .inputrc .Xdefaults .gitconfig .gitignore .nanorc; do
    test -f "$HOME/$conf" && {
      mv "$HOME/$conf" "$HOME/$conf.bak"
      info "Backing up '$HOME/$conf' -> '$HOME/$conf.bak'"
    }

    info "Installing '$HOME/$conf'"
    ln -sf "$(pwd)/$conf" "$HOME/$conf"
  done

  if [[ "$OS" = "darwin" ]]; then
    info "Installing fonst into: '$HOME/Library/Fonts'"
    wget -qO- https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip | bsdtar -xvf- -C ~/Library/Fonts

    # defaults import com.apple.finder osx/finder/com.apple.finder.plist
    # defaults import com.googlecode.iterm2 osx/iterm2/com.googlecode.iterm2.plist
    defaults write com.apple.dock minimize-to-application -bool true
    defaults write com.apple.dock show-recents -bool false
    # defaults write com.apple.dock magnification -bool true

    # restart dock and finder
    killall Dock Finder
  fi

  printf "\n"
  info "::: Remember to run: rm -f ~/.zcompdump; compinit when finished inside zsh shell"
  info "::: If you are getting permissions problems on OSX, run this: compaudit | xargs chmod g-w"
  printf "\n\n"
}

if [[ $# = 0 ]]; then
  install_system
elif [[ $# = 1 && "$1" = "-h" || "$1" = "--help" ]]; then
  usage
else
  abort "::: Invalid arguments, check the help: install.sh -h"
fi
