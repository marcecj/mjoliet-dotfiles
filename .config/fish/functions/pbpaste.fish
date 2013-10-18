function pbpaste --description 'Paste from the X clipboard'
    xsel --clipboard --output $argv
end
