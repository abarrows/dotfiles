cask_args appdir: '/Applications'
tap 'homebrew/bundle'
tap 'homebrew/cask'
tap 'homebrew/cask-fonts'
tap 'homebrew/core'
tap 'homebrew/services'
brew "coreutils" # REQUIRED - ROR/DEVOPS Required to build ruby containers and new ruby version binaries.
brew "cmake" # RECOMMENDED - ROR/DEVOPS
# brew "openjdk" # RECOMMENDED - Used within some of our legacy gems
brew 'imagemagick' # RECOMMENDED - ROR Image manipulation utility for web applications
brew 'libyaml' # RECOMMENDED - ROR/DEVOPS Compiled Dependency for web applications with Ruby on Rails
brew 'memcached' # RECOMMENDED - ROR Performance Caching library for Ruby on Rails
brew "mysql", restart_service: true # REQUIRED - ROR/DEVOPS/PYTHON/PG Database Dependency for MySQL (Usually used by non-containerized web applications)
brew "mysql-client" # REQUIRED - ROR/DEVOPS/PYTHON/PG Database Dependency for MySQL
brew "openssl" # REQUIRED - ROR/DEVOPS/PYTHON/PG Database Dependency for MySQL
brew "pidof" # RECOMMENDED - ROR CL Dependency for displaying PID for a running process
brew "rbenv" # REQUIRED - ROR Ruby Version Manager that replaces RVM
brew "rbenv-default-gems" # RECOMMENDED - ROR Ruby Version Manager default gems for all projects.
brew "readline" # REQUIRED - ROR/DEVOPS/PYTHON/PG Database Dependency for MySQL
brew "ruby-build" # REQUIRED - ROR Dependency for rbenv
brew "solargraph" # RECOMMENDED - ROR debugging and language server for Ruby on Rails
brew "sphinx" # RECOMMENDED - ROR Application Dependency for search functionality in Ruby on Rails (Legacy)
brew "shfmt" # OPTIONAL - BASE/ROR/NODE/DEVOPS/PYTHON Linter for shell scripts
brew "zlib" # NOT-USED Image Dependency data compression library
