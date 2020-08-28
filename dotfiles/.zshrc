# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#!/usr/bin/env bash

# DEBUGGING SCRIPTS

# GENERAL SETTINGS

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).export UPDATE_ZSH_DAYS=30

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

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
ZSH_CUSTOM="$ZSH/custom/"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  bundler
  dotenv
  git
  history
  history-substring-search
  notify
  nvm-auto
  osx
  rake
  ruby
  rvm
  thefuck
  vscode
  yarn
  zsh-autosuggestions
  zsh-syntax-highlighting )
#echo "IF BREW NULL: PREPENDING FPath: /share/zsh/site-functions (brew)"
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# PERSONAL SETTINGS
alias personal="cd ~/documents/AMU/repos/personal"
alias aw="cd ~/documents/AMU/repos/personal/animatronic-workhorse/animatronic-workhorse && codeinsiders"
alias dotfiles="cd ~/documents/AMU/repos/personal/dotfiles-and-tooling/ && codeinsiders"

# Team Tools and Settings
alias teamtools="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings && codeinsiders"
alias workhorsenode="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings/dev-ops-scripts/environments/workhorse_node && codeinsiders"
alias workhorseruby="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings/dev-ops-scripts/environments/ruby && codeinsiders"
alias skeleton="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings/boilerplates/ruby_on_rails/skeleton && codeinsiders"
alias wps='./bin/webpack-dev-server'
alias comicviewer="cd ~/documents/AMU/repos/amu-digital-technology-prototyping/mobile-friendly-comic-viewer && codeinsiders"
alias repomigrater="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings/dev-ops-scripts/repository_utilities/bitbucket-to-github && codeinsiders"
function updateorigin()
{
  if git remote rename origin bitbucket ; then
    printf "%s\n" "1. ...Renamed origin to bitbucket" && git remote add origin https://github.com/Andrews-McMeel-Universal/"$1".git
  else
    printf "%s\n" "1. ...Origin could not be found.  Simply adding github as the new origin..." &&
    git remote add origin https://github.com/Andrews-McMeel-Universal/"$1".git
  fi
  printf "%s\n" "2. ...Successfully updated your bitbucket remotes to github:" && git remote -v && \
  printf "%s\n" "3. ...Fetching and getting any new work from your new remotes." && git fetch --all && \
  printf "%s\n" "4. ...Now setting staging and production to point upstream to github." \
  && git branch --set-upstream-to=origin/staging staging && \
  git branch --set-upstream-to=origin/production production && git pull \
  && printf "%s\n" "5. ...Lastly, a fresh pull and you are all set!"
}

function replaceorigin()
{
  if git remote rename origin oldorigin ; then
    echo "1. ...Renamed origin to oldorigin" && git remote add origin https://github.com/Andrews-McMeel-Universal/"$1".git
  else
    echo "1. ...Origin could not be found.  Simply adding github as the new origin..." &&
    git remote add origin https://github.com/Andrews-McMeel-Universal/"$1".git
  fi
  if git remote remove oldorigin ; then
    printf "%s\n" "2. ...Removing old origin."
  else
    printf "%s\n" "2. ...Could not find an old origin so no cleanup is needed."
  fi
  printf "%s\n" "3. ...Successfully updated your bitbucket remotes to github:"
  git remote -v
  printf "%s\n" "3. ...Fetching and getting any new work from github."
  git fetch --all
  printf "%s\n" "4. ...Now setting staging and production to point upstream to github."
  git branch --set-upstream-to=origin/staging staging
  git branch --set-upstream-to=origin/production production && git pull
  printf "%s\n" "5. ...Lastly, a fresh pull and you are all set!"
}

