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
alias repos="cd ~/$CURRENT_COMPANY/repos/"

# General Shell Operation
alias ls="ls -al"
alias du="docker compose up --build"
# alias dockerdestroy="docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) && docker rmi -f $(docker images -a -q) && docker builder prune -f && docker volume prune -f && docker system prune -f && docker networ
# k prune -f"
alias brewlist="brew list --versions"
alias zplugins="cd ~/.oh-my-zsh/custom/plugins"
alias checkpath="print -l PATH"
alias addalias="dotfiles && $IDE_PATH shell/.aliases.zsh"
alias savealias="source ~/.zshrc"
alias amiroot="who -u"
alias checkprocess="lsof -i:3000"
alias killprocess='kill -9 $1'
alias killbg='kill ${${(v)jobstates##*:*:}%=*}'
alias killpid='kill -9 $1'
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
alias gitreset="git reset --hard HEAD"
alias updatesubmodule="git pull --recurse-submodules && git submodule update --remote --recursive"
# alias gpull="\$updatesubmodule && git pull --all"
alias removegit="rm -rf .git"
alias prunebranches="$HOME/.onboarding_bin/prune-merged-in-branches.sh"

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
alias gemglobal="rbenv @global do gem install $1"

# Rails
alias rclear="rake assets:clean && rake tmp:clear"
alias rload="rake feature_data:reload"
alias rloadrecent="rake feature_data:reload_recent"
alias vsdebug="rdebug-ide ./bin/rails server puma"
alias rspecintegration="rails g integration_test $1"
alias rspeccontroller="rails g controller_test $1"

# Node and Javascript
alias wpd="./bin/webpack-dev-server"

# Personal
alias personal="cd ~/$CURRENT_COMPANY/repos/personal"
alias chatwithacb="cd ~/$CURRENT_COMPANY/repos/personal/chat-with-acb && $IDE_PATH ."
# material-skilltree
alias skilltree="cd ~/$CURRENT_COMPANY/repos/personal/skilltree-ui && $IDE_PATH ."
alias dotfiles="cd ~/$CURRENT_COMPANY/repos/development-team/dotfiles/ && $IDE_PATH ."
alias dotnetskills="cd ~/$CURRENT_COMPANY/repos/personal/dot-net-api-skills-framework/ && $IDE_PATH ."
alias acmepullrequest="cd ~/$CURRENT_COMPANY/repos/personal/acme-pull-request/ && $IDE_PATH ."
alias typescriptplayground="cd ~/$CURRENT_COMPANY/repos/personal/typescript-playground/ && $IDE_PATH ."
alias nextjsplayground="cd ~/$CURRENT_COMPANY/repos/personal/nextjs-playground/ && $IDE_PATH ."
alias personalresume="cd ~/$CURRENT_COMPANY/repos/personal/resume/ && $IDE_PATH ."
alias resume="cd ~/$CURRENT_COMPANY/repos/personal/resume/ && $IDE_PATH ."

# Clients
alias clients="cd ~/$CURRENT_COMPANY/repos/clients"

# Company Team Tools and Settings
alias team="cd ~/$CURRENT_COMPANY/repos/development-team && $IDE_PATH ."
alias teamtools="cd ~/$CURRENT_COMPANY/repos/development-team/team-tools-and-settings && $IDE_PATH ."
alias teamonboarding="cd ~/$CURRENT_COMPANY/repos/development-team/onboarding/ && $IDE_PATH ."
alias teamuitemplate="cd ~/$CURRENT_COMPANY/repos/development-team/template-nextjs-ui/ && $IDE_PATH ."
alias uitemplate="cd ~/$CURRENT_COMPANY/repos/development-team/template-nextjs-ui/ && $IDE_PATH ."
alias teamstandards="cd ~/$CURRENT_COMPANY/repos/development-team/code_standards/ && $IDE_PATH ."
alias teammatrix="cd ~/$CURRENT_COMPANY/repos/digital-team/dungeons-and-developers-2nd-edition/ && $IDE_PATH ."
alias teamworkflows="cd ~/$CURRENT_COMPANY/repos/digital-team/reusable_workflows && $IDE_PATH ."

echo "ZSH/ALIASES: Loaded."
