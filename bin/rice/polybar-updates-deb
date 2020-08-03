#!/bin/sh

if ! updates=$(apt-get upgrade -s | grep -P '^\d+ upgraded' |cut -d " " -f1); then
    updates=0
fi

if [ "$updates" -gt 0 ]; then
    echo "# $updates"
else
    echo ""
fi