function mirrororigin()
{
  printf "%s\n" "1. ...Checking if repo exists in personal github"
  if git remote set-url origin --push --add https://github.com/abarrows/"$1".git ; then
    printf "%s\n" "2. ...The repo exists.  Added it as a remote." \
    && git remote -v \
    && printf "%s\n" "3. Easy as 1,2,3!  All done, here are your remotes!"
  else
    printf "%s\n" "3b. The repo does NOT exists.  Please create first."
  fi
}

function gitsearch()
{
   searchCrit='stash\|'$1
   git stash list | while IFS=: read -r STASH ETC; do echo "$STASH: $ETC"; git diff --stat "$STASH"~.."$STASH" --; done | grep -e "$searchCrit"
}
alias searchstash=gitsearch


# Security
#alias security= "cd ~~"
#alias zed = "open cd /Applications/OWASP ZAP.app"
#alias arachni= "cd ~/Career_Archive/Resources/Arms/Code_Stock/SECURITY/arachni"
#alias startarachni="bin/arachni "
#function startarachni() { bin/arachni "$@" ;}

# Clients
alias clients="cd ~/documents/AMU/repos/clients"
alias specificwellness="cd ~/documents/AMU/repos/clients/specific_wellness/ && codeinsiders"
alias panda="cd ~/documents/AMU/repos/personal/andy-and-paige-wedding/ && codeinsiders"

# AMU General Pathing
alias repos="cd ~/documents/AMU/repos/"
alias amudigitalproducts="cd ~/documents/AMU/repos/amu-digital-products"
alias amudigitalservices="cd ~/documents/AMU/repos/amu-digital-services"
alias repos="cd ~/documents/AMU/repos/"
alias amusnippets="cd ~/documents/AMU/repos/amu-snippets"
alias amudocker="cd ~/documents/AMU/repos/amu-docker/"
alias amuadmins="cd ~/documents/AMU/repos/amu-admins"
alias amugems="cd ~/documents/AMU/repos/amu-gems"
alias prototyping="cd ~/documents/AMU/repos/amu-digital-technology-prototyping"
alias webpackstatic="cd ~/documents/AMU/repos/amu-digital-technology-prototyping/static-html-webpack-boilerplate && codeinsiders"

# AMU Digital Products
alias dilbert="cd ~/documents/AMU/repos/amu-digital-products/dilbert/ && codeinsiders"
alias rsdilbert="rails server --port=3013 && ./bin/webpack-dev-server"
alias doones="cd ~/documents/AMU/repos/amu-digital-products/doonesbury && codeinsiders"
alias rsdoones="rails server --port=3002"
alias gocomics="cd ~/documents/AMU/repos/amu-digital-products/gocomics5/ && codeinsiders"
alias rsgocomics="rails server --port=3001"
alias tps="cd ~/documents/AMU/repos/amu-digital-products/puzzlesociety/ && codeinsiders"
alias rstps="rails server --port=3004"
alias uu="cd ~/documents/AMU/repos/amu-digital-products/universaluclick/ && codeinsiders"
alias rsuu="rails server --port=3006"
alias uexpress="cd ~/documents/AMU/repos/amu-digital-products/uexpress && codeinsiders"
alias rsuexpress="rails server --port=3010"
alias farside="cd ~/documents/AMU/repos/amu-digital-products/thefarside/ && codeinsiders"
alias rsfarside="rails server --port=3020"
alias gcemail="cd ~/documents/AMU/repos/amu-digital-products/gocomics_daily_pro_email && codeinsiders"

# Admins
alias admincontent="cd ~/documents/AMU/repos/amu-admins/content_admin && codeinsiders"
alias rsadmincontent="rails server --port=3022"
alias adminclient="cd ~/documents/AMU/repos/amu-admins/client_admin && codeinsiders"
alias rsclientadmin="rails server --port=3062"
alias adminotterloop="cd ~/documents/AMU/repos/amu-admins/otterloop && codeinsiders"
alias rsadminotterloop="rails server --port=3063"
alias adminconsumer="cd ~/documents/AMU/repos/amu-admins/consumer_admin && codeinsiders"
alias rsconsumeradmin="rails server --port=3042"
alias adminsubscribermail="cd ~/documents/AMU/repos/amu-admins/subscriber_mail_admin && codeinsiders"
alias rssubscribermailadmin="rails server --port=3080"

