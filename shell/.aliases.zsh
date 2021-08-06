#!/usr/bin/env bash

# Onboarding Initialize Scripts
alias alwaysstartmysql="brew services start mysql"
alias generatekey="ls ~/.ssh/*.pub"
alias shidden="defaults write com.apple.Finder AppleShowAllFiles YES"
alias alwaysstartpsql="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
alias dotfilesinstall="dotfiles && dotfiles/install"

# General Pathing
alias desktop="cd ~/Desktop"
alias apps="cd /Applications"
alias code="$IDE_PATH ."
alias code-insiders="open . -a 'Visual Studio Code - Insiders'"
alias downloads="cd ~/Downloads"
alias repos="cd ~/documents/$CURRENT_COMPANY/repos/"

# General Shell Operation
alias ls="ls -al"
alias brewlist="brew list --versions"
alias zplugins="cd ~/.oh-my-zsh/custom/plugins"
alias checkpath="print -l PATH"
alias addalias="cd ~/ && $IDE_PATH . .zshrc"
alias savealias="source ~/.zshrc"
alias amiroot="who -u"
alias checkprocesses="ps au"
alias killbg='kill ${${(v)jobstates##*:*:}%=*}'
alias checksshkey='cat ~/.ssh/id_rsa.pub'
alias checkip='curl ipecho.net/plain ; echo'
alias edithosts="sudo open -a Visual\ Studio\ Code.app /etc/hosts"

# Version Control
alias gs="git status"
alias glog="git log --pretty=format:'%h was %an, %ar, message: %s'"
alias gadd="git add ."
alias gaddu="git add -u"
alias gremove="git rm -f "
alias gpush="git push origin --all"
alias updatesubmodule="git pull --recurse-submodules && git submodule update --remote --recursive"
alias gpull="\$updatesubmodule && git pull --all"
alias removegit="rm -rf .git"
alias syncbranches="git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -d"

# Apache
alias editapache="cd ~/etc && cd apache2 && edit httpd.conf"
alias openapache="cd ~/etc && cd apache2 && open ."
alias editapacheuser="cd ~/private/etc/apache2/users/ && edit $CURRENT_USER.conf"
alias openapacheuser="cd ~/private/etc/apache2/users/ && open ."
alias restartapache="sudo apachectl restart"
alias startapache="sudo apachectl start"
alias stopapache="sudo apachectl stop"
alias checkapache="sudo apachectl -S"

# Heroku
alias hr="heroku restart"
alias hp="git push heroku master"
alias hschema="heroku db:push"

# Vitual Machine
alias dockernuke="docker system prune --volumes"

# Database
alias checkmysql="mysqladmin version"
alias startmysql="mysql.server start"
alias stopmysql="mysql.server stop"
alias startpg="postgres -D /usr/local/var/postgres"

# PHP
alias checkphp="php -i"

# Ruby
# Use gem shutup for killing persistent rails servers
# alias findruby="lsof -wni tcp:3000"
# alias killruby="cd tmp/pids/ && rm -rf server.pid && killall ruby"
# alias killforeman="killall \"foreman: master\""
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

# Rails
alias rclear="rake assets:clean && rake tmp:clear"
alias rload="rake feature_data:reload"
alias rloadrecent="rake feature_data:reload_recent"
alias vsdebug="rdebug-ide ./bin/rails server puma"
alias rspecintegration="rails g integration_test $1"
alias rspeccontroller="rails g controller_test $1"

# Python
alias python="/usr/local/bin/python3"
alias pip="/usr/local/bin/pip3"

# Node and Javascript
alias wpd="./bin/webpack-dev-server"

# Personal
alias personal="cd ~/documents/$CURRENT_COMPANY/repos/personal"
alias dotfiles="cd ~/documents/$CURRENT_COMPANY/repos/personal/dotfiles/ && $IDE_PATH ."

# Clients
alias clients="cd ~/documents/$CURRENT_COMPANY/repos/clients"

# Company Team Tools and Settings
alias team="cd ~/documents/$CURRENT_COMPANY/repos/amu-development-team && $IDE_PATH ."
alias teamtools="cd ~/documents/$CURRENT_COMPANY/repos/amu-development-team/team-tools-and-settings && $IDE_PATH ."
alias teamonboarding="cd ~/documents/$CURRENT_COMPANY/repos/amu-development-team/amu-onboarding/ && $IDE_PATH ."
alias teamstandards="cd ~/documents/$CURRENT_COMPANY/repos/amu-development-team/amu-code_standards/ && $IDE_PATH ."

# Company Prototyping and Research

# Company Digital Products
alias dilbert="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/dilbert/ && $IDE_PATH ."
alias rsdilbert="RAILS_ENV=development rails s -p 3013 && ./bin/webpack-dev-server"
alias doonesbury="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/doonesbury && $IDE_PATH ."
alias rsdoonesbury="RAILS_ENV=development rails s -p 3002"
alias gocomics="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/gocomics5/ && $IDE_PATH ."
alias rsgocomics="RAILS_ENV=development rails s -p 3001"
alias oldpuzzlesociety="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/puzzlesociety/ && $IDE_PATH ."
alias rsoldpuzzlesociety="RAILS_ENV=development rails s -p 3004"
alias uipuzzlesociety="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/puzzle-society_ui/ && $IDE_PATH ."
alias rsuipuzzlesociety="yarn install && yarn dev"
alias uiuexpress="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/uexpress_ui && $IDE_PATH ."
alias rsuiuexpress="yarn install && yarn dev"
alias syndication="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/universaluclick/ && $IDE_PATH ."
alias rssyndication="RAILS_ENV=development rails s -p 3006"
alias thefarside="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/thefarside/ && $IDE_PATH ."
alias rsthefarside="RAILS_ENV=development rails s -p 3020"
alias gcemail="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/gocomics_daily_pro_email && $IDE_PATH ."
alias gamecrossword="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/crossword_game/ && $IDE_PATH . && docker run --rm -it -p 3000:3000 crossword-games"
alias startgamecrossword="docker build -t crossword-game ."

