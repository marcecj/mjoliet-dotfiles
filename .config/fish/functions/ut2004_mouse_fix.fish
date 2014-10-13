function ut2004_mouse_fix --description 'Start UT2004 with a mouse fix'

    set -x DL_VIDEO_X11_DGAMOUSE 0
    ut2004 $argv

end