# Legacy
alias ug="cd ~/documents/AMU/repos/amu-legacy/uclickgames && codeinsiders"
alias sherpa="cd ~/documents/AMU/repos/amu-legacy/site_comicssherpa.com/ && codeinsiders"

# Services
alias filemover="cd ~/documents/AMU/repos/amu-digital-services/filemover && codeinsiders"
alias servicecontent="cd ~/documents/AMU/repos/amu-digital-services/webservice_content && codeinsiders"
alias rsservicecontent="rails s -p '3030'"
alias serviceasset="cd ~/documents/AMU/repos/amu-digital-services/asset_engine && codeinsiders"
alias rsserviceasset="rails server --port=3031"
alias serviceregistration="cd ~/documents/AMU/repos/amu-digital-services/webservice_registration && codeinsiders"
alias rsserviceregistration="rails server --port=3040"
alias servicefeatureavatar="cd ~/documents/AMU/repos/amu-digital-services/webservice_feature_avatars && codeinsiders"
alias rsservicefeatureavatar="rails server --port=3041"
alias serviceuseravatar="cd ~/documents/AMU/repos/amu-digital-services/webservice_avatars && codeinsiders"
alias rsserviceuseravatar="rails server --port=3042"
alias serviceembed="cd ~/documents/AMU/repos/amu-digital-services/embed_service/ && codeinsiders"
alias rsserviceclient="rails s -p '3050'"
alias serviceclient="cd ~/documents/AMU/repos/amu-digital-services/go-webservice-client && codeinsiders"
alias rsserviceembed="rails server --port=3060"
alias servicegocontent="cd ~/documents/AMU/repos/amu-digital-services/embedded_entertainment/ && codeinsiders"
alias rsservicegoc="rails server --port=3070"
alias servicegames="cd ~/documents/AMU/repos/amu-digital-services/amu_games/ && codeinsiders"
alias rsservicegames="rails server --port=3061"
alias servicegamedata="cd ~/documents/AMU/repos/amu-digital-services/webservice_gamedata/ && codeinsiders"
alias rsservicegamedata="rails server --port=3064"

# Wordpress
# alias kcgac="cd /Users/andrewbarrows/Career/Clients/KCGAC/3_develop && codeinsiders"
alias dilbertblog="cd ~/documents/AMU/repos/amu-digital-products/wpengine-dilbertblog"
alias dailycartoonist="cd ~/documents/AMU/repos/amu-digital-products/devkit/dailycartoonist && codeinsiders"
alias dailycartoonist="cd ~/documents/AMU/repos/amu-digital-products/devkit/dailycartoonist && codeinsiders && wpe start"
alias wonderword="cd ~/documents/AMU/repos/amu-digital-products/wonderword && codeinsiders"
alias rswonderword="cd ~/documents/AMU/repos/amu-digital-products/wonderword && codeinsiders && wpe start"
alias multiamu="cd ~/documents/AMU/repos/amu-digital-products/multiamu"
alias ssmultiamu="cd ~/documents/AMU/repos/amu-digital-products/multiamu && codeinsiders && open /Applications/MAMP"

