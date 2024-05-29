function zcompile-many() {
  local f
  for f; do zcompile -R -- "$f".zwc "$f"; done
}

# Clone and compile missing plugins
if [[ ! -e "$HOME/.config/zsh/fzf-tab" ]]; then
  git clone git@github.com:Aloxaf/fzf-tab.git "$HOME/.config/zsh/fzf-tab"
fi

if [[ ! -e "$HOME/.cache/completion-for-pnpm.zsh" ]]; then
  pnpm completion zsh > "$HOME/.cache/completion-for-pnpm.zsh"
fi

# set PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.npm-global/bin:$PATH
export PATH=$HOME/.deno/bin:$PATH
export PATH=$HOME/.bun/bin:$PATH
export PATH="$(brew --prefix)/opt/openjdk/bin:$PATH"

# history
export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS

# shell Options
setopt AUTO_CD # automatic directory change
setopt GLOBDOTS # hidden files globbing
setopt HIST_EXPIRE_DUPS_FIRST # expire duplicates first
setopt HIST_REDUCE_BLANKS # removes blank lines from history
setopt INC_APPEND_HISTORY # adds commands as they are typed, not at shell exit
setopt INTERACTIVE_COMMENTS # ignore commands starting with hashtag
setopt NO_CASE_GLOB # case insensitive globbing

# brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# set Completion PATH
export FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"

# user settings
export GIT_SEQUENCE_EDITOR="code --wait --diff"
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse"
# export FZF_COMPLETION_TRIGGER="*" # always trigger single asterix

# aliases
if [ -f ~/.aliases ]; then
  . ~/.aliases
fi

# Enable the "new" completion system (compsys)
autoload -Uz compinit && compinit
[[ ~/.zcompdump.zwc -nt ~/.zcompdump ]] || zcompile-many ~/.zcompdump
unfunction zcompile-many

# plugins
source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
source "$(brew --prefix)/share/zsh/site-functions"
source "$HOME/.config/zsh/fzf-tab/fzf-tab.plugin.zsh"
source "$HOME/.cache/completion-for-pnpm.zsh"

# prompt
eval "$(starship init zsh)"

# links and stuff
# In case of unsecure: "compaudit | xargs chmod g-w"
# https://github.com/romkatv/zsh-bench/blob/master/configs/diy%2B%2Bfsyh/skel/.zshrc
