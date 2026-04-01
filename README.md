# ![horiceon](.horiceon/horiceon.png)

[![GitHub contributors][shield_contrib]][contrib]
[![issues][shield_issues]][issues]

## Idea

Origin: https://news.ycombinator.com/item?id=11071754

## Setup

You can replicate your home directory on a new machine using the following command:


### Option A: Clean Home Directory

```sh
git clone --separate-git-dir=~/.dotfiles git@github.com:shiftgeist/horiceon.git ~
```

### Option B

```shell
git clone --separate-git-dir=$HOME/.dotfiles git@github.com:shiftgeist/horiceon.git $HOME/dotfiles-tmp
rm -r ~/dotfiles-tmp/
alias horiceon="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
horiceon checkout -- . # get the actual files
```

## Tool Setup

```sh
source ~/.zshrc
brew-recover
mise up
```

## Usage

```sh
horiceon $GIT_COMMAND
```

## Git Commits

- Project commits follow the structure of [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)

[contrib]: https://github.com/shiftgeist/horiceon/graphs/contributors
[issues]: https://github.com/shiftgeist/horiceon/issues
[shield_contrib]: https://img.shields.io/github/contributors/shiftgeist/horiceon
[shield_issues]: https://img.shields.io/github/issues/shiftgeist/horiceon
