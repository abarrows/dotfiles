#!/usr/bin/env bash

# OH MY ZSH THEME

# POWERLEVEL10K (Installed via homebrew)
echo 'source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc_theme.zsh
ZSH_THEME="powerlevel10k/powerlevel10k.zsh-theme"

# PowerLevel10k prompts
POWERLEVEL10k_LEFT_PROMPT_ELEMENTS=(status os_icon battery dir dir_writable node_version rvm vcs)
POWERLEVEL10k_RIGHT_PROMPT_ELEMENTS=(time background_jobs ram)

#PowerLevel10k config
POWERLEVEL10k_VCS_SHORTEN_LENGTH=22
POWERLEVEL10k_VCS_SHORTEN_MIN_LENGTH=11
POWERLEVEL10k_VCS_SHORTEN_STRATEGY=truncate_from_right
POWERLEVEL10k_SHOW_CHANGESET=true
POWERLEVEL10k_TIME_FORMAT="%D{\uf017 %H:%M \uf073 %y.%m.%d}"
POWERLEVEL10k_PROMPT_ON_NEWLINE=true
POWERLEVEL10k_BATTERY_VERBOSE=false
POWERLEVEL10k_BATTERY_HIDE_ABOVE_THRESHOLD=40

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
