#!/usr/bin/env bash
# End-to-end self-test for repo_hygiene.py on a throwaway repository.
# Builds: merged branch, squash-merged branch (no PR record), unique never-pushed branch,
# pushed-then-remote-deleted branch, a clean worktree on a merged branch, a dirty worktree,
# an autostash and a named stash. Runs audit -> manifest -> (edit) -> apply -> apply --execute
# -> verify -> restore --all, and asserts every deleted SHA is restorable.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ENGINE="$HERE/repo_hygiene.py"
T="$(mktemp -d /tmp/repo-hygiene-selftest.XXXXXX)"
trap 'rm -rf "$T"' EXIT
export GIT_AUTHOR_NAME=selftest GIT_AUTHOR_EMAIL=selftest@example.com GIT_COMMITTER_NAME=selftest GIT_COMMITTER_EMAIL=selftest@example.com
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null HOME="$T/home"
mkdir -p "$HOME" "$T/repos/cat" "$T/.archive"
git init -q --bare -b develop "$T/origin.git"
git clone -q "$T/origin.git" "$T/repos/cat/demo" 2>/dev/null || true
R="$T/repos/cat/demo"
g() { git -C "$R" "$@"; }
g checkout -q -b develop 2>/dev/null || g checkout -q develop
echo base > "$R/base.txt"; g add -A; g commit -q -m "base"; g push -q -u origin develop
git -C "$T/origin.git" symbolic-ref HEAD refs/heads/develop
g remote set-head origin develop

# 1. merged branch (D1)
g checkout -q -b feature/merged; echo m > "$R/m.txt"; g add -A; g commit -q -m "merged work"
g checkout -q develop; g merge -q --no-ff feature/merged -m "merge feature/merged"; g push -q origin develop
# 2. squash-merged, remote branch deleted, no PR record (D5, cherry_unique should be 0)
g checkout -q -b feature/squashed; echo s > "$R/s.txt"; g add -A; g commit -q -m "squashed work"; g push -q -u origin feature/squashed
g checkout -q develop; g merge -q --squash feature/squashed; g commit -q -m "squash: feature/squashed"; g push -q origin develop; g push -q origin --delete feature/squashed
# 3. unique never-pushed (D7, review -> user marks archive-delete)
g checkout -q -b feature/unique; echo u > "$R/u.txt"; g add -A; g commit -q -m "unique work"
# 4. pushed then remote-deleted with unique commit (D5, review -> user marks keep)
g checkout -q -b feature/gone; echo gone > "$R/gone.txt"; g add -A; g commit -q -m "gone work"; g push -q -u origin feature/gone; g push -q origin --delete feature/gone
# 5. clean worktree on a merged branch (auto remove) and a dirty worktree on a unique branch (salvage-remove)
g checkout -q develop
g checkout -q -b feature/merged2; echo m2 > "$R/m2.txt"; g add -A; g commit -q -m "merged2"; g checkout -q develop; g merge -q --no-ff feature/merged2 -m "merge merged2"; g push -q origin develop
mkdir -p "$R/.claude/worktrees"; printf '.claude/worktrees/\n' >> "$R/.git/info/exclude"
g worktree add -q "$R/.claude/worktrees/wt-clean" feature/merged2
g worktree add -q -b feature/wtdirty "$R/.claude/worktrees/wt-dirty" develop
echo dirty > "$R/.claude/worktrees/wt-dirty/dirty.txt"; git -C "$R/.claude/worktrees/wt-dirty" add -A; git -C "$R/.claude/worktrees/wt-dirty" commit -q -m "wtdirty commit"
echo more > "$R/.claude/worktrees/wt-dirty/uncommitted.txt"
# 6. stashes
echo x > "$R/x.txt"; g add x.txt; g stash push -q -m "autostash"; echo y > "$R/y.txt"; g add y.txt; g stash push -q -m "named wip"
g fetch -q --prune origin

cat > "$T/hygiene.toml" <<EOF
root = "$T/repos"
archive = "$T/.archive"
categories = ["cat"]
EOF
RH="python3 $ENGINE --config $T/hygiene.toml"
echo "== audit"; $RH audit --repo cat/demo
echo "== manifest"; $RH manifest --repo cat/demo
M="$T/.archive/cat__demo/manifest.tsv"
echo "-- manifest as generated:"; grep -v '^#' "$M" | cut -f1-4,10 | column -t -s $'\t' | sed 's/^/   /'
# simulate the user's marks
python3 - "$M" <<'EOF'
import sys
p = sys.argv[1]; out = []
for line in open(p):
    if line.startswith("#") or line.startswith("kind\t"):
        out.append(line); continue
    c = line.rstrip("\n").split("\t")
    kind, action, name = c[0], c[1], c[3]
    if kind == "branch" and name == "feature/unique": c[1] = "archive-delete"
    if kind == "branch" and name == "feature/gone": c[1] = "keep"
    if kind == "branch" and name == "feature/wtdirty": c[1] = "archive-delete"
    if kind == "worktree" and name.endswith("wt-dirty"): c[1] = "salvage-remove"
    if kind == "stash" and "named wip" in line: c[1] = "export-drop"
    out.append("\t".join(c) + "\n")
