#!/usr/bin/env bash
#
# onboard.sh — one-shot machine provisioning orchestrator.
#
# GOAL
#   Take a bare macOS machine to a fully provisioned dev environment with the
#   fewest possible manual steps. A true "one shot" is not achievable: a handful
#   of gates are interactive by design and cannot be scripted away —
#     1. sudo password (Homebrew install + chown of the brew prefix)
#     2. Xcode Command Line Tools GUI dialog (must be clicked + downloads)
#     3. `gh auth login` (browser / device identity)
#     4. GPG passphrase entry (pinentry dialog — protects your signing key)
#   SSH + GPG PUBLIC keys are uploaded to GitHub automatically via `gh` (it falls
#   back to printing the key + opening the settings page only if the gh token
#   lacks key-write scope).
#   Everything else is automated and sequenced here. This script collapses the
#   ~10-step README flow into: run one command, answer the gates above.
#
# USAGE
#   Remote bootstrap (bare machine, repo not yet cloned):
#     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abarrows/dotfiles/production/onboarding_bin/onboard.sh)" -- [stack]
#
#   Local (already inside the dotfiles repo):
#     ./onboarding_bin/onboard.sh [stack]
#
#   stack (optional): react | ruby | devops    (the `base` profile is always
#   installed first; the stack profile, if given, is installed on top.)
#
# SAFETY
#   Re-running is safe. Every step detects prior completion and skips. The
#   script never deletes existing keys, .envrc, or repos.

set -uo pipefail

