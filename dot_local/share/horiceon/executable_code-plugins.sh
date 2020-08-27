#!/usr/bin/env bash

PLUGINS=(
    coenraads.bracket-pair-colorizer-2
    editorconfig.editorconfig
    ow.vscode-subword-navigation
    wakatime.vscode-wakatime
)

OPTIONAL=(
    bierner.markdown-preview-github-styles
    naumovs.color-highlight
    pkief.material-icon-theme
)

echo "Install optional plugins? [Yn]"
read -r ans
case $ans in
    Y|"")
        echo "yes"
        PLUGINS+=("${OPTIONAL[@]}")
        ;;
    N)
        echo "no"
        ;;
esac

for i in "${PLUGINS[@]}"
do
    code --install-extension "$i"
done
