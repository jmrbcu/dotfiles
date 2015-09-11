if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    # install command line tools
    xcode-select --install

    # install homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew doctor

    # add some brew repositories
    brew tap caskroom/cask
    brew update

    # install a lot of apps 
    brew install mc xz elinks bash-completion
    brew install git

    # htop
    brew install htop
    sudo chown root:wheel /usr/local/Cellar/htop-osx/0.8.2.2/bin/htop
    sudo chmod u+s /usr/local/Cellar/htop-osx/0.8.2.2/bin/htop

    # mysql
    brew install mysql
    mysql.server start
    mysql_secure_installation
    mysql.server stop

    # python
    brew install python
    pip install --upgrade setuptools
    pip install --upgrade pip

    # zsh
    brew install zsh
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

    for rcfile in `ls "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/z*`; do
      ln -s $rcfile ~/.${rcfile##*/};
    done

    cp zpresto_config/* ~/.zprezto/runcoms/

    # change the shell to zsh
    chsh -s /bin/zsh

    # vim
    brew install --override-system-vi vim
else
    # Do something under Linux platform
    if grep --quiet CentOS /etc/issue ; then
        sudo yum install zsh;
    elif grep --quiet Debian /etc/issue ; then
        sudo aptitude install zsh;
    elif grep --quiet Arch /etc/issue ; then
        sudo pacman -S zsh;
    else
        echo "Unsupported OS, exiting..."
        exit 1
    fi
fi

# general configuration files
ln -sf `pwd`/.Xdefaults ~/.Xdefaults
ln -sf `pwd`/.gitconfig ~/.gitconfig
ln -sf `pwd`/.gitignore ~/.gitignore

# bash configuration files
mv ~/.bashrc ~/.bashrc_old
mv ~/.profile ~/.profile_old

ln -sf `pwd`/.bashrc ~/.bashrc
ln -sf `pwd`/.inputrc ~/.inputrc
ln -sf `pwd`/.profile ~/.profile
ln -sf `pwd`/.dircolors ~/.dircolors

# vim configuration
git clone https://github.com/timss/vimconf.git ~/.vim
ln -sf ~/.vim/.vimrc ~/.vimrc

