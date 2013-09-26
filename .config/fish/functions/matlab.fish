function matlab -d "Starts MATLAB sanely."
    set --export LD_PRELOAD /usr/lib/libportaudio.so /usr/lib/gcc/x86_64-pc-linux-gnu/(gcc -dumpversion)/libstdc++.so
    command padsp matlab $argv
end