# Company Admins
alias admincontent="cd ~/documents/$CURRENT_COMPANY/repos/amu-admins/content_admin && $IDE_PATH ."
alias rsadmincontent="RAILS_ENV=development rails s -p 3022"
alias adminclient="cd ~/documents/$CURRENT_COMPANY/repos/amu-admins/client_admin && $IDE_PATH ."
alias rsadminclient="RAILS_ENV=development rails s -p 3062"
alias adminotterloop="cd ~/documents/$CURRENT_COMPANY/repos/amu-admins/otterloop && $IDE_PATH ."
alias rsadminotterloop="RAILS_ENV=development rails s -p 3063"
alias adminconsumer="cd ~/documents/$CURRENT_COMPANY/repos/amu-admins/consumer_admin && $IDE_PATH ."
alias rsadminconsumer="RAILS_ENV=development rails s -p 3042"
alias adminsubscribermail="cd ~/documents/$CURRENT_COMPANY/repos/amu-admins/subscriber_mail_admin && $IDE_PATH ."
alias rsadminsubscribermail="RAILS_ENV=development rails s -p 3080"

# Company Web Services
alias filemover="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-services/file-mover && $IDE_PATH ."
alias servicecontent="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-services/webservice_content && $IDE_PATH ."
alias rsservicecontent="rails s -p '3030'"
alias serviceasset="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-services/asset_engine && $IDE_PATH ."
alias rsserviceasset="RAILS_ENV=development rails s -p 3031"
# alias serviceregistration="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-services/webservice_registration && $IDE_PATH ."
# alias rsserviceregistration="RAILS_ENV=development rails s -p 3040"
alias servicefeatureavatar="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-services/webservice_feature_avatars && $IDE_PATH ."
alias rsservicefeatureavatar="RAILS_ENV=development rails s -p 3041"
alias serviceuseravatar="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-services/webservice_avatars && $IDE_PATH ."
alias rsserviceuseravatar="RAILS_ENV=development rails s -p 3042"
alias serviceembed="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-services/embed_service/ && $IDE_PATH ."
alias rsserviceembed="RAILS_ENV=development rails s -p 3060"
alias serviceclient="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-services/go-webservice-client && $IDE_PATH ."
alias rsserviceclient="rails s -p '3050'"
alias servicegocontent="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-services/embedded_entertainment/ && $IDE_PATH ."
alias rsservicegocontent="RAILS_ENV=development rails s -p 3070"
alias servicegames="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-services/amu_games/ && $IDE_PATH ."
alias servicegamedata="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-services/webservice_gamedata/ && $IDE_PATH ."
alias rsservicegamedata="RAILS_ENV=development rails s -p 3064"

# Wordpress
# TODO: Update these with the new paths.
# alias rsdailycartoonist="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/devkit/dailycartoonist && $IDE_PATH . && wpe start"
# alias wonderword="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/wonderword && $IDE_PATH ."
# alias rswonderword="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/wonderword && $IDE_PATH . && wpe start"
# alias multiamu="cd ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/multiamu"
# alias ssmultiamu="cd
# ~/documents/$CURRENT_COMPANY/repos/amu-digital-products/multiamu && $IDE_PATH
# . && open /Applications/MAMP"

# Server SSH
alias sshsyndicateproduction="ssh $CURRENT_USER@$PRODUCT_SYNDICATION_PRODUCTION"
alias sshsyndicateproduction2="ssh $CURRENT_USER@$PRODUCT_SYNDICATION_PRODUCTION_2"
alias syndicateadminproduction="ssh $CURRENT_USER@$ADMIN_SYNDICATION_PRODUCTION"
alias syndicatetemplates="cd /home/mover/template/"
alias sshorangetoolproduction="ssh $CURRENT_USER@$SERVICE_GOCONTENT_PRODUCTION"
alias sshorangetoolproduction2="ssh $CURRENT_USER@$ADMIN_SYNDICATION_PRODUCTION"
alias orangetooltemplates="cd /usr/local/perlib/ucomics/templates/"
alias sshpuzzlesocietystaging="ssh $CURRENT_USER@$PRODUCT_PUZZLESOCIETY_STAGING"
alias sshpuzzlesocietystaging2="ssh $CURRENT_USER@$PRODUCT_PUZZLESOCIETY_STAGING_2"
alias sshgocontentstaging="ssh $CURRENT_USER@$SERVICE_GOCONTENT_STAGING"
alias sshadminproduction="ssh $CURRENT_USER@$ADMIN_TOOLS_PRODUCTION"
alias sshlicensingstage1="ssh $CURRENT_USER@$PRODUCT_LICENSING_STAGING"
alias sshlicensingstage2="ssh $CURRENT_USER@$PRODUCT_LICENSING_STAGING_2"
alias sshfarsides="ssh $CURRENT_USER@$PRODUCT_FARSIDE_STAGING"

echo "ZSH/ALIASES: Loaded."
