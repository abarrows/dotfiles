#!/usr/bin/env bash

echo "ZSH/FUNCTIONS: Loaded."

# DEBUGGING SCRIPTS

# FUNCTIONS
function updateorigin()
{
  if git remote rename origin bitbucket ; then
    printf "%s\n" "1. ...Renamed origin to bitbucket" && git remote add origin https://github.com/Andrews-McMeel-Universal/"$1".git
  else
    printf "%s\n" "1. ...Origin could not be found.  Simply adding github as the new origin..." &&
    git remote add origin https://github.com/Andrews-McMeel-Universal/"$1".git
  fi
  printf "%s\n" "2. ...Successfully updated your bitbucket remotes to github:" && git remote -v && \
  printf "%s\n" "3. ...Fetching and getting any new work from your new remotes." && git fetch --all && \
  printf "%s\n" "4. ...Now setting staging and production to point upstream to github." \
  && git branch --set-upstream-to=origin/staging staging && \
  git branch --set-upstream-to=origin/production production && git pull \
  && printf "%s\n" "5. ...Lastly, a fresh pull and you are all set!"
}

function replaceorigin()
{
  if git remote rename origin oldorigin ; then
    echo "1. ...Renamed origin to oldorigin" && git remote add origin https://github.com/Andrews-McMeel-Universal/"$1".git
  else
    echo "1. ...Origin could not be found.  Simply adding github as the new origin..." &&
    git remote add origin https://github.com/Andrews-McMeel-Universal/"$1".git
  fi
  if git remote remove oldorigin ; then
    printf "%s\n" "2. ...Removing old origin."
  else
    printf "%s\n" "2. ...Could not find an old origin so no cleanup is needed."
  fi
  printf "%s\n" "3. ...Successfully updated your bitbucket remotes to github:"
  git remote -v
  printf "%s\n" "3. ...Fetching and getting any new work from github."
  git fetch --all
  printf "%s\n" "4. ...Now setting staging and production to point upstream to github."
  git branch --set-upstream-to=origin/staging staging
  git branch --set-upstream-to=origin/production production && git pull
  printf "%s\n" "5. ...Lastly, a fresh pull and you are all set!"
}

function mirrororigin()
{
  printf "%s\n" "1. ...Checking if repo exists in personal github"
  if git remote set-url origin --push --add https://github.com/abarrows/"$1".git ; then
    printf "%s\n" "2. ...The repo exists.  Added it as a remote." \
    && git remote -v \
    && printf "%s\n" "3. Easy as 1,2,3!  All done, here are your remotes!"
  else
    printf "%s\n" "3b. The repo does NOT exists.  Please create first."
  fi
}

function gitsearch()
{
   searchCrit='stash\|'$1
   git stash list | while IFS=: read -r STASH ETC; do echo "$STASH: $ETC"; git diff --stat "$STASH"~.."$STASH" --; done | grep -e "$searchCrit"
}

#function startarachni() { bin/arachni "$@" ;}

function edit() {
    "open -a Visual\ Studio\ Code\ -\ Insiders.app $1"
}
function foremanstop()
{
    "kill $(redis|sidekiq|unicorn|puma|webrick|webpack|foreman) | grep -v grep | awk '{print $2}')"
}
function checkport()
{
    "lsof -i $1"
}
function killjob()
{
    kill -9 "$1"
}

function killport()
{
    lsof -ti tcp:"$1" | xargs kill
}
