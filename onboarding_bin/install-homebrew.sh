#!/bin/bash

# Homebrew install logic is mirrored in onboard.sh `install_homebrew()` (the
# canonical reference for the one-shot flow) and pre-onboarding-script.sh.
# Keep the three in sync: native arm64 (no `arch -x86_64`) + NONINTERACTIVE=1.

# Detect the architecture of the mac (arm64 is for M1 Macs, x86_64 is for Intel Macs)
arch_name="$(uname -m)"

# Check if homebrew is installed and if not, install it.
if [[ ! -r "/usr/local/bin/brew" && ! -r "/opt/homebrew/bin/brew" ]]; then
  echo "Homebrew is NOT already installed."

  if [ "${arch_name}" = "arm64" ]; then
    # Apple Silicon Macs — install NATIVE arm64 Homebrew into /opt/homebrew.
    # (Do NOT prefix with `arch -x86_64`: that installs Rosetta x86 Homebrew
    # into /usr/local, which is wrong for Apple Silicon and diverges from
    # pre-onboarding-script.sh / onboard.sh.)
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  elif [ "${arch_name}" = "x86_64" ]; then
    # Intel Macs
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Unknown architecture: ${arch_name}"
    exit 1
  fi

else
  echo "Homebrew IS already installed."
fi

# Optionally, set permissions back to the user if needed.
sudo chown -R $(whoami) $(brew --prefix)/*
