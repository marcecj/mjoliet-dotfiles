function matlab -d "Starts MATLAB sanely."
    set LD_PRELOAD /usr/\$LIB/libportaudio.so /usr/\$LIB/pulseaudio/libpulsedsp.so
    if test "$MATLAB_ARCH" -eq "glnx86" -a "(uname --machine)" -eq "x86_64"
        set LD_PRELOAD $LD_PRELOAD /usr/lib/gcc/x86_64-pc-linux-gnu/(gcc -dumpversion)/32/libstdc++.so
    else
        set LD_PRELOAD $LD_PRELOAD /usr/lib/gcc/x86_64-pc-linux-gnu/(gcc -dumpversion)/libstdc++.so
    end
    set --export LD_PRELOAD
    command matlab $argv
end
