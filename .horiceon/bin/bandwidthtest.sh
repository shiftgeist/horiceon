#!/bin/sh

# Original Author: Luke Smith
# Original Source: https://www.youtube.com/watch?v=cvDyQUpaFf4

# Used for educational purposes

init="$(($(cat /sys/class/net/[ew]*/statistics/rx_bytes | paste -sd '+')))"
init_date=$(date)

printf "Recording bandwidth. Press enter to stop..."

read -r enter

fin="$(($(cat /sys/class/net/[ew]*/statistics/rx_bytes | paste -sd '+')))"
fin_date=$(date)

BAND_DIFF=$((fin - init))
DATE_DIFF=$(printf "%s\n" $(($(date -d "$fin_date" "+%s") - $(date -d "$init_date" "+%s"))))

to_minute=$(echo "$DATE_DIFF" | awk '{printf "%f", $1 / 60}')
minute=$(echo "$BAND_DIFF $to_minute" | awk '{printf "%f", $1 / $2}')
second=$(echo "$minute" | awk '{printf "%f", $1 / 60}')
hour=$(echo "$minute" | awk '{printf "%f", $1 * 60}')

printf "%5sB captured in %1s %-3s\\n" "$(numfmt --to=iec $BAND_DIFF)" "$DATE_DIFF" "sec"
printf "\\n"
printf "%5sB/s\\n" "$(numfmt --to=iec "$second")"
printf "%5sB/min\\n" "$(numfmt --to=iec "$minute")"
printf "%5sB/h\\n" "$(numfmt --to=iec "$hour")"
