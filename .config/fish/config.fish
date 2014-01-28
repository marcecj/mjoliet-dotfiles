# unset the default greeting
set fish_greeting

# TODO: it seems fish is not started as a login shell. Why?
# if status --is-login

set PATH $PATH "$HOME/bin/" "$HOME/.local/bin/"

# set the default MPD host to my desktop machine
set -x MPD_HOST marcec.marcnet

## activate colorgcc - colorized gcc output
#if [[ -z $(echo $PATH | grep colorgcc) && -d "/usr/lib/colorgcc/bin/" ]]; then
#    set -x PATH "/usr/lib/colorgcc/bin/" $PATH
#fi

## mpc tries localhost, which is ipv6
#set -x MPD_HOST ::1

## File ledger uses
#set -x LEDGER_FILE $HOME/finances.dat

# setup a directory for finished python modules
set -x PYTHONPATH $HOME/python

# activate S3TC
set -x R600_ENABLE_S3TC 1
