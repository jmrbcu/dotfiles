#!/usr/bin/env bash

# documentation for bash: http://wiki.bash-hackers.org/commands/classictest

# check for color support
if [ -t 1 ]; then

    # see if it supports colors...
    ncolors=$(tput colors)

    if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
        normal="$(tput sgr0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
    fi
fi

header () {
    printf "\n"
    printf "${yellow}#####################################################################${normal}\n"
    printf "${yellow}$1${normal}\n"
    printf "${yellow}#####################################################################${normal}\n"
    printf "\n"
}


info () {
    printf "${normal}[${cyan}INFO${normal}] ${green}$1${normal}\n"
}


error () {
    printf "${normal}[${cyan}ERROR${normal}] ${red}$1${normal}\n" >&2   ## Send message to stderr. Exclude >&2 if you don't want it that way.
}


warning () {
    printf "${normal}[${cyan}WARN${normal}] ${magenta}$1${normal}\n" >&2   ## Send message to stderr. Exclude >&2 if you don't want it that way.
}


lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}


system_detect() {
    # This function will set the following enviroment variables:
    # OS: Operation system, Ej: windows, mac, linux, etc
    # KERNEL: Kervel version, Ej: 2.6.32-696.30.1.el6.x86_64
    # ARCH: System architecture, Ej: x86_64
    # DIST: Distibution ID, Ej: debian, ubuntu, centos, redhat
    # VER: Distribution version: Ej: 18.04, 9.6
    
	OS=`lowercase \`uname\``
	KERNEL=`lowercase \`uname -r\``
	ARCH=`lowercase \`uname -m\``
    DIST=""
    VER=""

	if [ "$OS" = "windowsnt" ]; then
		OS="windows"
	elif [ "$OS" = "darwin" ]; then
		OS="osx"
	else # linux
        command -v lsb_release >/dev/null 2>&1 || {
            info "Installing lsb_release in order to detect the system..."
            if command -v apt >/dev/null 2>&1; then
                apt -y install lsb_release >/dev/null 2>&1
            elif command -v yum >/dev/null 2>&1; then
                yum -y install redhat-lsb-core >/dev/null 2>&1
            fi

            command -v lsb_release >/dev/null 2>&1 || {
                error "Cannot install lsb_release, please, install it before running this script"
                exit 1
            }
        }

        DIST=`lowercase \`lsb_release -s -i\``
        VER=`lowercase \`lsb_release -s -r\``
	fi

    readonly OS
    readonly KERNEL
    readonly ARCH
    readonly DIST
    readonly VER
}


abort () {
    # Usage: 
    #   abort "This is an error message"
    #   abort ${BASH_SOURCE[0]} $LINENO "Invalid stuff..."

    if [ $# = 3 ]; then
        error "$1:$2 $3"
    else
        error "$1"
    fi
    exit 1  
}



install_python () {
    PYTHON_VER=$1
    PYTHON_PREFIX=/usr/local
    PYTHON_URL="https://www.python.org/ftp/python"
    PYTHON_MAJOR=`echo $PYTHON_VER|cut -d '.' -f 1-1`
    PYTHON_MINOR=`echo $PYTHON_VER|cut -d '.' -f 2-2`
    PYTHON_EXEC="python$PYTHON_MAJOR.$PYTHON_MINOR"
    PYTHON_OPTS="--prefix=$PYTHON_PREFIX --enable-shared --with-threads --with-computed-gotos --enable-ipv6 \
                --with-fpectl --enable-unicode=ucs4 --with-lto --with-dbmliborder=bdb:gdbm --with-system-expat \
                --with-system-ffi"

    # yum -y install zlib-devel bzip2-devel xz-devel lzma-devel expat-devel gmp-devel openssl-devel sqlite-devel \
    #            ncurses-devel readline-devel gdbm-devel db4-devel libpcap-devel libffi-devel pkgconfig
    PYTHON_DEPS="build-essential pkg-config libssl-dev zlib1g-dev libbz2-dev liblzma-dev xz-utils libreadline-dev \
                 libsqlite3-dev llvm libncurses5-dev libncursesw5-dev libxml2-dev libxmlsec1-dev libffi-dev libdb-dev \
                 libgdbm-dev  libexpat1-dev curl"

    # add some options specifically for python 3
    if [ -n $PYTHON_MAJOR ] && [ $PYTHON_MAJOR == "3" ]; then
        PYTHON_DEPS="$PYTHON_DEPS libmpdec-dev"
        PYTHON_OPTS="$PYTHON_OPTS --enable-loadable-sqlite-extensions --with-system-libmpdec"
    fi

    # compile and install python from source
    header "Installing Python v$PYTHON_VER"
    if [ ! -e "/usr/local/bin/python$PYTHON_MAJOR.$PYTHON_MINOR" ]; then
        # install python build dependencies
        apt -y install $PYTHON_DEPS

        # got to the build dir
        pushd /usr/src > /dev/null

        # download python source code and abort if not found or there is any error downloading it
        curl "$PYTHON_URL/$PYTHON_VER/Python-$PYTHON_VER.tgz" -o Python-$PYTHON_VER.tgz
        if [[ $? -ne 0 ]]; then
            abort ${BASH_SOURCE[0]} $LINENO "Invalid version of python: $PYTHON_VER"
        fi

        # extract the source code
        tar -xpf Python-$PYTHON_VER.tgz

        # start the build process
        pushd Python-$PYTHON_VER > /dev/null
        ./configure $PYTHON_OPTS CFLAGS="-O2" LDFLAGS="-Wl,-rpath=$PYTHON_PREFIX/lib"
        make -j
        make altinstall
        popd > /dev/null
        popd > /dev/null
    else
        warning "Found existing Python v$PYTHON_MAJOR.$PYTHON_MINOR at /usr/local/bin, skipping installation..."
    fi

    # install pip
    header "Installing Pip, Virtualenv and Virtualenvwrapper for python v$PYTHON_VER"
    if [ ! -e "/usr/local/bin/pip$PYTHON_MAJOR" ] && [ ! -e "/usr/local/bin/pip$PYTHON_MAJOR.$PYTHON_MINOR" ]; then
        pushd /usr/src > /dev/null
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        $PYTHON_PREFIX/bin/$PYTHON_EXEC get-pip.py
        $PYTHON_PREFIX/bin/"pip$PYTHON_MAJOR.$PYTHON_MINOR" install --upgrade virtualenv virtualenvwrapper
        popd > /dev/null
    else
        warning "Found existing Pip for Python v$PYTHON_MAJOR, skipping installation..."
    fi
}

_python_install_cleanup() {
    rm -rf /usr/src/Python*
    rm -rf /usr/src/get-pip.py
}
trap _python_install_cleanup EXIT



