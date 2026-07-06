#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# provision-coding-harness.sh
# Stand up the local AI coding harness: Ollama (local models) behind Hermes,
# with rs-agents skills synced in. Idempotent + re-runnable.
#
#   bash provision-coding-harness.sh [--dry-run] [--enable-service]
#
#   --dry-run         print what would happen, change nothing
#   --enable-service  install the always-on launchd Ollama unit even off a mini
#
# Model is chosen by RAM (both need tool-calling + >=64K context for Hermes):
#   >=32 GB (mac-mini / always-on)  -> llama3.1:8b   (native 128K, true 64K)
#   <32 GB  (laptop)                -> qwen2.5-coder:7b (32K, lifted via knobs)
#
# The always-on launchd service is installed only on a >=32 GB box (or with
# --enable-service): a KeepAlive model resident 24/7 would starve a 16 GB laptop.
# See OLLAMA-HERMES-RUNBOOK.md for the why behind every step.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# Onboarding + launchd runs often lack Homebrew on PATH; make brew-installed and
# user-local tools (ollama, hermes) resolve on both Apple-silicon and Intel Macs.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

DRY=0; ENABLE_SERVICE=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --enable-service) ENABLE_SERVICE=1 ;;
    *) echo "unknown arg: $a"; exit 2 ;;
  esac
