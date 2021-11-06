#!/usr/bin/env bash
# documentation for bash: http://wiki.bash-hackers.org/commands/classictest

set -eE

CENTOS_REPO=$(cat <<EOM
[base]
name=CentOS-6.10 - Base
baseurl=https://vault.centos.org/centos/6.10/os/x86_64/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#released updates
[updates]
name=CentOS-6.10 - Updates
baseurl=https://vault.centos.org/centos/6.10/updates/x86_64/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#additional packages that may be useful
[extras]
name=CentOS-6.10 - Extras
baseurl=https://vault.centos.org/centos/6.10/extras/x86_64/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-6.10 - Plus
baseurl=https://vault.centos.org/centos/6.10/centosplus/x86_64/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#contrib - packages by Centos Users
[contrib]
name=CentOS-6.10 - Contrib
baseurl=https://vault.centos.org/centos/6.10/contrib/x86_64/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
EOM
)

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
    info ":::   # install only mysql"
    info ":::   install.sh mysql"
    info "::: "
}

system-detect() {
    # This function will set the following enviroment variables:
    # OS: Operation system, Ej: Darwin, Linux
    # KERNEL: Kervel version, Ej: 2.6.32-696.30.1.el6.x86_64
    # ARCH: System architecture, Ej: x86_64
    # DIST: Distibution ID, Ej: debian, ubuntu, centos, redhat
    # VER: Distribution version: Ej: 18.04, 9.6
    OS=$(uname | tr '[:upper:]' '[:lower:]')
    KERNEL=$(uname -r | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m | tr '[:upper:]' '[:lower:]')
    BASE_DIST=""
    DIST=""
    VER=""

    if [[ "$OS" == "darwin" ]]; then # OSX
        BASE_DIST="macos"
        DIST="macos"
        VER=$(sw_vers -productVersion | tr '[:upper:]' '[:lower:]')
    else # Linux
        if [ -f /etc/os-release ]; then
            BASE_DIST=$(cat /etc/os-release | sed -rn 's/^ID_LIKE="?(\w+)"?.*/\1/p' | tr '[:upper:]' '[:lower:]')
            DIST=$(cat /etc/os-release | sed -rn 's/^ID="?(\w+)"?.*/\1/p' | tr '[:upper:]' '[:lower:]')
            VER=$(cat /etc/os-release | sed -rn 's/^VERSION_ID="?([0-9\.]+)"?.*/\1/p' | tr '[:upper:]' '[:lower:]')
        elif [ -f /etc/redhat-release ]; then
            BASE_DIST="redhat"
            DIST=$(sed -rn 's/^(\w+).*/\1/p' /etc/redhat-release | tr '[:upper:]' '[:lower:]')
            VER=$(sed -rn 's/.*([0-9]+\.[0-9]+).*/\1/p' /etc/redhat-release | tr '[:upper:]' '[:lower:]')
        fi

        if [[ "$DIST" == "debian" || "$DIST" == "ubuntu" ]]; then
            BASE_DIST=debian
        elif [[ "$DIST" == "centos" || "$DIST" == "redhat" || "$DIST" == "redhatenterpriseserver" ]]; then
            BASE_DIST=redhat
        fi

    fi
}

