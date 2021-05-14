#!/usr/bin/env bash

# DYNAMIC VALUES
ide_path=$IDE_PATH
current_user=$CURRENT_USER
current_company=$CURRENT_COMPANY
# PERSONAL SETTINGS
alias personal="cd ~/documents/\${current_company}/repos/personal"
alias aw="cd ~/documents/\${current_company}/repos/personal/animatronic-workhorse/animatronic-workhorse && \${ide_path} ."
alias dotfiles="cd ~/documents/\${current_company}/repos/personal/dotfiles/ && \${ide_path} ."

# Team Tools and Settings
alias teamtools="cd ~/documents/\${current_company}/repos/amu-development-team/team-tools-and-settings && \${ide_path} ."
alias workhorsenode="cd ~/documents/\${current_company}/repos/amu-development-team/team-tools-and-settings/dev-ops-scripts/environments/workhorse_node && \${ide_path} ."
alias workhorseruby="cd ~/documents/\${current_company}/repos/amu-development-team/team-tools-and-settings/dev-ops-scripts/environments/ruby && \${ide_path} ."
alias skeleton="cd ~/documents/\${current_company}/repos/amu-development-team/team-tools-and-settings/boilerplates/ruby_on_rails/skeleton && \${ide_path} ."
alias wps='./bin/webpack-dev-server'
alias comicviewer="cd ~/documents/\${current_company}/repos/amu-digital-technology-prototyping/mobile-friendly-comic-viewer && \${ide_path} ."
alias repomigrater="cd ~/documents/\${current_company}/repos/amu-development-team/team-tools-and-settings/dev-ops-scripts/repository_utilities/bitbucket-to-github && \${ide_path} ."
alias searchstash=gitsearch

# Security
#alias security= "cd ~~"
#alias zed = "open cd /Applications/OWASP ZAP.app"
#alias arachni= "cd ~/Career_Archive/Resources/Arms/Code_Stock/SECURITY/arachni"
#alias startarachni="bin/arachni "
#function startarachni() { bin/arachni "$@" ;}

# Clients
alias clients="cd ~/documents/\${current_company}/repos/clients"
alias specificwellness="cd ~/documents/\${current_company}/repos/clients/specific_wellness/ && \${ide_path} ."
alias panda="cd ~/documents/\${current_company}/repos/personal/andy-and-paige-wedding/ && \${ide_path} ."

# AMU General Pathing
alias repos="cd ~/documents/\${current_company}/repos/"
alias amudigitalproducts="cd ~/documents/\${current_company}/repos/amu-digital-products"
alias amudigitalservices="cd ~/documents/\${current_company}/repos/amu-digital-services"
alias repos="cd ~/documents/\${current_company}/repos/"
alias amusnippets="cd ~/documents/\${current_company}/repos/amu-snippets"
alias amudocker="cd ~/documents/\${current_company}/repos/amu-docker/"
alias amuadmins="cd ~/documents/\${current_company}/repos/amu-admins"
alias amugems="cd ~/documents/\${current_company}/repos/amu-gems"
alias prototyping="cd ~/documents/\${current_company}/repos/amu-digital-technology-prototyping"
alias webpackstatic="cd ~/documents/\${current_company}/repos/amu-digital-technology-prototyping/static-html-webpack-boilerplate && \${ide_path} ."

# AMU Digital Products
alias dilbert="cd ~/documents/\${current_company}/repos/amu-digital-products/dilbert/ && \${ide_path} ."
alias rsdilbert="rails server --port=3013 && ./bin/webpack-dev-server"
alias doones="cd ~/documents/\${current_company}/repos/amu-digital-products/doonesbury && \${ide_path} ."
alias rsdoones="rails server --port=3002"
alias gocomics="cd ~/documents/\${current_company}/repos/amu-digital-products/gocomics5/ && \${ide_path} ."
alias rsgocomics="rails server --port=3001"
alias tps="cd ~/documents/\${current_company}/repos/amu-digital-products/puzzlesociety/ && \${ide_path} ."
alias rstps="rails server --port=3004"
alias puzzlesociety="cd ~/documents/\${current_company}/repos/amu-digital-products/puzzle-society_ui/ && \${ide_path} ."
alias rspuzzlesociety="yarn install && yarn dev"
alias uu="cd ~/documents/\${current_company}/repos/amu-digital-products/universaluclick/ && \${ide_path} ."
alias rsuu="rails server --port=3006"
alias uexpress="cd ~/documents/\${current_company}/repos/amu-digital-products/uexpress && \${ide_path} ."
alias rsuexpress="rails server --port=3010"
alias farside="cd ~/documents/\${current_company}/repos/amu-digital-products/thefarside/ && \${ide_path} ."
alias rsfarside="rails server --port=3020"
alias gcemail="cd ~/documents/\${current_company}/repos/amu-digital-products/gocomics_daily_pro_email && \${ide_path} ."

# Admins
alias admincontent="cd ~/documents/\${current_company}/repos/amu-admins/content_admin && \${ide_path} ."
alias rsadmincontent="rails server --port=3022"
alias adminclient="cd ~/documents/\${current_company}/repos/amu-admins/client_admin && \${ide_path} ."
alias rsclientadmin="rails server --port=3062"
alias adminotterloop="cd ~/documents/\${current_company}/repos/amu-admins/otterloop && \${ide_path} ."
alias rsadminotterloop="rails server --port=3063"
alias adminconsumer="cd ~/documents/\${current_company}/repos/amu-admins/consumer_admin && \${ide_path} ."
alias rsconsumeradmin="rails server --port=3042"
alias adminsubscribermail="cd ~/documents/\${current_company}/repos/amu-admins/subscriber_mail_admin && \${ide_path} ."
alias rssubscribermailadmin="rails server --port=3080"

