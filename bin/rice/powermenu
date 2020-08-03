#!/bin/bash

rofi_command="rofi -theme powermenu.rasi"

### Options ###
power_off="power off"
reboot="reboot"
lock="look"
suspend="suspend"
log_out="log out"
# Variable passed to rofi
options="$power_off\n$reboot\n$lock\n$suspend\n$log_out"

chosen="$(echo -e "$options" | $rofi_command -dmenu -selected-row 2)"
case $chosen in
    $power_off)
        i3-nagbar -t warning -m 'Shutdown?' -B 'Yes, shutdown' 'systemctl poweroff'
        ;;
    $reboot)
        i3-nagbar -t warning -m 'Reboot?' -B 'Yes, reboot' 'systemctl reboot'
        ;;
    $lock)
        light-locker-command -l
        ;;
    $suspend)
        mpc -q pause
        amixer set Master mute
        systemctl suspend
        ;;
    $log_out)
        i3-msg exit
        ;;
esac
