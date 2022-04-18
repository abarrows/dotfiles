#!/bin/bash

# First check if homebrew is installed and if not
if [ ! -x /usr/local/bin/brew ]; then
  echo "Homebrew is NOT already installed."
  arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew IS already installed."
fi

# Set permissions back to the user.
sudo chown -R $(whoami) $(brew --prefix)/*
