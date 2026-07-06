#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# install-claude-plugins.sh — register the Retail Success plugin marketplace and
# install the rs-agents plugin into Claude Code (non-interactive, idempotent).
#
# This is the SOURCE OF TRUTH channel for local machines: Claude Code auto-updates
# rs-agents on startup (marketplace `autoUpdate`), and the Hermes skills-sync
# mirrors from the resulting plugin cache. Run this BEFORE sync-rs-agents-to-hermes.sh.
#
# Note: the marketplace's declared name has been both `retailsuccess` (current
# marketplace.json) and `wayroo` (older / already on some machines), so we try
# both plugin identifiers. The Hermes sync glob is name-agnostic either way.
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail

if ! command -v claude >/dev/null 2>&1; then
  echo "! claude CLI not installed — skipping rs-agents plugin install (install Claude Code first)."
  exit 0
fi

# CLAUDECODE= clears the in-session guard so these run from a plain shell.
echo "▶ Registering the Retail Success plugin marketplace (Retail-Success/Wayroo.tools)..."
CLAUDECODE= claude plugin marketplace add Retail-Success/Wayroo.tools 2>&1 | tail -2 || true

echo "▶ Installing/enabling the rs-agents plugin..."
if CLAUDECODE= claude plugin install rs-agents@retailsuccess 2>/dev/null; then
  echo "  installed rs-agents@retailsuccess"
elif CLAUDECODE= claude plugin install rs-agents@wayroo 2>/dev/null; then
  echo "  installed rs-agents@wayroo"
else
  echo "! Could not auto-install rs-agents — open Claude Code and run '/plugin' to add it,"
  echo "  or check the marketplace name with 'claude plugin marketplace list'."
  exit 0
fi

echo "✔ rs-agents installed. Claude Code auto-updates it on startup (marketplace autoUpdate:true)."
echo "  → downstream: run mac-mini-agent/sync-rs-agents-to-hermes.sh to mirror skills into Hermes."
