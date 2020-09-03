#!/bin/sh

mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/"

clonePlugins () {
    cd "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/" || exit
    for n in "$@"; do
        git clone "$n" 2> /dev/null
    done
}

# Install theme
# [ ! -d  "/usr/local/bin/starship" ] && curl -fsSL https://starship.rs/install.sh | bash || echo "Skipping starship install."

# Install plugins
clonePlugins \
    "git@github.com:denysdovhan/spaceship-prompt.git" \
    "git@github.com:MichaelAquilina/zsh-you-should-use.git" \
    "git@github.com:zsh-users/zsh-autosuggestions.git" \
    "git@github.com:zsh-users/zsh-completions.git" \
    "git@github.com:zsh-users/zsh-syntax-highlighting.git"
