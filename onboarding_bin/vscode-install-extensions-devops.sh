#!/bin/bash

# This script will use the version controlled list of extensions from the team
# in order to bootstrap your vs code install.

echo "1. VSCode - Retrieving all devops extensions from team dotfiles in version control..."
while read -r my_extension; do
  code --install-extension "$my_extension"
done <engineering/ide/.vscode/extensions_devops.txt

echo "\n\n\n3. VSCode - DevOps extensions are all done!"
