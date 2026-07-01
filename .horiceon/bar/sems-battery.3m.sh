#!/bin/zsh

# SwiftBar Metadata
# <swiftbar.title>Solar Battery Monitor</swiftbar.title>
# <swiftbar.version>1.0</swiftbar.version>
# <swiftbar.author>Felix</swiftbar.author>
# <swiftbar.desc>Monitors GoodWe home battery status via SEMS portal</swiftbar.desc>

BATTERY_SCRIPT="/Users/felix/.horiceon/bin/sems-battery"

DATA=$($BATTERY_SCRIPT 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$DATA" ]; then
  echo "⚠️ Error | color=red"
  echo "---"
  echo "Failed to fetch battery data"
  echo "$DATA"
  exit 0
fi

echo "${DATA}"
