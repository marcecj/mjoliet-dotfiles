function matlab_nox --description 'Start Matlab without X support.'

    padsp matlab -nodesktop -nodisplay -nosplash $argv

end
