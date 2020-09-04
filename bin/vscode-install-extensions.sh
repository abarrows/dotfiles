echo "1. VSCode - Retrieving all extensions..."
code-insiders --list-extensions > dotfiles/ide/.vscode/extensions.txt

echo "2. VSCode - Parsing all extensions..."
while read -r my_extension; do
  code-insiders --install-extension $my_extension
done <dotfiles/ide/.vscode/extensions.txt

echo "\n\n\n3. VSCode - All done!"
