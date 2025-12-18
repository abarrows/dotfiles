#!/usr/bin/env bash

# DEBUGGING SCRIPTS

# LOCAL
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export GPG_TTY=$(tty)

# Next line is needed due to a bug with Warp.
# SPACESHIP_PROMPT_ASYNC="FALSE"

# PATHING

# Chat GPT Recommendation after prompting.
# Homebrew path - Prioritize Homebrew binaries.
# Determine the architecture and set the Homebrew path accordingly
if [[ "$(uname -m)" == "arm64" ]]; then
  # M1 Mac
  export PATH="/opt/homebrew/bin:$PATH"
else
  # Intel Mac
  export PATH="/usr/local/bin:$PATH"
fi

# The system paths are implicitly included, but can be specified if needed.
# export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Finally, if you have a specific path for Yarn or other tools, append them at the end.
# export PATH="$PATH:$YARN_PATH"

# Setup for ruby and rbenv with guard clause.
if command -v rbenv >/dev/null 2>&1; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# Path to your oh-my-z/opt/homebrew/binsh installation.
ZSH_DOTENV_FILE=$HOME/.envrc
export ZSH="$HOME/.oh-my-zsh"

source "$HOME/.envrc"
source "$HOME/.theme.zsh"
source "$HOME/.plugins.zsh"
source "$HOME/.functions.zsh"
source "$HOME/.aliases.zsh"
source "$HOME/.starship.zsh"

# OLD PATHING

# MYSQL
#echo 'APPENDING Path: /usr/local/mysql/bin'

# ImageMagick
#echo 'APPENDING Path: /usr/local/opt/imagemagick@6/bin'

# Homebrew
#echo "EXPORT: PREPENDING Path: /usr/local/sbin (homebrew)"

# Yarn
#echo "EXPORT: PREPENDING Path: /usr/local/sbin (yarn)"
#export PATH="$(yarn global bin):$PATH"

# GENERAL SETTINGS
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Load nvm automatically (optional)
# source "$HOME/plugins-initialize.sh"

# Golang environment variables
export GOROOT=$(brew --prefix go)/libexec
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH

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
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
)

echo "ZSH/PLUGINS: Loaded."

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# source "$HOME/.m1-mysql-fixes.zsh"

# Load Angular CLI autocompletion.
# source <(ng completion script)

PATH=~/.console-ninja/.bin:$PATH

# Increase file descriptor limit for development tools
ulimit -n 10240

# Added by Windsurf
export PATH="/Users/andyb/.codeium/windsurf/bin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/andyb/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
