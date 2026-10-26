#!/usr/bin/env bash
# SessionEnd hook — report-only. Tells you about STALE worktrees, and only those.
#
# A worktree under <repo>/.claude/worktrees/ is "stale" when nothing in it is waiting on you:
#   merged      its branch is already part of the default branch
#   remote gone its branch was deleted on origin (a PR merged or closed, or you deleted it)
#   idle        nothing committed or touched for IDLE_DAYS
# A worktree you are using today is never reported. One with uncommitted changes is listed in the
# report but marked "has uncommitted changes" and never counted as safe to clear.
#
# Output:   ~/Library/Logs/repo-hygiene/latest-report.md   (what, why, and the command to clear it)
# Alert:    "Repo Hygiene Alerts" app, once per repo per day. Clicking it opens the report.
# Never removes anything, and every path exits 0 so it can never fail a session.
#
# Wired from ~/.claude/settings.json on SessionEnd (matcher prompt_input_exit|logout|other, timeout 5).

set -uo pipefail

IDLE_DAYS="${REPO_HYGIENE_IDLE_DAYS:-14}"
LOG_DIR="$HOME/Library/Logs/repo-hygiene"
REPORT="$LOG_DIR/latest-report.md"
STAMP_DIR="$LOG_DIR/.notified"
APP="$HOME/Applications/Repo Hygiene Alerts.app/Contents/MacOS/applet"
mkdir -p "$LOG_DIR" "$STAMP_DIR" 2>/dev/null || exit 0

# Claude Code sends JSON on stdin; cwd is the only field needed. (macOS has no `timeout`.)
PAYLOAD="$(cat 2>/dev/null || true)"
CWD=""
if [ -n "$PAYLOAD" ]; then
  if command -v jq >/dev/null 2>&1; then CWD="$(printf '%s' "$PAYLOAD" | jq -r '.cwd // empty' 2>/dev/null || true)"
  else CWD="$(printf '%s' "$PAYLOAD" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"; fi
fi
[ -n "$CWD" ] || CWD="$PWD"
[ -d "$CWD" ] || exit 0

COMMON="$(git -C "$CWD" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
[ -n "$COMMON" ] || exit 0
REPO_ROOT="$(dirname "$COMMON")"
REPO_NAME="$(basename "$REPO_ROOT")"

DEFAULT="$(git -C "$REPO_ROOT" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')"
[ -n "$DEFAULT" ] || DEFAULT=develop
NOW="$(date +%s)"

STALE=0; DIRTY=0; ROWS=""
while IFS=$'\t' read -r path branch; do
  case "$path" in */.claude/worktrees/*) ;; *) continue ;; esac
  [ -d "$path" ] || continue
  head="$(git -C "$path" rev-parse HEAD 2>/dev/null || true)"
  [ -n "$head" ] || continue

  last="$(git -C "$path" log -1 --format=%ct 2>/dev/null || echo 0)"
  touched="$(stat -f %m "$path" 2>/dev/null || echo 0)"
  [ "$touched" -gt "$last" ] && last="$touched"
  idle=$(( (NOW - last) / 86400 ))

  reason=""
  if git -C "$REPO_ROOT" merge-base --is-ancestor "$head" "origin/$DEFAULT" 2>/dev/null; then
    reason="merged into $DEFAULT"
  elif [ -n "$branch" ] && git -C "$REPO_ROOT" for-each-ref --format='%(upstream:track)' "refs/heads/$branch" 2>/dev/null | grep -q 'gone'; then
    reason="branch deleted on origin"
  elif [ "$idle" -ge "$IDLE_DAYS" ]; then
    reason="idle ${idle} days"
  fi
  [ -n "$reason" ] || continue

  # commits that exist only on this machine: the branch is kept either way, but say so
  ahead="$(git -C "$REPO_ROOT" rev-list --count "origin/$DEFAULT..$head" 2>/dev/null || echo 0)"
  note=""
  case "$reason" in
    "branch deleted on origin"|idle*) [ "${ahead:-0}" -gt 0 ] && note=" · branch holds ${ahead} commit(s) not on origin; removing the worktree keeps the branch" ;;
  esac
  changes="$(git -C "$path" status --porcelain 2>/dev/null | grep -vc 'codegraph\|tsbuildinfo' || true)"
  if [ "${changes:-0}" -gt 0 ]; then
    DIRTY=$((DIRTY+1))
    ROWS="$ROWS- **${path##*/}** — ${reason}, **has ${changes} uncommitted change(s): look before removing**  \n  branch \`${branch:-detached}\`\n"
  else
    STALE=$((STALE+1))
    ROWS="$ROWS- **${path##*/}** — ${reason}  \n  branch \`${branch:-detached}\`${note} · clear it: \`git -C \"$REPO_ROOT\" worktree remove \"$path\"\`\n"
  fi
done < <(git -C "$REPO_ROOT" worktree list --porcelain 2>/dev/null \
          | awk '/^worktree /{p=substr($0,10)} /^branch /{b=substr($0,19)} /^$/{if(p!="")print p"\t"b; p="";b=""} END{if(p!="")print p"\t"b}')

[ $((STALE + DIRTY)) -gt 0 ] || exit 0

{
  printf '# Stale worktrees — %s\n\n' "$REPO_NAME"
  printf '_%s · %s clear to remove, %s with uncommitted changes · nothing here has been touched_\n\n' "$(date '+%Y-%m-%d %H:%M')" "$STALE" "$DIRTY"
  printf '%b\n' "$ROWS"
  printf 'A worktree is listed when its branch is already merged, was deleted on origin, or has sat idle %s+ days. Anything you are working in today is not listed.\n' "$IDLE_DAYS"
} > "$REPORT" 2>/dev/null || true

STAMP="$STAMP_DIR/$REPO_NAME-$(date +%Y-%m-%d)"
if [ ! -e "$STAMP" ] && [ -x "$APP" ]; then
  : > "$STAMP" 2>/dev/null || true
  MSG="$STALE stale worktree(s) in $REPO_NAME"
  [ "$DIRTY" -gt 0 ] && MSG="$MSG, $DIRTY with uncommitted changes"
  "$APP" "$MSG" >/dev/null 2>&1 || true
fi
exit 0
