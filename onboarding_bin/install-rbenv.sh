#!/bin/bash

# RBENV is the best way to install Ruby.  It allows for multiple versions of
# Ruby on your machine.  It also allows for multiple versions of RubyGems

# Step 1: Requires homebrew package: gnupg, rbenv, ruby-build  (Should be installed with Brewfile.)
# Step 2: Initialize rbenv
# Initialise rbenv
rbenv init

# Step 3: Add rbenv to PATH by adding this into your .zshrc file:
#??? echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
eval $(rbenv init - zsh)

# Step 4: Install global ruby version
rbenv install 3.0.3

# Step 5: Verify installation
rbenv install -l

# Step 5: Set global ruby version
rbenv global 3.0.3

# Step 6: Verify zsh plugin has been added.  Navigate to .plugins.zsh and verify
# plugins=(
# ...
# rbenv
