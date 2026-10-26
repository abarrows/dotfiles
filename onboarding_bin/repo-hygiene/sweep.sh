#!/usr/bin/env bash
# Periodic repo-hygiene sweep.
#
# Report mode (the default) changes nothing: it audits every repo, verifies the
# end-state invariants, and writes a log plus an anomaly list. Safe mode also
# applies the provably-safe subset — branches already merged by ancestry, squash
# -merged branches whose tip matches the PR head, clean idle worktrees on those
# branches, and noise stashes. Everything else stays report-only, forever.
#
# The policy starts at `report` and should only be moved to `safe` after two
# consecutive clean weekly reports. This script prints when that is true; it
# never promotes itself.
#
#   ~/.config/repo-hygiene/policy      one word: report | safe
#   ~/Library/Logs/repo-hygiene/       sweep-YYYY-MM-DD.log, anomalies.md, state
#
# Usage: sweep.sh [--policy report|safe] [--repo <category>/<name>] [--quiet]

set -uo pipefail

ROOT="${REPO_HYGIENE_ROOT:-$HOME/Retail-Success/repos}"
LOG_DIR="$HOME/Library/Logs/repo-hygiene"
POLICY_FILE="${REPO_HYGIENE_POLICY_FILE:-$HOME/.config/repo-hygiene/policy}"
STATE_FILE="$LOG_DIR/state"
ANOMALIES="$LOG_DIR/anomalies.md"
LOG="$LOG_DIR/sweep-$(date +%Y-%m-%d).log"
BIN="${REPO_HYGIENE_BIN:-$HOME/.local/bin/repo-hygiene}"

POLICY=""
SCOPE_ARGS=(--all)
QUIET=0
while [ $# -gt 0 ]; do
  case "$1" in
    --policy) POLICY="${2:-}"; shift 2 ;;
    --repo)   SCOPE_ARGS=(--repo "${2:-}"); shift 2 ;;
    --quiet)  QUIET=1; shift ;;
    -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "sweep.sh: unknown argument '$1'" >&2; exit 2 ;;
  esac
done

mkdir -p "$LOG_DIR" "$(dirname "$POLICY_FILE")"
[ -n "$POLICY" ] || POLICY="$(tr -d '[:space:]' < "$POLICY_FILE" 2>/dev/null || true)"
[ -n "$POLICY" ] || POLICY="report"
case "$POLICY" in
  report|safe) ;;
  *) echo "sweep.sh: policy must be 'report' or 'safe', got '$POLICY'" >&2; exit 2 ;;
esac

[ -x "$BIN" ] || { echo "sweep.sh: repo-hygiene not executable at $BIN" >&2; exit 2; }

log() { printf '%s\n' "$*" >> "$LOG"; [ "$QUIET" -eq 1 ] || printf '%s\n' "$*"; }

START=$(date +%s)
log "== repo-hygiene sweep $(date '+%Y-%m-%d %H:%M:%S')  policy=$POLICY  root=$ROOT"

# ---------------------------------------------------------------- audit (read-only)
# `audit` fetches and rewrites .archive/<repo>/audit-latest.json for every repo.
# It is the slow step, so it runs at low priority and its output is kept.
nice -n 10 "$BIN" audit "${SCOPE_ARGS[@]}" >> "$LOG" 2>&1
AUDIT_RC=$?
log "-- audit exit=$AUDIT_RC"

