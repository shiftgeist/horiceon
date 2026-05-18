# ![horiceon](.horiceon/horiceon.png)

[![](https://img.shields.io/github/contributors/shiftgeist/horiceon)](https://github.com/shiftgeist/horiceon/graphs/contributors)
[![](https://img.shields.io/github/issues/shiftgeist/horiceon)](https://github.com/shiftgeist/horiceon/issues)

## Install

You can replicate your home directory on a new machine using the following command:

1. Install Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Add ssh key to your GitHub Account

```sh
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub
```

3. Get the rice

```sh
git clone --separate-git-dir=$HOME/.dotfiles git@github.com:shiftgeist/horiceon.git $HOME/dotfiles-tmp
rm -rf ~/dotfiles-tmp
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -- .
```

4. Setup

```sh
source ~/.zshrc
mise up
# docker missing is expected
```

### Configurating Top Bar Apps

- maccy
- orbstack
- rectangle
- resilio-sync (optional)
- trex

### macOS more

1. Settings -> Displays -> Built-in Display -> More space
2. Settings -> Display & Dock -> Size -> Small
2. Settings -> Display & Dock -> Automatically hide and show the Dock -> True
3. Settings -> Keyboard -> Key repeat rate -> Fast
4. Settings -> Mouse -> Advanced -> Pointer acceleration -> False
5. Settings -> Trackpad -> Point & Click -> Tap to click -> True
6. Settings -> Trackpad -> Scroll & Zoom -> Natural scrolling -> False
7. iTerm2 -> Preferences -> General -> Settings -> Load preferences from a custom folder or URL -> `/Users/$YOUR_USER/.config/iterm2`
8. iTerm2 -> Preferences -> General -> Settings -> Save changes -> Automatically

### WSL

```sh
windows-sync
```

## Usage

```sh
horiceon $GIT_COMMAND
```

## Git Commits

- Project commits follow the structure of [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)

## Origins

https://news.ycombinator.com/item?id=11071754
