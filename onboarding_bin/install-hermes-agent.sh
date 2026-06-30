#!/bin/bash

# install-hermes-agent.sh — Install the Hermes Agent (Nous Research) AI coding
# harness via its official first-party installer, then open its interactive
# setup wizard ("the installer").
#
# Why not Homebrew: Hermes is a self-updating, self-learning agent. It installs
# under ~/.hermes, links a `hermes` shim into ~/.local/bin, and upgrades itself
# via `hermes update`. A Homebrew keg would fight that self-update (and shadow
# the shim on PATH), so Hermes is installed from its own installer instead.
# ~/.local/bin is placed on PATH by the dotfiles (shell/.zprofile, shell/.zshrc).
#
# Idempotent: if `hermes` is already installed, just (re)open the setup wizard
# instead of reinstalling.

if command -v hermes >/dev/null 2>&1; then
  echo "Hermes Agent IS already installed: $(hermes --version 2>/dev/null | head -1)"
  echo "Opening the Hermes setup wizard to (re)configure..."
  hermes setup
else
  echo "Hermes Agent is NOT installed. Downloading and installing now..."
  # The installer downloads Hermes to ~/.hermes, links ~/.local/bin/hermes, and
  # auto-opens the interactive setup wizard at the end. The wizard reads from
  # /dev/tty, so it still prompts even though the script is piped from curl.
  # With no terminal available it skips the wizard and prints a reminder to
  # "Run 'hermes setup' after install".
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
fi
