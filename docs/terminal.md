# Terminal

Speed up working on terminal.

## SSH

> Generate new > share

Generate SSH key

    ssh-keygen -t ed25519 -C "your_email@example.com"

Generate SSH key (legacy)

    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

List SSH key

    ls -lah ~/.ssh

Copy public ssh key to server (`-n` dry run)

    ssh-copy-id -n user@server

## GPG

Generate GPG key (> 2.1.17, `RSA and RSA`, min `4096` bits, `2y`)

    gpg --full-generate-key

List GPG keys

    gpg --list-secret-keys --keyid-format LONG

- example output (`3AA5C34371567BD2` = Public key)

      $ gpg --list-secret-keys --keyid-format LONG
      /Users/hubot/.gnupg/secring.gpg
      ------------------------------------
      sec   4096R/3AA5C34371567BD2 2016-03-10 [expires: 2017-03-10]
      uid                          Hubot
      ssb   4096R/42B317FD4BA89E7A 2016-03-10

Export GPG key

    gpg --armor --export 3AA5C34371567BD2

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

    ls -laht
