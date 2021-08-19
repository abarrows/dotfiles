#!/bin/bash

ZSH_THEME="powerlevel10k/powerlevel10k"

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  echo "Oh my Zsh theme: Powerlevel10k is NOT installed!  Installing now..."
  echo "source $(brew --prefix)/opt/powerlevel10k/powerlevel10k.zsh-theme"
elif [ -x "$(command p10k)" ]; then
  echo "Oh my Zsh theme: Powerlevel10k IS already installed.  Current Theme: $ZSH_THEME (If this is not p10k, change it in /shell/.theme.zsh)"
  [[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh
else
  echo "Oh my Zsh theme: Powerlevel10k is installed but NOT configured.  Configuring now..."
  echo "source $(brew --prefix)/opt/powerlevel10k/powerlevel10k.zsh-theme"
  p10k configure
fi
