# tell other scripts this file was sourced to prevent double loading
# export BASH_PROFILE_LOADED=1

# include .bashrc if it wasn't already sourced
# [[ -z $BASHRC_LOADED ]] && source ~/.bashrc
[[ -f ~/.bashrc ]] && source ~/.bashrc

# Activate keychain for ssh-agent
# keychain id_rsa &>/dev/null
# . ~/.keychain/$HOSTNAME-sh
