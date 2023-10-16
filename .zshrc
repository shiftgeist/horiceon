# Set PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.npm-global/bin:$PATH
export PATH=$HOME/.deno/bin:$PATH
export PATH=$HOME/.bun/bin:$PATH

# Aliases
if [ -f ~/.aliases ]; then
  . ~/.aliases
fi

# brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# fzf
source "/opt/homebrew/opt/fzf/shell/completion.zsh"
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

# Setup starship prompt if unset
eval "$(starship init zsh)"
