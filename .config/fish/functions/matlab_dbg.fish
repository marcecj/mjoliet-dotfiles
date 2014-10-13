function matlab_dbg --description 'Start Matlab with gdb as a debugger (for MEX files).'

    matlab -Dgdb $argv

end
