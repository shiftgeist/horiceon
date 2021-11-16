#!/bin/sh

# helper command to toggle play status with catt
# Dependency: https://github.com/skorokithakis/catt

cli_name=${0##*/}

while [ $# -gt 0 ]; do
  case $1 in
  -d) DEVICE="$2" ;;
  --)
    shift
    break
    ;;
  -*)
    echo "$0: error - unrecognized option $1" 1>&2
    exit 1
    ;;
  *) break ;;
  esac
  shift
done

if [ -z "$DEVICE" ]; then
  echo "Specified device not found."
  echo ""
  echo "Usage:"
  echo "  $cli_name -d DeviceOrIP"
  echo ""
  catt scan
  exit
fi

STATUS=$(catt -d "$DEVICE" info -j | jq ".player_state")

if echo "$STATUS" | grep "PLAYING" >/dev/null; then
  catt -d "$DEVICE" pause
elif echo "$STATUS" | grep "PAUSED" >/dev/null; then
  catt -d "$DEVICE" play
else
  echo "Unknown status \"$STATUS\""
fi
