# install command line tools
xcode-select --install

# install homebrew
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
brew doctor

# install a lot of apps
brew install mc xz elinks bash-completion
brew install  --with-ares --with-gssapi --with-idn --with-libmetalink --with-openssl --with-rtmp --with-ssh curl
brew install --with-brewed-curl --with-brewed-openssl  git

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


# zsh and zprezto
brew install zsh
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

chsh -s /bin/zsh
