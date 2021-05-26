#!/usr/bin/env bash
echo 'Testing dotenv vars.  The current company is: "\$CURRENT_COMPANY"'

# Dynamic Values (Populated by dotenv)
export ide_path=$IDE_PATH
export current_user=$CURRENT_USER
export current_company=$CURRENT_COMPANY

# General Pathing
alias desktop="cd ~/Desktop"
alias apps="cd /Applications"
alias code="\${ide_path} ."
alias code-insiders="open . -a 'Visual Studio Code - Insiders'"
alias downloads="cd ~/Downloads"
alias repos="cd ~/documents/\${current_company}/repos/"

# Personal
alias personal="cd ~/documents/\${current_company}/repos/personal"
alias dotfiles="cd ~/documents/\${current_company}/repos/personal/dotfiles/ && \${ide_path} ."

# Team Tools and Settings
alias teamtools="cd ~/documents/\${current_company}/repos/amu-development-team/team-tools-and-settings && \${ide_path} ."
alias onboarding="cd ~/documents/\${current_company}/repos/amu-development-team/amu-onboarding/ && \${ide_path} ."

# Prototyping and Research
alias prototyping="cd ~/documents/\${current_company}/repos/amu-digital-technology-prototyping/"
alias prototyping="cd ~/documents/\${current_company}/repos/amu-digital-technology-prototyping"
alias comicviewer="cd ~/documents/\${current_company}/repos/amu-digital-technology-prototyping/mobile-friendly-comic-viewer && \${ide_path} ."
alias rscomicviewer="cd ~/documents/\${current_company}/repos/amu-digital-technology-prototyping/mobile-friendly-comic-viewer && \${ide_path} . && rails server --port=3099 && ./bin/webpack-dev-server"
alias repomigrater="cd ~/documents/\${current_company}/repos/amu-development-team/team-tools-and-settings/dev-ops-scripts/repository_utilities/bitbucket-to-github && \${ide_path} ."

# Company Digital Products
alias dilbert="cd ~/documents/\${current_company}/repos/amu-digital-products/dilbert/ && \${ide_path} ."
alias rsdilbert="rails server --port=3013 && ./bin/webpack-dev-server"
alias doonesbury="cd ~/documents/\${current_company}/repos/amu-digital-products/doonesbury && \${ide_path} ."
alias rsdoonesbury="rails server --port=3002"
alias gocomics="cd ~/documents/\${current_company}/repos/amu-digital-products/gocomics5/ && \${ide_path} ."
alias rsgocomics="rails server --port=3001"
alias tps="cd ~/documents/\${current_company}/repos/amu-digital-products/puzzlesociety/ && \${ide_path} ."
alias rstps="rails server --port=3004"
alias uipuzzlesociety="cd ~/documents/\${current_company}/repos/amu-digital-products/puzzle-society_ui/ && \${ide_path} ."
alias rsuipuzzlesociety="yarn install && yarn dev"
alias syndication="cd ~/documents/\${current_company}/repos/amu-digital-products/universaluclick/ && \${ide_path} ."
alias rssyndication="rails server --port=3006"
# alias uexpress="cd ~/documents/\${current_company}/repos/amu-digital-products/uexpress && \${ide_path} ."
# alias rsuexpress="rails server --port=3010"
alias thefarside="cd ~/documents/\${current_company}/repos/amu-digital-products/thefarside/ && \${ide_path} ."
alias rsthefarside="rails server --port=3020"
alias gcemail="cd ~/documents/\${current_company}/repos/amu-digital-products/gocomics_daily_pro_email && \${ide_path} ."

# Company Admins
alias admincontent="cd ~/documents/\${current_company}/repos/amu-admins/content_admin && \${ide_path} ."
alias rsadmincontent="rails server --port=3022"
alias adminclient="cd ~/documents/\${current_company}/repos/amu-admins/client_admin && \${ide_path} ."
alias rsadminclient="rails server --port=3062"
alias adminotterloop="cd ~/documents/\${current_company}/repos/amu-admins/otterloop && \${ide_path} ."
alias rsadminotterloop="rails server --port=3063"
alias adminconsumer="cd ~/documents/\${current_company}/repos/amu-admins/consumer_admin && \${ide_path} ."
alias rsadminconsumer="rails server --port=3042"
alias adminsubscribermail="cd ~/documents/\${current_company}/repos/amu-admins/subscriber_mail_admin && \${ide_path} ."
alias rsadminsubscribermail="rails server --port=3080"

