# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# append to the history file, don't overwrite it
shopt -s histappend

# do not save empty lines in the history
export HISTCONTROL=ignoreboth

# I want a lot..
export HISTFILESIZE=1000

# my PS1
if [ $(id -u) -eq 0 ]; then
    PS1="[\[\e[1;31m\]\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]][\[\e[1;32m\]\@\[\e[0m\]][\[\e[1;36m\]\w\[\e[0m\]] "
else
    PS1="[\[\e[1;36m\]\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]][\[\e[1;32m\]\@\[\e[0m\]][\[\e[1;36m\]\w\[\e[0m\]] "
fi

if [[ "$OSTYPE" == darwin* ]]; then
    # Bash Completion
    [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
fi

# pyenv
command -v pyenv >/dev/null && {
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
}

# include our custom config for both: zsh and bash
[[ ! -f ~/.common.sh ]] || source ~/.common.sh