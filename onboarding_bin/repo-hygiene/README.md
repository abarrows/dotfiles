# repo-hygiene

Keeps `~/Retail-Success/repos/*` down to active work: branches, stashes and worktrees.
`audit` → `manifest` → decide → `apply` (dry-run) → `apply --execute` → `verify`.

## Removal means local **and** origin

Unless told otherwise, when a branch is set to `archive-delete`, `apply --execute` deletes it on this
machine **and** on origin, after the bundle is written and verified. It will not delete on origin when:

| Reason | Why |
|---|---|
| the branch is protected (`develop`, `main`, `release/*`, …) or is the default | never auto-removed anywhere |
| it has an open PR | the PR would be orphaned |
| origin's tip has commits the archive does not hold | someone pushed more; deleting would lose them |
| `gh` cannot confirm there is no open PR | fails closed |
| it is named in `.archive/<repo>/keep-remote.txt` | one branch name per line; that is how you say "local only" |

`apply --local-only` turns the origin step off for a whole run. Every origin deletion is written to
`.archive/<repo>/<ts>.remote-deleted.tsv` (name, tip), and the tip is in the bundle, so
`git push origin <tip>:refs/heads/<name>` puts it back.

Stashes and worktrees have no remote; they are removed locally as before.

## Alerts

Notifications come from **Repo Hygiene Alerts** (`alerts/`, build with `alerts/build.sh`). A plain
`osascript display notification` is attributed to Script Editor and opens a blank one when clicked.
This app posts under its own name, and clicking it opens `~/Library/Logs/repo-hygiene/latest-report.md`,
which lists each item with the command that clears it.

- `hooks/worktree-leftovers.sh` (SessionEnd) reports only **stale** worktrees: merged, deleted on origin,
  or idle 14+ days. A worktree you are using is never listed, and nothing is removed.
- `sweep.sh` (weekly, report-only until `~/.config/repo-hygiene/policy` says `safe`) also reports
  branches deleted on origin that are still here, **including protected ones** (`PROTECTED_REMOTE_GONE`).
