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

# enable go completion?
# autoload -U go

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

# automatically create a cgroup for each TTY; see
# http://www.webupd8.org/2010/11/alternative-to-200-lines-kernel-patch.html and
# http://lkml.org/lkml/2010/11/16/392
# if [ "$PS1" -a ! -d /dev/cgroup/cpu/user/$$ ] ; then
#     mkdir -m 0700 /dev/cgroup/cpu/user/$$
#     echo $$ > /dev/cgroup/cpu/user/$$/tasks
# fi
# From gentoo-user:
## Turn on cgroups
#if [ "$PS1" ] ; then
#  if [ -d /sys/fs/cgroup ] ; then
#    cdir=/sys/fs/cgroup
#  else
#    cdir=/dev/cgroup
#  fi
#
#  mkdir -p -m 0700 $cdir/user/$$ > /dev/null 2>&1
#  /bin/echo $$ > $cdir/user/$$/tasks
#  /bin/echo '1' > $cdir/user/$$/notify_on_release
#fi

# TODO: adapt to personal needs
# function precmd {

#     local TERMWIDTH
#     (( TERMWIDTH = ${COLUMNS} - 1 ))


#     ###
#     # Truncate the path if it's too long.
    
#     PR_FILLBAR=""
#     PR_PWDLEN=""
    
#     local promptsize=${#${(%):---(%n@%m:%l)---()--}}
#     local pwdsize=${#${(%):-%~}}
    
#     if [[ "$promptsize + $pwdsize" -gt $TERMWIDTH ]]; then
#         ((PR_PWDLEN=$TERMWIDTH - $promptsize))
#     else
#     PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize)))..${PR_HBAR}.)}"
#     fi


#     ###
#     # Get APM info.

#     if which ibam > /dev/null; then
#     PR_APM_RESULT=`ibam --percentbattery`
#     elif which apm > /dev/null; then
#     PR_APM_RESULT=`apm`
#     fi
# }


# setopt extended_glob
# preexec () {
#     if [[ "$TERM" == "screen" ]]; then
#     local CMD=${1[(wr)^(*=*|sudo|-*)]}
#     echo -n "\ek$CMD\e\\"
#     fi
# }


# setprompt () {
#     ###
#     # Need this so the prompt will work.

#     setopt prompt_subst


#     ###
#     # See if we can use colors.

#     autoload colors zsh/terminfo
#     if [[ "$terminfo[colors]" -ge 8 ]]; then
#     colors
#     fi
#     for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
#     eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
#     eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
#     (( count = $count + 1 ))
#     done
#     PR_NO_COLOUR="%{$terminfo[sgr0]%}"


#     ###
#     # See if we can use extended characters to look nicer.
    
#     typeset -A altchar
#     set -A altchar ${(s..)terminfo[acsc]}
#     PR_SET_CHARSET="%{$terminfo[enacs]%}"
#     PR_SHIFT_IN="%{$terminfo[smacs]%}"
#     PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
#     PR_HBAR=${altchar[q]:--}
#     PR_ULCORNER=${altchar[l]:--}
#     PR_LLCORNER=${altchar[m]:--}
#     PR_LRCORNER=${altchar[j]:--}
#     PR_URCORNER=${altchar[k]:--}

    
#     ###
#     # Decide if we need to set titlebar text.
    
#     case $TERM in
#     xterm*)
#         PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
#         ;;
#     screen)
#         PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
#         ;;
#     *)
#         PR_TITLEBAR=''
#         ;;
#     esac
    
    
#     ###
#     # Decide whether to set a screen title
#     if [[ "$TERM" == "screen" ]]; then
#     PR_STITLE=$'%{\ekzsh\e\\%}'
#     else
#     PR_STITLE=''
#     fi
    
    
#     ###
#     # APM detection
    
#     if which ibam > /dev/null; then
#     PR_APM='$PR_RED${${PR_APM_RESULT[(f)1]}[(w)-2]}%%(${${PR_APM_RESULT[(f)3]}[(w)-1]})$PR_LIGHT_BLUE:'
#     elif which apm > /dev/null; then
#     PR_APM='$PR_RED${PR_APM_RESULT[(w)5,(w)6]/\% /%%}$PR_LIGHT_BLUE:'
#     else
#     PR_APM=''
#     fi
    
    
#     ###
#     # Finally, the prompt.

#     PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
# $PR_CYAN$PR_SHIFT_IN$PR_ULCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
# $PR_GREEN%(!.%SROOT%s.%n)$PR_GREEN@%m:%l\
# $PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_HBAR${(e)PR_FILLBAR}$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
# $PR_MAGENTA%$PR_PWDLEN<...<%~%<<\
# $PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_URCORNER$PR_SHIFT_OUT\

# $PR_CYAN$PR_SHIFT_IN$PR_LLCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
# %(?..$PR_LIGHT_RED%?$PR_BLUE:)\
# ${(e)PR_APM}$PR_YELLOW%D{%H:%M}\
# $PR_LIGHT_BLUE:%(!.$PR_RED.$PR_WHITE)%#$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
# $PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
# $PR_NO_COLOUR '

#     RPROMPT=' $PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_BLUE$PR_HBAR$PR_SHIFT_OUT\
# ($PR_YELLOW%D{%a,%b%d}$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'

#     PS2='$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
# $PR_BLUE$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT(\
# $PR_LIGHT_GREEN%_$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
# $PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_NO_COLOUR '
# }

# setprompt
