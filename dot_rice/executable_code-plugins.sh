#!/bin/bash

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
    usernamehw.errorlens
)

echo "Install optional plugins? [Yn]"
read ans
case $ans in
    Y  ) echo "yes"; PLUGINS+=(${OPTIONAL[@]}); break;;
    N  ) echo "no"; break;;
    "" ) echo "yes"; PLUGINS+=(${OPTIONAL[@]}); break;;
esac

for i in ${PLUGINS[@]}
do
    code --install-extension $i
done
