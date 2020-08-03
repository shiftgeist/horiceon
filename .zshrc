export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="spaceship"

HYPHEN_INSENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="dd.mm.yyyy"

plugins=(
  git
  git-flow
  zsh-better-npm-completion # https://github.com/lukechilds/zsh-better-npm-completion
  zsh-completions # https://github.com/zsh-users/zsh-completions
)

source $ZSH/oh-my-zsh.sh
export PATH=$PATH:$HOME/bin/rice

# autostart X at login
if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
fi


# alias
alias syslog-crit="sudo dmesg -w -l err,warn"
alias syslog="sudo dmesg -w"

alias aglu="apt list --upgradable"
alias agli="apt list --installed"
alias agu="sudo apt update"
alias agug="sudo apt upgrade"
alias battery-status="upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E 'state|time\ to\ full|percentage'"
alias docker-cleanup="echo 'Cleaning docker images older than 24h' && docker image prune -a --filter 'until=24h'"
alias find-broken-symlinks="find ~/ -xtype l -print"
alias ports="netstat -tlpn"

alias gbc="git branch --merged | egrep -v '(^\*|master|dev)' | xargs git branch -d && git pull --prune"

alias nr="npm run"
alias nlsg0="npm list -g --depth=0"
alias nv="npm version --no-git-tag-version"

if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi
