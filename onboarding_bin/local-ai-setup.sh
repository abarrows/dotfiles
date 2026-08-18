#!/bin/bash
# local-ai-setup.sh — Retail Success AI bootstrap (public loader).
#
# Destined for abarrows/dotfiles: onboarding_bin/local-ai-setup.sh (branch: production).
# Run via:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abarrows/dotfiles/production/onboarding_bin/local-ai-setup.sh)"
#
# Thin by design: installs the apps and the Retail Success plugin, then hands
# off to the setup.sh that ships INSIDE the plugin (rides plugin autoUpdate).
# Standalone (curl-able): no repo-relative sourcing. Idempotent throughout.

set -u

BOLD=$(tput bold 2>/dev/null || true); RESET=$(tput sgr0 2>/dev/null || true)
step() { printf '\n%s==> %s%s\n' "$BOLD" "$*" "$RESET"; }
ok()   { printf '  ✔ %s\n' "$*"; }
warn() { printf '  ⚠ %s\n' "$*" >&2; }
die()  { printf '\n  ✖ %s\n' "$*" >&2; exit 1; }

# =============================================================== 1. guards ===
step "Checking this machine"

# Windows machines get the PowerShell loader (Chocolatey-based). Catch the
# common mistake of pasting this bash one-liner into Git Bash or WSL.
windows_redirect() {
  cat >&2 <<'TXT'

  ✖ This looks like a Windows machine. This bash loader targets macOS only —
    the apps must install on the Windows side. Open PowerShell **as
    administrator** (not Git Bash / WSL) and run the Windows one-liner:

      irm https://raw.githubusercontent.com/abarrows/dotfiles/production/onboarding_bin/local-ai-setup.ps1 | iex
TXT
  exit 1
}
case "$(uname -s)" in
  Darwin) : ;;
  MINGW*|MSYS*|CYGWIN*) windows_redirect ;;
  Linux) grep -qi microsoft /proc/version 2>/dev/null && windows_redirect
         die "macOS or Windows only. For other platforms, ask in the AI rollout channel." ;;
  *) die "macOS or Windows only. For other platforms, ask in the AI rollout channel." ;;
esac

[ "$(id -u)" -ne 0 ] || die "Don't run as root/sudo — Homebrew refuses root. Run as yourself; you'll be prompted when needed."

