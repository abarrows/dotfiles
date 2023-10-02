#!/bin/bash

# This script will use the version controlled list of extensions from the team
# in order to bootstrap your vs code install.

echo -e "1. VSCode - Retrieving all React extensions from team \n dotfiles in version control..."
while read -r my_extension; do
  code --install-extension "$my_extension"
done <engineering/ide/.vscode/extensions_react.txt

echo -e "\n\n\n3. VSCode - React extensions are all done!"
