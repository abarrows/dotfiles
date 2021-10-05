#!/bin/bash

extension_count=$(wc -l < /Users/"$CURRENT_USER"/documents/"$CURRENT_COMPANY"/repos/personal/dotfiles/engineering/ide/.vscode/extensions.txt)
echo "The extension count is $extension_count"
if (( $extension_count > 20 ));
then
    echo "There are more than 20 vs code extensions"
else
    echo "There are less than 20 vs code extensions"
fi
