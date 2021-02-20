#!/usr/bin/env bash
set -e
cd $(dirname $(realpath $0))


test $(uname) = "Darwin" || {
    printf "::: ERROR: This is script must be run only in OSX!\n\n"
    exit 1
}


########################################################################################################################
# Install Homebrew
########################################################################################################################
command -v brew >/dev/null 2>&1 || {
    # install Homebrew
    printf "::: Installing Homebrew ...\n\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}


########################################################################################################################
# Install Programs
########################################################################################################################
printf "::: Installing Apps ...\n\n"
brew update
brew upgrade
brew install bash-completion wget curl htop mc cabextract p7zip xz rpm git subversion pfetch vim \
    zsh zsh-completions


########################################################################################################################
# Configure Vim
########################################################################################################################
# backup old vim directories
test -d ~/.vim && {
    printf "::: Backing up ~/.vim config directory!\n\n"
    rm -rf ~/.vim.bak
    mv ~/.vim ~/.vim.bak
}

test -f ~/.vimrc && {
    printf "::: Backing up ~/.vimrc config file!\n\n"
    rm -rf .vimrc.bak
    mv ~/.vimrc ~/.vimrc.bak
}

if [[ -d ~/.vim_runtime ]]; then
    printf "::: Found existing vim runtime, updating it ...\n\n"
    pushd ~/.vim_runtime > /dev/null 2>&1
    git pull --rebase
    python update_plugins.py
    popd > /dev/null 2>&1
else
    printf "::: Installing vim runtime ...\n\n"
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
fi


########################################################################################################################
# Configure ZSH (OH MY ZSH)
########################################################################################################################
# install oh-my-zsh, not using its regular install script
if [[ -d ~/.oh-my-zsh ]]; then
    printf "::: Found existing Oh-My-Zsh install, updating it ...\n\n"
    omz update
else
    printf "::: Installing O-My-Zsh ...\n\n"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# force rebuild `zcompdump`:
rm -f ~/.zcompdump; compinit


########################################################################################################################
# Install .dotfiles and set zsh as shell
########################################################################################################################
# backup old configurations
test -f ~/.profile && {
    mv ~/.profile ~/.profile.bak
    ln -sf $(realpath ..)/.profile ~/.profile
}

test -f ~/.bashrc && {
    mv ~/.bashrc ~/.bashrc.bak
    ln -sf $(realpath ..)/.bashrc ~/.bashrc
}
    
test -f ~/.dircolors && {
    mv ~/.dircolors ~/.dircolors.bak
    ln -sf $(realpath ..)/.dircolors ~/.dircolors
}

test -f ~/.inputrc && {
    mv ~/.inputrc ~/.inputrc.bak
    ln -sf $(realpath ..)/.inputrc ~/.inputrc
}

test -f ~/.Xdefaults && {
    mv ~/.Xdefaults ~/.Xdefaults.bak
    ln -sf $(realpath ..)/.Xdefaults ~/.Xdefaults
}

test -f ~/.gitconfig && {
    mv ~/.gitconfig ~/.gitconfig.bak
    ln -sf $(realpath ..)/.gitconfig ~/.gitconfig
}

test -f ~/.gitignore && {
    mv ~/.gitignore ~/.gitignore.bak
    ln -sf $(realpath ..)/.gitignore ~/.gitignore
}

test -f ~/.zshrc && {
    mv ~/.zshrc ~/.zshrc.bak
    ln -sf $(realpath ..)/.zshrc ~/.zshrc
}

# change the shell if is not already "zsh"
TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
if [[ "$TEST_CURRENT_SHELL" != "zsh" ]]; then
    sudo chsh -s $(grep /zsh$ /etc/shells | tail -1)
fi

