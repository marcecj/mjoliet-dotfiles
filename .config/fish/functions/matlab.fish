function matlab -d "Starts MATLAB sanely."
    set --export LD_PRELOAD libportaudio.so /usr/\$LIB/pulseaudio/libpulsedsp.so libstdc++.so
    command matlab $argv
end
