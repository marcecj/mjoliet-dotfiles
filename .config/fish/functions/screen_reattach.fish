function screen_reattach --description 'Connect to a running screen instance'
    screen -D -R $argv
end