# ----------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------
STEP=0
log()  { printf '\n\033[1;34m▶ %s\033[0m\n' "$*"; }
step() { STEP=$((STEP + 1)); printf '\n\033[1;36m━━ Step %s: %s ━━\033[0m\n' "$STEP" "$*"; }
ok()   { printf '   \033[0;32m✓ %s\033[0m\n' "$*"; }
warn() { printf '   \033[0;33m⚠ %s\033[0m\n' "$*"; }
die()  { printf '\n\033[0;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

# Read interactively even when this script is piped from `curl | bash`.
ask() { # ask <prompt-var-assignment-name> <prompt-text> [default]
  local __var="$1" __prompt="$2" __default="${3:-}" __input=""
  if [[ -r /dev/tty ]]; then
    read -rp "$__prompt" __input </dev/tty || true
  else
    read -rp "$__prompt" __input || true
  fi
  printf -v "$__var" '%s' "${__input:-$__default}"
}

STACK="${1:-}"
MANUAL_ACTIONS=()

# ----------------------------------------------------------------------------
# Step 5a — Collect machine variables BEFORE resolve_repo so CURRENT_COMPANY
#            is set correctly before the clone-path decision.  On re-runs this
#            is a no-op (sources the existing .envrc and returns immediately).
#            Writes to ~/.envrc; ensure_envrc (post-clone) moves it into
#            $REPO_DIR and sources it as the authoritative copy.
# ----------------------------------------------------------------------------

# Global scratch vars (NOT local) so ask()'s printf -v assignment propagates back.
_CMV_EMAIL="" _CMV_NAME="" _CMV_USER="" _CMV_GITHUB="" _CMV_COMPANY=""
_CMV_IDE="" _CMV_JIRA_URL="" _CMV_GPG="" _CMV_JIRA_EMAIL=""

collect_machine_vars() {
  # Running from inside the repo already?  Source the repo's .envrc if valid.
  local here; here="$(cd "$(dirname "${BASH_SOURCE[0]:-}")/.." 2>/dev/null && pwd)"
  if [[ -n "$here" && -f "$here/install-profile" && -d "$here/meta" ]]; then
    if [[ -f "$here/.envrc" ]] && envrc_is_sourceable "$here/.envrc"; then
      set -a; . "$here/.envrc"; set +a
      ok "Machine variables loaded from repo .envrc (re-run)"
      return
    fi
  fi

  # ~/.envrc written by a prior bootstrap run?  Adopt it.
  if [[ -f "$HOME/.envrc" ]] && envrc_is_sourceable "$HOME/.envrc"; then
    set -a; . "$HOME/.envrc"; set +a
    ok "Machine variables loaded from existing ~/.envrc"
    return
  fi

  # First run: prompt, write ~/.envrc, source it so CURRENT_COMPANY is available
  # to resolve_repo immediately below.
  log "Collecting machine variables (needed before cloning the dotfiles repo)..."

  _CMV_EMAIL="${GIT_EMAIL_ADDRESS_PROFESSIONAL:-}"
  _CMV_NAME="${CURRENT_NAME:-}"
  _CMV_USER="${CURRENT_USER:-$USER}"
  _CMV_GITHUB="${CURRENT_USER_GITHUB_URL:-https://github.com/$USER}"
  # Hardcode the company default: ignoring any stale CURRENT_COMPANY in the calling
  # shell is the whole point of this fix — "Retail-Success" is always the correct
  # answer for this repo's onboarding.
  _CMV_COMPANY="Retail-Success"
  # Default to "code" (VS Code CLI); normalise any stale "vscode" value.
  _CMV_IDE="${IDE_PATH:-code}"
  [[ "$_CMV_IDE" == "vscode" ]] && _CMV_IDE="code"
  _CMV_JIRA_URL="${JIRA_BASE_URL:-}"
  _CMV_GPG="${CURRENT_USER_GPG_KEY:-}"
  _CMV_JIRA_EMAIL="${JIRA_USER_EMAIL:-}"

  ask _CMV_EMAIL      "Enter your git email [$_CMV_EMAIL]: "                      "$_CMV_EMAIL"
  ask _CMV_NAME       "Enter your name [$_CMV_NAME]: "                            "$_CMV_NAME"
  ask _CMV_USER       "Enter your username [$_CMV_USER]: "                        "$_CMV_USER"
  ask _CMV_GITHUB     "Enter your GitHub URL [$_CMV_GITHUB]: "                    "$_CMV_GITHUB"
  ask _CMV_COMPANY    "Enter your company name [$_CMV_COMPANY]: "                 "$_CMV_COMPANY"
  ask _CMV_IDE        "Enter your IDE command (e.g. 'code') [$_CMV_IDE]: "        "$_CMV_IDE"
  ask _CMV_JIRA_URL   "Enter your JIRA Base URL [$_CMV_JIRA_URL]: "               "$_CMV_JIRA_URL"
  ask _CMV_GPG        "Enter your GPG key id (blank = none) [$_CMV_GPG]: "        "$_CMV_GPG"
  ask _CMV_JIRA_EMAIL "Enter your JIRA user email [$_CMV_JIRA_EMAIL]: "           "$_CMV_JIRA_EMAIL"

  # Normalise IDE_PATH in case the user typed "vscode".
  [[ "$_CMV_IDE" == "vscode" ]] && _CMV_IDE="code"

  # Write ~/.envrc with the full variable set from .envrc.example (JIRA_API_TOKEN
  # and GIT_EMAIL_ADDRESS_PERSONAL are intentionally left empty — set them manually
  # after onboarding completes, or let the dotbot security step handle them).
  cat > "$HOME/.envrc" <<ENVRC
# Dotfiles Environment Variables (Generated by onboard.sh)

# Sensitive Variables
export GIT_EMAIL_ADDRESS_PROFESSIONAL="$_CMV_EMAIL"
export CURRENT_USER_GPG_KEY="$_CMV_GPG"
export JIRA_API_TOKEN=""

# Non-Sensitive Variables
export CURRENT_NAME="$_CMV_NAME"
export CURRENT_USER="$_CMV_USER"
export CURRENT_USER_GITHUB_URL="$_CMV_GITHUB"
export CURRENT_COMPANY="$_CMV_COMPANY"
export IDE_PATH="$_CMV_IDE"
export JIRA_BASE_URL="$_CMV_JIRA_URL"
export JIRA_USER_EMAIL="$_CMV_JIRA_EMAIL"

# Optional Variables
export GIT_EMAIL_ADDRESS_PERSONAL=""
ENVRC

  set -a; . "$HOME/.envrc"; set +a
  ok "Machine variables written to ~/.envrc"
}

# ----------------------------------------------------------------------------
# Step 1 — Xcode Command Line Tools  (GATE: GUI dialog + download)
# ----------------------------------------------------------------------------
install_xcode_clt() {
  step "Xcode Command Line Tools"
  if xcode-select -p >/dev/null 2>&1; then
    ok "Already installed ($(xcode-select -p))"
    return
  fi
  warn "A macOS dialog will open — click 'Install' and accept the license."
  xcode-select --install >/dev/null 2>&1 || true
  log "Waiting for Command Line Tools to finish installing..."
  until xcode-select -p >/dev/null 2>&1; do sleep 15; done
  ok "Command Line Tools installed"
}

# ----------------------------------------------------------------------------
# Step 2 — Homebrew  (GATE: sudo password)
#
# CANONICAL Homebrew install logic. Mirrored (kept in sync) in
# install-homebrew.sh and pre-onboarding-script.sh — those two CANNOT source
# this one because both run in the curl|bash bootstrap path before the repo
# exists. If you change the install command here, update those two to match:
# native arm64 (no `arch -x86_64`) + NONINTERACTIVE=1.
# ----------------------------------------------------------------------------
install_homebrew() {
  step "Homebrew"
  local prefix
  if [[ "$(uname -m)" == "arm64" ]]; then prefix="/opt/homebrew"; else prefix="/usr/local"; fi

  if [[ -x "$prefix/bin/brew" || -x /usr/local/bin/brew || -x /opt/homebrew/bin/brew ]]; then
    ok "Already installed"
  else
    warn "Homebrew will prompt for your sudo password."
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      || die "Homebrew installation failed"
    ok "Homebrew installed"
  fi

  # Make brew available in THIS shell session.
  if [[ -x "$prefix/bin/brew" ]]; then
    eval "$("$prefix/bin/brew" shellenv)"
  fi
  command -v brew >/dev/null 2>&1 || die "brew not on PATH after install"
}

# ----------------------------------------------------------------------------
# Step 3 — Bootstrap packages needed before the repo / Brewfile run.
# ----------------------------------------------------------------------------
install_bootstrap_pkgs() {
  step "Bootstrap packages (git, gh, direnv, gnupg, pinentry-mac)"
  local pkg
  # gnupg + pinentry-mac are here (not just in Brewfile.base) so the GPG step's
  # interactive passphrase dialog works even if that step runs before/without a
  # full Brewfile pass.
  for pkg in git gh direnv gnupg pinentry-mac; do
    if brew list --formula "$pkg" >/dev/null 2>&1; then
      ok "$pkg present"
    else
      log "Installing $pkg..."
      brew install "$pkg" >/dev/null || warn "Could not install $pkg (continuing)"
    fi
  done
}

# ----------------------------------------------------------------------------
# Step 4 — GitHub auth  (GATE: browser/device login). Must precede clone.
# ----------------------------------------------------------------------------
ensure_gh_auth() {
  step "GitHub CLI authentication"
  if gh auth status >/dev/null 2>&1; then
    ok "Already authenticated"
    return
  fi
  warn "Opening GitHub login — follow the prompts (SSH key upload optional here)."
  if [[ -r /dev/tty ]]; then
    gh auth login </dev/tty || die "gh auth login did not complete"
  else
    gh auth login || die "gh auth login did not complete"
  fi
  ok "Authenticated with GitHub"
}

# ----------------------------------------------------------------------------
# Step 5 — Locate or clone the dotfiles repo.
# ----------------------------------------------------------------------------
REPO_DIR=""

# Bring an existing checkout up to date and CONTINUE — never abort the run.
# Safe by design: skips when the tree has uncommitted changes, and only ever
# fast-forwards (won't create merge commits or clobber local work). Any failure
# (offline, diverged, detached) just warns and proceeds with what's on disk.
update_checkout() {
  local dir="$1"
  if [[ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]]; then
    warn "Local changes present — leaving checkout as-is (run 'git pull' yourself if needed)."
    return
  fi
  log "Updating checkout (git pull --ff-only)..."
  if git -C "$dir" pull --ff-only >/dev/null 2>&1; then
    ok "Up to date"
  else
    warn "Could not fast-forward (offline or diverged) — continuing with the current checkout."
  fi
}

resolve_repo() {
  step "Dotfiles repository"

  # Already running from inside the repo?
  # ${BASH_SOURCE[0]:-} defaults to empty so `set -u` does not abort on the
  # curl|bash bootstrap path, where BASH_SOURCE is unset (then `here` is empty
  # and we fall through to the clone path, which is correct for that case).
  local here; here="$(cd "$(dirname "${BASH_SOURCE[0]:-}")/.." 2>/dev/null && pwd)"
  if [[ -n "$here" && -f "$here/install-profile" && -d "$here/meta" ]]; then
    REPO_DIR="$here"
    ok "Using existing checkout: $REPO_DIR"
    update_checkout "$REPO_DIR"
    return
  fi

  # Otherwise clone into the structured path.
  local company="${CURRENT_COMPANY:-Retail-Success}"
  local parent="$HOME/$company/repos/development-team"
  REPO_DIR="$parent/dotfiles"
  if [[ -d "$REPO_DIR/.git" ]]; then
    ok "Found existing clone: $REPO_DIR"
    update_checkout "$REPO_DIR"
    return
  fi
  mkdir -p "$parent"
  log "Cloning dotfiles into $REPO_DIR ..."
  gh repo clone abarrows/dotfiles "$REPO_DIR" || die "Clone failed (is gh authenticated?)"
  ok "Cloned"
}

# ----------------------------------------------------------------------------
# Step 6 — Machine variables (.envrc).  GATE only on first run (fill values).
# ----------------------------------------------------------------------------

# True when $1 sources cleanly. A malformed old-template file (e.g. a line like
# `VAR=# Your key here` — `VAR=#` then `Your` is parsed as a command) emits
# "command not found" to stderr; empty stderr means the file is safe to adopt.
# Sourced in a throwaway subshell so it can't pollute our environment.
envrc_is_sourceable() {
  [[ -f "$1" ]] || return 1
  local errout
  errout="$(bash -c "source '$1'" 2>&1 >/dev/null)" || true
  [[ -z "$errout" ]]
}

# Prompt for machine variables and write a clean .envrc to $1.
generate_envrc() {
  local target="$1"
  # collect_machine_vars may have already written ~/.envrc before the clone.
  # If so, move it into place rather than prompting the user a second time.
  if [[ -f "$HOME/.envrc" ]] && envrc_is_sourceable "$HOME/.envrc"; then
    mv "$HOME/.envrc" "$target"
    ok ".envrc moved from ~/ into repo"
    return
  fi
  local pre="$REPO_DIR/onboarding_bin/pre-onboarding-script.sh"
  if [[ -f "$pre" ]]; then
    # Delegate to pre-onboarding-script.sh: it prompts for each value and writes
    # a clean, `export`-style ~/.envrc (no malformed placeholders). ONBOARD_ORCHESTRATED
    # tells it to skip its brew/clone tail (onboard.sh already did both). We feed
    # /dev/tty so the prompts work even when this runs via `curl ... | bash`.
    log "Collecting your machine variables..."
    if [[ -r /dev/tty ]]; then
      ONBOARD_ORCHESTRATED=1 bash "$pre" </dev/tty || warn "pre-onboarding-script.sh reported errors (review above)"
    else
      ONBOARD_ORCHESTRATED=1 bash "$pre" || warn "pre-onboarding-script.sh reported errors (review above)"
    fi
    if [[ -f "$HOME/.envrc" ]] && envrc_is_sourceable "$HOME/.envrc"; then
      mv "$HOME/.envrc" "$target"
      ok ".envrc generated and saved into the repo"
    else
      warn "~/.envrc was not created cleanly — falling back to the template"
      cp "$REPO_DIR/.envrc.example" "$target"
      "${EDITOR:-open}" "$target" >/dev/null 2>&1 || open "$target" 2>/dev/null || true
      ask _ "   Press Enter once you've saved your values in .envrc... "
    fi
  else
    cp "$REPO_DIR/.envrc.example" "$target"
    warn "Created .envrc from template — fill in your real values."
    "${EDITOR:-open}" "$target" >/dev/null 2>&1 || open "$target" 2>/dev/null || true
    ask _ "   Press Enter once you've saved your values in .envrc... "
    ok ".envrc ready"
  fi
}

ensure_envrc() {
  step "Machine variables (.envrc)"
  local target="$REPO_DIR/.envrc"

  # Only adopt an existing .envrc if it actually sources cleanly. Otherwise an
  # old-template copy (malformed `VAR=# ...` lines, placeholder values) gets
  # silently adopted, the prompt is skipped, and every new shell spews
  # "command not found" while aliases resolve to bogus placeholder paths.
  if [[ -f "$target" ]]; then
    if envrc_is_sourceable "$target"; then
      ok ".envrc already present in repo"
    else
      warn "Repo .envrc is malformed (old template?) — backing up to .envrc.malformed.bak and regenerating"
      mv "$target" "$target.malformed.bak"
      generate_envrc "$target"
    fi
  elif [[ -f "$HOME/.envrc" ]]; then
    if envrc_is_sourceable "$HOME/.envrc"; then
      mv "$HOME/.envrc" "$target"
      ok "Moved ~/.envrc into the repo"
    else
      warn "Existing ~/.envrc is malformed (old template?) — backing up to ~/.envrc.malformed.bak and regenerating"
      mv "$HOME/.envrc" "$HOME/.envrc.malformed.bak"
      generate_envrc "$target"
    fi
  else
    generate_envrc "$target"
  fi

  # Load values into THIS session so later steps (company path, keys) see them.
  set -a; # shellcheck disable=SC1090
  . "$target" 2>/dev/null || true; set +a
}

# ----------------------------------------------------------------------------
# Step 7 — Run dotbot (base profile, then optional stack).
# ----------------------------------------------------------------------------
run_dotbot() {
  step "Provisioning via dotbot (./install-profile)"
  ( cd "$REPO_DIR" && ./install-profile base ) || die "install-profile base failed"
  ok "Base profile installed"

  if [[ -n "$STACK" && "$STACK" != "base" ]]; then
    if [[ -f "$REPO_DIR/meta/profiles/$STACK" ]]; then
      log "Installing '$STACK' stack on top of base..."
      ( cd "$REPO_DIR" && ./install-profile "$STACK" ) \
        || warn "install-profile $STACK reported errors (review above)"
      ok "Stack '$STACK' processed"
    else
      warn "No profile named '$STACK' (expected react | ruby | devops). Skipping."
    fi
  fi
}

# ----------------------------------------------------------------------------
# Step 8 — SSH key. Generated non-interactively; the PUBLIC key is auto-uploaded
#          to GitHub via `gh ssh-key add` (manual paste only as a fallback).
# ----------------------------------------------------------------------------
setup_ssh_key() {
  step "SSH key"
  local key="$HOME/.ssh/id_ed25519"
  local email="${GIT_EMAIL_ADDRESS_PROFESSIONAL:-${JIRA_USER_EMAIL:-$USER@$(hostname)}}"
  mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"

  if [[ -f "$key" ]]; then
    ok "SSH key already exists ($key)"
  else
    log "Generating ed25519 key (no passphrase; set SSH_PASSPHRASE to override)..."
    ssh-keygen -t ed25519 -C "$email" -f "$key" -N "${SSH_PASSPHRASE:-}" -q \
      || { warn "ssh-keygen failed; skipping SSH setup"; return; }
    ok "Key generated"
  fi

  # ~/.ssh/config so VS Code / agent use the keychain.
  if ! grep -qs "id_ed25519" "$HOME/.ssh/config" 2>/dev/null; then
    cat >>"$HOME/.ssh/config" <<'EOF'

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
    ok "Wrote ~/.ssh/config"
  fi
  chmod 600 "$key" "$HOME/.ssh/config" 2>/dev/null || true
  chmod 644 "$key.pub" 2>/dev/null || true

  eval "$(ssh-agent -s)" >/dev/null 2>&1 || true
  ssh-add --apple-use-keychain "$key" >/dev/null 2>&1 || ssh-add "$key" >/dev/null 2>&1 || true
  grep -qs github.com "$HOME/.ssh/known_hosts" 2>/dev/null \
    || ssh-keyscan -t ed25519 github.com >>"$HOME/.ssh/known_hosts" 2>/dev/null || true

  # Upload the public key to GitHub (gh is authenticated by now).
  local title out
  title="${CURRENT_NAME:-$USER}@$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
  if out="$(gh ssh-key add "$key.pub" --title "$title" 2>&1)"; then
    ok "SSH public key uploaded to GitHub"
  elif printf '%s' "$out" | grep -qiE 'already|exist'; then
    ok "SSH public key already on GitHub"
  else
    warn "Could not auto-upload SSH key (token may lack the 'admin:public_key' scope)."
    printf '\n   Your SSH PUBLIC key:\n\n'
    sed 's/^/      /' "$key.pub"
    open "https://github.com/settings/ssh/new" >/dev/null 2>&1 || true
    MANUAL_ACTIONS+=("Add your SSH key: paste it at https://github.com/settings/ssh/new — or run: gh auth refresh -s admin:public_key && gh ssh-key add $key.pub")
  fi
}

# ----------------------------------------------------------------------------
# Step 9 — GPG signing key. Generation is INTERACTIVE (you set a passphrase via
#          the pinentry dialog, protecting your signing identity); the resulting
#          PUBLIC key is auto-uploaded via `gh gpg-key add` and user.signingkey is
#          wired up so signed commits work immediately. Replaces setup_gpg.sh's
#          ~16-step manual `gpg --full-gen-key` walkthrough.
# ----------------------------------------------------------------------------
setup_gpg_key() {
  step "GPG signing key"
  command -v gpg >/dev/null 2>&1 || { warn "gpg not installed; skipping (commit signing is enabled in gitconfig — install gnupg and re-run)"; return; }

  local name="${CURRENT_NAME:-$USER}"
  local email="${GIT_EMAIL_ADDRESS_PROFESSIONAL:-${JIRA_USER_EMAIL:-}}"
  [[ -z "$email" ]] && { warn "No email in .envrc; skipping GPG generation"; return; }

  mkdir -p "$HOME/.gnupg"; chmod 700 "$HOME/.gnupg"

  local keyid
  keyid="$(gpg --list-secret-keys --keyid-format=long "$email" 2>/dev/null | awk '/^sec/{print $2}' | cut -d/ -f2 | head -1)"

  if [[ -z "$keyid" ]]; then
    log "Generating a 4096-bit RSA GPG key for $name <$email> (3y expiry)."
    warn "A passphrase dialog will appear — choose a passphrase to protect your signing key."
    gpg --quick-generate-key "$name <$email>" rsa4096 default 3y \
      || { warn "GPG generation failed; run ./onboarding_bin/setup_gpg.sh manually"; return; }
    keyid="$(gpg --list-secret-keys --keyid-format=long "$email" 2>/dev/null | awk '/^sec/{print $2}' | cut -d/ -f2 | head -1)"
  fi
  [[ -z "$keyid" ]] && { warn "Could not determine GPG key id; skipping"; return; }
  ok "GPG key id: $keyid"

  # Close the loop so signed commits actually work.
  git config --global user.signingkey "$keyid"
  git config --global commit.gpgsign true
  git config --global gpg.program "$(command -v gpg)"

  # Persist the key id into .envrc (CURRENT_USER_GPG_KEY) for future runs.
  local envf="$REPO_DIR/.envrc"
  if [[ -f "$envf" ]]; then
    if grep -qs '^export CURRENT_USER_GPG_KEY=' "$envf"; then
      sed -i '' "s|^export CURRENT_USER_GPG_KEY=.*|export CURRENT_USER_GPG_KEY=\"$keyid\"|" "$envf" 2>/dev/null || true
    elif grep -qs '^CURRENT_USER_GPG_KEY=' "$envf"; then
      sed -i '' "s|^CURRENT_USER_GPG_KEY=.*|CURRENT_USER_GPG_KEY=\"$keyid\"|" "$envf" 2>/dev/null || true
    fi
  fi

  # Upload the public key to GitHub (gh is authenticated by now).
  local gout
  if gout="$(gpg --armor --export "$keyid" | gh gpg-key add - 2>&1)"; then
    ok "GPG public key uploaded to GitHub"
  elif printf '%s' "$gout" | grep -qiE 'already|exist'; then
    ok "GPG public key already on GitHub"
  else
    warn "Could not auto-upload GPG key (token may lack the 'write:gpg_key' scope)."
    printf '\n   Your GPG PUBLIC key:\n\n'
    gpg --armor --export "$keyid" | sed 's/^/      /'
    open "https://github.com/settings/gpg/new" >/dev/null 2>&1 || true
    MANUAL_ACTIONS+=("Add your GPG key: paste it at https://github.com/settings/gpg/new — or run: gh auth refresh -s write:gpg_key && gpg --armor --export $keyid | gh gpg-key add -")
  fi
}

# ----------------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------------
summary() {
  printf '\n\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n'
  printf '\033[1;32m  Onboarding complete.\033[0m\n'
  printf '\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n'
  if ((${#MANUAL_ACTIONS[@]})); then
    printf '\n Remaining manual actions (the unavoidable identity gates):\n'
    local i=1
    for action in "${MANUAL_ACTIONS[@]}"; do
      printf '   %s. %s\n' "$i" "$action"; i=$((i + 1))
    done
  fi
  printf '\n Then open a new terminal (or `source ~/.zshrc`) and you are ready.\n\n'
}

# ----------------------------------------------------------------------------
# Administrator access — ask for the sudo password ONCE up front, then keep the
# sudo timestamp warm in the background so the many cask installers that call
# sudo don't each re-prompt. NOTE: casks that use their own macOS privileged-
# helper GUI prompt (some .pkg / system-extension casks) may still ask — that's
# a system security gate we won't bypass (would require a NOPASSWD sudoers rule).
# ----------------------------------------------------------------------------
SUDO_KEEPALIVE_PID=""
prime_sudo() {
  step "Administrator access"
  warn "Enter your macOS password once — it will be cached for the rest of the run."
  if [[ -r /dev/tty ]]; then
    sudo -v </dev/tty || die "sudo is required to install Homebrew and casks"
  else
    sudo -v || die "sudo is required to install Homebrew and casks"
  fi
  # Refresh the timestamp every 50s (under sudo's default 5-min timeout) until
  # this script exits, so later sudo calls inherit the cached credentials.
  ( while true; do sudo -n true 2>/dev/null; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
  SUDO_KEEPALIVE_PID=$!
  ok "Credentials cached for this session"
}

stop_sudo_keepalive() {
  [[ -n "$SUDO_KEEPALIVE_PID" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
}

# ----------------------------------------------------------------------------
main() {
  trap stop_sudo_keepalive EXIT
  log "Mac onboarding — stack: ${STACK:-base only}"
  prime_sudo
  install_xcode_clt
  install_homebrew
  install_bootstrap_pkgs
  ensure_gh_auth
  collect_machine_vars
  resolve_repo
  ensure_envrc
  run_dotbot
  setup_ssh_key
  setup_gpg_key
  summary
}

main "$@"
