#!/usr/bin/env bash

# DYNAMIC VALUES
alias currentide="code"

# PERSONAL SETTINGS
alias personal="cd ~/documents/AMU/repos/personal"
alias aw="cd ~/documents/AMU/repos/personal/animatronic-workhorse/animatronic-workhorse && currentide"
alias dotfiles="cd ~/documents/AMU/repos/personal/dotfiles-and-tooling/ && currentide"

# Team Tools and Settings
alias teamtools="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings && currentide"
alias workhorsenode="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings/dev-ops-scripts/environments/workhorse_node && currentide"
alias workhorseruby="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings/dev-ops-scripts/environments/ruby && currentide"
alias skeleton="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings/boilerplates/ruby_on_rails/skeleton && currentide"
alias wps='./bin/webpack-dev-server'
alias comicviewer="cd ~/documents/AMU/repos/amu-digital-technology-prototyping/mobile-friendly-comic-viewer && currentide"
alias repomigrater="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings/dev-ops-scripts/repository_utilities/bitbucket-to-github && currentide"
alias searchstash=gitsearch

# Security
#alias security= "cd ~~"
#alias zed = "open cd /Applications/OWASP ZAP.app"
#alias arachni= "cd ~/Career_Archive/Resources/Arms/Code_Stock/SECURITY/arachni"
#alias startarachni="bin/arachni "
#function startarachni() { bin/arachni "$@" ;}

# Clients
alias clients="cd ~/documents/AMU/repos/clients"
alias specificwellness="cd ~/documents/AMU/repos/clients/specific_wellness/ && currentide"
alias panda="cd ~/documents/AMU/repos/personal/andy-and-paige-wedding/ && currentide"

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
alias webpackstatic="cd ~/documents/AMU/repos/amu-digital-technology-prototyping/static-html-webpack-boilerplate && currentide"

# AMU Digital Products
alias dilbert="cd ~/documents/AMU/repos/amu-digital-products/dilbert/ && currentide"
alias rsdilbert="rails server --port=3013 && ./bin/webpack-dev-server"
alias doones="cd ~/documents/AMU/repos/amu-digital-products/doonesbury && currentide"
alias rsdoones="rails server --port=3002"
alias gocomics="cd ~/documents/AMU/repos/amu-digital-products/gocomics5/ && currentide"
alias rsgocomics="rails server --port=3001"
alias tps="cd ~/documents/AMU/repos/amu-digital-products/puzzlesociety/ && currentide"
alias rstps="rails server --port=3004"
alias uu="cd ~/documents/AMU/repos/amu-digital-products/universaluclick/ && currentide"
alias rsuu="rails server --port=3006"
alias uexpress="cd ~/documents/AMU/repos/amu-digital-products/uexpress && currentide"
alias rsuexpress="rails server --port=3010"
alias farside="cd ~/documents/AMU/repos/amu-digital-products/thefarside/ && currentide"
alias rsfarside="rails server --port=3020"
alias gcemail="cd ~/documents/AMU/repos/amu-digital-products/gocomics_daily_pro_email && currentide"

# Admins
alias admincontent="cd ~/documents/AMU/repos/amu-admins/content_admin && currentide"
alias rsadmincontent="rails server --port=3022"
alias adminclient="cd ~/documents/AMU/repos/amu-admins/client_admin && currentide"
alias rsclientadmin="rails server --port=3062"
alias adminotterloop="cd ~/documents/AMU/repos/amu-admins/otterloop && currentide"
alias rsadminotterloop="rails server --port=3063"
alias adminconsumer="cd ~/documents/AMU/repos/amu-admins/consumer_admin && currentide"
alias rsconsumeradmin="rails server --port=3042"
alias adminsubscribermail="cd ~/documents/AMU/repos/amu-admins/subscriber_mail_admin && currentide"
alias rssubscribermailadmin="rails server --port=3080"

# Legacy
alias ug="cd ~/documents/AMU/repos/amu-legacy/uclickgames && currentide"
alias sherpa="cd ~/documents/AMU/repos/amu-legacy/site_comicssherpa.com/ && currentide"

