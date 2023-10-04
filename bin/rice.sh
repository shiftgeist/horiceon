#!/bin/sh

# install helper

set -e

main() {
    cli_name=${0##*/}

    cli_help() {
        echo "
Horiceon helper cli
Usage: $cli_name [command]

  install i   install packages
  docs d      show docs
  *           help"
        exit 1
    }

    case "$1" in
    install | i)
        install "$@"
        ;;
    docs | d)
        docs "$@"
        ;;
    *)
        cli_help
        ;;
    esac
}

install() {
    cli_help_packages() {
        echo "
Install packages
Usage: $cli_name install [command]

Commands:
  fzf               install fzf
  golang            install go ([version] optional, eg. '1.0.0', default latest)
  kitty             install kitty terminal
  neovim-plug       install vim-plug
  node              install nodejs package universal ([version] optional, eg. '18', default 'lts')
  watson            install watson time tracking

  pkg-arch          arch packages
  pkg-code          vscode extensions
  pkg-deb-cli       debian cli packages
  pkg-deb-node      setup nodejs package debian source ([version] optional, eg. '18', default '18')
  pkg-deb-ui        debian ui packages
  pkg-flatpak       flatpak packages
  pkg-go            go packages
  pkg-npm           npm global packages
"
        exit 1
    }

    case "$2" in
    fzf)
        chmod +x ~/.local/src/fzf/install
        ~/.local/src/fzf/install --bin
        ;;
    golang)
        sudo rm -rf /usr/local/go
        if [ "$3" ]; then
            GO_VERSION="go$3"
        else
            GO_VERSION=$(curl -s "https://go.dev/VERSION?m=text")
        fi
        curl --progress-bar "https://dl.google.com/go/$GO_VERSION.linux-amd64.tar.gz" | sudo tar zxf - -C /usr/local
        go version
        ;;
    kitty)
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin installer=nightly launch=n
        ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
        cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
        sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty.desktop
        ;;
    node)
        if [ "$3" ]; then
            NODE_VERSION="$3"
        else
            NODE_VERSION="lts"
        fi
        curl -sL "install-node.vercel.app/$NODE_VERSION" | bash
        ;;
    neovim-plug)
        # https://github.com/junegunn/vim-plug#neovim
        curl -fLo "$XDG_DATA_HOME/nvim/site/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        ;;
    watson)
        python3 -m pip install -U td-watson
        # Broken completions https://github.com/TailorDev/Watson/issues/477
        # Using voidus/Watson watson.zsh-completion version:
        curl -L https://raw.githubusercontent.com/voidus/Watson/fix-completions/watson.zsh-completion -o "$HOME/.zinit/completions/_watson"
        ;;
    pkg-arch)
        if hash yay 2>/dev/null; then
            yay -Syu suckless-tools brave-bin notion-app alacritty zsh neofetch htop neovim code rsync rclone openssh go ttf-dejavu noto-fonts-emoji otf-overpass feh flameshot gpick xsel xcape compton exa tmux screen ghostwriter rofi
        else
            echo "Dependency \"yay\" not found."
            exit 1
        fi
        ;;
    pkg-code)
        # code --install-extension "EXTENSION_ID"                               # TOPIC
        code --install-extension "dracula-theme.theme-dracula"                  # theme
        code --install-extension "editorconfig.editorconfig"                    # lint
        code --install-extension "kshetline.ligatures-limited"                  # utility
        code --install-extension "maattdd.gitless"                              # git
        code --install-extension "naumovs.color-highlight"                      # utility
        code --install-extension "ow.vscode-subword-navigation"                 # utility
        code --install-extension "simonsiefke.prettier-vscode"                  # lint
        code --install-extension "streetsidesoftware.code-spell-checker-german" # lint
        code --install-extension "streetsidesoftware.code-spell-checker"        # lint
        code --install-extension "yzhang.markdown-all-in-one"                   # markdown
        code --install-extension "zengxingxin.sort-js-object-keys"              # utility
        ;;
    pkg-deb-cli)
        sudo apt-get install \
            dstat \
            git \
            git-merge-changelog \
            htop \
            lua5.4 \
            net-tools \
            network-manager \
            nload \
            nodejs \
            telnet \
            tmux \
            vim \
            zsh \
        ;;
    pkg-deb-node)
        if [ "$3" ]; then
            NODE_VERSION="$3"
        else
            NODE_VERSION="20"
        fi
        curl -fsSL "https://deb.nodesource.com/setup_$NODE_VERSION.x" | sudo -E bash -
        ;;
    pkg-deb-ui)
        sudo apt-get install \
            flameshot \
            rofi \
            wicd-client \
        ;;
    pkg-flatpak)
        flatpak install --noninteractive \
            com.spotify.Client
        ;;
    pkg-go)
        go get -u \
            github.com/cosmtrek/air \
            github.com/mikefarah/yq/v4@latest \
            github.com/nektos/act \
            github.com/xxxserxxx/gotop/cmd/gotop \
            github.com/yudai/gotty \
        ;;
    pkg-npm)
        npm i -g \
            diff-so-fancy \
            doctoc \
            imagemin \
            imagemin-webp \
            js-beautify \
            jscpd \
            markdownlint-cli \
            npm \
            npm-check-updates \
            prettier \
            semver \
            tinypng-cli \
            ts-node
        ;;
    *)
        cli_help_packages
        ;;
    esac
}

docs() {
    cli_name=${0##*/}
    BASE_CHEZMOI="$(chezmoi source-path)/docs/"

    cli_help_docs() {
        echo "
Usage: $cli_name docs TOPIC

TOPICS:
$(ls -1 $BASE_CHEZMOI | sed -e 's/\.md$//')"
        exit 1
    }

    if [ -f "$BASE_CHEZMOI/$2.md" ]; then
        less "$BASE_CHEZMOI/$2.md"
    else
        cli_help_docs
    fi
}

main "$@"
