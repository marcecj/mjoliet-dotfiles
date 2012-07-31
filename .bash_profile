# tell other scripts this file was sourced to prevent double loading
# export BASH_PROFILE_LOADED=1

# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
[[ -f ~/.bashrc ]] && . ~/.bashrc

# Activate keychain for ssh-agent
# keychain id_rsa &>/dev/null
# . ~/.keychain/$HOSTNAME-sh
