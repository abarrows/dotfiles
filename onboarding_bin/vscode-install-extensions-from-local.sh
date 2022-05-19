#!/bin/bash

# This script will NOT use the version controlled list of extensions from the
# team and assumes you have your own list of extensions installed.  NOTE: This
# is typically only used by the maintainer or in circumstances where an engineer
# wants to record their own VS code extensions.

# Use IDE_PATH if you are getting your ide dynamically.
echo "1. VSCode - Retrieving all extensions..."
code --list-extensions > ../engineering/ide/.vscode/extensions_base.txt

echo "2. VSCode - Parsing all extensions..."
while read -r my_extension; do
  code --install-extension "$my_extension"
done <engineering/ide/.vscode/extensions.txt

echo "\n\n\n3. VSCode - All done!"
