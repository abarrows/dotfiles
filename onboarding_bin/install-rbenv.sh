#!/bin/bash

# RBENV is the best way to install Ruby.
# It allows for multiple versions of Ruby
# on your machine.  It also allows for multiple versions of RubyGems

# Step 1: Requires homebrew package: rbenv and ruby-build
# (Completed by running ./install-profile ruby)
# NOTE: For M1 Macs - https://kemalmutlu.medium.com/installing-ruby-on-rails-macbook-pro-m1-4272da855fb3

# Step 2: Initialize RBENV if it is not already initialized
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >>~/.zshrc

# Step 3: Reload shell so RBENV is initialized
exec zsh

# Step 4b: For Intel-based Macs
# OPTIONAL: If path issues arise, try this:
# echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >>~/.zshrc
source ~/.zshrc
