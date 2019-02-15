#!/usr/bin/env bash

# move to script directory so all relative paths work
CURRENT_DIR="$(dirname "$0")"
cd $CURRENT_DIR

. ./utils.sh

# make sure lsb_release is installed
command -v lsb_release >/dev/null 2>&1 || {
    abort "lsb_release command not found, please install it before running this script..."
}

# make sure sudo is installed
command -v sudo >/dev/null 2>&1 || {
    abort "sudo command not found, please install it before running this script..."
}

system_detect
if [ "$DIST" != "debian" ] && [ "$DIST" != "ubuntu" ]; then
    ./install_debian.sh
elif [ "$DIST" != "centos" ] && [ "$DIST" != "redhat" ]; then
    ./install_centos.sh
else
    error "System unsupported: $DIST"
fi