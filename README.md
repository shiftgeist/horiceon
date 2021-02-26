![hoRICEon](.github/horiceon.png)

[![GitHub contributors](https://img.shields.io/github/contributors/shiftgeist/horiceon)](https://github.com/shiftgeist/horiceon/graphs/contributors)
[![issues](https://img.shields.io/github/issues/shiftgeist/horiceon)](https://github.com/shiftgeist/horiceon/issues)

## about

- This repo contains dotfiles for my personal use
- Suggestion are welcome, but if they don't fit my prefferences, when they aren't taken further
- Managed by [chezmoi](https://github.com/twpayne/chezmoi) using symlinks soonTM ([#726](https://github.com/twpayne/chezmoi/issues/726))

## goals

- Dynamic environment - `arch`, `debian` or `ubuntu (wsl)`
- Focus on terminal and programs\
   for desktop environment head [over to this](https://github.com/shiftgeist/horiceon-dwm)
- Learn go

## setup

Get started

```
chezmoi init https://github.com/shiftgeist/horiceon.git

chezmoi apply ~/.local/bin
```

For `dwm` and `fzf`

```
git submodule update --init
```

### extra

Extras can be found under [`horiceon-extra`](https://github.com/shiftgeist/horiceon-extra).

## credits

This project is originally inspired by [Horizon Theme](https://marketplace.visualstudio.com/items?itemName=jolaleye.horizon-theme-vscode), is now based around the [Panda Syntax](https://github.com/tinkertrain/panda-syntax-vscode) color palette.\
Config files are it's inspired by [LukeSmithxyz/voidrice](https://github.com/LukeSmithxyz/voidrice) and [paulirish/dotfiles](https://github.com/paulirish/dotfiles).
