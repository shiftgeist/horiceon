# ZSH CONFIG
# zmodload zsh/zprof # Debug

# Basic requirements: curl, docker, git, lsof

IS_WSL=$([[ -f /proc/version ]] && grep -qi microsoft /proc/version && echo true)

# Brew
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
test -d /opt/homebrew/bin/brew && eval "$(/opt/homebrew/bin/brew shellenv zsh)"

###
# Zshrc helper
###

preexec() {
	local after="${1##*|}"
	[[ "$after" =~ ^[[:space:]]*copy([[:space:]]|$) ]] && _last_cmd="${1%|*}" || _last_cmd="$1"
}

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
export PATH=$HOME/.horiceon/bin:$PATH

# History
export HISTSIZE=200000 # 5y of 100 commands/day
export SAVEHIST=$HISTSIZE

# Options
setopt AUTO_CD              # automatic directory change
setopt BANG_HIST            # treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY     # write the history file in the ":start:elapsed;command" format.
setopt GLOBDOTS             # hidden files globbing
setopt HIST_FIND_NO_DUPS    # only skips dupes during Ctrl+R search
setopt INC_APPEND_HISTORY   # write to the history file immediately, not when the shell exits.
setopt INTERACTIVE_COMMENTS # ignore commands starting with hashtag
setopt NO_CASE_GLOB         # case insensitive globbing
setopt SHARE_HISTORY        # share history between all sessions.

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
alias finder="open"
alias grepf="fzf -f"
alias horiceon="/usr/bin/git --git-dir=$RICE_HOME --work-tree=$HOME"
alias la="ls -la"
alias now="date +%s"
alias rm="trash"
alias timestamp="date +%s"
alias la="ls -la"

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

function alias-suggest() {
  local noise='awk|sort|head'

  fc -l 1 |
    # Drop the leading history event number.
    sed -E 's/^[[:space:]]*[0-9]+[[:space:]]*//' |
    # Split pipelines into separate command segments and unescape.
    sed -E 's/\\n/ /g; s/ \| /\n/g; s/\\//g' |
    # Trim surrounding whitespace, drop blank lines.
    awk 'NF { $1=$1; print }' |
    # Keep lines that look like a command invocation...
    grep -E '^[a-zA-Z/~.]' |
    # ...excluding noise commands and any leftover pipelines...
    grep -Ev "^($noise) " |
    grep -v '|' |
    # ...and excluding assignments or quoted strings.
    awk '$1 !~ /["=]/ && $1 ~ /[a-z]/' |
    # Normalize: expand the leading command word so `g status` and
    # `git status` (where g=git) contribute to the same count.
    while read -r line; do
      local cmd="${line%% *}"
      local rest="${line#"$cmd"}"
      print -r -- "${aliases[$cmd]:-$cmd}$rest"
    done |
    # Count identical commands, keep repeats, most frequent first.
    sort | uniq -c | awk '$1 > 1' | sort -rn
}

_cli_continues="$HOME/code/cli-continues"

if [[ ! -e "$_cli_continues/dist/cli.js" ]]; then
	[[ ! -d "$_cli_continues" ]] && git clone git@github.com:shiftgeist/cli-continues.git "$_cli_continues"
	(cd "$_cli_continues" && pnpm install && pnpm run build)
fi

alias continues="node $_cli_continues/dist/cli.js"
alias continues-dump="continues dump ./sessions --preset full --limit 1"

if _check-commands bat; then
	alias cat="bat -p"
fi

if _check-commands brew; then
	function brew-bundle-dump() {
		brew bundle dump --global --force --no-go --no-npm
		brew bundle remove --global awscli antigravity-cli claude-code claudebar gemini-cli microsoft-teams mistral-vibe ladybird
		echo "Brewfile dumped and filtered"
	}

	alias brew-recover="brew bundle install --global && mise up"
	alias brew-up-apps="brew upgrade \
  affinity \
  beekeeper-studio \
  blender \
  bruno \
  cyberduck \
  figma \
  iterm2 \
  obsidian \
  slack \
  spotify \
  zen"
	alias brew-up="brew upgrade && brew-up-apps"
	alias brew-up-all="brew upgrade --greedy && mise up"

	alias ladybird-setup="brew create https://github.com/LadybirdBrowser/ladybird/archive/refs/heads/master.zip --set-name ladybird --set-version HEAD && brew edit ladybird" # sorry no formula code available
	if [ -d /opt/homebrew/opt/ladybird/.brew/ladybird.rb ]; then
		alias ladybird-install="HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source ladybird"
		alias ladybird-update="HOMEBREW_NO_INSTALL_FROM_API=1 brew upgrade --fetch-HEAD ladybird"
		alias ladybird-make-app="sudo rm -rf /Applications/Ladybird.app && sudo cp -R /opt/homebrew/opt/ladybird/bundle/Ladybird.app /Applications/Ladybird.app"
		alias ladybird-reinstall="HOMEBREW_NO_INSTALL_FROM_API=1 brew reinstall --build-from-source ladybird"
	fi