fix-centos6-repos() {
    # must run system-detect first
    if [[ "$BASE_DIST" = "redhat" && "$VER" =~ 6.[0-9]+ ]]; then
        info "::: Fixing CentOS repositories ...\n"
        
        # base
        sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.old
        echo "$CENTOS_REPO" | sudo tee /etc/yum.repos.d/CentOS-Base.repo >/dev/null

        # remove unused repositories
        sudo rm -rf /etc/yum.repos.d/CentOS-fasttrack.repo* /etc/yum.repos.d/CentOS-Vault.repo* \
            /etc/yum.repos.d/CentOS-Debuginfo.repo* /etc/yum.repos.d/CentOS-Media.repo \
            /etc/yum.repos.d/*rpmforge* /etc/yum.repos.d/*rpmfusion*

        # SCL: First pass just in case is already broken
        test -e /etc/yum.repos.d/CentOS-SCLo-scl.repo && {
            sudo cp /etc/yum.repos.d/CentOS-SCLo-scl.repo /etc/yum.repos.d/CentOS-SCLo-scl.repo.old
            sudo sed -e '/mirrorlist=.*/d' \
                -e 's/#\s*baseurl=/baseurl=/' \
                -e "s/baseurl=.*/baseurl=http:\/\/vault.centos.org\/6.10\/sclo\/x86_64\/sclo/g" \
                -i /etc/yum.repos.d/CentOS-SCLo-scl.repo
        }

        test -e /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && {
            sudo cp /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo.old
            sudo sed -e '/mirrorlist=.*/d' \
                -e 's/#\s*baseurl=/baseurl=/' \
                -e "s/baseurl=.*/baseurl=http:\/\/vault.centos.org\/6.10\/sclo\/x86_64\/rh/g" \
                -i /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
        }
        sudo rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-SIG-SCLo || rpm --import keys/scl.key

        # epel and SCL
        if yum -C repolist epel | grep epel; then
            sudo yum -y update ca-certificates nss curl --disablerepo=epel
        else
            sudo yum -y update ca-certificates nss curl
        fi
        sudo yum -y install https://archives.fedoraproject.org/pub/archive/epel/6/x86_64/epel-release-6-8.noarch.rpm centos-release-scl

        # SCL
        test -e /etc/yum.repos.d/CentOS-SCLo-scl.repo && {
            sudo cp /etc/yum.repos.d/CentOS-SCLo-scl.repo /etc/yum.repos.d/CentOS-SCLo-scl.repo.old
            sudo sed -e '/mirrorlist=.*/d' \
                -e 's/#\s*baseurl=/baseurl=/' \
                -e "s/baseurl=.*/baseurl=http:\/\/vault.centos.org\/6.10\/sclo\/x86_64\/sclo/g" \
                -i /etc/yum.repos.d/CentOS-SCLo-scl.repo
        }

        test -e /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && {
            sudo cp /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo.old
            sudo sed -e '/mirrorlist=.*/d' \
                -e 's/#\s*baseurl=/baseurl=/' \
                -e "s/baseurl=.*/baseurl=http:\/\/vault.centos.org\/6.10\/sclo\/x86_64\/rh/g" \
                -i /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
        }

        printf "\n\n"
    fi
}

install-homebrew() {
    if [[ "$BASE_DIST" != "macos" ]]; then
        return
    fi

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
}

install-git() {
    info ":::  Installing Git ...\n"

    if [[ "$BASE_DIST" = "macos" ]]; then
        brew install git
    elif [[ "$BASE_DIST" = "redhat" ]]; then
        if [[ "$VER" =~ 6.[0-9]+ ]]; then
            sudo yum -y install http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm || :
        fi
        sudo yum -y install git
    elif [[ "$BASE_DIST" = "debian" ]]; then
        sudo apt-get -y install git
    else
        abort "::: Unsupported OS: $BASE_DIST"
    fi

    printf "\n\n"
}

install-configs() {
    info "::: Installing dot files ...\n"

    # diable login messages
    touch ~/.hushlogin

    # install our dot files
    test -f ~/.profile && mv ~/.profile ~/.profile.bak
    ln -sf $(pwd)/.profile ~/.profile

    test -f ~/.zprofile && mv ~/.zprofile ~/.zprofile.bak
    ln -sf $(pwd)/.zprofile ~/.zprofile

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

    test -f ~/.nanorc && mv ~/.nanorc ~/.nanorc.bak
    ln -sf $(pwd)/.nanorc ~/.nanorc

    if [[ "$BASE_DIST" = "macos" ]]; then
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

    printf "\n\n"
}

install-apps() {
    info "::: Installing Apps ...\n"
    if [[ "$BASE_DIST" = "macos" ]]; then
        brew upgrade
        brew install bash-completion wget curl htop mc cabextract p7zip xz zlib rpm dpkg subversion pfetch vim \
            pyenv pyenv-virtualenv subversion gnu-tar sox mysql freetds coreutils openssl readline sqlite3 watch \
            ruby telnet nmap httpie

        brew install --cask -f appcleaner acorn anydesk adobe-acrobat-reader google-chrome microsoft-word microsoft-excel \
            microsoft-powerpoint the-unarchiver google-drive wireshark slack 4k-video-downloader 4k-youtube-to-mp3 vlc \
            whatsapp messenger jetbrains-toolbox virtualbox virtualbox-extension-pack handbrake mpv inkscape visual-studio-code \
            viscosity purevpn skype spotify "local" webtorrent transmission balenaetcher vagrant gfxcardstatus

        info "Download and install by hand: CleanMyDrive, Amphetamine, Logitech Options, Magnet\n\n"
    elif [[ "$BASE_DIST" = "redhat" ]]; then
        sudo yum -y install redhat-lsb-core cabextract p7zip p7zip-plugins unrar xz mc htop bash-completion ctags \
            subversion elinks curl wget coreutils telnet nmap net-tools bind-utils
    elif [[ "$BASE_DIST" = "debian" ]]; then
        sudo apt-get -y update
        sudo apt-get -y upgrade
        sudo apt-get -y install lsb-release cabextract p7zip-full xz-utils rpm mc htop bash-completion exuberant-ctags \
            subversion elinks curl wget coreutils telnet nmap net-tools dnsutils psmisc
    else
        abort "::: Unsupported OS"
    fi

    printf "\n\n"
}

