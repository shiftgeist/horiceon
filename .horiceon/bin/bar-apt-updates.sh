#!/usr/bin/env bash

# shows count of upgradable apt packages
# xfce genmon docs: https://docs.xfce.org/panel-plugins/xfce4-genmon-plugin/start

INFO=
MORE_CMD=

UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable)

if [ "$UPDATES" -ne "0" ]; then
  MORE_CMD="<txtclick>kitty sudo aptitude full-upgrade</txtclick>"
  INFO+="<txt> "
  INFO+="$UPDATES 📦"
  INFO+=" </txt>"
fi

# Panel Print
echo -e "${INFO}"

# Tooltip Print
echo -e "${MORE_CMD}"
