#!/bin/bash

echo "1. VSCode - Retrieving all extensions..."
echo '[' >engineering/ide/.vscode/extensions_base.json
code --list-extensions | awk '{if(NR>1) printf(",\n"); printf("  \"%s\"", $0)}' >>engineering/ide/.vscode/extensions_base.json
echo -e '\n]' >>engineering/ide/.vscode/extensions_base.json

echo -e "\n\n\n3. VSCode - All done!"
