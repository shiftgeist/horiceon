export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="spaceship"

HYPHEN_INSENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="dd.mm.yyyy"

plugins=(
    git
    zsh-better-npm-completion
    zsh-completions
    git-flow
)

source $ZSH/oh-my-zsh.sh

# node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Keymap (setxkbmap -query)
setxkbmap us altgr-intl

# System
SUDO_ASKPASS=~/bin/askpass-rofi

# alias
alias battery-status="upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E 'state|time\ to\ full|percentage'"
alias docker-cleanup="yes | docker image prune -a --filter 'until=24h'"
alias git-whoami="echo -e '\e[96mUsername\e[0m: $(git config user.name)' && echo -e '\e[96mE-Mail\e[0m: ' ' $(git config user.email)'"
alias git-cleanup="git branch --merged | egrep -v '(^\*|master|dev)' | xargs git branch -d && git pull --prune"
alias syslog-crit="sudo dmesg -w -l err,warn"
alias syslog="sudo dmesg -w"
alias fortune="fortune | cowsay | lolcat"

if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi
