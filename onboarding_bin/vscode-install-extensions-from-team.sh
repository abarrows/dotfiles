#!/bin/bash

# This script will use the version controlled list of extensions from the team
# in order to bootstrap your vs code install.
# Use IDE_PATH if you are getting your ide dynamically.
# echo "1. VSCode - Retrieving all extensions..."
# code --list-extensions > ../engineering/ide/.vscode/extensions.txt

echo "1. VSCode - Retrieving all base extensions from team dotfiles in version control..."
while read -r my_extension; do
  code --install-extension "$my_extension"
done <engineering/ide/.vscode/extensions.txt

echo "\n\n\n3. VSCode - All done!"
