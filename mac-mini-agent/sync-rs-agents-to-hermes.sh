#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# sync-rs-agents-to-hermes.sh
# Mirror the rs-agents skills from the INSTALLED Claude Code plugin into Hermes.
#
# This is the Hermes equivalent of "reload plugins": Claude Code consumes the
# rs-agents plugin natively, but Hermes has its own skills store and cannot read
# the plugin layout (`ai/skills/<name>/`). This script copies the skills from the
# *released* plugin cache into `~/.hermes/skills/rs-agents/` so the local model
# can discover them on-demand.
#
#   ⚠️ READ-ONLY CONSUMER. The source of truth is the Wayroo.tools repo; new/
#   changed skills are authored there and shipped via the plugin (Jira → PR →
#   merge → `reload plugins`). NEVER author a skill in ~/.hermes/skills — it is
#   overwritten on every sync.
#
# Safe to sync all skills: Hermes injects only a ~8 KB skills *index* (name +
# description) into the prompt and loads a full skill on-demand via its tool, so
# the per-skill prompt cost is one index line, not the whole body.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
step() { printf '\n\033[1;36m▶ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*"; }

HERMES_SKILLS_DIR="${HERMES_SKILLS_DIR:-$HOME/.hermes/skills/rs-agents}"

step "Locating the installed rs-agents plugin (released version)"
# Prefer the Claude Code plugin cache (exactly what `reload plugins` installed).
# Pick the highest version dir if several are cached.
SRC="$(ls -d "$HOME"/.claude/plugins/cache/*/rs-agents/*/skills 2>/dev/null | sort -V | tail -1 || true)"
if [[ -z "${SRC}" || ! -d "${SRC}" ]]; then
  warn "rs-agents plugin skills not found under ~/.claude/plugins/cache/*/rs-agents/*/skills"
  warn "Install/refresh the plugin in Claude Code first (add the wayroo marketplace, then 'reload plugins')."
  exit 1
fi
bold "  source: ${SRC}"

step "Mirroring skills into Hermes"
# Clean rebuild so removed/renamed skills don't linger (idempotent).
rm -rf "${HERMES_SKILLS_DIR}"
mkdir -p "${HERMES_SKILLS_DIR}"
count=0
for d in "${SRC}"/*/; do
  [[ -f "${d}SKILL.md" ]] || continue
  name="$(basename "$d")"
  mkdir -p "${HERMES_SKILLS_DIR}/${name}"
  cp "${d}SKILL.md" "${HERMES_SKILLS_DIR}/${name}/SKILL.md"
  count=$((count + 1))
done
bold "  synced ${count} rs-agents skills -> ${HERMES_SKILLS_DIR}"

step "Verifying Hermes sees them"
if command -v hermes >/dev/null 2>&1; then
  hermes skills list 2>/dev/null | grep -c "rs-agents" | xargs -I{} echo "  hermes reports {} skills in the 'rs-agents' category"
else
  warn "hermes not on PATH — skipped verification"
fi
bold "✔ Sync complete. Local models can now discover rs-agents skills on-demand."
