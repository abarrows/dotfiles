#!/bin/bash

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh

# Generate key for work account
ssh-keygen -t ed25519 -C "jdoe@company.com" -f ~/.ssh/id_ed25519_work

# Generate key for personal account
ssh-keygen -t ed25519 -C "jdoe@gmail.com" -f ~/.ssh/id_ed25519_personal

# Set correct permissions
chmod 600 ~/.ssh/id_ed25519_work
chmod 600 ~/.ssh/id_ed25519_personal
chmod 644 ~/.ssh/id_ed25519_work.pub
chmod 644 ~/.ssh/id_ed25519_personal.pub

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add both keys to ssh-agent
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_work
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_personal
