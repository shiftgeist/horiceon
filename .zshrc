# Set PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.npm-global/bin:$PATH
export PATH=$HOME/.deno/bin:$PATH
export PATH=$HOME/.bun/bin:$PATH

# Shell Options
setopt NO_CASE_GLOB # case insensitive globbing
setopt AUTO_CD # automatic directory change
setopt INC_APPEND_HISTORY # adds commands as they are typed, not at shell exit
setopt HIST_EXPIRE_DUPS_FIRST # expire duplicates first
setopt HIST_REDUCE_BLANKS # removes blank lines from history

# brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Set Completion PATH
export FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"

# Completion
autoload -U compinit; compinit

# Aliases
if [ -f ~/.aliases ]; then
  . ~/.aliases
fi

# fzf
source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"

# prompt
eval "$(starship init zsh)"
