#!/usr/bin/env bash

# cp ~/.oh-my-zsh/templates/zshrc.zsh ~/.zshrc

# PLUGINS

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  zsh-autosuggestions
  bundler
  zsh-completions
  dotenv
  git
  history
  history-substring-search
  osx
  rake
  ruby
  rvm
  zsh-syntax-highlighting
  thefuck
  vscode
  yarn
  vscode
)


# BUILT-IN OH-MY-ZSH PLUGINS
# bundler
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/bundler

# dotenv
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dotenv
# DESCRIPTION: Automatically load your project ENV variables from .env file when you cd into project root directory.

# git
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git

# history
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/history
# COMMANDS: h (prints out your history), hs (use grep to search your command history)

# osx
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/osx

# thefuck
# https://github.com/laggardkernel/zsh-thefuck

# rake
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rake

# rvm
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rvm

# Yarn
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/yarn

# VSCode
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vscode



# CUSTOM INSTALLED PLUGINS

# NVM - Non-Oh-My-Zsh
# Now provides a built-in hook for autoswitching place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# ZSH PLUGIN: zsh-completions
# https://github.com/zsh-users/zsh-completions
if [[ -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions" ]]; then
  echo 'Plugin should be sourced: zsh-completion.'
  autoload -U compinit && compinit
else
  echo 'Cloning plugin: zsh-completion'
  git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
fi

# ZSH PLUGIN: zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions/
if [[ -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions" ]]; then
  echo 'Plugin should be sourced: zsh-autosuggestions.'
else
  echo 'Cloning plugin: zsh-autosuggestions'
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# ZSH PLUGIN: zsh-history-substring-search
# https://github.com/zsh-users/zsh-history-substring-search
if [[ -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-history-substring-search" ]]; then
  echo 'Plugin should be sourced: zsh-history-substring-search.'
else
  echo 'Cloning plugin: zsh-history-substring-search'
  git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
fi

# ZSH PLUGIN: zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting
if [[ -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting" ]]; then
  echo 'Plugin should be sourced: zsh-syntax-highlighting.'
else
  echo 'Cloning plugin: zsh-syntax-highlighting'
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Docker-completions
# https://github.com/chr-fritz/docker-completion.zsh

# Docker-helpers
# https://github.com/unixorn/docker-helpers.zsh

echo "ZSH/PLUGINS: Loaded."
