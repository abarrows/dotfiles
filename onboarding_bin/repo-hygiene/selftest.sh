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
# 7. remote deletion: branches that ARE still on origin
#    rpushed  merged + on origin           -> deleted on origin too (the default rule)
#    rkeep    merged + on origin, but named in keep-remote.txt -> stays on origin
#    rahead   origin has a commit the archive lacks -> stays on origin even though it is deleted locally
#    release/v1  protected pattern         -> never touched, locally or on origin
g checkout -q develop
for b in feature/rpushed feature/rkeep release/v1; do
  g checkout -q -b "$b" develop; echo "$b" > "$R/$(echo $b | tr / _).txt"; g add -A; g commit -q -m "work on $b"; g push -q -u origin "$b"
  g checkout -q develop; g merge -q --no-ff "$b" -m "merge $b"; g push -q origin develop
done
g checkout -q -b feature/rahead develop; echo a > "$R/rahead.txt"; g add -A; g commit -q -m "rahead work"; g push -q -u origin feature/rahead
git clone -q "$T/origin.git" "$T/other" 2>/dev/null; ( cd "$T/other" && git checkout -q feature/rahead && echo extra > extra.txt && git add -A && git commit -q -m "someone else pushed more" && git push -q origin feature/rahead )
g checkout -q develop
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
# the user's marks, applied through the `mark` subcommand (the documented path)
NAMED_STASH_ROW="$(awk -F'\t' '!/^#/ && $1=="stash" && /named wip/{print $4}' "$M")"
D="$T/.archive/cat__demo/decisions.tsv"
{
  printf 'branch\tarchive-delete\tfeature/unique\n'
  printf 'branch\tkeep\tfeature/gone\n'
  printf 'branch\tarchive-delete\tfeature/wtdirty\n'
  printf 'branch\tarchive-delete\tfeature/rahead\n'
  printf 'worktree\tsalvage-remove\twt-dirty\n'
  [ -n "$NAMED_STASH_ROW" ] && printf 'stash\texport-drop\t%s\n' "$NAMED_STASH_ROW"
} > "$D"
printf '# kept on origin on purpose\nfeature/rkeep\n' > "$T/.archive/cat__demo/keep-remote.txt"
echo "== mark"; $RH mark --repo cat/demo --from "$D"
# an entry that matches nothing must abort without writing, so a typo cannot silently no-op
cp "$M" "$M.probe"
printf 'branch\tkeep\tfeature/does-not-exist\n' > "$D.bad"
if $RH mark --repo cat/demo --from "$D.bad" >/dev/null 2>&1; then
  echo "FAIL: mark accepted an unmatched entry"; exit 1
fi
cmp -s "$M" "$M.probe" || { echo "FAIL: mark wrote the manifest despite an unusable entry"; exit 1; }
echo "   mark rejects an unmatched entry and leaves the manifest untouched: ok"
# re-running the same decisions file must be a no-op, not an error (marks survive a regenerate)
$RH mark --repo cat/demo --from "$D" | grep -q 'already set' || { echo "FAIL: mark is not idempotent"; exit 1; }
cmp -s "$M" "$M.probe" || { echo "FAIL: idempotent mark changed the manifest"; exit 1; }
echo "   mark is idempotent when every row is already decided: ok"
# an AUTO row carries the engine's own provably-safe default, so overriding one takes --force
AUTO_ROW="$(awk -F'\t' '!/^#/ && $1=="branch" && $2=="archive-delete" && $3=="D1"{print $4; exit}' "$M")"
printf 'branch\tkeep\t%s\n' "$AUTO_ROW" > "$D.auto"
if $RH mark --repo cat/demo --from "$D.auto" >/dev/null 2>&1; then
  echo "FAIL: mark overrode an AUTO row without --force"; exit 1
fi
cmp -s "$M" "$M.probe" || { echo "FAIL: refused AUTO override still wrote the manifest"; exit 1; }
$RH mark --repo cat/demo --from "$D.auto" --force >/dev/null
[ "$(awk -F'\t' -v b="$AUTO_ROW" '!/^#/ && $1=="branch" && $4==b{print $2}' "$M")" = "keep" ] \
  || { echo "FAIL: --force did not override the AUTO row"; exit 1; }
