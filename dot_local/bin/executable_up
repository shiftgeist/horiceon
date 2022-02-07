#!/usr/bin/env bash

# bump git and npm semantic version with

set -e

if ! command -v semver &>/dev/null; then
  echo "semver could not be found"
  exit
fi

function help() {
  cli_name=${0##*/}
  echo "
usage: $cli_name [npm|git] [command] [prerelease]
"
  exit 0
}

function latest_tag() {
  if [[ "$SOURCE" == "git" ]]; then
    git describe --tags "$(git rev-list --tags --max-count=1)"
  fi

  if [[ "$SOURCE" == "npm" ]]; then
    sed -nE 's/^\s*"version": "(.*?)",$/\1/p' package.json
  fi
}

# parse input parameters
for i in "$@"; do
  case $i in
  alpha)
    PRERELEASE=true
    PREID="alpha"
    ;;
  beta)
    PRERELEASE=true
    PREID="beta"
    ;;
  rc)
    PRERELEASE=true
    PREID="rc"
    ;;
  patch)
    LEVEL="patch"
    ;;
  minor)
    LEVEL="minor"
    ;;
  major)
    LEVEL="major"
    ;;
  rev)
    PRERELEASE=true
    ;;
  npm)
    SOURCE="npm"
    ;;
  git)
    SOURCE="git"
    ;;
  now)
    echo "$TAG"
    ;;
  *) # unknown command
    help
    ;;
  esac
  shift
done

TAG="$(latest_tag)"

if [[ ${PRERELEASE} ]]; then
  if [[ ${#PREID} == 0 ]]; then
    OPTIONS="-i prerelease"
  else
    OPTIONS="-i pre$LEVEL --preid $PREID"
  fi
else
  OPTIONS="-i $LEVEL"
fi

EXEC=$(printf "%s %s" "$TAG" "$OPTIONS")

# echo "semver $EXEC" # debug

echo "$EXEC" | xargs semver
