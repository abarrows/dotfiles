#!/bin/bash

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  echo "Oh my Zsh IS installed and is using this theme: " && echo $ZSH_THEME
else
  echo "Oh my Zsh is not installed!  Installing now..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
