# common colors
red=$fg[red]
blue=$fg_bold[blue]
yellow=$fg[yellow]


# use extended color palette if available
if [[ $terminfo[colors] -ge 256 ]]; then
    turquoise="%F{81}"
    orange="%F{166}"
    purple="%F{135}"
    hotpink="%F{161}"
    limegreen="%F{118}"
else
    turquoise="%F{cyan}"
    orange="%F{yellow}"
    purple="%F{magenta}"
    hotpink="%F{red}"
    limegreen="%F{green}"
fi

# set the caret color based on the user id (root/non root)
if [ $UID -eq 0 ]; then
    caret="%F{red}"
else
    caret=$purple;
fi

local return_code="%(?..%{$red%}%? ↵%{$reset_color%})"

PROMPT='%{$turquoise%}%m%{$turquoise%} :: %{$limegreen%}%~ $(git_prompt_info)%{$caret%}»%{${reset_color}%} '

RPS1="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$blue%}git:‹%{$red%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$blue%}› %{$yellow%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$blue%}›"
