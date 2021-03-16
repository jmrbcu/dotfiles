#!/usr/bin/env bash
# documentation for bash: http://wiki.bash-hackers.org/commands/classictest

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

header() {
  printf "$yellow#####################################################################$normal\n"
  printf "$yellow# $1 $normal\n"
  printf "$yellow#####################################################################$normal\n\n"
}

info() {
  printf "$yellow$1$normal\n"
}

error() {
  printf "$red$1$normal\n" >&2 ## Send message to stderr. Exclude >&2 if you don't want it that way.
}

warning() {
  printf "$magenta$1$normal\n" >&2 ## Send message to stderr. Exclude >&2 if you don't want it that way.
}

log() {
  LEVEL=$(echo "$1" | tr '[:lower:]' '[:upper:]')
  MESSAGE=$2

  logger -t "[$LEVEL]" "$MESSAGE"
  if [[ $LEVEL == "WARNING" ]]; then
    warning "$MESSAGE"
  elif [[ $LEVEL == "ERROR" ]]; then
    error "$MESSAGE"
  else
    info "$MESSAGE"
  fi
}

abort() {
  test -n "$1" && error "$1"
  exit 1
}

install-custom-repos() {
  # must run system-detect first
  if [[ "$BASE_DIST" == "redhat" ]]; then
    test -f /etc/yum.repos.d/totaltrack.repo || {
      # add totaltrack repository
      echo "[totaltrack]" | sudo tee /etc/yum.repos.d/totaltrack.repo >/dev/null
      echo "name=TotalTrack" | sudo tee -a /etc/yum.repos.d/totaltrack.repo >/dev/null
      echo 'baseurl=http://packages.interactivetel.com/centos/$releasever/$basearch/' | sudo tee -a /etc/yum.repos.d/totaltrack.repo >/dev/null
      echo "enabled=1" | sudo tee -a /etc/yum.repos.d/totaltrack.repo >/dev/null
      echo "gpgcheck=0" | sudo tee -a /etc/yum.repos.d/totaltrack.repo >/dev/null
    }

    # add irontec repository (sngrep)
    test -f /etc/yum.repos.d/irontec.repo || {
      echo "[irontec]" | sudo tee /etc/yum.repos.d/irontec.repo >/dev/null
      echo "name=Irontec RPMs repository" | sudo tee -a /etc/yum.repos.d/irontec.repo >/dev/null
      echo 'baseurl=http://packages.irontec.com/centos/$releasever/$basearch/' | sudo tee -a /etc/yum.repos.d/irontec.repo >/dev/null
      echo "enabled=1" | sudo tee -a /etc/yum.repos.d/irontec.repo >/dev/null
      echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/irontec.repo >/dev/null
      sudo rpm --import http://packages.irontec.com/public.key >/dev/null
    }
  else
    abort "Unsupported linux distribution, we only support: redhat based distros"
  fi
}

fix-centos6-repos() {
  # must run system-detect first
  if [[ "$BASE_DIST" = "redhat" && $(echo "$VER" | cut -d '.' -f 1) -eq 6 ]]; then
    # base
    test -e /etc/yum.repos.d/CentOS-Base.repo && {
      sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.old
      sudo sed -e '/mirrorlist=.*/d' \
        -e 's/#\s*baseurl=/baseurl=/' \
        -e 's/baseurl=.*\/centos\/\$releasever\/os\/\$basearch\//baseurl=http:\/\/vault.centos.org\/6.10\/os\/x86_64/g' \
        -e 's/baseurl=.*\/updates\/.*/baseurl=https:\/\/vault.centos.org\/6.10\/updates\/x86_64\//g' \
        -e 's/baseurl=.*\/extras\/.*/baseurl=https:\/\/vault.centos.org\/6.10\/extras\/x86_64\//g' \
        -e 's/baseurl=.*\/centosplus\/.*/baseurl=https:\/\/vault.centos.org\/6.10\/centosplus\/x86_64\//g' \
        -e 's/baseurl=.*\/contrib\/.*/baseurl=https:\/\/vault.centos.org\/6.10\/contrib\/x86_64\//g' \
        -i /etc/yum.repos.d/CentOS-Base.repo
    }
    sudo rm -rf /etc/yum.repos.d/CentOS-fasttrack.repo* /etc/yum.repos.d/CentOS-Vault.repo* /etc/yum.repos.d/CentOS-Debuginfo.repo* /etc/yum.repos.d/CentOS-Media.repo

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
    sudo rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-SIG-SCLo >/dev/null

    # epel and SCL
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
    sudo rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-SIG-SCLo >/dev/null
  else
    abort "Unsupported linux distribution, we only support: redhat based distros"
  fi
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

trap 'abort "::: Unexpected error on line: $LINENO: ${BASH_COMMAND}"' ERR
