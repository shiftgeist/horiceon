# ZSH CONFIG

# Zshrc helper
function zcompile-many() {
  local f
  for f; do zcompile -R -- "$f".zwc "$f"; done
}

# Basic
export XDG_CACHE="$HOME/.cache/"
export ZSH_CONFIG="$HOME/.config/zsh"

# Clone missing plugins
if [[ ! -e "$ZSH_CONFIG/fzf-tab" ]]; then
  git clone git@github.com:Aloxaf/fzf-tab.git "$ZSH_CONFIG/fzf-tab"
fi

if [[ ! -e "$ZSH_CONFIG/alias-tips" ]]; then
  git clone git@github.com:djui/alias-tips.git "$ZSH_CONFIG/alias-tips"
fi

# Compile missing plugins
if [[ ! -e "$XDG_CACHE/completion-for-pnpm.zsh" ]]; then
  pnpm completion zsh > "$XDG_CACHE/completion-for-pnpm.zsh"
fi

# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Set PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.npm-global/bin:$PATH
export PATH=$HOME/.deno/bin:$PATH
export PATH=$HOME/.bun/bin:$PATH
export PATH="$(brew --prefix)/opt/openjdk/bin:$PATH"
export PATH="$(go env GOPATH)/bin:$PATH"

# History
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE

# Options
setopt BANG_HIST              # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY       # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY     # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY          # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST # Expire dup event first when trimming hist
setopt HIST_FIND_NO_DUPS      # Do not display previously found event
setopt HIST_IGNORE_ALL_DUPS   # Delete old event if new is dup
setopt HIST_IGNORE_DUPS       # Do not record consecutive dup events
setopt HIST_IGNORE_SPACE      # Do not record event starting with a space
setopt HIST_SAVE_NO_DUPS      # Do not write dup event to hist file
setopt AUTO_CD                # automatic directory change
setopt GLOBDOTS               # hidden files globbing
setopt INTERACTIVE_COMMENTS   # ignore commands starting with hashtag
setopt NO_CASE_GLOB           # case insensitive globbing

# Backup history
cp $HISTFILE $HISTFILE.old

# Set completion PATH
export FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"

# User settings
export GIT_SEQUENCE_EDITOR="code --wait --diff"
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse"

zstyle ':completion:*' completer _complete _ignored _expand_alias

# Enable the "new" completion system (compsys)
autoload -Uz compinit && compinit
[[ ~/.zcompdump.zwc -nt ~/.zcompdump ]] || zcompile-many ~/.zcompdump
unfunction zcompile-many

# Plugins
source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
source "$(brew --prefix)/share/zsh/site-functions"
source "$ZSH_CONFIG/fzf-tab/fzf-tab.plugin.zsh"
source "$ZSH_CONFIG/alias-tips/alias-tips.plugin.zsh"
source "$XDG_CACHE/completion-for-pnpm.zsh"

# Completion Settings
# preview content or directory's content with eza when completing
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || eza -la --color=always $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# Aliases that should not be pet's
alias run="pet exec"
alias horiceon="/usr/bin/git --git-dir=$HOME/code/horiceon --work-tree=$HOME"

if command -v eza &> /dev/null; then
  alias ls="eza"
fi

if command -v bat &> /dev/null; then
  alias cat="bat -p"
fi

# Always enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

function prev() {
  PREV=$(fc -lrn | head -n 1)
  sh -c "pet new --tag `printf %q "$PREV"`"
}

eval "$(direnv hook zsh)"

# Prompt
eval "$(starship init zsh)"

# Links and stuff
# In case of unsecure: "compaudit | xargs chmod g-w"
# https://github.com/romkatv/zsh-bench/blob/master/configs/diy%2B%2Bfsyh/skel/.zshrc

# pnpm
export PNPM_HOME="/Users/felix/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Commands

# Save brewfile
alias brew-dump="brew bundle dump -gf"

# Edit rice config files
alias horiceon-code="GIT_WORK_TREE=$HOME GIT_DIR=$HOME/code/horiceon code $HOME"

# Delete merged branches
alias git-cleanup="git branch --merged | grep -E -v '(^\\*|master|dev|main)' | xargs git branch -d && git pull --prune"

# Start docker with clean build
alias mb-docker-dev="APP_VERSION=$(git rev-parse --short HEAD) docker compose pull && APP_VERSION=$(git rev-parse --short HEAD) pnpm load-env -- docker compose up -d --force-recreate && pnpm install && TURBO_UI=true pnpm dev"

# Run pnpm dev with environment variables
alias dev="TURBO_UI=true pnpm dev"

# Find process with port
alias check-port-8080="lsof -i tcp:8080"

# Watch for git changes every N seconds
alias git-watch="watch -n 5 -d --color 'git fetch --quiet && GIT_PAGER=bat git log --oneline --graph --all --decorate --color=always'"
