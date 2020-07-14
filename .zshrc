export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="spaceship"

HYPHEN_INSENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="dd.mm.yyyy"

plugins=(
  git
  npm
  zsh-completions
  git-flow
)

source $ZSH/oh-my-zsh.sh

# autostart X at login
if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
fi

# alias
alias syslog-crit="sudo dmesg -w -l err,warn"
alias syslog="sudo dmesg -w"
alias git-whoami="~/bin/rice/git-whoami.sh"
alias git-cleanup="git branch --merged | egrep -v '(^\*|master|dev)' | xargs git branch -d && git pull --prune"
alias battery-status="upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E 'state|time\ to\ full|percentage'"
alias nr="npm run"
alias nlsg0="npm list -g --depth=0"
alias docker-cleanup="echo 'Cleaning docker images older than 24h' && docker image prune -a --filter 'until=24h'"
alias find-broken-symlinks="find ~/ -xtype l -print"
alias ports="netstat -tlpn"

if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi
