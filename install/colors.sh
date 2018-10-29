#!/bin/bash

header () {
    printf "\n"
    printf "${yellow}#####################################################################${normal}\n"
    printf "${yellow}$1${normal}\n"
    printf "${yellow}#####################################################################${normal}\n"
    printf "\n"
}

info () {
    echo "${yellow}$1${normal}"
}

error () {
    echo "${red}$1${normal}"
}

warning () {
    echo "${magenta}$1${normal}"
}

# check for color support
if test -t 1; then

    # see if it supports colors...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test $ncolors -ge 8; then
        normal="$(tput sgr0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
    fi
fi