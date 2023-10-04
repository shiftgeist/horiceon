#!/bin/sh

# xinitrc runs automatically when you run startx

setxkbmap us altgr-intl &
setxkbmap -option caps:escape -option lv3:ralt_switch & # Map the caps lock key to escape
xset r rate 300 50 &                                    # Increase key speed via a rate change
xinput set-prop 11 290 1 &                              # Touchpad libinput enabled soft tapping
xrdb "$XDG_CONFIG_HOME/Xresources" &                    # Use Xresources colors/settings on startup

export SSH_AUTH_SOCK

if [ -z "$SSH_AUTH_SOCK" ]; then
  eval $(ssh-agent -s)
  ssh-add ~/.ssh/id_rsa
fi

if [ "$(tty)" = "/dev/tty1" ]; then
  ssh-agent startxfce4
fi
