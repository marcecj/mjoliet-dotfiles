#!/usr/bin/env sh
#
# this file is called by startx and the slim display manager

export LANG="de_DE.UTF-8"

# Workaround until https://bugs.launchpad.net/ubuntu/+source/lightdm/+bug/919200
# is fixed.  This appears to retain all other settings from xorg.conf.d.
setxkbmap -layout "de, us" -variant "nodeadkeys,"

#  Start whatever program I want at X startup (via startx or slim)
$HOME/.monicarc   #monitor calibration

# uncomment when starting via "startx" in an ssh session
xrdb -merge .Xresources

# required by uzbl
export XDG_DATA_HOME="$HOME/.config"

# binds keys to shell commands
# xbindkeys &

# start a urxvt daemon, will quit with the X server
urxvtd -q -o -f

# start a terminal that runs keychain, which will set the necessary environment
# variables for other process to connect to {gpg,ssh}-agent
urxvtc -e sh -c "eval \$(keychain --nogui --eval id_rsa C3E99E07 </dev/null)" &

# udisks based automounter
udisks-glue -p ~/.udisks-glue.pid &

# misc
pulseaudio --check || pulseaudio --start &
# wicd-gtk &
nm-applet &
batti &
#fbsetbg -l &   # set the background wallpaper
#conky &		# an alternative system monitor to gkrellm

# who can live without a screensaver?
#xscreensaver &
xautolock &  # configuration in .Xresources

# sets monitor color temp according to daytime
pgrep redshift && killall -TERM redshift
redshift &

# chat program
#gajim &
pidgin &

# some terminals to always start
# NOTE: the resolution is too low for multitail
#urxvtc -name "multitail-syslog" -e sh -c "sudo multitail -n 300 --retry -f /var/log/messages" &
urxvtc -name "htop-sys" -e sh -c "htop" &

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
