#################################################################################
# General Options
#################################################################################

# path
custom="$HOME/.local/bin /usr/local/bin /usr/local/sbin /usr/local/opt/ruby/bin $HOME/.dotnet/tools"
for P in $custom; do
  test -d $P && export PATH=$P:$PATH
done

# Set the default Less options.
export LESS='-c -g -i -M -R -S -w -X -z-4'
# command -v source-highlight >/dev/null 2>&1 && export LESSOPEN="| $HOME/.dotfiles/less.sh %s"

# Preferred editor for local and remote sessions, in this order: vim, nano
EDITOR="$(command -v vim 2>/dev/null || command -v nano)"

#################################################################################
# Command Aliases
#################################################################################

alias du="du -h -s"
alias df="df -h"
alias py=ipython
alias mc="mc -u"

#################################################################################
# Utility Functions
#################################################################################

# creates a local socks proxy using the remote server as exit point
function proxy() {
  if [ "$#" -eq 2 ]; then
    echo "::: Listening in: localhost:$2"
    ssh -D $2 -q -C -N $1
  else
    echo "::: Usage: proxy <[user@]host[:port]> <local-port>"
    echo ":::     <[user@]host[:port]>: exit point host"
    echo ":::     <local-port>: Port on the local machine we want to forward"
  fi
}

# forward local port to a remote port using ssh
function forward() {
  if [ "$#" -ge 2 ]; then
    for arg in "${@:2}"; do
      params="-L $arg $params"
    done
    echo "$params $1"
    eval "ssh -q -N -C $params $1"
    unset params
  else
    echo "::: Usage: forward <[user@]host[:port]> <local-port>:<remote-host>:<remote-port> ... <local-port>:<remote-host>:<remote-port>"
    echo ":::     <[user@]host[:port]>: Intermediate host with ssh"
    echo ":::     <local-port>: Port on the local machine we want to forward"
    echo ":::     <remote-host: Remote host where the local port will be forwarded to"
    echo ":::     <remote-port: Port in the remote host where the local port will be forwarded to"
  fi
}

# capture traffic from a remote server
function remote-capture() {
  if [ "$#" -eq 2 ]; then
    ssh $1 'dumpcap -w - -i $2 -f "not port 22"' | wireshark -k -i -
  elif [ "$#" -eq 3 ]; then
    # ssh -q -N -C -p $2 $1 "tcpdump -i $3 -U -s0 -w -" | wireshark -k -i -
    ssh -p $2 $1 'dumpcap -w - -i $3 -f "not port 22"' | wireshark -k -i -
  else
    echo "::: Usage:"
    echo ":::    remote-capture <[user@]host> [ssh-port] <iface>\n"
  fi
}

#################################################################################
# OS Detection
#################################################################################

if [[ "$OSTYPE" == darwin* ]]; then
  # Use GNU ls instead of BSD ls if available
  alias ls="ls -hlGF"
  alias la="ls -hlGFA"

  if $(command -v exa >/dev/null 2>&1); then
    alias ls="exa -hl --group-directories-first --git"
    alias la="exa -hla --group-directories-first --git"
  elif $(command -v gls >/dev/null 2>&1); then
    alias ls="gls -hlF --color=always --group-directories-first"
    alias la="gls -hlAF --color=always --group-directories-first"
  fi
else
  # Command Aliases
  alias ls="ls -hlF --color=always --group-directories-first"
  alias la="ls -hlAF --color=always --group-directories-first"

  if $(command -v exa >/dev/null 2>&1); then
    alias ls="exa -hl --group-directories-first --git"
    alias la="exa -hla --group-directories-first --git"
  fi
fi
