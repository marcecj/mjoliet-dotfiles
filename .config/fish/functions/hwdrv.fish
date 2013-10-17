function hwdrv --description 'Associates devices in /sys/ with their drivers'
    find /sys/devices -name driver -print0|xargs -0 ls -l|cut -d' ' -f9-|sed -e 's/\.\.\///g'
end
