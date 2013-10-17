function lh --description 'List the N newest files sorted by time, arguments are passed to head'
    ls -lht --color=always | head $argv
end
