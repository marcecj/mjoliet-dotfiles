function progs_to_restart --description 'List programs accessing deleted libraries'
    lsof | grep 'DEL.*lib' | cut -f 1 -d ' ' | sort -u $argv
end
