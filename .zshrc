# ZSH CONFIG

# Zshrc helper
function zcompile-many() {
  local f
  for f; do zcompile -R -- "$f".zwc "$f"; done
}

# Basic
export XDG_CACHE="$HOME/.cache/"
export ZSH_CONFIG="$HOME/.config/zsh"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Clone missing plugins
if [[ ! -e "$ZSH_CONFIG/fzf-tab" ]]; then
  git clone git@github.com:Aloxaf/fzf-tab.git "$ZSH_CONFIG/fzf-tab"
fi

if [[ ! -e "$ZSH_CONFIG/alias-tips" ]]; then
  git clone git@github.com:djui/alias-tips.git "$ZSH_CONFIG/alias-tips"
fi

# Compile missing plugins
if [[ ! -e "$XDG_CACHE/completion-for-pnpm.zsh" ]]; then
  pnpm completion zsh >"$XDG_CACHE/completion-for-pnpm.zsh"
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
export PATH="$HOME/Library/pnpm:$PATH"
export PATH="$COMPOSER_HOME/vendor/bin:$PATH"

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
zstyle ':completion:*:git-checkout:*' sort false

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

###
# Prompt
###

if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

###
# Aliases
###

alias horiceon="/usr/bin/git --git-dir=$HOME/code/horiceon --work-tree=$HOME"
alias horiceon-code="GIT_WORK_TREE=$HOME GIT_DIR=$HOME/code/horiceon code $HOME"
alias rm="trash"
alias la="ls -la"
alias grepf='fzf -f'

if command -v bat &>/dev/null; then
  alias cat="bat -p"
fi

if command -v docker &>/dev/null; then
  alias docekr=docker

  function _mba-launch {
    if pnpm load-env -- echo; then
      pnpm load-env -- docker compose --profile="infra" pull
      pnpm load-env -- docker compose --profile="infra" up -d $@
    else
      docker compose --profile="infra" pull
      docker compose --profile="infra" up -d $@
    fi
  }

  function mba-launch {
    export APP_ENV="development"
    export APP_VERSION="$(git rev-parse --short HEAD &>/dev/null)"
    _mba-launch &
    pnpm install &
    wait
    pnpm dev
  }
fi

if command -v glow &>/dev/null; then
  alias glow="glow --width \"$(tput cols)\""
fi

if command -v eza &>/dev/null; then
  alias ls="eza"
fi

if command -v mask &>/dev/null; then
  mask() {
    local args=()
    [[ ! -f "maskfile.md" && -f "README.md" ]] && args=(--maskfile README.md)
    command mask "${args[@]}" "$@"
  }
fi

if command -v uv &>/dev/null; then
  alias pip="uv pip"
fi

if command -v yq &>/dev/null; then
  alias jq="yq"
fi

if command -v yazi &>/dev/null; then
  y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd <"$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd="z"
  alias cdi="zi"
fi

alias brew-bundle-dump="brew bundle dump --global --force"

check-port() {
  lsof -i tcp${1:+":$1"}
}

pnpm-run() {
  if [ "$2" = "!" ]; then
    pnpm run "$1"
  elif [ -n "$1" ]; then
    cat package.json | yq -o=json -r ".scripts.$1" | bat -l sh -p
  else
    cat package.json | yq -o=json -r ".scripts"
  fi
}

alias ts-prune="pnpx knip"

kill_port() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: kill_port <PORT>"
    return 1
  fi

  PORT=$1

  PID=$(lsof -t -i tcp:$PORT)

  if [ -z "$PID" ]; then
    echo "No process found running on port $PORT"
    return 1
  fi

  echo "Killing process $PID running on port $PORT"
  kill -9 $PID
}

cheatsheet_iterm2() {
  URL='https://gist.githubusercontent.com/squarism/ae3613daf5c01a98ba3a/raw/e0b1c1c0309244400b847fc539899bcfde42f98a/iterm2.md'
  CACHE_FILE="$XDG_CACHE_HOME/$(echo "$URL" | sha256sum | cut -d' ' -f1).md"

  [[ ! -f "$CACHE_FILE" ]] && curl -sL "$URL" -o "$CACHE_FILE"

  glow --pager "$CACHE_FILE"
}

tool() {
  if [ $# -lt 1 ]; then
    echo "Usage: tool <package> [args...]"
    return 1
  fi

  local package=$1
  shift
  docker run --rm -it --init -v "$(pwd)":/app -w /app alpine:latest sh -c "apk add --quiet $package && $package \"\$@\"" -- "$@"
}

command_not_found_handler() {
  local cmd=$1

  if [[ ! -t 0 ]]; then
    echo "Command '$cmd' not found"
    return 127
  fi

  echo
  echo "Command '$cmd' not found. Try with alpine? [Y/n]"
  read -k 1 run_response

  if [[ $run_response == "n" || $run_response == "N" ]]; then
    return 127
  fi

  shift
  tool $cmd "$@"
}
