function gvim_mlab_gdb --description 'Run Pyclewn with gvim for debugging MATLAB Mex files'

    python -m clewn -e /usr/bin/gvim --pgm=mlab_debug.sh $argv

end
