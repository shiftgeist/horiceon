![Horiceon](.github/header.png)

# Horiceon

> Dark 🌆 themed 🎨 rice 🍚.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [What's included?](#whats-included)
- [Theme](#theme)
- [Installation](#installation)
- [About](#about)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## What's included?

🎨 Theme, 📖 Config, ⌨️ Shortcut, 🛰️ Same as source, but in the home directory.

| Purpose | Source | Target |
| ------- | ------ | ------ |
| 🎨 Code | `.config/Code/Theme` | `~/.vscode/extensions/horiceon-theme` |
| 📖 Code | `.config/Code/User/settings.json` | 🛰️ |
| ⌨️ Code | `.config/Code/User/keybindings.json` | 🛰️ |
| 📖 Dunst | `.config/dunst/dunstrc` | 🛰️ |
| 📖 i3 | `.config/i3` | 🛰️ |
| 📖 Kitty | `.config/kitty` | 🛰️ |
| 📖 Polybar | `.config/polybar` | 🛰️ |
| 📖 Rofi | `.config/rofi` | 🛰️ |
| 🎨 Spotify | `.config/spicetify/Themes/Horiceon` | 🛰️ |

(See [Installation](#installation) for example.)

## Theme

**Typography**

* Monospace: [Dank Mono](https://dank.sh/)
* Sans: [Overpass](http://overpassfont.org/)

**Syntax Colors**

![colors-syntax](.github/colors-syntax.png)

**UI Colors**

![ui-colors-accents](.github/ui-colors-accents.png)

<details>
  <summary>More</summary>

  ![ui-colors-base](.github/ui-colors-base.png)

  ![ui-status-colors](.github/ui-status-colors.png)

  **ANSI**

  ![ansi](.github/ansi.png)

</details>

<details>
  <summary>Shortcuts</summary>

  | Binding | Function |
  | --- | --- |
  | `Super` + `Ctrl` + `L` | Lock screen |
  | `Super` + `E` | Open files |
  | `Super` + `Q` | Close Application |
  | `Super` + `Return` | Launch Terminal |
  | `Super` + `Space` | Open Application Launcher |
  | `Super` + Number | Switch to tag number |

</details>

## Installation

```bash
~/
➜ sudo pacman -Syu base-devel git

# install yay
➜ git clone https://aur.archlinux.org/yay.git
➜ cd yay
➜ makepkg -si

git clone git@github.com:shiftgeist/horiceon.git
cd horiceon

# core packages of horiceon
~/horiceon
➜ ./helper/yay-core.sh

# symlink or copy packages into your home directory
# example
~/horiceon
➜ ln -s $PWD/.config/rofi ~/.config/rofi
```

Usefull AUR packages besides yay-core

```bash
yay -S brave-bin spotify notion-app bitwarden-bin typora
```

<details>

  | Software | What i use | AUR Name |
  | -------- | ---------- | -------- |
  | Browser | [Brave](https://brave.com/) | `brave-bin` |
  | Music Client | [Spotify](https://www.spotify.com/) | `spotify` |
  | Notes | [Notion](https://www.notion.so/) | `notion-app` |
  | Password Manager | [Bitwarden](https://github.com/bitwarden/desktop) | `bitwarden-bin` |
  | WYSIWYG Editor | [Typora](https://typora.io/)  | `typora` |

</details>

## About

Status: ⚠️ Work in progress.

**Inspiration**

This project is inspired by the vscode [Horizon Theme](https://marketplace.visualstudio.com/items?itemName=jolaleye.horizon-theme-vscode) by [@jolaleye](https://github.com/jolaleye).

**Statistics**

![time tracker](https://wakatime.com/badge/github/shiftgeist/horiceon.svg) [![github issues](https://img.shields.io/github/issues/shiftgeist/horiceon)](https://github.com/shiftgeist/horiceon/issues) [![github stars](https://img.shields.io/github/stars/shiftgeist/horiceon)](https://github.com/shiftgeist/horiceon/stargazers)
