#!/usr/bin/env bash

# cp ~/.oh-my-zsh/templates/zshrc.zsh ~/.zshrc

# PLUGINS

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)

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

# rake
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rake

# rbenv
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/rbenv

# Yarn
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/yarn

# VSCode
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vscode

# CUSTOM INSTALLED PLUGINS

# ZSH PLUGIN: zsh-completions
# https://github.com/zsh-users/zsh-completions
if [[ -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions" ]]; then
  autoload -U compinit && compinit
else
  echo 'Cloning plugin: zsh-completion'
  git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions
fi

# ZSH PLUGIN: zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions/
if [[ ! -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions" ]]; then
  echo 'Cloning plugin: zsh-autosuggestions'
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions
fi

# ZSH PLUGIN: zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting
if [[ ! -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting" ]]; then
  echo 'Cloning plugin: zsh-syntax-highlighting'
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting
fi

# ZSH PLUGIN: zsh-history-substring-search
# https://github.com/zsh-users/zsh-history-substring-search
if [[ ! -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-history-substring-search" ]]; then
  echo 'Cloning plugin: zsh-history-substring-search'
  git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-history-substring-search
fi

# ZSH PLUGIN: zsh-nvm
# Variables needed before loading plugin.
export NVM_COMPLETION=true
export NVM_AUTO_USE=true
export NVM_AUTOLOAD=true
export NVM_LAZY_LOAD=true

# https://github.com/lukechilds/zsh-nvm
if [[ ! -r "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-nvm" ]]; then
  echo 'Cloning plugin: zsh-nvm'
  git clone "https://github.com/lukechilds/zsh-nvm" "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-nvm"
fi
# Setup nvm autoloader before the call to oh-my-zsh.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Function to install the required Node.js version if not already installed
load_nvmrc() {
  if [ -f .nvmrc ]; then
    local nvm_version
    nvm_version=$(<.nvmrc)
    if ! nvm ls "$nvm_version" >/dev/null 2>&1; then
      nvm install "$nvm_version"
    fi
    nvm use "$nvm_version"
  fi
}

# Call the function to load the required Node.js version
load_nvmrc

# Docker-completions
# https://github.com/chr-fritz/docker-completion.zsh

# Docker-helpers
# https://github.com/unixorn/docker-helpers.zsh

# Final plugins declaration
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  bundler
  dotenv
  extract
  git
  history
  history-substring-search
  zsh-nvm
  macos
  rake
  ruby
  rbenv
  vscode
  yarn
  vscode
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
)

echo "ZSH/PLUGINS: Loaded."
