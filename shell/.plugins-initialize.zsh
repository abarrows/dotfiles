#!/usr/bin/env bash

# ZSH PLUGIN: zsh-nvm
# Variables needed before loading plugin.
export NVM_COMPLETION=true
export NVM_AUTO_USE=true
export NVM_AUTOLOAD=true
export NVM_LAZY_LOAD=true

# Setup nvm autoloader before the call to oh-my-zsh.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

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
