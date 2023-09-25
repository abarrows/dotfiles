#!/bin/bash

# Detect the architecture of the mac (arm64 is for M1 Macs, x86_64 is for Intel Macs)
arch_name="$(uname -m)"

# Check if homebrew is installed and if not, install it.
if [[ ! -r "/usr/local/bin/brew" && ! -r "/opt/homebrew/bin/brew" ]]; then
  echo "Homebrew is NOT already installed."

  if [ "${arch_name}" = "arm64" ]; then
    # M1 Macs
    arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  elif [ "${arch_name}" = "x86_64" ]; then
    # Intel Macs
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Unknown architecture: ${arch_name}"
    exit 1
  fi

else
  echo "Homebrew IS already installed."
fi

# Optionally, set permissions back to the user if needed.
# sudo chown -R $(whoami) $(brew --prefix)/*
