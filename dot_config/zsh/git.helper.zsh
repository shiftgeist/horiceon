#!/usr/bin/env zsh

# We wrap in a local function instead of exporting the variable directly in
# order to avoid interfering with manually-run git commands by the user.
__git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

git_is_repo() {
  __git rev-parse HEAD > /dev/null 2>&1
}

git_is_clean() {
  if [[ -z $(__git status -s) ]]
  then
    return 0
  else
    return 1
  fi
}

# Outputs the name of the current branch
__git_current_branch() {
  git_is_repo || return
  ref=$(__git symbolic-ref --quiet HEAD 2> /dev/null)
  ret=$?
  if [ $ret -ne 0 ]; then
    [ $ret -eq 128 ] && return  # no git repo.
    ref=$(__git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo "${ref#refs/heads/}"
}

# Outputs the id of the current commit
__git_current_commit() {
  ref=$(__git rev-list --tags --max-count=1)
  echo "$ref"
}

__git_fzf_branch() {
  git_is_repo || return

  __git branch --all --sort=-committerdate --color=always |
    # remove entries with "HEAD" in them
    grep -v HEAD |
    # run thought fzf
    fzf --ansi --no-multi --preview-window right:65% --preview '__git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s (%an)" $(sed "s/.* //" <<< {})' |
    # trim asterisk and leading whitespace
    sed "s/.* //"
}

__git_fzf_checkout() {
  git_is_repo || return

  if [[ $@ ]]; then
    command __git checkout "$@"
    return $?
  fi

  local branch
  branch=$(__git_fzf_branch)
  [[ "$branch" = "" ]] && return

  if [[ "$branch" = "remotes/"* ]]; then
    __git checkout "$(echo $branch | cut -d '/' -f 3-4)";
  else
    __git checkout "$branch";
  fi
}

__git_push_current_to_origin() {
  __git push --set-upstream origin "$(__git_current_branch)"
}

__npm_set_tag() {
  git_is_clean || return

  if [ -f "package.json" ]; then
    jq ".version=\"$1\"" package.json > package.json.tmp
    mv package.json.tmp package.json
  fi

  if [ -f "package-lock.json" ]; then
    jq ".version=\"$1\"" package-lock.json > package-lock.json.tmp
    mv package-lock.json.tmp package-lock.json
  fi
}

__git_latest_tag() {
  __git describe --tags "$(__git_current_commit)"
}

__git_push_force_ask() {
  read "REPLY?Force push? (Yy) "
  case $REPLY in
    *)
    __git push --force-with-lease
    ;;
  esac
}

__git_flow_release_start() {
  if [[ $@ ]]; then
    NEW_GIT_TAG="$@"
  else
    read "REPLY?[m]ajor, m[I]nor or [p]atch? "
    case $REPLY in
      m|major)
      NEW_GIT_TAG=$(up git major)
      ;;
      p|patch)
      NEW_GIT_TAG=$(up git patch)
      ;;
      *|i)
      NEW_GIT_TAG=$(up git minor)
      ;;
    esac
  fi

  __git flow release start $NEW_GIT_TAG
  __npm_set_tag $NEW_GIT_TAG
}

__git_flow_hotfix_start() {
  if [[ $@ ]]; then
    NEW_GIT_TAG="$@"
  else
    NEW_GIT_TAG=$(up git patch)
  fi

  __git flow hotfix start $NEW_GIT_TAG
  __npm_set_tag $NEW_GIT_TAG
}

__git_flow_finish() {
  local BRANCH=$(__git_current_branch)
  local FLOW_TYPE="$(cut -d '/' -f1 <<< "$BRANCH")"
  local FLOW_NAME="$(cut -d '/' -f2 <<< "$BRANCH")"
  local FLOW_MESSAGE=""

  echo "git flow $FLOW_TYPE finish -m \"$FLOW_NAME\""

  export GIT_MERGE_AUTOEDIT=no
  __git flow $FLOW_TYPE finish $FLOW_MESSAGE
  unset GIT_MERGE_AUTOEDIT
}
