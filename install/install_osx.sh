#!/usr/bin/env bash

# install error exit trap
trap "exit 1" ERR

# move to script directory so all relative paths work
CURRENT_DIR="$(dirname "$0")"
cd $CURRENT_DIR

. ./utils.sh


install_common() {
    # install command line tools
    xcode-select --install
    
    # install common programs
    header "Installing common programs (mc, htop, git, etc...)"
    brew update
    brew upgrade
    brew install install cabextract p7zip xz rpm mc htop bash-completion ctags git subversion elinks wget neofetch \
                         python@2 python ipython@5 ipython|| exit 1
}


install_vim() {
    header "Installing Vim"
    brew install git vim || exit 1

    # backup old vim directories
    if [ -d ~/.vim.bak ]; then
        warning "Removing old vim backup directory: ~/.vim.bak";
        rm -rf ~/.vim.bak
    fi

    if [ -d ~/.vim ]; then
        warning "Backing up old vim config directory: ~/.vim ==> ~/.vim.bak";
        mv ~/.vim ~/.vim.bak
    fi

    if [ -f ~/.vimrc ] || [ -h ~/.vimrc ]; then
        warning "Backing up old vim config file: ~/.vimrc ==> ~/.vimrc.bak";
        mv ~/.vimrc ~/.vimrc.bak
    fi

    # install vim configuration system
    git clone https://github.com/timss/vimconf.git ~/.vim || exit 1

    info "Linking our .vimrc: ~/.vimrc ==> ~/.vim/.vimrc"
    ln -sf ~/.vim/.vimrc ~/.vimrc
}


install_zsh() {
    # install zsh
    header "Installing ZSH"

    # install zsh and oh-my-zsh
    brew install install zsh zsh-completions || exit 1

    # install oh-my-zsh, not using its regular install script
    if [ ! -d ~/.oh-my-zsh ]; then
        git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh || exit 1
    else
        warning "Existing install of Oh-My-ZSH was found, skipping install"
    fi

    if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
        warning "Backing up old zsh config file: ~/.zshrc ==> ~/.zshrc.bak";
        mv ~/.zshrc ~/.zshrc.bak;
    fi

    info "Using the Oh My Zsh template file as ~/.zshrc"
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

    # force rebuild `zcompdump`:
    rm -f ~/.zcompdump; compinit
}


install_config() {
    header "Installing our configuration files"
    CONFIG_DIR=$CURRENT_DIR/..

    # backup old configurations
    if [ -f ~/.profile ] || [ -h ~/.profile ]; then
        warning "Backing up old profile config file: ~/.profile ==> ~/.profile.bak";
        mv ~/.profile ~/.profile.bak
    fi
    info "Installing .profile config file\n"
    cp $CONFIG_DIR/.profile ~/.profile

    if [ -f ~/.bashrc ] || [ -h ~/.bashrc ]; then
        warning "Backing up old bash config file: ~/.bashrc ==> ~/.bashrc.bak";
        mv ~/.bashrc ~/.bashrc.bak
    fi
    info "Installing .bashrc config file\n"
    cp $CONFIG_DIR/.bashrc ~/.bashrc

    if [ -f ~/.dircolors ] || [ -h ~/.dircolors ]; then
        warning "Backing up old dircolors config file: ~/.dircolors ==> ~/.dircolors.bak";
        mv ~/.dircolors ~/.dircolors.bak
    fi
    info "Installing .dircolors config file\n"
    cp $CONFIG_DIR/.dircolors ~/.dircolors

    if [ -f ~/.inputrc ] || [ -h ~/.inputrc ]; then
        warning "Backing up old inputrc config file: ~/.inputrc ==> ~/.inputrc.bak";
        mv ~/.inputrc ~/.inputrc.bak
    fi
    info "Installing .inputrc config file\n"
    cp $CONFIG_DIR/.inputrc ~/.inputrc

    if [ -f ~/.Xdefaults ] || [ -h ~/.Xdefaults ]; then
        warning "Backing up old Xdefaults config file: ~/.Xdefaults ==> ~/.Xdefaults.bak";
        mv ~/.Xdefaults ~/.Xdefaults.bak
    fi
    info "Installing .Xdefaults config file\n"
    cp $CONFIG_DIR/.Xdefaults ~/.Xdefaults

    if [ -f ~/.gitconfig ] || [ -h ~/.gitconfig ]; then
        warning "Backing up old gitconfig config file: ~/.gitconfig ==> ~/.gitconfig.bak";
        mv ~/.gitconfig ~/.gitconfig.bak
    fi
    info "Installing .gitconfig config file\n"
    cp $CONFIG_DIR/.gitconfig ~/.gitconfig
    

    if [ -f ~/.gitignore ] || [ -h ~/.gitignore ]; then
        warning "Backing up old gitignore config file: ~/.gitignore ==> ~/.gitignore.bak";
        mv ~/.gitignore ~/.gitignore.bak
    fi
    info "Installing .gitignore config file\n"
    cp $CONFIG_DIR/.gitignore ~/.gitignore

    if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
        warning "Backing up old zsh config file: ~/.zshrc ==> ~/.zshrc.bak";
        mv ~/.zshrc ~/.zshrc.bak
    fi
    info "Installing .zshrc config file\n"
    cp $CONFIG_DIR/.zshrc ~/.zshrc

    # nuke MOTD that is shown upon successfully login
    info "Removing MOTD message\n"
    sed -i '/^[^#]*\<pam_motd.so\>/s/^/#/' /etc/pam.d/sshd
}


main() {
    # detect the system
    system_detect
    if [ "$OS" != "osx" ]; then
        abort "Unsupported operating system: $OS"
    fi

    command -v brew >/dev/null 2>&1 || {
        # install Homebrew
        header "Installing Homebrew"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    }

    # install common programs
    install_common

    # install vim
    install_vim

    # install zsh
    install_zsh

    # install our config files
    install_config

    # change the shell if is not already "zsh"
    TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
    if [[ "$TEST_CURRENT_SHELL" != "zsh" ]]; then
        sudo chsh -s $(grep /zsh$ /etc/shells | tail -1)
    fi
}


# run the script just if we are executing it from the command line, not sourcing it
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
