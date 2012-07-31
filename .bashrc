# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# common environment variables
source $HOME/.env_vars

# activate bash-completion
# TODO: figure out how to check for login shell
[[ -f /etc/profile.d/bash-completion ]] \
&& source /etc/profile.d/bash-completion
