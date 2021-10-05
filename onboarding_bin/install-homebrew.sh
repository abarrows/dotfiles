#!/bin/bash

# First check if homebrew is installed and if not
if [ ! -x /usr/local/bin/brew ]; then
  echo "Homebrew is NOT already installed."
  arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew IS already installed."
fi
