#!/bin/sh

awk '/MemAvailable/ { printf "%.3f \n", $2/1024/1024 }' /proc/meminfo
