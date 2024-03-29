# DEBUGGING SCRIPTS

# LOCAL
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export GPG_TTY=$(tty)
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_AUTO_USE=true

# PATHING

# Chat GPT Recommendation after prompting.
# Homebrew path - Prioritize Homebrew binaries.
export PATH="/opt/homebrew/bin:$PATH"

# Your personal bin directory.
export PATH="$HOME/bin:$PATH"

# Legacy system-wide binaries.
export PATH="/usr/local/bin:$PATH"

# The system paths are implicitly included, but can be specified if needed.
# export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Finally, if you have a specific path for Yarn or other tools, append them at the end.
# export PATH="$PATH:$YARN_PATH"

# Path to your oh-my-z/opt/homebrew/binsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_DOTENV_FILE=$HOME/.envrc

source "$HOME/.envrc"
source "$HOME/.theme.zsh"
source "$HOME/.plugins.zsh"
source "$HOME/.functions.zsh"
source "$HOME/.aliases.zsh"
# source "$HOME/.m1-mysql-fixes.zsh"

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

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=$ZSH/custom

source $ZSH/oh-my-zsh.sh

# NON-OH-MY-ZSH EXTENSIONS
# iTerm2 Integration
[[ ! -f "$HOME/.iterm2_shell_integration.zsh" ]] || source "$HOME/.iterm2_shell_integration.zsh"