# Server SSH
alias syndicate01="ssh abarrows@hfsyndicate201.amuniversal.com"
alias syndicate02="ssh abarrows@hfsyndicate202.amuniversal.com"
alias syndicateadmin="ssh abarrows@hfsyndicateadmin202.amuniversal.com"
alias admintools="ssh abarrows@hfadmintools201.amuniversal.com"
alias syndicatetemplates="cd /home/mover/template/"
alias images01="ssh abarrows@hfimages01.amuniversal.com"
alias images02="ssh abarrows@hfimages02.amuniversal.com"
alias imagestemplate="cd /usr/local/perlib/ucomics/templates/"
alias puzzle401="ssh abarrows@hfspuzzleapp401.amuniversal.com"
alias puzzle402="ssh abarrows@hfspuzzleapp402.amuniversal.com"
alias stageservices="ssh abarrows@hfstagerailsservices201.amuniversal.com"
alias stage201="ssh abarrows@hfstagerailsapp201.amuniversal.com"
alias stage301="ssh abarrows@hfsrailsapp301.amuniversal.com"
alias stage302="ssh abarrows@hfsrailsapp302.amuniversal.com"
alias stage303="ssh abarrows@hfsrailsapp303.amuniversal.com"
alias stage304="ssh abarrows@hfsrailsapp304.amuniversal.com"
alias dev301="ssh abarrows@hfdrailsapp301.amuniversal.com"
alias dev302="ssh abarrows@hfdrailsapp302.amuniversal.com"

# PHP Permissions
alias checkphp="php -i"

# Git stuff
alias gs="git status"
alias glog="git log --pretty=format:'%h was %an, %ar, message: %s'"
alias gadd="git add ."
alias gaddu="git add -u"
alias gremove="git rm -f "
alias gpush="git push origin master"
alias gpull="git pull origin master"
alias removegit="rm -rf .git"

# Heroku Stuff
alias hr="heroku restart"
alias hp="git push heroku master"
alias hschema="heroku db:push"

# Ruby Stuff
alias findruby="lsof -wni tcp:3000"
alias killruby="cd tmp/pids/ && rm -rf server.pid && killall ruby"
alias killforeman="killall \"foreman: master\""
alias dbcreate="bin/rake db:create db:migrate"
alias bmigrate="bundle exec rake db:migrate"
alias btest="bundle exec rspec spec"
alias abc="rake db:migrate db:test:clone"
alias rc="rails console"
alias findassets="y Rails.application.config.assets.paths"
alias sphinxindex="rake ts:index"
alias sphinxrebuild="rake ts:rebuild"
alias sphinx="rake ts:index && rake ts:rebuild"

# Rails Stuff
alias cleanassets="rake assets:clean assets:precompile"
alias seedfeatures="rake feature_data:reload"
alias seedfeaturesrecent="rake feature_data:reload_recent"
alias vsdebug="rdebug-ide ./bin/rails server puma"

# Pathing
alias desktop="cd ~/Desktop"
alias apps="cd /Applications"
alias codeinsiders="open . -a 'Visual Studio Code - Insiders'"
alias downloads="cd ~/Downloads"
alias team="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings"
alias prototype="cd ~/documents/AMU/repos/amu-digital-technology-prototyping/"
#   alias drive="cd ~/"

#Bash Stuff
alias addalias="cd ~/ && codeinsiders .zshrc"
alias savealias="source ~/.zshrc"
alias amiroot="who -u"
alias checkprocesses="ps au"
alias killbg='kill ${${(v)jobstates##*:*:}%=*}'
alias checksshkey='cat ~/.ssh/id_rsa.pub'
alias checkip='curl ipecho.net/plain ; echo'
function edit() {
    "open -a Visual\ Studio\ Code\ -\ Insiders.app $1"
}
function foremanstop()
{
    "kill $(redis|sidekiq|unicorn|puma|webrick|webpack|foreman) | grep -v grep | awk '{print $2}')"
}
function checkport()
{
    "lsof -i $1"
}
function killjob()
{
    kill -9 "$1"
}

function killport()
{
    lsof -ti tcp:"$1" | xargs kill
}

# Host File Modification
alias edithosts="sudo open -a Visual\ Studio\ Code.app /etc/hosts"