install-vim() {
    info "::: Installing vim ...\n"

    if [[ "$BASE_DIST" = "macos" ]]; then
        brew install vim
    elif [[ "$BASE_DIST" = "redhat" ]]; then
        sudo yum -y install vim
    elif [[ "$BASE_DIST" = "debian" ]]; then
        sudo apt-get -y install vim
    else
        abort "::: Unsupported OS: $BASE_DIST"
    fi

    # backup old vim directories
    test -d ~/.vim && {
        rm -rf ~/.vim.bak && mv ~/.vim ~/.vim.bak
    }

    test -f ~/.vimrc && {
        rm -rf .vimrc.bak && mv ~/.vimrc ~/.vimrc.bak
    }

    if [[ ! -d ~/.vim_runtime ]]; then
        git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    fi
    sh ~/.vim_runtime/install_awesome_vimrc.sh

    printf "\n\n"
}

install-zsh() {
    info "::: Installing zsh ...\n"

    if [[ "$BASE_DIST" = "macos" ]]; then
        brew install zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions
    elif [[ "$OS" = "linux" ]]; then
        if [[ "$BASE_DIST" = "redhat" ]]; then
            sudo yum -y install zsh
        elif [[ "$BASE_DIST" = "debian" ]]; then
            sudo apt-get -y install zsh
        else
            abort "::: Unsupported OS: $BASE_DIST"
        fi

        if [[ ! -d ~/.zsh-autosuggestions ]]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh-autosuggestions
        fi

        if [[ ! -d ~/.zsh-syntax-highlighting ]]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh-syntax-highlighting
        fi

        if [[ ! -d ~/.zsh-completions ]]; then
            git clone git://github.com/zsh-users/zsh-completions.git ~/.zsh-completions
        fi
    else
        abort "::: Unsupported OS"
    fi

    # install oh-my-zsh, not using its regular install script
    if [[ ! -d ~/.oh-my-zsh ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # oh-my-zsh installation overwrote our .zshrc, put it back
    test -f ~/.zshrc && mv ~/.zshrc ~/.zshrc.bak
    ln -sf ~/.dotfiles/.zshrc ~/.zshrc

    # change the shell if is not already "zsh"
    TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
    if [[ "$TEST_CURRENT_SHELL" != "zsh" ]]; then
        sudo chsh -s $(grep /zsh$ /etc/shells | tail -1) $USER
    fi

    info "::: Remember to run: rm -f ~/.zcompdump; compinit when finished inside zsh shell"
    printf "\n\n"
}



main() {
    CMDS=()
    if [[ "$1" = "configs" ]]; then
        CMDS=(install-configs)
    elif [[ "$1" = "vim" ]]; then
        CMDS=(install-git install-vim)
    elif [[ "$1" = "zsh" ]]; then
        CMDS=(install-git install-zsh)
    elif [[ "$1" = "apps" ]]; then
        CMDS=(install-git install-apps)
    elif [[ "$1" = "all" ]]; then
        CMDS=(install-git install-apps install-vim install-zsh install-configs)
    else
        abort "::: Invalid arguments, check the help: install.sh -h"
    fi

    system-detect
    if [[ "$1" != "configs" ]]; then
        if [[ "$BASE_DIST" = "macos" ]]; then
            install-homebrew
        elif [[ "$BASE_DIST" = "redhat" && "$VER" =~ 6.[0-9]+ ]]; then
            fix-centos6-repos
        fi
    fi

    for CMD in ${CMDS[*]}; do
        $CMD
    done

    info "Finished, log out and log back in, enjoy!"
}

# parameter check
if [[ $# = 0 ]]; then
    usage
elif [[ $# = 1 ]]; then
    if [[ "$1" = "-h" || "$1" = "--help" ]]; then
        usage
    else
        main $1
    fi
else
    abort "::: Invalid arguments, check the help: install.sh -h"
fi
