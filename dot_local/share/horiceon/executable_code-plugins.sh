#!/bin/sh

installPlugins () {
    for n in "$@"; do
        code --install-extension "$n"
    done
}

installPlugins \
    "coenraads.bracket-pair-colorizer-2" \
    "editorconfig.editorconfig" \
    "ow.vscode-subword-navigation" \
    "wakatime.vscode-wakatime" \
    "bierner.markdown-preview-github-styles" \
    "naumovs.color-highlight" \
    "pkief.material-icon-theme"
