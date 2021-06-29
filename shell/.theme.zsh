#!/usr/bin/env bash

# OH MY ZSH THEME
if [[ -r "$ZSH_CUSTOM/themes/spaceship-prompt" ]]; then
  echo 'Theme should be sourced: Starship.'
else
  echo 'Cloning the theme: Starship'
  # sh -c "$(curl -fsSL https://starship.rs/install.sh)"
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1

fi


# Symlink spaceship prompt to your theme.
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme"
"$ZSH_CUSTOM/themes/spaceship.zsh-theme"

ZSH_THEME="starship"

echo "ZSH/THEME: Loaded."
