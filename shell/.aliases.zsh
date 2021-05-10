#!/usr/bin/env bash

# DYNAMIC VALUES
alias currentide="code"
alias companyFolder="yourCompany"

# PERSONAL SETTINGS
alias personal="cd ~/documents/AMU/repos/personal"

# Team Tools and Settings
alias teamtools="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings && currentide"
alias wps='./bin/webpack-dev-server'
alias searchstash=gitsearch

# Clients

# Personal Pathing
alias repos="cd ~/documents/${companyFolder}/repos/"
alias desktop="cd ~/Desktop"
alias apps="cd /Applications"
alias code="code ."
alias code-insiders="open . -a 'Visual Studio Code - Insiders'"
alias downloads="cd ~/Downloads"
alias team="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings"
alias prototype="cd ~/documents/AMU/repos/amu-digital-technology-prototyping/"

# Web Applications

# Web Admins

# Legacy Applications

# Services and APIs

# Wordpress Products

# Server SSH

# PHP Permissions
alias checkphp="php -i"

# Git stuff
alias gs="git status"
alias glog="git log --pretty=format:'%h was %an, %ar, message: %s'"
alias gadd="git add ."
alias gaddu="git add -u"
alias gremove="git rm -f "
alias gpush="git push origin --all"
alias updatesubmodule="git pull --recurse-submodules && git submodule update --remote --recursive"
alias gpull="\$updatesubmodule && git pull --all"
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
alias gemglobal="rvm @global do gem install $1"

# Rails Stuff
alias cleanassets="rake assets:clean assets:precompile"
alias seedfeatures="rake feature_data:reload"
alias seedfeaturesrecent="rake feature_data:reload_recent"
alias vsdebug="rdebug-ide ./bin/rails server puma"

# Python stuff
alias python="/usr/local/bin/python3"
alias pip="/usr/local/bin/pip3"

#Bash Stuff
alias addalias="cd ~/ && currentide .zshrc"
alias savealias="source ~/.zshrc"
alias amiroot="who -u"
alias checkprocesses="ps au"
alias killbg='kill ${${(v)jobstates##*:*:}%=*}'
alias checksshkey='cat ~/.ssh/id_rsa.pub'
alias checkip='curl ipecho.net/plain ; echo'

# Host File Modification
alias edithosts="sudo open -a ${currentide} /etc/hosts"

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

# Database
alias startpg="postgres -D /usr/local/var/postgres"
#alias ="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"

# Personal Applications
alias dotfilesinstall="dotfiles && dotfiles/install"

echo "ZSH/ALIASES: Loaded."
