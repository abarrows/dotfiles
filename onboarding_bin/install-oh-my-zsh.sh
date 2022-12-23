#!/bin/bash

# TODO: Force this in case.

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  echo "Oh my Zsh IS already installed.  Current Theme: $ZSH_THEME"
else
  echo "Oh my Zsh is NOT installed!  Installing now..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
