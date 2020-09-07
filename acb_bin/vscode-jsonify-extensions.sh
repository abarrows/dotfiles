echo "1. VSCode - Retrieving all extensions..."
code-insiders --list-extensions > dotfiles/ide/.vscode/extensions.json

echo "2. VSCode - Parsing all extensions into comma separated list..."
awk '{ printf "\"%s\",\n", $0 }' dotfiles/ide/.vscode/extensions.txt > dotfiles/ide/.vscode/extensions.json

echo "\n\n\n3. VSCode - All done!"
