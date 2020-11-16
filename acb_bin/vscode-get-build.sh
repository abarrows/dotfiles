#!/usr/bin/env bash

# First check if vscode is installed.  NOTE: IDE_PATH is used with
# dotbot and generating a path for where the symlinked setting files go.
if [[ $(which code) ]]; then
  IDE_BUILD="code"
  IDE_PATH="code"
fi

# Next, if the vscode insiders app is installed via cask (homebrew), override
# the original IDE_PATH with the insider's build directory name.  (IE: /usr/local/bin/code-insiders)
if [[ $(which code-insiders) ]]; then
  IDE_BUILD="code-insiders"
  IDE_PATH="Code - Insiders"
fi

# Hard coded for testing.
IDE_PATH="code"
IDE_BUILD="code"
echo "The IDE Path is: $IDE_PATH and the IDE_BUILD is: $IDE_BUILD"
export IDE_PATH
export IDE_BUILD
