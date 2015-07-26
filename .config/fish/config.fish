# unset the default greeting
set fish_greeting

# TODO: it seems fish is not started as a login shell. Why?

set PATH $PATH "$HOME/bin/" "$HOME/.local/bin/"

# override $JAVA_HOME if java-config exists (i.e., a Java runtime is installed);
# this is for MATLAB, so that the GUI can start without crashing
if test -x (which java-config-2);
    set -x JAVA_HOME (java-config-2 -g JAVA_HOME)
end

# setup a directory for finished python modules
set -x PYTHONPATH $HOME/python

# activate S3TC
set -x R600_ENABLE_S3TC 1

# used by FISH's help system
set -x BROWSER /usr/bin/rekonq