# Company Web Services
alias filemover="cd ~/documents/\${current_company}/repos/amu-digital-services/file-mover && \${ide_path} ."
alias servicecontent="cd ~/documents/\${current_company}/repos/amu-digital-services/webservice_content && \${ide_path} ."
alias rsservicecontent="rails s -p '3030'"
alias serviceasset="cd ~/documents/\${current_company}/repos/amu-digital-services/asset_engine && \${ide_path} ."
alias rsserviceasset="rails server --port=3031"
# alias serviceregistration="cd ~/documents/\${current_company}/repos/amu-digital-services/webservice_registration && \${ide_path} ."
# alias rsserviceregistration="rails server --port=3040"
alias servicefeatureavatar="cd ~/documents/\${current_company}/repos/amu-digital-services/webservice_feature_avatars && \${ide_path} ."
alias rsservicefeatureavatar="rails server --port=3041"
alias serviceuseravatar="cd ~/documents/\${current_company}/repos/amu-digital-services/webservice_avatars && \${ide_path} ."
alias rsserviceuseravatar="rails server --port=3042"
alias serviceembed="cd ~/documents/\${current_company}/repos/amu-digital-services/embed_service/ && \${ide_path} ."
alias rsserviceembed="rails server --port=3060"
alias serviceclient="cd ~/documents/\${current_company}/repos/amu-digital-services/go-webservice-client && \${ide_path} ."
alias rsserviceclient="rails s -p '3050'"
alias servicegocontent="cd ~/documents/\${current_company}/repos/amu-digital-services/embedded_entertainment/ && \${ide_path} ."
alias rsservicegocontent="rails server --port=3070"
alias servicegames="cd ~/documents/\${current_company}/repos/amu-digital-services/amu_games/ && \${ide_path} ."
alias wwgame="cd ~/documents/\${current_company}/repos/amu-digital-products/wonderword_game && \${ide_path} ."
alias servicegamedata="cd ~/documents/\${current_company}/repos/amu-digital-services/webservice_gamedata/ && \${ide_path} ."
alias rsservicegamedata="rails server --port=3064"

# Wordpress
# alias dailycartoonist="cd ~/documents/\${current_company}/repos/amu-digital-products/devkit/dailycartoonist && \${ide_path} ."
# alias rsdailycartoonist="cd ~/documents/\${current_company}/repos/amu-digital-products/devkit/dailycartoonist && \${ide_path} . && wpe start"
# alias wonderword="cd ~/documents/\${current_company}/repos/amu-digital-products/wonderword && \${ide_path} ."
# alias rswonderword="cd ~/documents/\${current_company}/repos/amu-digital-products/wonderword && \${ide_path} . && wpe start"
# alias multiamu="cd ~/documents/\${current_company}/repos/amu-digital-products/multiamu"
# alias ssmultiamu="cd ~/documents/\${current_company}/repos/amu-digital-products/multiamu && \${ide_path} . && open /Applications/MAMP"

# Clients
alias clients="cd ~/documents/\${current_company}/repos/clients"

# Server SSH
alias syndicate01="ssh \${current_user}@hfsyndicate201.amuniversal.com"
alias syndicate02="ssh \${current_user}@hfsyndicate202.amuniversal.com"
alias syndicateadmin="ssh \${current_user}@hfsyndicateadmin201.amuniversal.com"
alias syndicatetemplates="cd /home/mover/template/"
alias sshorangetoolproduction1="ssh \${current_user}@hfimages01.amuniversal.com"
alias sshorangetoolproduction2="ssh \${current_user}@Is .amuniversal.com"
alias orangetooltemplates="cd /usr/local/perlib/ucomics/templates/"
alias sshtps1="ssh \${current_user}@hfspuzzleapp401.amuniversal.com"
alias sshtps2="ssh \${current_user}@hfspuzzleapp402.amuniversal.com"
alias sshgocontentstage="ssh \${current_user}@hfstagerailsservices201.amuniversal.com"
alias sshadminstage1="ssh \${current_user}@hfstagerailsapp201.amuniversal.com"
alias sshadminproduction="ssh \${current_user}@hfadmintools201.amuniversal.com"
alias sshlicensingstage1="ssh \${current_user}@hfsrailsapp303.amuniversal.com"
alias sshlicensingstage2="ssh \${current_user}@hfsrailsapp304.amuniversal.com"

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
alias searchstash=gitsearch

# Heroku Stuff
alias hr="heroku restart"
alias hp="git push heroku master"
alias hschema="heroku db:push"

# Ruby Stuff
# Use gem shutup
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

# Rails Stuff
alias cleanassets="rake assets:clean assets:precompile"
alias seedfeatures="rake feature_data:reload"
alias seedfeaturesrecent="rake feature_data:reload_recent"
alias vsdebug="rdebug-ide ./bin/rails server puma"

# Node Stuff
alias wps='./bin/webpack-dev-server'

# Python stuff
alias python="/usr/local/bin/python3"
alias pip="/usr/local/bin/pip3"

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
