function progs_to_restart
    lsof | grep 'DEL.*lib' | cut -f 1 -d ' ' | sort -u $argv
end