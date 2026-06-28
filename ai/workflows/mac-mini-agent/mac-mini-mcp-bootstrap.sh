#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# mac-mini-mcp-bootstrap.sh
# Stand up Docker MCP Toolkit + Claude Code on a 24/7 Mac mini.
#
# Replicates the "default" profile from andyb's primary machine.
# Run interactively the first time:   bash mac-mini-mcp-bootstrap.sh
#
# Docker MCP Toolkit connects over LOCAL STDIO (`docker mcp gateway run`).
# There is NO url and NO auth token to configure — ignore any yaml template
# that asks for `url:` / `auth:`. That format is for remote HTTP/SSE servers.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
step() { printf '\n\033[1;36m▶ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*"; }

# ── 0. Prereqs ───────────────────────────────────────────────────────────────
step "0. Checking prerequisites"
command -v docker  >/dev/null || { warn "Docker Desktop not installed. Install it first: https://docs.docker.com/desktop/setup/install/mac-install/"; exit 1; }
command -v claude  >/dev/null || { warn "Claude Code CLI not on PATH. Install: npm i -g @anthropic-ai/claude-code (or the official installer)"; exit 1; }
docker mcp --version >/dev/null 2>&1 || { warn "'docker mcp' unavailable — enable MCP Toolkit in Docker Desktop > Settings > Beta features."; exit 1; }
bold "  docker:  $(docker --version)"
bold "  claude:  $(claude --version 2>/dev/null || echo present)"

# ── 1. Make sure Docker is actually running ──────────────────────────────────
step "1. Verifying Docker daemon is up"
if ! docker info >/dev/null 2>&1; then
  warn "Docker isn't running. Start Docker Desktop, wait for it to go green, then re-run."
  open -a Docker || true
  exit 1
fi
bold "  Docker daemon reachable ✔"

# ── 2. Enable the servers (default profile) ──────────────────────────────────
# Mirrors the primary machine. Edit this list to taste.
step "2. Enabling MCP servers on the 'default' profile"
DEFAULT_SERVERS=(
  atlassian
  awslabs-cloudwatch
  awslabs-cloudwatch-appsignals
  context7
  fetch
  filesystem
  gemini-api-docs
  git
  github-chat
  github-official
  markdownify
  memory
  npm-sentinel
  playwright
  playwright-mcp-server
  sentry-remote
  sequentialthinking
  youtube_transcript
)
docker mcp profile server add default "${DEFAULT_SERVERS[@]}"
bold "  Enabled: ${DEFAULT_SERVERS[*]}"
echo
docker mcp profile server ls

# ── 3. Secrets — these do NOT transfer from the other Mac ────────────────────
# Secrets live in the macOS Keychain on each machine. Set them here once.
# Re-run any line as needed; value is read from stdin so it won't hit shell history.
step "3. Secrets (set the ones you use; skip with Ctrl-D)"
warn "These are stored in this Mac mini's keychain. They were NOT copied from your laptop."
set_secret() {
  local key="$1" label="$2"
  read -r -s -p "  ${label} (Enter to skip): " val; echo
  if [[ -n "${val}" ]]; then
    printf '%s' "${val}" | docker mcp secret set "${key}"
    bold "    set ${key}"
  else
    echo "    skipped ${key}"
  fi
}
set_secret github.personal_access_token        "GitHub PAT"
set_secret github-chat.api_key                 "github-chat API key"
set_secret atlassian.jira.api_token            "Jira API token"
set_secret atlassian.jira.personal_token       "Jira personal token"
set_secret atlassian.confluence.api_token      "Confluence API token"
set_secret atlassian.confluence.personal_token "Confluence personal token"
echo
warn "OAuth-based servers (atlassian-remote, sentry-remote, github official OAuth) must be"
warn "re-authorized interactively on THIS machine:  docker mcp oauth authorize <name>"

# ── 4. Connect Claude Code to the gateway (the easy way) ─────────────────────
step "4. Wiring Claude Code to the Docker MCP gateway"
docker mcp client connect claude-code
# Equivalent manual form (stdio, no url/auth):
#   claude mcp add MCP_DOCKER -- docker mcp gateway run
bold "  Connected. Verify with: claude mcp list"

# ── 5. Make it survive reboots (mostly manual / GUI) ─────────────────────────
step "5. 24/7 survival checklist (do these once, by hand)"
cat <<'EOF'
  Docker Desktop must be running for the gateway to work, and that needs a
  logged-in GUI session. SSH alone is not enough. Configure:

  a) AUTO-LOGIN after reboot:
     System Settings > Users & Groups > Automatic login > <this user>
     (Disable FileVault, or auto-login won't run until you type the disk password.)

  b) DOCKER DESKTOP autostart:
     Docker Desktop > Settings > General >
       [x] Start Docker Desktop when you sign in
       [x] (optional) Open Docker Dashboard at startup  -> leave OFF for headless

  c) PREVENT SLEEP (so the box stays reachable 24/7):
       sudo pmset -a sleep 0 disablesleep 1 womp 1
       sudo systemsetup -setcomputersleep Never

  d) KEYCHAIN: auto-login keeps the login keychain unlocked, which is what lets
     `docker mcp secret` read your tokens unattended. If you lock the screen
     manually the keychain stays unlocked; a full logout will re-lock it.
EOF

step "Done."
bold "Sanity check:  claude mcp list   (look for: MCP_DOCKER: docker mcp gateway run - Connected)"
