#!/usr/bin/env bash

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