fi

if _check-commands code; then
	export VISUAL="code"

	alias horiceon-code='GIT_DIR="$RICE_HOME" GIT_WORK_TREE="$HOME" code --disable-extensions "$HOME"'
fi

if _check-commands glow; then
	alias glow="glow --width \"$(tput cols)\""
fi

if _check-commands eza; then
	alias exa="eza"
	alias ls="eza"
fi

if _check-commands fd; then
	alias fda="fd --unrestricted --full-path"
fi

if _check-commands mise; then
	eval "$(mise activate zsh)"
	echo "mise active"
fi

if _check-commands pnpm; then
	alias ts-prune="pnpx knip"
fi

if _check-commands pbcopy pbcopy; then
	function copy() {
		local include_cmd=false
		[[ "$1" == "-c" ]] && include_cmd=true

		local content=$(cat)
		printf '%s\n' "$content"

		if $include_cmd; then
			printf '%s\n%s\n' "$_last_cmd" "$content" | pbcopy
		else
			printf '%s\n' "$content" | pbcopy
		fi
	}

	alias clipboard="copy"
	alias paste="pbpaste"
fi

if _check-commands uv; then
	alias pip="uv pip"
	alias bestllm="uvx whichllm@latest --profile coding"
fi

if _check-commands vim; then
	export EDITOR="vim"
fi

if _check-commands yq; then
	alias jq="yq"

	function curl-pretty {
		curl -s $@ | yq -P
	}

	function run() {
		# --- tool detection (overridable as first arg) ---
		local tool

		if [ "$1" = "npm" ] || [ "$1" = "pnpm" ] || [ "$1" = "bun" ] || [ "$1" = "mise" ] || [ "$1" = "make" ]; then
			tool="$1"
			shift
		elif [ -f ".mise.toml" ]; then
			tool="mise"
		elif [ -f "Makefile" ]; then
			tool="make"
		elif [ -f "package.json" ]; then
			if [ -f "pnpm-lock.yaml" ]; then
				tool="pnpm"
			elif [ -f "bun.lockb" ]; then
				tool="bun"
			else
				tool="npm"
			fi
		else
			echo "No recognized project file found (.mise.toml / Makefile / package.json)"
			return 1
		fi

		# --- list tasks/scripts when called with no args ---
		if [ -z "$1" ]; then
			case "$tool" in
			mise) mise tasks ls ;;
			make) make -qp 2>/dev/null | grep -E '^[a-zA-Z][a-zA-Z0-9_-]*:' | cut -d: -f1 | sort ;;
			*) yq -o=json ".scripts" package.json ;;
			esac
			return
		fi

		# --- exact run with trailing ! (e.g. `run build !`) ---
		if [ "$2" = "!" ]; then
			case "$tool" in
			mise) mise run "$1" ;;
			make) make "$1" ;;
			*) $tool run "$1" ;;
			esac
			return
		fi

		# --- fuzzy match for node package managers ---
		if [ "$tool" = "pnpm" ] || [ "$tool" = "npm" ] || [ "$tool" = "bun" ]; then
			local matches
			matches=$(yq -o=json ".scripts | with_entries(select(.key | test(\"(?i)$1\")))" package.json)
			local count
			count=$(echo "$matches" | jq 'length')

			if [ "$count" -eq 0 ]; then
				echo "No scripts matching '$1'"
				return 1
			elif [ "$count" -eq 1 ]; then
				local script
				script=$(echo "$matches" | jq -r 'keys[0]')
				echo "Running $script with $tool"
				sleep 0.3
				$tool run "$script"
			else
				echo "$matches" | bat -l json -p
			fi
			return
		fi

		# --- mise / make: pass through directly ---
		case "$tool" in
		mise) mise run "$1" ;;
		make) make "$1" ;;
		esac
	}

	alias B="run build"
	alias D="run dev"
	alias T="run test"
	alias I="run install"
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