if ! groups | grep -qw admin; then
  cat >&2 <<'TXT'

  ✖ This account is not a macOS administrator, and installs need admin rights.
    → Ask IT to grant temporary admin, or have an admin run this command for
      you, then re-run it yourself (it's safe to run twice).
TXT
  exit 1
fi
ok "admin account"

ARCH=$(uname -m)
if [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = "1" ]; then ARCH="x86_64"; fi # Rosetta lies about arm64
INTEL=0
if [ "$ARCH" = "x86_64" ]; then
  INTEL=1
  cat >&2 <<'TXT'

  ⚠⚠  INTEL MAC DETECTED  ⚠⚠
  The company setup targets Apple Silicon. Continuing best-effort: everything
  should install, but Docker Desktop and local AI performance will be
  noticeably worse. Flag your machine in the AI rollout channel for the
  hardware refresh list.
TXT
else
  ok "Apple Silicon"
fi

# Floor pinned from cask requirements at authoring time (Docker Desktop + Warp
# require ≥ 13; re-verify with `brew info --cask` when bumping). Override:
# RS_AI_SETUP_MIN_MACOS=12 ./local-ai-setup.sh
MIN_MACOS="${RS_AI_SETUP_MIN_MACOS:-13}"
MACOS_MAJOR=$(sw_vers -productVersion | cut -d. -f1)
[ "$MACOS_MAJOR" -ge "$MIN_MACOS" ] || die "macOS $MACOS_MAJOR too old (need ≥ $MIN_MACOS). Update via System Settings → General → Software Update, then re-run."
ok "macOS $(sw_vers -productVersion)"

curl -fsSL --max-time 10 -o /dev/null https://raw.githubusercontent.com \
  || die "Can't reach github. Check network/VPN and re-run."
ok "network reachable"

# ============================================================= 2. installs ===
step "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then ok "already installed"; else
  xcode-select --install 2>/dev/null || true
  echo "  Waiting for the CLT installer to finish (accept the dialog)…"
  until xcode-select -p >/dev/null 2>&1; do sleep 10; done
  ok "installed"
fi

step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || die "Homebrew install failed."
fi
# Put brew on PATH for this run (Apple Silicon vs Intel prefix).
if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
if [ -x /usr/local/bin/brew ];    then eval "$(/usr/local/bin/brew shellenv)"; fi
command -v brew >/dev/null 2>&1 || die "brew not on PATH after install — open a new terminal and re-run."
ok "$(brew --version | head -1)"

step "Apps (only what's missing)"
brew_formula() { brew list --formula "$1" >/dev/null 2>&1 && ok "$1 (present)" || { brew install "$1" && ok "$1 installed" || warn "$1 failed to install"; }; }
brew_cask()    { brew list --cask "$1"    >/dev/null 2>&1 && ok "$1 (present)" || { brew install --cask "$1" && ok "$1 installed" || warn "$1 failed to install"; }; }
brew_formula gh
brew_cask claude              # desktop app
brew_cask claude-code         # CLI
brew_cask docker-desktop
brew_cask warp
brew_cask visual-studio-code

if command -v code >/dev/null 2>&1; then
  if code --list-extensions 2>/dev/null | grep -qi '^anthropic.claude-code$'; then
    ok "VS Code Claude extension (present)"
  else
    code --install-extension anthropic.claude-code >/dev/null 2>&1 && ok "VS Code Claude extension installed" || warn "VS Code extension install failed — install 'Claude Code' from the marketplace manually"
  fi
else
  warn "code CLI not on PATH — in VS Code run 'Shell Command: Install code in PATH', then re-run"
fi

# =============================================================== 3. gates ====
step "GitHub auth"
if gh auth status >/dev/null 2>&1; then ok "gh authenticated"; else
  echo "  Opening GitHub login (choose HTTPS + browser)…"
  gh auth login || die "GitHub auth is required for the private plugin repo. Re-run after 'gh auth login' succeeds."
fi

step "Docker Desktop + MCP Toolkit"
if ! docker info >/dev/null 2>&1; then
  open -a Docker || die "Could not open Docker Desktop."
  echo "  Waiting for the Docker daemon (accept the first-run dialogs)…"
  for _ in $(seq 1 60); do docker info >/dev/null 2>&1 && break; sleep 3; done
  docker info >/dev/null 2>&1 || die "Docker daemon never came up. Finish Docker Desktop first-run setup, then re-run."
fi
ok "docker daemon running"
docker mcp --help >/dev/null 2>&1 || die "'docker mcp' unavailable — update Docker Desktop (≥ 4.42) / enable the MCP Toolkit, then re-run."
ok "MCP Toolkit available"

# ============================================================== 4. plugin ====
step "Retail Success Claude plugin"
command -v claude >/dev/null 2>&1 || die "claude CLI missing after install — open a new terminal and re-run."
# CLAUDECODE='' : the plugin CLI refuses to run nested inside a Claude session.
CLAUDECODE='' claude plugin marketplace add Retail-Success/Wayroo.tools >/dev/null 2>&1 || true # idempotent: errors if present
if CLAUDECODE='' claude plugin install rs-agents@retailsuccess >/dev/null 2>&1; then
  ok "rs-agents@retailsuccess"
elif CLAUDECODE='' claude plugin install rs-agents@wayroo >/dev/null 2>&1; then
  ok "rs-agents@wayroo (fallback marketplace name)"
elif CLAUDECODE='' claude plugin list 2>/dev/null | grep -q 'rs-agents'; then
  ok "rs-agents already installed"
else
  die "Could not install the rs-agents plugin. Run 'claude plugin marketplace add Retail-Success/Wayroo.tools' then 'claude plugin install rs-agents@retailsuccess' manually."
fi

# ============================================================= 5. handoff ====
step "Handing off to the plugin's setup.sh (MCP wiring + settings)"
# Name-agnostic glob over the plugin cache — layout varies across CLI versions.
SETUP_SH=$(ls -t "$HOME"/.claude/plugins/*/*/skills/local-ai-setup/setup.sh \
                 "$HOME"/.claude/plugins/*/skills/local-ai-setup/setup.sh \
                 2>/dev/null | head -1)
if [ -n "${SETUP_SH:-}" ] && [ -f "$SETUP_SH" ]; then
  ok "found $SETUP_SH"
  bash "$SETUP_SH" || warn "setup.sh reported issues — see output above; re-run any time with: bash \"$SETUP_SH\""
else
  cat >&2 <<'TXT'
  ⚠ Could not locate the plugin's setup.sh in ~/.claude/plugins.
    Recovery: open a terminal, run `claude`, then type /local-ai-setup —
    the skill will locate and run its own setup script.
TXT
fi

# ============================================================= 6. wrap-up ====
step "Final check"
claude doctor || warn "claude doctor reported problems (see above)"
cat <<TXT

  ── Done ──────────────────────────────────────────────────────────────
  Installed/verified: Claude desktop, Claude Code (CLI + VS Code), Docker
  Desktop (MCP Toolkit), Warp, VS Code, gh, rs-agents plugin.
  Next: open Warp, cd into any repo, run: claude   →  then try /local-ai-setup
  for the guided tour. Re-run this one-liner any time; it only fixes gaps.
$( [ "$INTEL" -eq 1 ] && echo "  Reminder: Intel Mac — flag for hardware refresh." )
TXT
