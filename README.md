# ![horiceon](.horiceon/horiceon.png)

[![GitHub contributors][shield_contrib]][contrib]
[![issues][shield_issues]][issues]

## Idea

Origin: https://news.ycombinator.com/item?id=11071754

## Setup

You can replicate your home directory on a new machine using the following command:

```shell
git clone --separate-git-dir=~/.dotfiles git@github.com:shiftgeist/horiceon.git ~

# Without a clean home directory
git clone --separate-git-dir=$HOME/.dotfiles git@github.com:shiftgeist/horiceon.git $HOME/dotfiles-tmp
cp ~/dotfiles-tmp/.gitmodules ~  # If you use Git submodules
rm -r ~/dotfiles-tmp/
alias horiceon="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
```

## Usage

```shell
horiceon $GIT_COMMAND
```

[contrib]: https://github.com/shiftgeist/horiceon/graphs/contributors
[issues]: https://github.com/shiftgeist/horiceon/issues
[shield_contrib]: https://img.shields.io/github/contributors/shiftgeist/horiceon
[shield_issues]: https://img.shields.io/github/issues/shiftgeist/horiceon
