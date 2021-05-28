echo "1. VSCode - Retrieving all extensions..."
code --list-extensions > .vscode/extensions.json

echo "2. VSCode - Parsing all extensions into comma separated list..."
awk '{ printf "\"%s\",\n", $0 }' .vscode/extensions.txt > .vscode/extensions.json

echo "\n\n\n3. VSCode - All done!"
