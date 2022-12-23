#!/usr/bin/env bash

# DEBUGGING SCRIPTS

# FUNCTIONS

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

#function startarachni() { bin/arachni "$@" ;}

function foremanstop() {
  "kill $(redis | sidekiq | unicorn | puma | webrick | webpack | foreman) | grep -v grep | awk '{print $2}')"
}
function checkport() {
  "lsof -i $1"
}
function killjob() {
  kill -9 "$1"
}

function killport() {
  lsof -ti tcp:"$1" | xargs kill
}

function ownfile() {
  chmod 755 "$1"
}

function ownfolder() {
  chmod -R 755 "$1"
}

echo "ZSH/FUNCTIONS: Loaded."
