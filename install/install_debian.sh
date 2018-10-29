#!/bin/bash

. ./colors.sh

# install common stuff
header "Installing common stuff"
apt -y install cabextract p7zip-full xz-utils rpm mc htop bash-completion exuberant-ctags \
               bash-completion git subversion 

# install python 2 and 3
PYTHON2_VER=2.7.15
PYTHON2_URL="https://www.python.org/ftp/python/$PYTHON2_VER/Python-$PYTHON2_VER.tgz"

PYTHON3_VER=3.7.1
PYTHON3_URL="https://www.python.org/ftp/python/$PYTHON3_VER/Python-$PYTHON3_VER.tgz"

pushd "/usr/src"
apt -y install build-essential pkg-config zlib1g-dev libbz2-dev liblzma-dev libexpat1-dev libgmp-dev libssl-dev \
       libsqlite3-dev libncurses5-dev libreadline-dev libgdbm-dev libffi-dev libpcap-dev libmpdec-dev

# python 2 build and install
header "Installing Python v$PYTHON2_VER"
curl $PYTHON2_URL -o Python-$PYTHON2_VER.tgz
tar -xpf Python-$PYTHON2_VER.tgz
pushd Python-$PYTHON2_VER
./configure --prefix="/usr/local" --enable-shared --with-threads --with-computed-gotos --enable-ipv6 \
            --enable-unicode=ucs4  --with-lto --with-system-expat --with-system-ffi LDFLAGS='-Wl,-rpath=/usr/local/lib'
make -j
make altinstall
popd

# python3 build and install
header "Installing Python v$PYTHON3_VER"
curl $PYTHON3_URL -o Python-$PYTHON3_VER.tgz
tar -xpf Python-$PYTHON3_VER.tgz
pushd Python-$PYTHON3_VER
./configure --prefix="/usr/local" --enable-shared --with-computed-gotos --enable-ipv6 --with-lto --with-system-expat \
            --enable-loadable-sqlite-extensions --with-system-ffi --with-system-libmpdec \
            LDFLAGS='-Wl,-rpath=/usr/local/lib'
make -j
make altinstall
popd

# install pip for python 2 and 3
header "Installing pip2, pip3, virtualenv and virtualenvwrapper"
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
/usr/local/bin/python2.7 get-pip.py
/usr/local/bin/python3.7 get-pip.py
/usr/local/bin/pip3 install --upgrade virtualenv virtualenvwrapper
popd

header "Installing NeoFetch"
wget -c https://github.com/dylanaraps/neofetch/releases/download/5.0.0/neofetch -o /usr/local/bin/neofetch
chmod 755 /usr/local/bin/neofetch

header "Installing httpie"
/usr/local/bin/pip3 install --upgrade httpie

header "Installing ipython2 and ipython3"
/usr/local/bin/pip2 install --upgrade ipython
/usr/local/bin/pip3 install --upgrade ipython

header "Installing vim"
apt -y install vim

# backup old vim directories
test -e ~/.vim && mv ~/.vim ~/.vim-save
test -e ~/.vimrc && mv ~/.vimrc ~/.vimrc-save

git clone https://github.com/timss/vimconf.git ~/.vim
ln -sf ~/.vim/.vimrc ~/.vimrc

# install zsh
header "Installing ZSH"
apt -y install zsh

# install oh my zsh
git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

# backup old configurations
test -e ~/.oh-my-zsh && mv ~/.oh-my-zsh ~/.oh-my-zsh-save
test -e ~/.zshrc && mv ~/.zshrc ~/.zshrc-save
test -e ~/.bashrc && mv ~/.bashrc ~/.bashrc-save
test -e ~/.dircolors && mv ~/.dircolors ~/.dircolors-save
test -e ~/.inputrc && mv ~/.inputrc ~/.inputrc-save
test -e ~/.profile && mv ~/.profile ~/.profile-save
test -e ~/.Xdefaults && mv ~/.Xdefaults ~/.Xdefaults-save
test -e ~/.gitconfig && mv ~/.gitconfig ~/.gitconfig-save
test -e ~/.gitignore && mv ~/.gitignore ~/.gitignore-save

# link our config files
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ln -sf $DIR/.bashrc ~/.bashrc
ln -sf $DIR/.dircolors ~/.dircolors
ln -sf $DIR/.inputrc ~/.inputrc
ln -sf $DIR/.profile ~/.profile
ln -sf $DIR/.Xdefaults ~/.Xdefaults
ln -sf $DIR/.gitconfig ~/.gitconfig
ln -sf $DIR/.gitignore ~/.gitignore

# If this user's login shell is not already "zsh", attempt to switch.
TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
    chsh -s $(grep /zsh$ /etc/shells | tail -1)
fi