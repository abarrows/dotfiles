#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# connect-hermes-mcp.sh
# Wire the Hermes Agent to the Docker Desktop MCP Toolkit gateway.
#
# Adds ONE stdio MCP server entry — MCP_DOCKER — to ~/.hermes/config.yaml that
# spawns `docker mcp gateway run --profile <profile>`. That single entry
# multiplexes every MCP server enabled in the machine's Docker MCP Toolkit,
# the same shape (and name) Claude Code already uses for its MCP_DOCKER entry.
#
# Why the gateway and not per-server wiring: the Toolkit (registry + Keychain)
# stays the single source of truth for WHICH servers exist and for their
# secrets. `docker mcp gateway run` watches for Toolkit changes by default
# (--watch) and reads secret values from Docker Desktop's Keychain store
# (--secrets docker-desktop) — secret values never touch Hermes config, this
# repo, or git. Add/remove a server in the Toolkit and the gateway picks it up;
# a Hermes session sees the new set on its next connect (Hermes also honors
# MCP tools/list_changed notifications for live sessions).
#
# Why NOT `hermes mcp add`: that command is interactive (security probe + a
# tty tool-selection checklist) and would hang a piped, zero-touch
# `./install-profile ai`. Instead the entry is upserted through Hermes' own
# config API (hermes_cli.mcp_config._save_mcp_server) via the Python
# interpreter Hermes ships — same validation, locking, and atomic write as the
# CLI, no interactivity, no extra dependency (no yq required).
#
# Idempotent: identical entry → no-op; missing/stale → insert/update in place.
# Rollback:  `hermes mcp remove MCP_DOCKER` — touches nothing else.
#
# Usage: connect-hermes-mcp.sh [--soft] [--dry-run]
#   --soft     onboarding mode: a missing prerequisite warns and exits 0 so the
#              Hermes install never fails on this step; re-run later.
#   --dry-run  show what would change without writing anything.
#   MCP_PROFILE=<id>  pin the gateway to a Toolkit profile (default: default —
#              the profile Docker Desktop manages; see `docker mcp profile ls`).
#   HERMES_TEST_TIMEOUT=<secs>  cap on the live gateway connect test (default:
#              180). A hung gateway must never stall a zero-touch install.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# launchd / piped installs run with a minimal PATH; resolve user-local tools.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
step() { printf '\n\033[1;36m▶ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*"; }

# macOS has no GNU timeout by default; perl (always present) is the fallback.
run_with_timeout() {
  local secs="$1"; shift
  if command -v timeout >/dev/null 2>&1; then timeout "$secs" "$@"
  elif command -v gtimeout >/dev/null 2>&1; then gtimeout "$secs" "$@"
  else perl -e 'alarm shift; exec @ARGV' "$secs" "$@"
  fi
}

SERVER_NAME="MCP_DOCKER"
MCP_PROFILE="${MCP_PROFILE:-default}"
HERMES_AGENT_DIR="${HERMES_AGENT_DIR:-$HOME/.hermes/hermes-agent}"

SOFT=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --soft) SOFT=1 ;;
    --dry-run) DRY_RUN=1 ;;
    *) warn "unknown flag: $arg (usage: connect-hermes-mcp.sh [--soft] [--dry-run])"; exit 2 ;;
  esac
done

soft_fail() {
  warn "$1"
  [[ $SOFT -eq 1 ]] && { warn "(--soft) skipping Hermes⇄MCP-Toolkit wiring; install continues."; exit 0; }
  exit 1
}

step "Preflight: docker + MCP Toolkit + hermes"
command -v docker >/dev/null 2>&1 \
  || soft_fail "docker CLI not found — install Docker Desktop, then re-run this script."
DOCKER_BIN="$(command -v docker)"
docker mcp --version >/dev/null 2>&1 \
  || soft_fail "'docker mcp' CLI plugin missing — enable the MCP Toolkit in Docker Desktop settings."
command -v hermes >/dev/null 2>&1 \
  || soft_fail "hermes not on PATH — run install-hermes-agent.sh first."
HERMES_PY="${HERMES_AGENT_DIR}/venv/bin/python"
[[ -x "$HERMES_PY" ]] \
  || soft_fail "Hermes venv python not found at ${HERMES_PY} — is the Hermes install complete?"

# The wiring is written even when the Docker daemon is down — the entry simply
# activates on the next Hermes session once Docker Desktop is running. Only the
# live verification below needs the daemon.
DAEMON_UP=1
if ! docker info >/dev/null 2>&1; then
  DAEMON_UP=0
  warn "Docker Desktop is not running. Writing the wiring anyway — start Docker"
  warn "Desktop (wait for the green whale), and the gateway connects on the next"
  warn "Hermes session. Live verification is skipped for now."
fi

if [[ "$MCP_PROFILE" != "default" ]]; then
  docker mcp profile show "$MCP_PROFILE" >/dev/null 2>&1 \
    || soft_fail "MCP Toolkit profile '${MCP_PROFILE}' does not exist (see: docker mcp profile ls)."
fi

# Full docker path in `command`: Hermes may run under launchd (mac-mini) whose
# minimal environment has no /usr/local or /opt/homebrew on PATH — a bare
# `docker` would fail to spawn there. An absolute path works in both worlds.
bold "  server : ${SERVER_NAME}"
bold "  spawns : ${DOCKER_BIN} mcp gateway run --profile ${MCP_PROFILE}"

