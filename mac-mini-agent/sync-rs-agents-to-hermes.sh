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

# launchd runs with a minimal PATH; make sure user-local tools (hermes) resolve.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
step() { printf '\n\033[1;36m▶ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*"; }

HERMES_SKILLS_DIR="${HERMES_SKILLS_DIR:-$HOME/.hermes/skills/rs-agents}"

# --soft: for onboarding — if no source is found, warn and exit 0 (don't fail the install).
SOFT=0
[[ "${1:-}" == "--soft" ]] && SOFT=1

step "Locating rs-agents skills (source of truth: the released plugin)"
# 1) Prefer the installed Claude Code plugin cache — exactly what `reload plugins` gave.
SRC="$(ls -d "$HOME"/.claude/plugins/cache/*/rs-agents/*/skills 2>/dev/null | sort -V | tail -1 || true)"
# 2) Fallback: a local Wayroo.tools clone (RS_AGENTS_SKILLS_SRC overrides). Same
#    <name>/SKILL.md layout, so the copy below works for either source.
if [[ -z "${SRC}" || ! -d "${SRC}" ]]; then
  for cand in "${RS_AGENTS_SKILLS_SRC:-}" \
              "$HOME/Retail-Success/repos/development-team/Wayroo.tools/ai/skills"; do
    [[ -n "$cand" && -d "$cand" ]] && { SRC="$cand"; break; }
  done
fi
if [[ -z "${SRC}" || ! -d "${SRC}" ]]; then
  warn "rs-agents skills not found (no plugin cache, no Wayroo.tools clone)."
  warn "Install the rs-agents plugin in Claude Code (add the wayroo marketplace + 'reload plugins'),"
  warn "or set RS_AGENTS_SKILLS_SRC=/path/to/Wayroo.tools/ai/skills, then re-run this script."
  [[ $SOFT -eq 1 ]] && { warn "(--soft) skipping rs-agents sync; Hermes install continues."; exit 0; }
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
