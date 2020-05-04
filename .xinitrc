#!/bin/sh

xrdb -merge ~/.Xresources
setxkbmap us altgr-intl
exec i3
