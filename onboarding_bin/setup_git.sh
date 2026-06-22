#!/bin/bash

# ⚠️ DEPRECATED as the onboarding path. The canonical global git configuration
# is now applied by meta/configs/version_control.yml (run by `install-profile
# base`), and onboard.sh sets user.signingkey directly. This script writes an
# OVERLAPPING gitconfig that DIFFERS from version_control.yml (editor `code` vs
# `windsurf`, pull.rebase false vs true) — running it after onboarding will
# silently change those settings. Kept only for manual/standalone repair. Do not
# wire it into a profile; pick one source of truth before using it.
#
# In order to setup your global git configuration you must set .envrc value
# prior running this script or onboarding.

# Function to load environment variables from .envrc file
load_envrc() {
  # Check if .envrc file exists
  if [ -f ~/.envrc ]; then
    # Load environment variables from .envrc
    set -a
    . ~/.envrc
    set +a
  else
    echo "Error: .envrc file not found. Please create a .envrc file with required environment variables."
    exit 1
  fi
}

# Function to set up .gitconfig using environment variables
setup_gitconfig() {
  # Check if environment variables are set
  # TODO: Need to make this more maintainable.  Only works with personal at the moment.
  # export CURRENT_EMAIL="${GIT_EMAIL_ADDRESS_PERSONAL:-GIT_EMAIL_ADDRESS_PROFESSIONAL}"
  # if [ -z "$CURRENT_USER" ] && [ -z "$CURRENT_EMAIL" ]; then
  echo "Setting up basic git user and email."
  git config --global user.name "$CURRENT_USER"
  git config --global user.email "$GIT_EMAIL_ADDRESS_PROFESSIONAL"

  # Now" checking for GPG key"
  if [ -n "${CURRENT_USER_GPG_KEY}" ]; then
    echo "Retrieved GPG key setting up signed commits."
    git config --global commit.gpgsign "true"
    git config --global user.signingkey "${CURRENT_USER_GPG_KEY}"
    git config --global gpg.program "$(which gpg)"
  else
    echo "Warning: Both CURRENT_USER and either CURRENT_USER_GPG_KEY or CURRENT_USER_GPG_KEY environment variables are required."
    exit 1
  fi

  # else
  #   git config --global gpg.program "gpg"
  #   git config --global commit.gpgsign "false"
  #   echo "WARNING: No GPG signingkey was found.  To minimize security risks, please follow these instructions to create a GPG key in github.  Update the CURRENT_USER_GPG_KEY or CURRENT_USER_GPG_KEY in the .envrc file afterwards and then rerun ./install-profile base."
  # fi

  git config --global user.url "$CURRENT_USER_GITHUB_URL"
  git config --global core.editor "$IDE_PATH"
  git config --global core.ignorecase "false"
  git config --global core.excludesfile "\$HOME/.git-template-directory/.gitignore"
  git config --global init.templateDir "$HOME/.git-template-directory"
  git config --global init.defaultBranch "main"
  git config --global filter.lfs.clean "git-lfs clean -- %f"
  git config --global filter.lfs.smudge "git-lfs smudge -- %f"
  git config --global filter.lfs.process "git-lfs filter-process"
  git config --global filter.lfs.required "true"
  git config --global pull.rebase "false"
  git config --global core.editor "code --wait"
  git config --global core.hooksPath "\$HOME/.git-template-directory/hooks"
  git config --global diff.tool "vscode"
  git config --global difftool.vscode.cmd "code --wait --diff \$LOCAL \$REMOTE"
  git config --global merge.tool "vscode"
  git config --global mergetool.vscode.cmd "code --wait \$MERGED"
  git config --global checkout.defaultRemote "origin"
  git config --global fetch.prune "true"

  # Optionally, you can add more configurations here using environment variables
  # Example: git config --global core.editor "$GIT_EDITOR"
}

# Main function to execute setup
main() {
  # Load environment variables
  load_envrc

  # Set up .gitconfig
  setup_gitconfig

  echo "Git configuration successfully set up."
}

# Execute main function
main
