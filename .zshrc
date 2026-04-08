# ZSH CONFIG
# zmodload zsh/zprof # Debug

# Basic requirements: curl, docker, git, lsof

# Brew
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

###
# Zshrc helper
###
function _zcompile-many() {
	local f
	for f; do zcompile -R -- "$f".zwc "$f"; done
}

function _check-commands() {
	local missing=()

	for cmd in "$@"; do
		if ! command -v "$cmd" &>/dev/null; then
			missing+=("$cmd")
		fi
	done

	if [ ${#missing[@]} -gt 0 ]; then
		echo "Missing commands: ${missing[*]}"
		return 1
	fi

	return 0
}

###
# Basics
###
RICE_HOME="$HOME/.dotfiles"
export XDG_CACHE="$HOME/.cache/"
export ZSH_CONFIG="$HOME/.config/zsh"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export AUTOSOURCE=1
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>' # where not to stop for word navigation

# Clone missing plugins
if [[ ! -e "$ZSH_CONFIG/fzf-tab" ]]; then
	git clone git@github.com:Aloxaf/fzf-tab.git "$ZSH_CONFIG/fzf-tab"
fi

if [[ ! -e "$ZSH_CONFIG/alias-tips" ]]; then
	git clone https://github.com/djui/alias-tips.git "$ZSH_CONFIG/alias-tips"
fi

# Compile missing plugins
if [[ ! -e "$XDG_CACHE/completion-for-pnpm.zsh" ]]; then
	pnpm completion zsh >"$XDG_CACHE/completion-for-pnpm.zsh"
fi

# Set PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.local/share/mise/installs/go/latest/bin:$PATH

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

# Set completion PATH
FPATH="$(brew --prefix)/share/zsh/site-functions:$HOME/.zsh/completions:$FPATH"

# User settings
export GIT_SEQUENCE_EDITOR="code --wait --diff"
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse"

# Completion Settings
zstyle ':completion:*' completer _complete _ignored _expand_alias
zstyle ':completion:*:git-checkout:*' sort false
# preview content or directory's content with eza when completing
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || eza -la --color=always $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# Enable the "new" completion system (compsys)
autoload -Uz compinit && compinit
[[ ~/.zcompdump.zwc -nt ~/.zcompdump ]] || _zcompile-many ~/.zcompdump
unfunction _zcompile-many

###
# Plugins
###

source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
source "$(brew --prefix)/share/zsh/site-functions"
source "$ZSH_CONFIG/fzf-tab/fzf-tab.plugin.zsh"
source "$ZSH_CONFIG/alias-tips/alias-tips.plugin.zsh"
source "$XDG_CACHE/completion-for-pnpm.zsh"
source "$HOME/.cargo/env"

###
# Keybinds
###

bindkey -e # emacs mode

###
# Internals
###

if _check-commands starship; then
	eval "$(starship init zsh)"
fi

function alpine() {
	function _help() {
		echo "Usage: alpine [--pkg=PKG] <binary> [args...]"
		echo "Example: 'alpine --pkg=android-tools adb pair 192.168.172.123:45678 123456'"
	}

	local package=$1

	if [[ "$1" == --pkg=* ]]; then
		package="${1#--pkg=}"
		shift
	elif [[ "$1" == --pkg ]]; then
		echo "Error: --pkg requires a value (use --pkg=VALUE)\n"
		_help
		return 1
	fi

	if [ $# -lt 1 ]; then
		_help
		return 1
	fi

	local bin=$1
	shift

	docker run --rm -it --init -v "$(pwd)":/app -w /app alpine:latest sh -c "apk add --quiet $package && $bin \"\$@\"" -- "$@"
}

if _check-commands docker; then
	function command_not_found_handler() {
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
		alpine $cmd "$@"
	}
fi

###
# User space
###

alias "..."="cd ../.."
alias "...."="cd ../../.."
alias clipboard="pbcopy"
alias copy="pbcopy"
alias finder="open"
alias grepf="fzf -f"
alias horiceon="/usr/bin/git --git-dir=$RICE_HOME --work-tree=$HOME"
alias la="ls -la"
alias now="date +%s"
alias rm="trash"
alias timestamp="date +%s"

function cheat {
	curl "cht.sh/$1" | less -R
}
alias example="cheat"
alias expl="cheat"
alias explain="cheat"
alias tldr="cheat"
alias help="cheat"
function til() {
	target=$(date -j -f "%H:%M" "$1" "+%s")
	now=$(date +%s)
	sleep $((target - now))
}

function wind {
	key="wind_speed_180m"
	json=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$1&longitude=$2&current=$key&wind_speed_unit=kmh&models=best_match&timezone=auto")
	wind=$(echo "$json" | yq -P ".current.$key")
	unit=$(echo "$json" | yq -P ".current_units.$key")

	echo "$wind $unit"
}

function check-port() {
	lsof -i tcp${1:+":$1"}
}

function kill_port() {
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

function cheatsheet_iterm2() {
	URL='https://gist.githubusercontent.com/squarism/ae3613daf5c01a98ba3a/raw/e0b1c1c0309244400b847fc539899bcfde42f98a/iterm2.md'
	CACHE_FILE="$XDG_CACHE_HOME/$(echo "$URL" | sha256sum | cut -d' ' -f1).md"

	[[ ! -f "$CACHE_FILE" ]] && curl -sL "$URL" -o "$CACHE_FILE"

	glow --pager "$CACHE_FILE"
}

if _check-commands bat; then
	alias cat="bat -p"
fi

if _check-commands brew; then
	function brew-bundle-dump() {
		brew bundle dump --global --force --no-go
		brew bundle remove --global awscli microsoft-teams gemini-cli mistral-vibe
		echo "Brewfile dumped and filtered"
		if _check-commands mise; then
			mise up # for good measures
		fi
	}

	alias brew-recover="brew bundle install --global"
fi

if _check-commands claude; then
	alias claude="claude --model sonnet --effort medium"
	alias claude-max="claude --model opus --effort medium"
fi

if _check-commands code; then
	export VISUAL="code"

	alias horiceon-code='GIT_DIR="$RICE_HOME" GIT_WORK_TREE="$HOME" code "$HOME"'
fi

if _check-commands glow; then
	alias glow="glow --width \"$(tput cols)\""
fi

if _check-commands eza; then
	alias exa="eza"
	alias ls="eza"
fi

if _check-commands mask; then
	function mask() {
		local args=()
		[[ ! -f "maskfile.md" && -f "README.md" ]] && args=(--maskfile README.md)
		command mask "${args[@]}" "$@"
	}
fi

if _check-commands mise; then
	eval "$(mise activate zsh)"

	alias corepack="~/.local/share/mise/installs/npm-corepack/latest/bin/corepack"

	function continues() {
		pnpx continues dump ${1:-claude} ./out --limit 1 --preset full
	}
fi

if _check-commands brew; then
	alias brew-up="brew upgrade && brew upgrade beekeeper-studio blender bruno cyberduck figma gimp helium-browser iterm2 keepingyouawake lens obs obsidian spotify visual-studio-code zen && mise up"
	alias mise-up="brew-up"
fi

if _check-commands npq-hero; then
	alias npm-check="npq-hero"
	alias pnpm-check="NPQ_PKG_MGR=pnpm npq-hero"
	alias yarn-check="NPQ_PKG_MGR=yarn npq-hero"
fi

if _check-commands pnpm; then
	alias B="pnpm build"
	alias D="pnpm dev"
	alias T="pnpm test"
	alias I="pnpm install"
	alias ts-prune="pnpx knip"

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
		export APP_VERSION="$(git rev-parse --short HEAD)"
		_mba-launch &
		pnpm install &
		wait
		pnpm dev
	}
fi

if _check-commands scrcpy; then
	alias android-remote="scrcpy"
fi

if _check-commands trivy; then
	alias trivy-scan="trivy fs --scanners=vuln,misconfig --list-all-pkgs --severity=CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN --skip-dirs=.build,.dart_tool,.egg-info,.egg,.git,.hg,.svn,.venv,.whl,bin,build,deps,node_modules,obj,pods,target,vendor,venv --exit-code=0 --format=json --output=results.json ."
fi

if _check-commands uv; then
	alias pip="uv pip"
fi

if _check-commands vim; then
	export EDITOR="vim"
fi

if _check-commands yq; then
	alias jq="yq"

	function run() {
		pm="pnpm"

		if [ "$1" = "npm" ] || [ "$1" = "pnpm" ] || [ "$1" = "bun" ]; then
			pm="$1"
			shift
		fi

		if [ "$2" = "!" ]; then
			$pm run "$1"
			return
		fi

		if [ -z "$1" ]; then
			yq -o=json ".scripts" package.json
			return
		fi

		matches=$(yq -o=json ".scripts | with_entries(select(.key | test(\"(?i)$1\")))" package.json)

		if [ $(echo "$matches" | jq 'length') -eq 1 ]; then
			$pm run $(echo "$matches" | jq -r 'keys[0]')
		else
			echo "$matches" | bat -l json -p
		fi
	}

	function curl-pretty {
		curl -s $@ | yq -P
	}
fi

if _check-commands yazi; then
	function y() {
		local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
		yazi "$@" --cwd-file="$tmp"
		IFS= read -r -d '' cwd <"$tmp"
		[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
		rm -f -- "$tmp"
	}
fi

if _check-commands zoxide; then
	export _ZO_DOCTOR=0
	eval "$(zoxide init zsh)"
	alias cd="z"
	alias cdi="zi"
fi

###
# WSL setups
###

IS_WSL=$([[ -f /proc/version ]] && grep -qi microsoft /proc/version && echo true)

if [[ $IS_WSL ]]; then
	function horiceon-sync() {
		cp -r ~/Library/Application\ Support/Code /mnt/c/Users/user/AppData/Roaming
	}

	if [[ ! -e ~/c ]]; then
		ln -s /mnt/c/Users/user/ $c_drive
	fi

	if [[ $(command -v apt-get) ]]; then
		alias apt-setup="sudo apt-get install trash-cli"
	fi
fi

# zprof # Debug performance (keep @ bottom)
