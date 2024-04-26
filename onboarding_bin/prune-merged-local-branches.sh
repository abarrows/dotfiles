#!/bin/bash

git fetch -p &&
  git for-each-ref --format '%(refname:short) %(upstream:track)' |
  awk '$2 == "[gone]" {print $1}' |
    xargs -r git branch -D
