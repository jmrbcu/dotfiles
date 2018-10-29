. ./colors.sh

# install common stuff
header "Installing common stuff"
yum -y install cabextract p7zip p7zip-plugins unrar xz mc htop bash-completion ctags git subversion
               
# install python 2 and 3
PYTHON2_VER=2.7.15
PYTHON2_URL="https://www.python.org/ftp/python/$PYTHON2_VER/Python-$PYTHON2_VER.tgz"

PYTHON3_VER=3.7.1
PYTHON3_URL="https://www.python.org/ftp/python/$PYTHON3_VER/Python-$PYTHON3_VER.tgz"

pushd "/usr/src"
yum -y install zlib-devel bzip2-devel xz-devel lzma-devel expat-devel gmp-devel openssl-devel sqlite-devel \
               ncurses-devel readline-devel gdbm-devel db4-devel libpcap-devel libffi-devel pkgconfig

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
yum -y install vim

# backup old vim directories
test -e ~/.vim && mv ~/.vim ~/.vim-save
test -e ~/.vimrc && mv ~/.vimrc ~/.vimrc-save

git clone https://github.com/timss/vimconf.git ~/.vim
ln -sf ~/.vim/.vimrc ~/.vimrc

# install zsh
header "Installing ZSH"
yum -y install zsh

# backup old configurations
test -e ~/.oh-my-zsh && mv ~/.oh-my-zsh ~/.oh-my-zsh-save
test -e ~/.zshrc && mv ~/.zshrc ~/.zshrc-save

# install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# link our config files
header "Installing our configuration files"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ln -sf $DIR/.bashrc ~/.bashrc
ln -sf $DIR/.dircolors ~/.dircolors
ln -sf $DIR/.inputrc ~/.inputrc
ln -sf $DIR/.profile ~/.profile
ln -sf $DIR/.Xdefaults ~/.Xdefaults
ln -sf $DIR/.gitconfig ~/.gitconfig
ln -sf $DIR/.gitignore ~/.gitignore