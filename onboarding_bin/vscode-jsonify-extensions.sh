#!/bin/bash

echo "1. VSCode - Retrieving all extensions..."
code --list-extensions >engineering/ide/.vscode/extensions_base.json

echo "2. VSCode - Parsing all extensions into comma separated list..."
awk '{ printf "\"%s\",\n", $0 }' engineering/ide/.vscode/extensions_base.txt >engineering/ide/.vscode/extensions_base.json

echo "\n\n\n3. VSCode - All done!"
