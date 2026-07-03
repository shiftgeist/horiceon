#!/bin/zsh

BATTERY_SCRIPT="/Users/felix/.horiceon/bin/sems-battery"

DATA=$($BATTERY_SCRIPT --bar 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$DATA" ]; then
  echo "⚠️ Error | color=red"
  echo "---"
  echo "Failed to fetch battery data"
  echo "$DATA"
  exit 0
fi

echo "${DATA}"
