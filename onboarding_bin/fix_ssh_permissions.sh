#!/bin/bash

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh

# Create known_hosts file if it doesn't exist
touch ~/.ssh/known_hosts

# Set correct permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 644 ~/.ssh/known_hosts

# Add GitHub's SSH key to known_hosts
ssh-keyscan -t rsa github.com >>~/.ssh/known_hosts

# Test the connection
echo "Testing GitHub SSH connection..."
ssh -T git@github.com
