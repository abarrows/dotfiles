#!/bin/bash

# First remove the submodule from git files
git config --file=.gitmodules --remove-section submodule.dotbot && git config --file=.git/config --remove-section submodule.dotbot && git rm --cached dotbot && git add .gitmodules
git commit -m "Remove dotbot submodule"

# Then add back in the submodule
git submodule add https://github.com/anishathalye/dotbot

# Then update the .gitmodules file with the new path to the submodule ie:
path="meta/dotbot"

# Commit the changes
git add .gitmodules meta/dotbot && git commit -m "Re-add dotbot submodule" && git push

# Sync and update the submodule
git submodule sync && git submodule update --init --recursive
