#!/bin/sh

git_is_repo=$(git rev-parse HEAD >/dev/null 2>&1)

echo "GIT: Name?"
read -r git_name

echo "GIT: E-Mail?"
read -r git_email

echo "GIT: GPG Key?"
read -r git_gpg

if [ -z "$git_is_repo" ]; then
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global user.signingkey "$git_gpg"
    git config --global commit.gpgsign true
else
    git config user.name "$git_name"
    git config user.email "$git_email"
    git config user.signingkey "$git_gpg"
    git config commit.gpgsign true
fi
