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

# ── Connect rs-agents into Hermes (via SKILLS, not `hermes plugins`) ──────────
# Hermes cannot consume the rs-agents *Claude Code plugin* directly — `hermes
# plugins` expects Python provider plugins, a different format. rs-agents reaches
# Hermes through its SKILLS: mirror the released plugin's SKILL.md files into
# ~/.hermes/skills/rs-agents so any selected local model can discover them
# on-demand. Best-effort (--soft): if the source isn't present yet (plugin not
# installed / repo not cloned), the Hermes install still succeeds — run the sync
# later once the rs-agents plugin is available.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1) Ensure the rs-agents Claude Code plugin is installed — that's the SOURCE the
#    Hermes sync mirrors from (and Claude Code auto-updates it on startup).
PLUGINS="${SCRIPT_DIR}/install-claude-plugins.sh"
if [ -f "$PLUGINS" ]; then
  echo ""
  echo "Ensuring the rs-agents Claude Code plugin is installed..."
  bash "$PLUGINS" || echo "rs-agents plugin install skipped (non-fatal)."
fi

# 2) Mirror the plugin's skills into Hermes (best-effort; soft-skips if no source).
SYNC="${SCRIPT_DIR}/../mac-mini-agent/sync-rs-agents-to-hermes.sh"
if [ -f "$SYNC" ]; then
  echo ""
  echo "Connecting rs-agents skills into Hermes (via skills sync)..."
  bash "$SYNC" --soft || echo "rs-agents sync skipped (non-fatal)."
fi

# 3) Wire Hermes to the Docker Desktop MCP Toolkit gateway (best-effort;
#    soft-skips if Docker/the Toolkit isn't installed yet). One MCP_DOCKER
#    entry gives any local model the same tool plane Claude Code uses; the
#    Toolkit + Keychain stay the source of truth for servers and secrets.
MCP_CONNECT="${SCRIPT_DIR}/connect-hermes-mcp.sh"
if [ -f "$MCP_CONNECT" ]; then
  echo ""
  echo "Connecting Hermes to the Docker MCP Toolkit gateway..."
  bash "$MCP_CONNECT" --soft || echo "MCP Toolkit wiring skipped (non-fatal)."
fi
