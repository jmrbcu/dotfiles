#!/usr/bin/env bash

# move to script directory so all relative paths work
CURRENT_DIR="$(dirname "$0")"
cd $CURRENT_DIR

. ./utils.sh

# detect the system
system_detect
if [ "$OS" = "osx" ]; then
    info "Operating system: OSX"
elif [ "$OS" = "osx" ]; then
    info "Operating system: Linux"
    if [ "$DIST" = "debian" ] || [ "$DISR" = "ubuntu" ]; then
        info "Distribution detected: Debian/Ubuntu"
        ./install_debian.sh
    elif [ "$DIST" = "centos" ] || [ "$DISR" = "redhat" ]; then
        info "Distribution detected: RedHat/CentOS"
        ./install_centos.sh
    else
        abort "Unsupported Linux Distribution, we only support: CentOS/RedHat and Debian/Ubuntu for now"
    fi
else
    abort "Unsupported OS"
fi