# ---------------------------------------------------------------- classify anomalies
# Every class here is report-only. The sweep never unlocks, never prunes, and
# never touches a /sessions/... registration — repairing those is a deliberate
# act (see rs-agents skills/git-worktree-workflow).
ANOM_OUT="$(ROOT="$ROOT" ONLY_REPO="${SCOPE_ARGS[1]:-}" python3 -I - <<'PY'
import json, os, glob
root = os.environ["ROOT"]
only = os.environ.get("ONLY_REPO") or ""   # empty for --all
GB = 1024 ** 3
rows = []
for path in sorted(glob.glob(os.path.join(root, ".archive", "*", "audit-latest.json"))):
    try:
        a = json.load(open(path))
    except Exception as e:
        rows.append(("UNREADABLE_AUDIT", os.path.basename(os.path.dirname(path)), str(e)))
        continue
    repo = a.get("repo", "?")
    if only and repo != only:
        continue
    # `dirt` is a list of porcelain lines; `last_touch` is already idle days;
    # `kind` is "main" or "linked" — the smells below are about linked worktrees,
    # since a dirty or large main checkout is just someone working.
    for w in a.get("worktrees", []):
        p, linked = w.get("path", "?"), w.get("kind") == "linked"
        if not w.get("present"):
            if w.get("sessions_path"):
                rows.append(("MISSING_LOCKED", repo, f"{p} — cloud-session registration; repair before any prune/unlock"))
            elif w.get("locked"):
                rows.append(("MISSING_LOCKED", repo, f"{p} — locked and missing"))
            continue
        if w.get("in_progress"):
            rows.append(("IN_PROGRESS", repo, f"{p} — {', '.join(w['in_progress'])} present; blocks any sweep over this repo"))
        if not linked:
            continue
        if not w.get("layout_ok"):
            rows.append(("LAYOUT_VIOLATION", repo, f"{p} — outside <repo>/.claude/worktrees/"))
        dirt, idle_d = len(w.get("dirt") or []), w.get("last_touch")
        if dirt and isinstance(idle_d, int) and idle_d >= 14:
            rows.append(("STALE_DIRTY", repo, f"{p} — {dirt} dirty file(s), untouched {idle_d}d"))
        if isinstance(idle_d, int) and idle_d >= 14 and not dirt:
            rows.append(("IDLE_NO_PR", repo, f"{p} — clean and untouched {idle_d}d; branch {w.get('branch') or 'detached'}"))
        if (w.get("size") or 0) > GB:
            rows.append(("OVERSIZED", repo, f"{p} — {w['size']/GB:.1f} GB"))
    for o in a.get("orphans", []):
        rows.append(("ORPHAN_GITFILE_DIR", repo,
                     f"{o.get('path','?')} — {o.get('shape','gitfile dir')}, no registration, last touched {o.get('mtime','?')}"))
    # Branches whose origin copy was deleted. Protected ones (release/*, develop, ...) are never
    # auto-removed, so before this check they sat here forever after being deleted on GitHub.
    for b in a.get("branches", []):
        if "gone" not in (b.get("track") or ""):
            continue
        n = b.get("ahead") or 0
        if b.get("bucket") == "D8":
            rows.append(("PROTECTED_REMOTE_GONE", repo, f"{b['name']} — deleted on origin, still here ({n} commit(s) ahead); remove it with `git branch -D {b['name']}` if you meant it to go"))
        elif b.get("bucket") in ("D5", "D6", "D7", "D4"):
            rows.append(("REMOTE_GONE", repo, f"{b['name']} — deleted on origin; {n} commit(s) exist only on this machine" if n else f"{b['name']} — deleted on origin, nothing unique left"))
    linked = [w for w in a.get("worktrees", []) if w.get("present") and w.get("kind") == "linked"]
    if len(linked) > 3:
        rows.append(("TOO_MANY_WORKTREES", repo, f"{len(linked)} linked worktrees"))
for cls, repo, detail in sorted(rows):
    print(f"{cls}\t{repo}\t{detail}")
PY
)"
ANOM_COUNT=$(printf '%s' "$ANOM_OUT" | grep -c . || true)

# ---------------------------------------------------------------- verify (read-only)
nice -n 10 "$BIN" verify "${SCOPE_ARGS[@]}" >> "$LOG" 2>&1
VERIFY_RC=$?
log "-- verify exit=$VERIFY_RC"

# ---------------------------------------------------------------- apply (safe mode only)
REMOVED=0
if [ "$POLICY" = "safe" ]; then
  BEFORE="$(find "$ROOT" -maxdepth 3 -name '*.bundle' -path '*/.archive/*' 2>/dev/null | wc -l | tr -d ' ')"
  nice -n 10 "$BIN" apply "${SCOPE_ARGS[@]}" --policy safe --execute >> "$LOG" 2>&1
  APPLY_RC=$?
  AFTER="$(find "$ROOT" -maxdepth 3 -name '*.bundle' -path '*/.archive/*' 2>/dev/null | wc -l | tr -d ' ')"
  REMOVED=$(( AFTER - BEFORE ))
  log "-- apply --policy safe exit=$APPLY_RC  new bundle(s)=$REMOVED"
else
  log "-- apply skipped (policy=report); nothing was changed"
