#!/bin/sh

git branch --merged | grep -E -v '(^\*|master|dev)' | xargs git branch -d && git pull --prune
