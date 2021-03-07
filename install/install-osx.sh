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
brew upgrade
brew install bash-completion wget curl htop mc cabextract p7zip xz rpm git subversion pfetch vim \
    zsh zsh-completions zsh-syntax-highlighting font-consolas-for-powerline font-droid-sans-mono-for-powerline \
    font-inconsolata-dz-for-powerline font-inconsolata-for-powerline font-inconsolata-for-powerline-bold \
    font-menlo-for-powerline font-meslo-for-powerline font-powerline-symbols font-sf-mono-for-powerline vagrant \
    pyenv pyenv-virtualenv

brew install appcleaner acorn anydesk adobe-acrobat-reader google-chrome microsoft-word microsoft-excel \
    microsoft-powerpoint the-unarchiver google-drive wireshark slack 4k-video-downloader 4k-youtube-to-mp3 vlc \
    whatsapp jetbrains-toolbox virtualbox virtualbox-extension-pack handbrake mpv inkscape visual-studio-code \
    viscosity purevpn skype spotify "local" webtorrent transmission balenaetcher

# CleanMyDrive, Amphetamine, Logitech Options, Magnet


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


########################################################################################################################
# Config OSX
########################################################################################################################

# disable sudo password for admins
read -r -d '' SUDO_NOPASSWD << 'EOM'
Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports
Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart
Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports
%admin ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE
%admin ALL=(ALL) NOPASSWD: ALL
EOM
echo "$SUDO_NOPASSWD" | sudo tee /etc/sudoers.d/nopasswd > /dev/null

# finder


# enable remote ssh access and enable network time
sudo systemsetup -setremotelogin on
sudo systemsetup -setusingnetworktime on


# change the shell if is not already "zsh"
TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
if [[ "$TEST_CURRENT_SHELL" != "zsh" ]]; then
    sudo chsh -s $(grep /zsh$ /etc/shells | tail -1)
fi

