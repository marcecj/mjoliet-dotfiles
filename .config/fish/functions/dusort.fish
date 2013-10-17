function dusort --description 'Run du and sort by size'
    du -sch $argv | sort -hr
end