open(p, "w").write("".join(out))
EOF
echo "== apply (dry)"; $RH apply --repo cat/demo
SHAS="$(for b in feature/merged feature/squashed feature/unique feature/wtdirty; do g rev-parse "$b"; done)"
STASH_NAMED="$(g stash list --format=%H | tail -1)"
echo "== apply --execute"; $RH apply --repo cat/demo --execute
echo "== state after apply"; g branch --list | sed 's/^/   /'; g worktree list | sed 's/^/   /'; g stash list | sed 's/^/   /'
test -z "$(g branch --list feature/merged feature/squashed feature/unique feature/wtdirty)" || { echo "FAIL: branches not deleted"; exit 1; }
test -n "$(g branch --list feature/gone)" || { echo "FAIL: kept branch deleted"; exit 1; }
test "$(g worktree list | wc -l | tr -d ' ')" = "1" || { echo "FAIL: worktrees remain"; exit 1; }
test "$(g stash list | wc -l | tr -d ' ')" = "0" || { echo "FAIL: stashes remain"; exit 1; }
ls "$T/.archive/cat__demo/" | sed 's/^/   /'
test -n "$(ls "$T/.archive/cat__demo"/*.bundle)" || { echo "FAIL: no bundle"; exit 1; }
test -n "$(ls "$T/.archive/cat__demo"/salvage/*.patch)" || { echo "FAIL: no salvage patch"; exit 1; }
test -n "$(ls "$T/.archive/cat__demo"/stashes/*.patch)" || { echo "FAIL: no stash patch"; exit 1; }
echo "== verify --restore-test"; $RH verify --repo cat/demo --restore-test
echo "== second apply --policy safe must be a no-op"; $RH audit --repo cat/demo --no-fetch >/dev/null; $RH apply --repo cat/demo --policy safe --execute | grep -E 'branch -D|worktree remove|stash drop' && { echo "FAIL: second run not a no-op"; exit 1; } || true
echo "== restore --all"; $RH restore --repo cat/demo --all
for s in $SHAS $STASH_NAMED; do g cat-file -e "$s^{commit}" || { echo "FAIL: $s not restorable"; exit 1; }; done
test -n "$(g branch --list feature/unique)" || { echo "FAIL: feature/unique not restored"; exit 1; }
# Branches whose tips stayed reachable from a protected ref are deliberately NOT bundled; they
# must still come back, from the refs.tsv record (regression: sourcery review of PR #55).
for b in feature/merged feature/merged2; do
  test -n "$(g branch --list $b)" || { echo "FAIL: $b not restored from refs.tsv (empty-bundle path)"; exit 1; }
done
echo "   reachable-tip branches restored from refs.tsv: ok"
# A repo with no resolvable integration target must not auto-delete anything.
NT="$T/no-target"; git init -q -b orphanmain "$NT"; ( cd "$NT" && echo x > f.txt && git add -A && git commit -q -m init && git checkout -q -b some-work && echo y >> f.txt && git commit -q -am work )
mkdir -p "$T/repos/cat2"; mv "$NT" "$T/repos/cat2/demo2"
cat > "$T/hygiene2.toml" <<EOF2
root = "$T/repos"
archive = "$T/.archive2"
categories = ["cat2"]
EOF2
python3 "$ENGINE" --config "$T/hygiene2.toml" audit --repo cat2/demo2 >/dev/null 2>&1
python3 "$ENGINE" --config "$T/hygiene2.toml" manifest --repo cat2/demo2 >/dev/null 2>&1
M2="$T/.archive2/cat2__demo2/manifest.tsv"
test -f "$M2" || { echo "FAIL: no-target manifest was never written, so the guard is untested"; exit 1; }
test "$(awk -F'\t' '!/^#/ && $1=="branch"' "$M2" | wc -l | tr -d ' ')" -ge 2 || { echo "FAIL: no-target manifest has too few branch rows to be meaningful"; exit 1; }
test -z "$(awk -F'\t' '!/^#/ && $1=="branch" && $2=="archive-delete"' "$M2")" || { echo "FAIL: a repo with no integration target prefilled a deletion"; exit 1; }
test -n "$(awk -F'\t' '!/^#/ && $1=="branch" && $2=="review"' "$M2")" || { echo "FAIL: no-target repo should send branches to review"; exit 1; }
echo "   no-integration-target repo: $(awk -F'\t' '!/^#/ && $1=="branch"' "$M2" | wc -l | tr -d ' ') branch rows, 0 auto-deletes, review required: ok"
g for-each-ref refs/archive --format='   restored %(refname)'
echo "SELFTEST PASSED"
