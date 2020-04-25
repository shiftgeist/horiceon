#!/bin/sh

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# set keyboard map (default us with `alt + {q, s, y, p}`)

setxkbmap us altgr-intl

# set background and background cursor

xsetroot -solid "#16161C" -cursor_name watch

# start some nice programs

exec i3
