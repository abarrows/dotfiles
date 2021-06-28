#!/bin/bash

# Use IDE_PATH if you are getting your ide dynamically.
echo "1. VSCode - Retrieving all extensions..."
code --list-extensions > ../.vscode/extensions.txt

echo "2. VSCode - Parsing all extensions..."
while read -r my_extension; do
  code --install-extension $my_extension
done <.vscode/extensions.txt

echo "\n\n\n3. VSCode - All done!"
