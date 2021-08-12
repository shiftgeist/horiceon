# ![horiceon](.github/horiceon.png)

[![GitHub contributors][contrib_shield]][contrib]
[![issues][issues_shield]][issues]

These are my personal configuration files and scripts, written primarily for
use on an Arch Linux system. In particular, I strive to minimise the amount of
files under `$HOME` by adhering to the [XDG standards][xdg] wherever possible.

## quick start

I manage my dotfiles with [Chezmoi][chezmoi]. Suggestion are welcome, but if they don't fit my prefferences, when they aren't taken further.

## starring

- Shell: [zsh][zsh] + [zinit][zinit]
- Terminal emulator: [Alacritty][alacritty]
- Interface Font: [Overpass][overpass]

## installation and usage

```
sh -c "$(curl -fsLS git.io/chezmoi)" -- init --apply shiftgeist/horiceon
```

## todos

- [ ] explore option to convert bin/executable_rice to ansible

[alacritty]: https://github.com/alacritty/alacritty
[chezmoi]: https://github.com/twpayne/chezmoi
[contrib_shield]: https://img.shields.io/github/contributors/shiftgeist/horiceon
[contrib]: https://github.com/shiftgeist/horiceon/graphs/contributors
[issues_shield]: https://img.shields.io/github/issues/shiftgeist/horiceon
[issues]: https://github.com/shiftgeist/horiceon/issues
[overpass]: https://github.com/RedHatOfficial/Overpass
[xdg]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
[zinit]: https://github.com/zdharma/zinit
[zsh]: https://github.com/zsh-users/zsh