done

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
step() { printf '\n\033[1;36m▶ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*"; }
run()  { if [[ $DRY -eq 1 ]]; then printf '   [dry-run] %s\n' "$*"; else eval "$*"; fi; }

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OLLAMA_BIN="${OLLAMA_BIN:-$(command -v ollama || true)}"
HERMES_PY="${HERMES_PY:-$HOME/.hermes/hermes-agent/venv/bin/python}"
RAM_GB=$(( $(sysctl -n hw.memsize) / 1073741824 ))

# ── 0. Prereqs ───────────────────────────────────────────────────────────────
step "0. Prerequisites (RAM=${RAM_GB} GB)"
[[ -n "$OLLAMA_BIN" && -x "$OLLAMA_BIN" ]] || { warn "ollama not installed — 'brew install ollama' (or run the Brewfile)."; exit 1; }
command -v hermes >/dev/null      || { warn "hermes not installed — run onboarding_bin/install-hermes-agent.sh first."; exit 1; }
[[ -x "$HERMES_PY" ]]             || { warn "Hermes venv python not found at $HERMES_PY — re-run onboarding_bin/install-hermes-agent.sh (or set HERMES_PY)."; exit 1; }
bold "  ollama: $("$OLLAMA_BIN" --version 2>/dev/null | head -1)"
bold "  hermes: $(hermes --version 2>/dev/null | head -1)"

if (( RAM_GB >= 32 )); then MODEL="llama3.1:8b"; else MODEL="qwen2.5-coder:7b"; fi
SMOKE="llama3.2:3b"
bold "  chosen default model: ${MODEL}   (smoke: ${SMOKE})"

# ── 1. Ollama service ────────────────────────────────────────────────────────
step "1. Ollama server"
PLIST="$HERE/com.retailsuccess.ollama.plist"
DEST_PLIST="$HOME/Library/LaunchAgents/com.retailsuccess.ollama.plist"
if (( RAM_GB >= 32 || ENABLE_SERVICE == 1 )); then
  bold "  installing always-on launchd unit (perf env vars baked in)"
  run "cp '$PLIST' '$DEST_PLIST'"
  run "launchctl unload '$DEST_PLIST' 2>/dev/null || true"
  run "launchctl load -w '$DEST_PLIST'"
else
  warn "  laptop (<32 GB): skipping always-on service. Starting Ollama on-demand for this run."
  if ! curl -s --max-time 3 http://localhost:11434/api/tags >/dev/null 2>&1; then
    run "OLLAMA_FLASH_ATTENTION=1 OLLAMA_KV_CACHE_TYPE=q8_0 OLLAMA_CONTEXT_LENGTH=65536 nohup '$OLLAMA_BIN' serve >/tmp/ollama.out.log 2>&1 &"
    [[ $DRY -eq 0 ]] && sleep 4
  fi
fi
[[ $DRY -eq 0 ]] && { curl -s --max-time 5 http://localhost:11434/api/tags >/dev/null && bold "  Ollama API up ✔" || warn "  Ollama API not responding yet"; }

# ── 2. Pull models ───────────────────────────────────────────────────────────
step "2. Pull models (sized to RAM)"
for m in "$MODEL" "$SMOKE"; do
  if [[ $DRY -eq 0 ]] && "$OLLAMA_BIN" list 2>/dev/null | grep -q "^${m}[[:space:]]"; then
    bold "  ${m} already present"
  else
    run "'$OLLAMA_BIN' pull '$m'"
  fi
done

# ── 3. Configure Hermes -> Ollama (idempotent, preserves comments) ───────────
step "3. Point Hermes at Ollama (model + 64K context knobs)"
run "cp -p '$HOME/.hermes/config.yaml' '$HOME/.hermes/config.yaml.bak-provision' 2>/dev/null || true"
if [[ $DRY -eq 1 ]]; then
  printf '   [dry-run] set model.default=%s, provider=custom, base_url=localhost:11434/v1, context_length=65536, ollama_num_ctx=65536\n' "$MODEL"
else
  "$HERMES_PY" - "$MODEL" <<'PY'
import sys, os
model = sys.argv[1]
p = os.path.expanduser("~/.hermes/config.yaml")
block = {"default": model, "provider": "custom",
         "base_url": "http://localhost:11434/v1",
         "context_length": 65536, "ollama_num_ctx": 65536}
try:
    from ruamel.yaml import YAML            # preserves comments
    yaml = YAML()
    with open(p) as f: data = yaml.load(f)
    data["model"] = block
    with open(p, "w") as f: yaml.dump(data, f)
    print("  config.yaml updated (ruamel, comments preserved)")
except Exception:
    import yaml as pyyaml                    # fallback: comments lost (backup exists)
    with open(p) as f: data = pyyaml.safe_load(f)
    data["model"] = block
    with open(p, "w") as f: pyyaml.safe_dump(data, f, sort_keys=False)
    print("  config.yaml updated (pyyaml; comments not preserved — see .bak-provision)")
PY
fi

# ── 4. Ensure the rs-agents Claude Code plugin (the sync SOURCE) ─────────────
step "4. Ensure rs-agents Claude Code plugin (source-of-truth channel)"
run "bash '$HERE/../onboarding_bin/install-claude-plugins.sh'"

# ── 5. Sync rs-agents skills into Hermes (the bridge) ────────────────────────
step "5. Sync rs-agents skills into Hermes"
run "bash '$HERE/sync-rs-agents-to-hermes.sh' --soft"

# ── 6. Keep Hermes in sync — launchd timer re-runs the sync (login + hourly) ─
# The clean-rebuild sync mirrors the plugin cache, so add/modify/DELETE all
# propagate. Cheap + idempotent, so it runs on both laptop and mini.
step "6. Install the rs-agents -> Hermes auto-resync timer"
SYNC_PLIST="$HOME/Library/LaunchAgents/com.retailsuccess.rs-agents-sync.plist"
if [[ $DRY -eq 1 ]]; then
  printf '   [dry-run] write + load %s (RunAtLoad + hourly: bash %s --soft)\n' "$SYNC_PLIST" "$HERE/sync-rs-agents-to-hermes.sh"
else
  cat > "$SYNC_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict>
  <key>Label</key><string>com.retailsuccess.rs-agents-sync</string>
  <key>ProgramArguments</key><array>
    <string>/bin/bash</string><string>$HERE/sync-rs-agents-to-hermes.sh</string><string>--soft</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>StartInterval</key><integer>3600</integer>
  <key>StandardOutPath</key><string>/tmp/rs-agents-sync.out.log</string>
  <key>StandardErrorPath</key><string>/tmp/rs-agents-sync.err.log</string>
</dict></plist>
PLIST
  launchctl unload "$SYNC_PLIST" 2>/dev/null || true
  launchctl load -w "$SYNC_PLIST"
  bold "  auto-resync installed (hourly + on login). Disable: launchctl unload $SYNC_PLIST"
fi

# ── 7. Health check ──────────────────────────────────────────────────────────
step "7. Verify the harness"
run "bash '$HERE/verify-ollama-hermes.sh' '$MODEL'"

printf '\n'; bold "✔ Coding harness provisioned. Default model: ${MODEL}. Talk to it with: hermes -z \"...\""
