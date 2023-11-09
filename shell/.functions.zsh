#!/usr/bin/env bash

# DEBUGGING SCRIPTS

# FUNCTIONS
function checkprocess() {
  local port="${1:-3000}" # Use the provided argument or default to 3000
  lsof -i:"$port"
}

function mirrororigin() {
  printf "%s\n" "1. ...Checking if repo exists in personal github"
  if git remote set-url origin --push --add https://github.com/abarrows/"$1".git; then
    printf "%s\n" "2. ...The repo exists.  Added it as a remote." &&
      git remote -v &&
      printf "%s\n" "3. Easy as 1,2,3!  All done, here are your remotes!"
  else
    printf "%s\n" "3b. The repo does NOT exists.  Please create first."
  fi
}

function gitsearch() {
  searchCrit='stash\|'$1
  git stash list | while IFS=: read -r STASH ETC; do
    echo "$STASH: $ETC"
    git diff --stat "$STASH"~.."$STASH" --
  done | grep -e "$searchCrit"
}

echo "ZSH/FUNCTIONS: Loaded."
