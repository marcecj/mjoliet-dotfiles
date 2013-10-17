function matlab -d "Starts MATLAB sanely."
    # override some of MATLAB's bundled libraries with those from the system in
    # order to prevent annoying run-time problems (such as portaudio not
    # supporting JACK)
    set --export LD_PRELOAD libportaudio.so /usr/\$LIB/pulseaudio/libpulsedsp.so libstdc++.so

    # use the system JAVA runtime if available
    if test -n "$JAVA_HOME" -a -d "$JAVA_HOME"/jre/;
        set --export MATLAB_JAVA "$JAVA_HOME"/jre/
    end

    # force MATLAB to use the BASH
    set -lx SHELL /bin/bash

    command matlab $argv
end
