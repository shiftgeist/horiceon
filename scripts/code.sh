#!/bin/bash

read -p "Enter Your Name: " OPTIONAL_DEPS

if [$OPTIONAL_DEPS]; then
    echo "Installing core and optional code dependencies"
    code --install-extension coenraads.bracket-pair-colorizer\n
        editorconfig.editorconfig\n
        ow.vscode-subword-navigation\n
        jolaleye.horizon-theme-vscode\n
        pkief.material-icon-theme\n
        wakatime.vscode-wakatime
else
    echo "Installing core code dependencies"
    code --install-extension coenraads.bracket-pair-colorizer\n
        editorconfig.editorconfig\n
        ow.vscode-subword-navigation\n
        jolaleye.horizon-theme-vscode\n
        pkief.material-icon-theme
fi
