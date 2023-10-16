#!/bin/sh

set -x # show output

git push origin --delete "$1"