step "Upserting ${SERVER_NAME} into ~/.hermes/config.yaml (via Hermes' own config API)"
UPSERT_RESULT="$(cd "$HERMES_AGENT_DIR" && "$HERMES_PY" - "$SERVER_NAME" "$DOCKER_BIN" "$MCP_PROFILE" "$DRY_RUN" <<'PYEOF'
import sys

name, docker_bin, profile = sys.argv[1], sys.argv[2], sys.argv[3]
dry_run = sys.argv[4] == "1"
# Same key set `hermes mcp add` writes for a stdio server (env omitted when
# empty). No tool-filter key exists at this level — a bare entry registers
# every tool the gateway exposes, which is what we want: the gateway already
# gates the server set.
desired = {
    "command": docker_bin,
    "args": ["mcp", "gateway", "run", "--profile", profile],
}

# Underscore-private Hermes internals: a `hermes update` could rename these.
# If this step starts failing after an update, check hermes_cli/mcp_config.py
# for the current add/save entry points.
from hermes_cli.mcp_config import _get_mcp_servers, _save_mcp_server

existing = _get_mcp_servers().get(name)
if existing == desired:
    print("UNCHANGED — already wired exactly like this; nothing written.")
elif dry_run:
    action = "UPDATE (stale entry)" if existing else "INSERT"
    print(f"DRY-RUN — would {action}: mcp_servers.{name} = {desired}")
else:
    # _save_mcp_server runs Hermes' own security validation, takes the config
    # lock, and writes atomically — identical code path to `hermes mcp add`.
    if not _save_mcp_server(name, desired):
        sys.exit(3)
    print(("UPDATED (was stale)" if existing else "INSERTED") + f" — mcp_servers.{name}")
PYEOF
)" || soft_fail "Hermes config upsert failed (rejected or errored — see output above)."
bold "  ${UPSERT_RESULT}"

if [[ $DRY_RUN -eq 1 ]]; then
  bold "✔ Dry run complete — nothing written."
  exit 0
fi

# ── Verify gate ──────────────────────────────────────────────────────────────
# Best-effort under --soft; loud otherwise. Never silence a broken connection
# (no `hermes -z`): a failure here must be visible.
VERIFY_OK=1

step "Verifying: Hermes lists the server"
if hermes mcp list 2>/dev/null | grep -q "$SERVER_NAME"; then
  bold "  hermes mcp list: ${SERVER_NAME} present"
else
  warn "hermes mcp list does not show ${SERVER_NAME}"
  VERIFY_OK=0
fi

if [[ $DAEMON_UP -eq 1 ]]; then
  step "Verifying: live gateway connect (hermes mcp test ${SERVER_NAME})"
  # Capped: --soft protects against failure but not against hanging, and an
  # unbounded stall here would freeze a piped `./install-profile ai`.
  if run_with_timeout "${HERMES_TEST_TIMEOUT:-180}" hermes mcp test "$SERVER_NAME"; then
    SERVER_COUNT="$(docker mcp profile show "$MCP_PROFILE" 2>/dev/null | grep -c '^    - type:' || true)"
    bold "  gateway OK — Toolkit profile '${MCP_PROFILE}' currently has ${SERVER_COUNT:-?} servers behind it"
  else
    RC=$?
    if [[ $RC -eq 124 || $RC -eq 142 ]]; then
      warn "hermes mcp test ${SERVER_NAME} timed out after ${HERMES_TEST_TIMEOUT:-180}s — entry written, gateway not confirmed."
    else
      warn "hermes mcp test ${SERVER_NAME} failed — the entry is written but the gateway did not connect."
    fi
    VERIFY_OK=0
  fi

  # OAuth-backed Toolkit servers are authorized per machine, by design. List
  # any that still need a one-time interactive grant (the only manual gate).
  UNAUTH="$(docker mcp oauth ls 2>/dev/null | awk -F'|' '/not authorized/ {gsub(/ /,"",$1); print $1}' || true)"
  if [[ -n "$UNAUTH" ]]; then
    step "Manual gate: OAuth servers not yet authorized on this machine"
    while IFS= read -r srv; do
      warn "  docker mcp oauth authorize ${srv}"
    done <<< "$UNAUTH"
    warn "(Only needed if you use those servers' tools — everything else works now.)"
  fi
fi

if [[ $VERIFY_OK -eq 1 && $DAEMON_UP -eq 1 ]]; then
  bold "✔ Hermes is connected to the Docker MCP Toolkit (profile: ${MCP_PROFILE})."
  bold "  Toolkit changes flow through automatically; a running Hermes session"
  bold "  picks them up on reconnect (or: hermes mcp test ${SERVER_NAME})."
  bold "  Rollback: hermes mcp remove ${SERVER_NAME}"
elif [[ $VERIFY_OK -eq 1 ]]; then
  # Daemon down: the wiring is in place but nothing has actually connected yet —
  # don't claim it has.
  bold "✔ Wiring written (profile: ${MCP_PROFILE}) — live verification deferred."
  bold "  Start Docker Desktop, then confirm with: hermes mcp test ${SERVER_NAME}"
  bold "  Rollback: hermes mcp remove ${SERVER_NAME}"
else
  [[ $SOFT -eq 1 ]] && { warn "(--soft) verification incomplete — re-run this script once Docker/Hermes are healthy."; exit 0; }
  soft_fail "verification failed — see warnings above."
fi
