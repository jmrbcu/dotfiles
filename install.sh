#!/usr/bin/env bash
set -eE
cd $(dirname "$0")

# include files
. lib.sh

usage() {
    info "::: Description:"
    info ":::   Installs base system for TotalTrack"
    info "::: "
    info "::: Supported systems:"
    info ":::   Debian, Ubuntu, CentOS and RedHat."
    info "::: "
    info "::: Usage:"
    info ":::   install.sh [-h|--help] | [base | mysql | ftpd | dotfiles | fix-repos | repos | fs | oa | tt | all]"
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
    info ":::   # install only mysql"
    info ":::   install.sh mysql"
    info "::: "
}

install-homebrew() {
    if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install
    fi

    command -v brew >/dev/null 2>&1 || {
        # install Homebrew
        printf "::: Installing Homebrew ...\n\n"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        printf "\n\n"
    }
}

install-configs() {
    # diable login messages
    info "::: Disabling login messages"
    touch ~/.hushlogin

    # install our dot files
    info "::: Installing our dot files"
    test -f ~/.profile && mv ~/.profile ~/.profile.bak
    ln -sf $(pwd)/.profile ~/.profile

    test -f ~/.bashrc && mv ~/.bashrc ~/.bashrc.bak
    ln -sf $(pwd)/.bashrc ~/.bashrc

    test -f ~/.dircolors && mv ~/.dircolors ~/.dircolors.bak
    ln -sf $(pwd)/.dircolors ~/.dircolors

    test -f ~/.inputrc && mv ~/.inputrc ~/.inputrc.bak
    ln -sf $(pwd)/.inputrc ~/.inputrc

    test -f ~/.Xdefaults && mv ~/.Xdefaults ~/.Xdefaults.bak
    ln -sf $(pwd)/.Xdefaults ~/.Xdefaults

    test -f ~/.gitconfig && mv ~/.gitconfig ~/.gitconfig.bak
    ln -sf $(pwd)/.gitconfig ~/.gitconfig

    test -f ~/.gitignore && mv ~/.gitignore ~/.gitignore.bak
    ln -sf $(pwd)/.gitignore ~/.gitignore

    test -f ~/.zshrc && mv ~/.zshrc ~/.zshrc.bak
    ln -sf $(pwd)/.zshrc ~/.zshrc

    if [[ "$OS" = "darwin" ]]; then
        info "::: Restoring Finder configs" && defaults import com.apple.finder osx/finder/com.apple.finder.plist
        info "::: Restoring iTerm2 configs" && defaults import com.googlecode.iterm2 osx/iterm2/com.googlecode.iterm2.plist

        # dock
        defaults write com.apple.dock minimize-to-application -bool true
        defaults write com.apple.dock show-recents -bool false
        defaults write com.apple.dock magnification -bool true

        # disable sudo password for admins
        if [[ ! -f /etc/sudoers.d/nopasswd ]]; then
            echo "Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports" | sudo tee -a /etc/sudoers.d/nopasswd >/dev/null
            echo "Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart" | sudo tee -a /etc/sudoers.d/nopasswd >/dev/null
            echo "Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports" | sudo tee -a /etc/sudoers.d/nopasswd >/dev/null
            echo "%admin ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE" | sudo tee -a /etc/sudoers.d/nopasswd >/dev/null
            echo "%admin ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/nopasswd >/dev/null
        fi

        # restart dock and finder
        killall Dock Finder
    fi
}

install-vim() {
    info "::: Installing vim ..."
    if [[ "$OS" = "darwin" ]]; then
        # install homebrew if is not installed
        install-homebrew
        brew list vim >/dev/null 2>&1 || brew install vim
    elif command -v yum >/dev/null 2>&1; then
        sudo yum -y install vim
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get -y install vim
    else
        abort "::: Unsupported OS"
    fi

    # backup old vim directories
    test -d ~/.vim && {
        info "::: Backing up ~/.vim config directory!"
        rm -rf ~/.vim.bak && mv ~/.vim ~/.vim.bak
    }

    test -f ~/.vimrc && {
        info "::: Backing up ~/.vimrc config file!"
        rm -rf .vimrc.bak && mv ~/.vimrc ~/.vimrc.bak
    }

    if [[ -d ~/.vim_runtime ]]; then
        info "::: Found existing vim runtime, updating it ..."
    else
        info "::: Installing vim runtime ..."
        git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
        sh ~/.vim_runtime/install_awesome_vimrc.sh
    fi
}

