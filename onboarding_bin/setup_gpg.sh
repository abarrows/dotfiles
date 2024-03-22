#!/bin/bash

# Resources
# https://dev.to/devmount/signed-git-commits-in-vs-code-36do
# https://gist.github.com/troyfontaine/18c9146295168ee9ca2b30c00bd1b41e
# https://twiserandom.com/git/github-error-remote-invalid-username-or-password-a-solution/index.html

# Step 1.  Use homebrew to install the following two packages.
brew install cask "gpg-suite"
brew install "gpg"
brew install "pinentry-mac"

# Step 2 Create the gnugp directory
mkdir ~/.gnupg

# NOTE: Intel-based Macs (M1 Macs do NOT use, it will break the setup.)
# echo 'pinentry-program $(brew --prefix)/bin/pinentry-mac' >
# ~/.gnupg/gpg-agent.conf

# Step 3. This tells gpg to use the gpg-agent
echo 'use-agent' >~/.gnupg/gpg.conf

# Step 4. Add this to your .zshrc file
echo 'export GPG_TTY=$(tty)' >>~/.zshrc

# Step 5. Restart terminal session so the variable is brought in.
source ~/.zshrc

# Step 6. Set permissions for gnupg
chmod 700 ~/.gnupg

# Step 7. Actually start creating your first key.  Follow the instructions below.
gpg --full-gen-key

# What type? Selection: <press enter>  This will pick (1) the default RSA and RSA
# 1. Length: 4096
# (Github requires 4096)
#
# Expiration Duration: 3y
# This is a safe duration.  TIP: Put reminder in
# calendar 3 years from today so you do not get blind-sided.
#
# Is this correct? (y/N): y
# Real name: John Doe
# (Your human friendly name written out.)
#
# Email address: jdoe@domain.com
# (NOTE: Use the github no-reply email address or your primary email address.)
#
# Comment: Personal
# (This will show up in parenthesis next to your name. Choose
# whatever you would like, or choose nothing.)
#
# You selected this USER-ID: John Doe (Personal) jdoe@domain.com
# Confirm all this: o

# Step 8. List your keys
gpg -k

# Step 9. Find the key you just made and copy what is after rsa4096 and paste it
# into the two scripts below (step 10. and 11.)
#gpg -K --keyid-format SHORT
#sec rsa4096/######## YYYY-MM-DD [SC] [expires: YYYY-MM-DD]

# Step 10. Set gpgsign program path NOTE: Take --global out if you have multiple .gitconfig files.
git config --global user.signingkey '**your key id from step 9, should still be in your clipboard**'

# Step 11. Set gpgsign program path NOTE: Take --global out if you have multiple .gitconfig files.
git config --global gpg.program "$(which gpg2)"

# Step 12. Set gpgsign to true NOTE: Take --global out if you have multiple .gitconfig files.
git config --global commit.gpgsign true

# Step 13. The export command below gives you the key you add to GitHub
gpg --armor --export '**your key id from step 9, should still be in your clipboard**'

# Step 14. Copy the GPG fingerprint and store it safely in a password manager
# like 1password or last pass.  It will start and end like this:
-----BEGIN PGP PUBLIC KEY BLOCK-----
...a lot of characters...
----------END PGP PUBLIC KEY BLOCK-----

# Navigate to
# [https://github.com/settings/gpg/new](https://github.com/settings/gpg/new) and
# paste in your GPG Fingerprint from step 14.

# Step 15. In VS Code, open settings.json (CMD+Shft+P and type settings json).
# Paste this configuration to tell vscode to sign all commits.
"git.enableCommitSigning": true

# Step 16. Test it out by making a change, adding files, and then committing.
git commit -S -s -m "My Signed Commit."

# IMPORTANT CAVEAT: If you are testing locally on a repo that was originally
# cloned using https, gpg signed commits will likely fail.  The safe bet is to
# do a fresh clone of a repo using ssh, to test your first signed commit.
