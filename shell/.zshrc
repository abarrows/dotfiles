#!/usr/bin/env bash

# DEBUGGING SCRIPTS

# LOCAL
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# PATHING
# If you come from bash you might have to change your $PATH.
PATH=:bin/~/bin:/usr/local/opt/libxslt/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/sbin:$PATH

# Path to your oh-my-zsh installation.
ZSH=$HOME/.oh-my-zsh
source "$HOME/.theme.zsh"
source "$HOME/.functions.zsh"
source "$HOME/.plugins.zsh"
source "$HOME/.aliases.zsh"

# CACHING
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# OLD PATHING
# RVM
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$HOME/.rvm/bin:$PATH"

# MYSQL
#echo 'APPENDING Path: /usr/local/mysql/bin'

# ImageMagick
#echo 'APPENDING Path: /usr/local/opt/imagemagick@6/bin'

# Homebrew
#echo "EXPORT: PREPENDING Path: /usr/local/sbin (homebrew)"

# Yarn
#echo "EXPORT: PREPENDING Path: /usr/local/sbin (yarn)"
#export PATH="$(yarn global bin):$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
#echo "EXPORT: APPENDING Path: /usr/local/sbin (rvm)"

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

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=$ZSH/custom

source $ZSH/oh-my-zsh.sh

# NON-OH-MY-ZSH EXTENSIONS
# iTerm2 Integration
[[ ! -f "$HOME/.iterm2_shell_integration.zsh" ]] || source "$HOME/.iterm2_shell_integration.zsh"

# GOOGLE CLOUD SDK
# shellcheck disable=SC1091
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
# shellcheck disable=SC1091
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# Python (Not in use.)
# eval "$(pyenv init -)"
