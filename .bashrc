# common environment variables
source $HOME/.env_vars

# so that pinfo is the default viewer
alias info=pinfo

# Make Bash behave like vi (instead of emacs)
# Is already set in ~/.inputrc
# set -o vi

# activate bash-completion
# TODO: figure out how to check for login shell
[[ -f /etc/profile.d/bash-completion ]] \
&& source /etc/profile.d/bash-completion