install-zsh() {
    info "::: Installing zsh ..."
    if [[ "$OS" = "darwin" ]]; then
        # install homebrew if is not installed
        install-homebrew
        brew install zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions
    elif command -v yum >/dev/null 2>&1; then
        sudo yum -y install http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm
        sudo yum -y install git zsh
        if [[ ! -d ~/.zsh-autosuggestions ]]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh-autosuggestions
        fi 

        if [[ ! -d ~/.zsh-syntax-highlighting ]]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh-syntax-highlighting
        fi

        if [[ ! -d ~/.zsh-completions ]]; then
            git clone git://github.com/zsh-users/zsh-completions.git ~/.zsh-completions
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get -y install zsh zsh-autosuggestions zsh-syntax-highlighting
        if [[ ! -d ~/.zsh-completions ]]; then
            git clone git://github.com/zsh-users/zsh-completions.git ~/.zsh-completions
        fi
    else
        abort "::: Unsupported OS"
    fi

    # install oh-my-zsh, not using its regular install script
    if [[ -d ~/.oh-my-zsh ]]; then
        info "::: Found existing Oh-My-Zsh install"
    else
        info "::: Installing Oh-My-Zsh ...\n"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # oh-my-zsh installation overwrote out .zshrc, put it back
    test -f ~/.zshrc && mv ~/.zshrc ~/.zshrc.bak
    ln -sf $(pwd)/.zshrc ~/.zshrc

    info "::: Remember to run: rm -f ~/.zcompdump; compinit when finished inside zsh shell"

    # change the shell if is not already "zsh"
    TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
    if [[ "$TEST_CURRENT_SHELL" != "zsh" ]]; then
        sudo chsh -s $(grep /zsh$ /etc/shells | tail -1) $USER
    fi
}

install-apps() {
    if [[ "$OS" = "darwin" ]]; then
        info "::: Installing Apps ...\n\n"
        brew upgrade
        brew install bash-completion wget curl htop mc cabextract p7zip xz rpm git subversion pfetch vim \
            pyenv pyenv-virtualenv subversion gnu-tar sox mysql coreutils

        info "\n\n::: Installing Cask Apps ...\n\n"
        brew install --cask -f appcleaner acorn anydesk adobe-acrobat-reader google-chrome microsoft-word microsoft-excel \
            microsoft-powerpoint the-unarchiver google-drive wireshark slack 4k-video-downloader 4k-youtube-to-mp3 vlc \
            whatsapp messenger jetbrains-toolbox virtualbox virtualbox-extension-pack handbrake mpv inkscape visual-studio-code \
            viscosity purevpn skype spotify "local" webtorrent transmission balenaetcher vagrant gfxcardstatus turbo-boost-switcher

        info "Download and install by hand: CleanMyDrive, Amphetamine, Logitech Options, Magnet\n\n"
    elif command -v yum >/dev/null 2>&1; then
        sudo yum -y install redhat-lsb-core cabextract p7zip p7zip-plugins unrar xz mc htop bash-completion ctags \
            git subversion elinks curl wget coreutils
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get -y update
        sudo apt-get -y install lsb-release cabextract p7zip-full xz-utils rpm mc htop bash-completion exuberant-ctags \
            git subversion elinks curl wget coreutils
    else
        abort "::: Unsupported OS"
    fi
}

# detect OS
system-detect

# parameter check
if [[ $# = 0 ]]; then
    usage
elif [[ $# = 1 ]]; then
    if [[ "$1" = "-h" || "$1" = "--help" ]]; then
        usage
    elif [[ "$1" = "configs" ]]; then
        install-configs
    elif [[ "$1" = "vim" ]]; then
        fix-centos6-repos
        install-vim
    elif [[ "$1" = "zsh" ]]; then
        fix-centos6-repos
        install-zsh
    elif [[ "$1" = "apps" ]]; then
        fix-centos6-repos
        install-apps
    elif [[ "$1" = "all" ]]; then
        fix-centos6-repos
        install-configs
        install-vim
        install-apps
        install-zsh
    else
        error "::: Invalid options: $*"
        usage
        exit 1
    fi
else
    error "::: Invalid options: $*"
    usage
    exit 1
fi
