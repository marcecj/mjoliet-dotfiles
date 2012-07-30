#!/usr/bin/env sh
#
# vim:nospell

# for xorg-server >= 1.6
# setxkbmap -option terminate:ctrl_alt_bksp

#  Start whatever program I want at X startup (via startx or slim)
$HOME/.monicarc   #monitor calibration

# uncomment when starting via "startx" in an ssh session 
xrdb -merge .Xresources

# required by uzbl
export XDG_DATA_HOME="$HOME/.config"

# makes stuff like printing work, but breaks newer versions of MATLAB
#export MATLAB_JAVA="/usr/lib/jvm/emul-linux-x86-java-1.6/"
#export MATLAB_JAVA="/opt/matlab/sys/java/jre/glnx86/jre1.5.0"

# binds keys to shell commands
xbindkeys &

# start a urxvt daemon, will quit with the X server
urxvtd -q -o -f

# udisks based automounter
pgrep udisks-glue || udisks-glue &

# misc
pulseaudio --check || pulseaudio --start &
mpd &
#fbsetbg -l &   # set the background wallpaper
#conky &		# an alternative system monitor to gkrellm

# who can live without a screensaver?
#xscreensaver &
xautolock &  # configuration in .Xresources

# sets monitor color temp according to daytime
redshift &

# chat program
#gajim &
pidgin &

# some terminals to always start
urxvtc -name "multitail-syslog" -e zsh -c "sudo multitail -n 300 --retry -f /var/log/messages" &
urxvtc -name "htop-sys" -e zsh -c "htop" &

# take care of input argument and SESSION variable
if [ -z $1 ]; then
  SESSION="AWESOME"
else
  SESSION=$1
fi

# specify a safe default session
DEFAULTSESSION=startfluxbox

# start specified session or safe default
case "$SESSION" in
  "FLUXBOX")
  fbpanel &
  exec startfluxbox
  ;;
  "AWESOME")
  export AWT_TOOLKIT="MToolkit" # fixes Java applications
  export wpsetters=xsri # set wallpaper setter for awsetbg
  exec awesome
  ;;
  "KDE-Awesome")
  export KDEWM=awesome
  exec startkde
  ;;
  "KDE")
  exec startkde
  ;;
  *) exec $DEFAULTSESSION
  ;;
esac
