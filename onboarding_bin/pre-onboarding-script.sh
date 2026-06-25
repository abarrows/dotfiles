#!/usr/bin/env bash

# Here is how to execute this in a Mac terminal

# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abarrows/dotfiles/production/onboarding_bin/pre-onboarding-script.sh)"

# Detect the architecture of the Mac
arch_name="$(uname -m)"

# Check if Homebrew is installed
if [[ ! -r "/usr/local/bin/brew" && ! -r "/opt/homebrew/bin/brew" ]]; then
  echo "Homebrew is NOT installed. Installing..."

  if [[ "${arch_name}" == "arm64" ]]; then
    # M1 Macs
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Installed Homebrew for M1+ Mac"
  elif [[ "${arch_name}" == "x86_64" ]]; then
    # Intel Macs
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Installed Homebrew for Intel-based Mac"
  else
    echo "Unknown architecture: ${arch_name}"
    exit 1
  fi
else
  echo "Homebrew is already installed."
fi

echo "Setting up your environment..."

# Initialize environment variables with defaults if needed
: "${GIT_EMAIL_ADDRESS_PROFESSIONAL:="default_email@example.com"}"
: "${CURRENT_NAME:="Default Name"}"
: "${CURRENT_USER:="default_user"}"
: "${CURRENT_USER_GITHUB_URL:="https://github.com/default_user"}"
: "${CURRENT_COMPANY:="Default Company"}"
: "${IDE_PATH:="/path/to/ide"}"
: "${JIRA_BASE_URL:="https://jira.example.com"}"
: "${CURRENT_USER_GPG_KEY:=""}"
: "${JIRA_USER_EMAIL:="jira_user@example.com"}"

# Prompt for user inputs
read -rp "Enter your git email address (press Enter to keep current: [$GIT_EMAIL_ADDRESS_PROFESSIONAL]): " userInput
GIT_EMAIL_ADDRESS_PROFESSIONAL="${userInput:-$GIT_EMAIL_ADDRESS_PROFESSIONAL}"

read -rp "Enter your name (press Enter to keep current: [$CURRENT_NAME]): " userInput
CURRENT_NAME="${userInput:-$CURRENT_NAME}"

read -rp "Enter your USER (press Enter to keep current: [$USER]): " userInput
CURRENT_USER="${userInput:-$USER}"

read -rp "Enter your GitHub URL (press Enter to keep current: [$CURRENT_USER_GITHUB_URL]): " userInput
CURRENT_USER_GITHUB_URL="${userInput:-$CURRENT_USER_GITHUB_URL}"

read -rp "Enter your Company Name (press Enter to keep current: [$CURRENT_COMPANY]): " userInput
CURRENT_COMPANY="${userInput:-$CURRENT_COMPANY}"

read -rp "Enter your IDE Path (press Enter to keep current: [$IDE_PATH]): " userInput
IDE_PATH="${userInput:-$IDE_PATH}"

read -rp "Enter your JIRA Base URL (press Enter to keep current: [$JIRA_BASE_URL]): " userInput
JIRA_BASE_URL="${userInput:-$JIRA_BASE_URL}"

read -rp "Enter your GPG Key (leave blank if none) (press Enter to keep current: [$CURRENT_USER_GPG_KEY]): " userInput
CURRENT_USER_GPG_KEY="${userInput:-$CURRENT_USER_GPG_KEY}"

read -rp "Enter your JIRA User Email (press Enter to keep current: [$JIRA_USER_EMAIL]): " userInput
JIRA_USER_EMAIL="${userInput:-$JIRA_USER_EMAIL}"

# Create .envrc
cat <<EOF > ~/.envrc
# Dotfiles Environment Variables (Generated)

# Sensitive Variables
export GIT_EMAIL_ADDRESS_PROFESSIONAL="$GIT_EMAIL_ADDRESS_PROFESSIONAL"

# Non-Sensitive Variables
export CURRENT_NAME="$CURRENT_NAME"
export CURRENT_USER="$CURRENT_USER"
export CURRENT_USER_GITHUB_URL="$CURRENT_USER_GITHUB_URL"
export CURRENT_COMPANY="$CURRENT_COMPANY"
export IDE_PATH="$IDE_PATH"
export JIRA_BASE_URL="$JIRA_BASE_URL"
export CURRENT_USER_GPG_KEY="$CURRENT_USER_GPG_KEY"
export JIRA_USER_EMAIL="$JIRA_USER_EMAIL"
EOF

echo ".envrc has been created or updated."

# When orchestrated by onboard.sh, stop here: onboard.sh already installs
# Homebrew/gh, clones the repo, and moves ~/.envrc into it. Running the tail
# below would install brew/gh again and clone a SECOND nested copy of the repo.
if [[ -n "${ONBOARD_ORCHESTRATED:-}" ]]; then
  echo "Orchestrated run — leaving repo clone + relocation to onboard.sh."
  return 0 2>/dev/null || exit 0
fi

# Standalone bootstrap: open .envrc, create the repo directory, install gh, and
# clone the dotfiles repo (moving ~/.envrc into it).
open ~/.envrc
mkdir -p "$CURRENT_COMPANY/repos/development-team"
cd "$CURRENT_COMPANY/repos/development-team" || exit
brew install gh
gh repo clone "$CURRENT_USER_GITHUB_URL/dotfiles" && mv ~/.envrc dotfiles/ && cd dotfiles/ && open .