# Apache Stuff
alias editapache="cd ~/etc && cd apache2 && edit httpd.conf"
alias openapache="cd ~/etc && cd apache2 && open ."
alias editapacheuser="cd ~/private/etc/apache2/users/ && edit andrewbarrows.conf"
alias openapacheuser="cd ~/private/etc/apache2/users/ && open ."
alias restartapache="sudo apachectl restart"
alias startapache="sudo apachectl start"
alias stopapache="sudo apachectl stop"
alias checkapache="sudo apachectl -S"

# PHP Stuff
alias checkphp="php -i"

# Virtual Box Environment Stuff
alias vup="vagrant up"
alias vstop="vagrant halt"
alias dockernuke="docker system prune --volumes"

# Misc
alias ls="ls -al"
alias clr="clear"
alias shidden="defaults write com.apple.Finder AppleShowAllFiles YES"
alias checkmysql="mysqladmin version"
alias startmysql="mysql.server start"
alias brewlist="brew list --versions"
alias wpd="./bin/webpack-dev-server"
alias zplugins="cd ~/.oh-my-zsh/custom/plugins"
alias checkpath="print -l PATH"
#alias alwaysstartmysql="brew services start mysql"
#alias generatekey="ls ~/.ssh/*.pub"

# Testing
#alias rspecintegration="rails g integration_test $1"
#alias rspeccontroller="rails g controller_test $1"

# DB
#alias startpg="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start"
#alias ="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"

# Personal Applications
alias bcsw="cd ~/specific-wellness-dev/"
# alias rrails server --port=3110"
alias bcdd="cd ~/driverdocs"
# alias rrails server --port=3102"
alias bcaap="cd ~/andyandpaige/"
# alias rrails server --port=3101"

# PLUGIN SETTINGS
# history autosubstring plugin
# DIRECTIONS: git clone
# https://github.com/zsh-users/zsh-history-substring-search
# ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
# source zsh-syntax-highlighting.zsh
# source zsh-history-substring-search.zsh
# NVM Plugin
# source $ZSH/custom/plugins/zsh-nvm/zsh-nvm.plugin.zsh
# nvm.sh previously had permission issues.  Use: chmod u+x nvm.sh
# shellcheck disable=SC1091
# [[ -s $HOME/.nvm/nvm.sh ]] && . "$HOME/.nvm/nvm.sh"  # This loads NVM

# place this after nvm initialization!
# autoload -U add-zsh-hook
# add-zsh-hook chpwd

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

# Notify Plugin Config
zstyle ':notify:*' error-title "Command failed (in #{time_elapsed} seconds)"
zstyle ':notify:*' success-title "Command finished (in #{time_elapsed} seconds)"

# PATHING
# NOTE: Need to setup pathing prior sourcing zsh.  nvm and rvm need to be checked at the very end of pathing and then sourced.
# echo "Base Path: $PATH"
PATH=$PATH
PATH=/usr/local/sbin:/usr/local/opt/mysql@5.6/bin:/usr/local/opt/mysql@5.7/bin:/usr/local/mysql/bin:/usr/local/opt/imagemagick@6/bin:$PATH
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$PATH:$HOME/bin"
fi

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

# shellcheck disable=SC1091
source "$ZSH/oh-my-zsh.sh"

# NVM
# nvm.sh previously had permission issues.  Use: chmod u+x /usr/local/opt/nvm/nvm.sh
export NVM_DIR="$HOME/.nvm"
# Speeds up load times for nvm but I do not know if it works with brew.
# [ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"
# export PATH="$NVM_DIR/versions/node/v$(<$NVM_DIR/alias/default)/bin:$PATH"
# alias nvm="unalias nvm; [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"; nvm $@"
source $(brew --prefix nvm)/nvm.sh

nvm_auto_switch

[[ ! -f "$HOME/.iterm2_shell_integration.zsh" ]] || source "$HOME/.iterm2_shell_integration.zsh"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$HOME/.rvm/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
# shellcheck disable=SC1091
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
# shellcheck disable=SC1091
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi
eval "$(pyenv init -)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"