fi

# ---------------------------------------------------------------- record
if [ "$ANOM_COUNT" -gt 0 ]; then
  {
    printf '\n## %s — %s anomal%s (policy=%s)\n\n' "$(date '+%Y-%m-%d %H:%M')" "$ANOM_COUNT" \
      "$([ "$ANOM_COUNT" -eq 1 ] && echo y || echo ies)" "$POLICY"
    printf '%s\n' "$ANOM_OUT" | awk -F'\t' '{printf "- **%s** · `%s` · %s\n", $1, $2, $3}'
  } >> "$ANOMALIES"
  log "-- $ANOM_COUNT anomaly/anomalies appended to $ANOMALIES"
  printf '%s\n' "$ANOM_OUT" | awk -F'\t' '{printf "   %-20s %-45s %s\n", $1, $2, $3}' >> "$LOG"
fi

# Consecutive clean reports — the gate for moving the policy to `safe`.
CLEAN_RUN=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
case "$CLEAN_RUN" in ''|*[!0-9]*) CLEAN_RUN=0 ;; esac
if [ "$ANOM_COUNT" -eq 0 ] && [ "$AUDIT_RC" -eq 0 ] && [ "$VERIFY_RC" -eq 0 ]; then
  CLEAN_RUN=$(( CLEAN_RUN + 1 ))
else
  CLEAN_RUN=0
fi
printf '%s\n' "$CLEAN_RUN" > "$STATE_FILE"
log "-- consecutive clean reports: $CLEAN_RUN"
if [ "$POLICY" = "report" ] && [ "$CLEAN_RUN" -ge 2 ]; then
  log "-- eligible for safe mode: echo safe > $POLICY_FILE"
fi

ELAPSED=$(( $(date +%s) - START ))
log "== done in ${ELAPSED}s"

# ---------------------------------------------------------------- notify (only if it matters)
if [ "$ANOM_COUNT" -gt 0 ] || [ "$REMOVED" -gt 0 ]; then
  MSG="$ANOM_COUNT anomaly/anomalies"
  [ "$REMOVED" -gt 0 ] && MSG="$MSG · $REMOVED repo(s) swept"
  # The report is what the alert opens. Grouped by what to do, one line each.
  REPORT="$LOG_DIR/latest-report.md"
  {
    printf '# Repo hygiene — %s\n\n_policy: %s · %s item(s)_\n\n' "$(date '+%Y-%m-%d %H:%M')" "$POLICY" "$ANOM_COUNT"
    printf '%s\n' "$ANOM_OUT" | awk -F'\t' '
      BEGIN{
        t["PROTECTED_REMOTE_GONE"]="Deleted on origin, still on this machine (protected, so never auto-removed)";
        t["REMOTE_GONE"]="Deleted on origin — local copy remains";
        t["STALE_DIRTY"]="Idle worktrees with uncommitted changes";
        t["IDLE_NO_PR"]="Idle clean worktrees — safe to remove";
        t["LAYOUT_VIOLATION"]="Worktrees outside .claude/worktrees";
        t["ORPHAN_GITFILE_DIR"]="Directories with no registration";
        t["OVERSIZED"]="Over 1 GB"; t["TOO_MANY_WORKTREES"]="More than 3 worktrees";
        t["MISSING_LOCKED"]="Cloud-session registrations — repair, never prune"; t["IN_PROGRESS"]="Unfinished merge or rebase"}
      {cls=$1; if(cls!=last){ printf "\n## %s\n\n", (cls in t ? t[cls] : cls); last=cls } printf "- `%s` — %s\n", $2, $3 }'
    printf '\nNothing above has been changed. To act on a repo: `repo-hygiene audit --repo <repo> && repo-hygiene manifest --repo <repo>`.\n'
  } > "$REPORT" 2>/dev/null || true
  APP="$HOME/Applications/Repo Hygiene Alerts.app/Contents/MacOS/applet"
  if [ -x "$APP" ]; then "$APP" "$MSG — see the list" >/dev/null 2>&1 || true
  else osascript -e "display notification \"$MSG\" with title \"repo-hygiene sweep\"" >/dev/null 2>&1 || true; fi
fi

# A sweep that could not audit is a real failure; anomalies on their own are not.
[ "$AUDIT_RC" -eq 0 ] || exit 1
exit 0
