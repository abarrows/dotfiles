#!/usr/bin/env bash

# Default Theme

# export ZSH_THEME="agnoster"

# Starship Theme
# Instructions: https://guinuxbr.com/en/posts/zsh+oh-my-zsh+starship/
if [[ -f "/opt/homebrew/bin/starship" ]]; then
  echo 'Theme should be sourced: Starship.'
  eval "$(starship init zsh)"
else
  # NOTE: Starship is brought in via Homebrew.base, below is a command line install.
  echo 'Starship ZSH theme SHOULD have been installed with base profile onboarding.  Please check Brewfile.base'
  # sh -c "$(curl -fsSL https://starship.rs/install.sh)"
fi

# ----------------------------------------------

echo "ZSH/THEME: Loaded."
