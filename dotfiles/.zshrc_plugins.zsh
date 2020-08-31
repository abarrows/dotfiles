#!/usr/bin/env bash

# PLUGINS

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  bundler
  dotenv
  osx
  rake
  rbenv
  ruby
)

# PLUGIN SETTINGS AND INSTALLATION

# ZSH PLUGIN@HOMEBREW: zsh-completions (Installed with homebrew)

# ZSH PLUGIN@HOMEBREW: zsh-history-substring-search (Installed with homebrew)

# ZSH PLUGIN@HOMEBREW: zsh-syntax-highlighting (Installed with homebrew)

# ZSH PLUGIN@HOMEBREW: zsh-autosuggestions (Installed with homebrew)

# ZSH PLUGIN@HOMEBREW: zsh-syntax-highlighting (Installed with homebrew)
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# history autosubstring plugin
# DIRECTIONS: git clone
# https://github.com/zsh-users/zsh-history-substring-search
# ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
# source zsh-syntax-highlighting.zsh
# source zsh-history-substring-search.zsh

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