# Services
alias filemover="cd ~/documents/AMU/repos/amu-digital-services/filemover && currentide"
alias servicecontent="cd ~/documents/AMU/repos/amu-digital-services/webservice_content && currentide"
alias rsservicecontent="rails s -p '3030'"
alias serviceasset="cd ~/documents/AMU/repos/amu-digital-services/asset_engine && currentide"
alias rsserviceasset="rails server --port=3031"
alias serviceregistration="cd ~/documents/AMU/repos/amu-digital-services/webservice_registration && currentide"
alias rsserviceregistration="rails server --port=3040"
alias servicefeatureavatar="cd ~/documents/AMU/repos/amu-digital-services/webservice_feature_avatars && currentide"
alias rsservicefeatureavatar="rails server --port=3041"
alias serviceuseravatar="cd ~/documents/AMU/repos/amu-digital-services/webservice_avatars && currentide"
alias rsserviceuseravatar="rails server --port=3042"
alias serviceembed="cd ~/documents/AMU/repos/amu-digital-services/embed_service/ && currentide"
alias rsserviceclient="rails s -p '3050'"
alias serviceclient="cd ~/documents/AMU/repos/amu-digital-services/go-webservice-client && currentide"
alias rsserviceembed="rails server --port=3060"
alias servicegocontent="cd ~/documents/AMU/repos/amu-digital-services/embedded_entertainment/ && currentide"
alias rsservicegoc="rails server --port=3070"
alias servicegames="cd ~/documents/AMU/repos/amu-digital-services/amu_games/ && currentide"
alias rsservicegames="rails server --port=3061"
alias servicegamedata="cd ~/documents/AMU/repos/amu-digital-services/webservice_gamedata/ && currentide"
alias rsservicegamedata="rails server --port=3064"

# Wordpress
# alias kcgac="cd /Users/andrewbarrows/Career/Clients/KCGAC/3_develop && currentide"
alias dilbertblog="cd ~/documents/AMU/repos/amu-digital-products/wpengine-dilbertblog"
alias dailycartoonist="cd ~/documents/AMU/repos/amu-digital-products/devkit/dailycartoonist && currentide"
alias dailycartoonist="cd ~/documents/AMU/repos/amu-digital-products/devkit/dailycartoonist && currentide && wpe start"
alias wonderword="cd ~/documents/AMU/repos/amu-digital-products/wonderword && currentide"
alias rswonderword="cd ~/documents/AMU/repos/amu-digital-products/wonderword && currentide && wpe start"
alias multiamu="cd ~/documents/AMU/repos/amu-digital-products/multiamu"
alias ssmultiamu="cd ~/documents/AMU/repos/amu-digital-products/multiamu && currentide && open /Applications/MAMP"

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

# Python stuff
alias python="/usr/local/bin/python3"
alias pip="/usr/local/bin/pip3"

# Pathing
alias desktop="cd ~/Desktop"
alias apps="cd /Applications"
alias code="code ."
alias code-insiders="open . -a 'Visual Studio Code - Insiders'"
alias downloads="cd ~/Downloads"
alias team="cd ~/documents/AMU/repos/amu-development-team/team-tools-and-settings"
alias prototype="cd ~/documents/AMU/repos/amu-digital-technology-prototyping/"
#   alias drive="cd ~/"

#Bash Stuff
alias addalias="cd ~/ && currentide .zshrc"
alias savealias="source ~/.zshrc"
alias amiroot="who -u"
alias checkprocesses="ps au"
alias killbg='kill ${${(v)jobstates##*:*:}%=*}'
alias checksshkey='cat ~/.ssh/id_rsa.pub'
alias checkip='curl ipecho.net/plain ; echo'

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

# Database
alias startpg="postgres -D /usr/local/var/postgres"
#alias ="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"

# Personal Applications
alias dotfilesinstall="dotfiles && dotfiles/install"
alias bcsw="cd ~/specific-wellness-dev/"
# alias rrails server --port=3110"
alias bcdd="cd ~/driverdocs"
# alias rrails server --port=3102"
alias bcaap="cd ~/andyandpaige/"
# alias rrails server --port=3101"

echo "ZSH/ALIASES: Loaded."