echo "   mark needs --force to override an AUTO row, and --force works: ok"
# put it back so the rest of the selftest sees the original plan
printf 'branch\tarchive-delete\t%s\n' "$AUTO_ROW" > "$D.auto"
$RH mark --repo cat/demo --from "$D.auto" --force >/dev/null
rm -f "$M.probe" "$D.bad" "$D.auto"
echo "== apply (dry)"; $RH apply --repo cat/demo | tee "$T/dry.txt"
grep -q 'push origin --delete feature/rpushed' "$T/dry.txt" || { echo "FAIL: dry run did not plan the remote deletion"; exit 1; }
if grep -qE 'push origin --delete (feature/rkeep|feature/rahead|release/v1)' "$T/dry.txt"; then echo "FAIL: dry run plans to delete a branch that must stay on origin"; exit 1; fi
SHAS="$(for b in feature/merged feature/squashed feature/unique feature/wtdirty; do g rev-parse "$b"; done)"
STASH_NAMED="$(g stash list --format=%H | tail -1)"
echo "== apply --execute"; $RH apply --repo cat/demo --execute
echo "== state after apply"; g branch --list | sed 's/^/   /'; g worktree list | sed 's/^/   /'; g stash list | sed 's/^/   /'
test -z "$(g branch --list feature/merged feature/squashed feature/unique feature/wtdirty)" || { echo "FAIL: branches not deleted"; exit 1; }
# remote side of the default rule
on_origin() { git -C "$T/origin.git" rev-parse --verify -q "refs/heads/$1" >/dev/null; }
on_origin feature/rpushed && { echo "FAIL: feature/rpushed is still on origin"; exit 1; }
on_origin feature/rkeep   || { echo "FAIL: keep-remote.txt was ignored; feature/rkeep left origin"; exit 1; }
on_origin feature/rahead  || { echo "FAIL: deleted a branch whose origin tip was not archived"; exit 1; }
on_origin release/v1      || { echo "FAIL: deleted a protected branch on origin"; exit 1; }
test -z "$(g branch --list feature/rpushed feature/rkeep feature/rahead)" || { echo "FAIL: the three remote-case branches should be deleted locally"; exit 1; }
test -n "$(g branch --list release/v1)" || { echo "FAIL: a protected branch was deleted locally"; exit 1; }
grep -q feature/rpushed "$T"/.archive/cat__demo/*.remote-deleted.tsv || { echo "FAIL: remote deletion not recorded"; exit 1; }
echo "   remote rule: merged branch removed from origin; keep-remote, unarchived-tip and protected branches stayed: ok"
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
# A tag sharing a branch's name makes %(refname:short) return "heads/<name>", which then fails
# to resolve as refs/heads/<name> (regression: Luci.Shopping.UI release/v87.1).
g checkout -q develop; g branch -q release/v9.9 2>/dev/null || true; g tag release/v9.9 2>/dev/null || true
$RH audit --repo cat/demo --no-fetch >/dev/null 2>&1
$RH manifest --repo cat/demo --force >/dev/null 2>&1
BAD="$(awk -F'\t' '!/^#/ && $1=="branch" && $4 ~ /^heads\//' "$T/.archive/cat__demo/manifest.tsv" | wc -l | tr -d ' ')"
test "$BAD" = "0" || { echo "FAIL: $BAD branch row(s) carry a heads/-prefixed name from a tag collision"; exit 1; }
awk -F'\t' '!/^#/ && $1=="branch" && $4=="release/v9.9"' "$T/.archive/cat__demo/manifest.tsv" | grep -q . || { echo "FAIL: the colliding branch is not in the manifest under its real name"; exit 1; }
echo "   tag/branch name collision resolves to the real branch name: ok"
echo "   no-integration-target repo: $(awk -F'\t' '!/^#/ && $1=="branch"' "$M2" | wc -l | tr -d ' ') branch rows, 0 auto-deletes, review required: ok"
g for-each-ref refs/archive --format='   restored %(refname)'
echo "SELFTEST PASSED"
