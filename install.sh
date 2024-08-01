#!/usr/bin/env bash
# documentation for bash: http://wiki.bash-hackers.org/commands/classictest

set -eE
cd "$(dirname "$0" 2>/dev/null)"
trap 'abort "Unexpected error on line: $LINENO: ${BASH_COMMAND}"' ERR

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

if [[ "$OS" = "darwin" ]]; then
  command -v brew >/dev/null 2>&1 || {
    info "*** Installing Homebrew ***\n"

    # install xcode command line tools, needed for homebrew
    if ! xcode-select -p >/dev/null 2>&1; then
      xcode-select --install
    fi

    # install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    printf "\n\n"
  }
fi

info "*** Installing Apps ***\n"
if command -v brew >/dev/null; then
  brew update
  # brew upgrade
  brew install git zsh bash-completion wget curl htop btop mc cabextract p7zip xz zlib rpm dpkg vim \
    gnu-tar coreutils fzf

  brew install appcleaner the-unarchiver google-chrome adobe-acrobat-reader google-drive anydesk spotify whatsapp 
elif command -v apt-get >/dev/null; then
  sudo apt-get -y update
  sudo apt-get -y upgrade
  sudo apt-get -y install git zsh bash-completion wget curl htop btop mc cabextract p7zip-full xz-utils rpm vim \
    coreutils telnet nmap net-tools dnsutils psmisc fzf lsb-release

  printf "\n\n"
else
  abort "::: Unsupported OS"
fi

info "*** Installing Oh My ZSH ***\n"

# remove p10k (unsupported)
test -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" && rm -rf "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
test -f "$HOME/.p10k.zsh" && rm -f "$HOME/.p10k.zsh"

# install oh-my-zsh
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


# install our config files
info "*** Installing configuration files ***\n"
touch "$HOME/.hushlogin"
for conf in .zshrc .bashrc .inputrc .gitconfig .gitignore .nanorc .vimrc; do
  test -f "$HOME/$conf" && {
    mv "$HOME/$conf" "$HOME/$conf.bak"
    info "Backing up '$HOME/$conf' -> '$HOME/$conf.bak'"
  }

  info "Installing '$HOME/$conf'"
  ln -sf "$(pwd)/$conf" "$HOME/$conf"
done

# OS specific stuff
if [[ "$OS" = "darwin" ]]; then
  # defaults read com.apple.finder 
  # defaults read com.googlecode.iterm2 
  defaults write com.apple.dock minimize-to-application -bool true
  defaults write com.apple.dock show-recents -bool false
  killall Dock
fi

# change the shell if is not already "zsh"
TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
if [[ "$TEST_CURRENT_SHELL" != "zsh" ]]; then
  sudo chsh -s "$(grep zsh$ /etc/shells | tail -1)" "$USER"
fi

printf "\n"
info "::: Remember to run: rm -f ~/.zcompdump; compinit when finished inside zsh shell"
info "::: If you are getting permissions problems on OSX, run this: compaudit | xargs chmod g-w"
printf "\n\n"
