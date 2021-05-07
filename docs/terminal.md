# Terminal

Speed up working on terminal.

## SSH

Generate new SSH key

```
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Generate new SSH key (legacy)

```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

List SSH key

```
ls -lah ~/.ssh
```

Copy public ssh key to server (`-n` dry run)

```
ssh-copy-id -n user@server
```

## Shortcuts

TMUX

- Min-/Maximise current pane: `c-b z`
- Backward Search: `c-b ctrl+shift+b`
- Resize pane: `c-b ctrl+[arrow-key]`

Shell

- delete word after cursor: `ctrl` + `w`
- delete word before cursor: `alt` + `d`
- undo: `ctrl` + `_`
- delete from cursor to start: `ctrl` + `u`

## VIM

Navigation

- word: `w` / `b`
- paragraph: `}` / `{`

Delete

- to end of line: `shift` + `d`
- line: `dd`

## Usefull

List all files with human readable units sorted by last changed

```
ls -laht
```