# Legacy
alias ug="cd ~/documents/\${current_company}/repos/amu-legacy/uclickgames && \${ide_path} ."
alias sherpa="cd ~/documents/\${current_company}/repos/amu-legacy/site_comicssherpa.com/ && \${ide_path} ."

# Services
alias filemover="cd ~/documents/\${current_company}/repos/amu-digital-services/filemover && \${ide_path} ."
alias servicecontent="cd ~/documents/\${current_company}/repos/amu-digital-services/webservice_content && \${ide_path} ."
alias rsservicecontent="rails s -p '3030'"
alias serviceasset="cd ~/documents/\${current_company}/repos/amu-digital-services/asset_engine && \${ide_path} ."
alias rsserviceasset="rails server --port=3031"
alias serviceregistration="cd ~/documents/\${current_company}/repos/amu-digital-services/webservice_registration && \${ide_path} ."
alias rsserviceregistration="rails server --port=3040"
alias servicefeatureavatar="cd ~/documents/\${current_company}/repos/amu-digital-services/webservice_feature_avatars && \${ide_path} ."
alias rsservicefeatureavatar="rails server --port=3041"
alias serviceuseravatar="cd ~/documents/\${current_company}/repos/amu-digital-services/webservice_avatars && \${ide_path} ."
alias rsserviceuseravatar="rails server --port=3042"
alias serviceembed="cd ~/documents/\${current_company}/repos/amu-digital-services/embed_service/ && \${ide_path} ."
alias rsserviceclient="rails s -p '3050'"
alias serviceclient="cd ~/documents/\${current_company}/repos/amu-digital-services/go-webservice-client && \${ide_path} ."
alias rsserviceembed="rails server --port=3060"
alias servicegocontent="cd ~/documents/\${current_company}/repos/amu-digital-services/embedded_entertainment/ && \${ide_path} ."
alias rsservicegoc="rails server --port=3070"
alias servicegames="cd ~/documents/\${current_company}/repos/amu-digital-services/amu_games/ && \${ide_path} ."
alias rsservicegames="rails server --port=3061"
alias wwgame="cd ~/documents/\${current_company}/repos/amu-digital-products/wonderword_game && \${ide_path} ."
alias servicegamedata="cd ~/documents/\${current_company}/repos/amu-digital-services/webservice_gamedata/ && \${ide_path} ."
alias rsservicegamedata="rails server --port=3064"

# Wordpress
# alias kcgac="cd /Users/andrewbarrows/Career/Clients/KCGAC/3_develop && \${ide_path} ."
alias dilbertblog="cd ~/documents/\${current_company}/repos/amu-digital-products/wpengine-dilbertblog"
alias dailycartoonist="cd ~/documents/\${current_company}/repos/amu-digital-products/devkit/dailycartoonist && \${ide_path} ."
alias dailycartoonist="cd ~/documents/\${current_company}/repos/amu-digital-products/devkit/dailycartoonist && \${ide_path} . && wpe start"
alias wonderword="cd ~/documents/\${current_company}/repos/amu-digital-products/wonderword && \${ide_path} ."
alias rswonderword="cd ~/documents/\${current_company}/repos/amu-digital-products/wonderword && \${ide_path} . && wpe start"
alias multiamu="cd ~/documents/\${current_company}/repos/amu-digital-products/multiamu"
alias ssmultiamu="cd ~/documents/\${current_company}/repos/amu-digital-products/multiamu && \${ide_path} . && open /Applications/MAMP"

# Server SSH
alias syndicate01="ssh \${current_user}@hfsyndicate201.amuniversal.com"
alias syndicate02="ssh \${current_user}@hfsyndicate202.amuniversal.com"
alias syndicateadmin="ssh \${current_user}@hfsyndicateadmin202.amuniversal.com"
alias admintools="ssh \${current_user}@hfadmintools201.amuniversal.com"
alias syndicatetemplates="cd /home/mover/template/"
alias images01="ssh \${current_user}@hfimages01.amuniversal.com"
alias images02="ssh \${current_user}@hfimages02.amuniversal.com"
alias imagestemplate="cd /usr/local/perlib/ucomics/templates/"
alias puzzle401="ssh \${current_user}@hfspuzzleapp401.amuniversal.com"
alias puzzle402="ssh \${current_user}@hfspuzzleapp402.amuniversal.com"
alias stageservices="ssh \${current_user}@hfstagerailsservices201.amuniversal.com"
alias stage201="ssh \${current_user}@hfstagerailsapp201.amuniversal.com"
alias stage301="ssh \${current_user}@hfsrailsapp301.amuniversal.com"
alias stage302="ssh \${current_user}@hfsrailsapp302.amuniversal.com"
alias stage303="ssh \${current_user}@hfsrailsapp303.amuniversal.com"
alias stage304="ssh \${current_user}@hfsrailsapp304.amuniversal.com"
alias dev301="ssh \${current_user}@hfdrailsapp301.amuniversal.com"
alias dev302="ssh \${current_user}@hfdrailsapp302.amuniversal.com"

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

# Pathing
alias desktop="cd ~/Desktop"
alias apps="cd /Applications"
alias code="code ."
alias code-insiders="open . -a 'Visual Studio Code - Insiders'"
alias downloads="cd ~/Downloads"
alias team="cd ~/documents/\${current_company}/repos/amu-development-team/team-tools-and-settings"
alias prototype="cd ~/documents/\${current_company}/repos/amu-digital-technology-prototyping/"
#   alias drive="cd ~/"

#Bash Stuff
alias addalias="cd ~/ && \${ide_path} . .zshrc"
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

echo "ZSH/ALIASES: Loaded."
