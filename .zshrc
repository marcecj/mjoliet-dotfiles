# common environment variables
# file not sourced, since ~/.zshenv is a symlink to it.
# source $HOME/.env_vars

# Set aliases like bash
alias grep='grep --colour=auto'
alias ls='ls --color=auto'
set -o vi

# Enable Portage completion and Gentoo prompt
autoload -U compinit promptinit
compinit
promptinit
prompt gentoo

# Use v to edit the command line in $EDITOR, like in bash
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Enable completion cache
zstyle ':completion::complete:*' use-cache 1

# Misc style features
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'

# History
export HISTSIZE=2000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

setopt correctall           # Autocorrect
setopt hist_ignore_all_dups # Ignore duplicates
setopt autocd               # Automatically change directory

#set prompt
# TODO: get a decent multiline prompt working, see
# http://aperiodic.net/phil/prompt/ for a howto

# this function sorts du's output by human output (e.g., 1G)
dusort ()
{
    du -sch $@ | sort -hr
}

export PROMPT='%B%F{green}>> (%F{yellow}%n@%m%F{green})-%B(%f%F{yellow}%*%f%F{green})-(%F{blue}%10~%F{green})
%F{green}>> (%F{red}%?%F{green}) %F{blue}%# %b%f'
