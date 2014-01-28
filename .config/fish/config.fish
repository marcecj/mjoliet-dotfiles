# unset the default greeting
set fish_greeting

# TODO: it seems fish is not started as a login shell. Why?

set PATH $PATH "$HOME/bin/" "$HOME/.local/bin/"

# override $JAVA_HOME if java-config exists (i.e., a Java runtime is installed);
# this is for MATLAB, so that the GUI can start without crashing
if test -x (which java-config);
    set -x JAVA_HOME (java-config -g JAVA_HOME)
end

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
