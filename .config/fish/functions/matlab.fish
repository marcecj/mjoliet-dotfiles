function matlab -d "Starts MATLAB sanely."
    # override some of MATLAB's bundled libraries with those from the system in
    # order to prevent annoying run-time problems (such as portaudio not
    # supporting JACK)
    set --export LD_PRELOAD libportaudio.so /usr/\$LIB/pulseaudio/libpulsedsp.so libstdc++.so
    command matlab $argv
end
