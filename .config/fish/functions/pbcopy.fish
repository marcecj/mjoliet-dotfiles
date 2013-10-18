function pbcopy --description 'Copy arguments to the X clipboard'
    xsel --clipboard --input $argv
end
