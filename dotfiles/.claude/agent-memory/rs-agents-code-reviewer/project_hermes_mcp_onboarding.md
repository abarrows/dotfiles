---
name: hermes-mcp-onboarding-review-notes
description: Review conventions for the mac-mini-agent Ollama+Hermes harness scripts — log paths, PATH export, set-flags, the on-demand-start blind spot
metadata:
  type: project
---

Review notes for `mac-mini-agent/` harness scripts (provision-coding-harness.sh, verify-ollama-hermes.sh, sync-rs-agents-to-hermes.sh, com.retailsuccess.ollama.plist).

**Ollama log paths (load-bearing for verify's local-routing proof).** The launchd unit `com.retailsuccess.ollama.plist` sets `StandardOutPath=/tmp/ollama.out.log` and `StandardErrorPath=/tmp/ollama.err.log`. Ollama writes its request/access log to **stderr** → `/tmp/ollama.err.log`. The on-demand start in provision-coding-harness.sh (`nohup ollama serve >/tmp/ollama.out.log 2>&1`) merges both streams into `/tmp/ollama.out.log`. So verify's `SLOGS="/tmp/ollama.err.log /tmp/ollama.out.log"` correctly covers BOTH deployment modes. When reviewing any change to verify's local-hit proof, re-check these two paths still match the plist + the on-demand redirect — if they drift, verify's hard-FAIL on empty proofs produces spurious "possible cloud fallback" failures on healthy machines.
**Why:** verify makes "both local-routing proofs empty" a hard FAIL; a log-path mismatch would fail a working setup.
**How to apply:** any SLOG/SLOGS or log-path edit → grep the plist Standard*Path AND the `ollama serve >...` redirect and confirm they are a subset of SLOGS.

**Cross-script conventions (all three scripts should stay identical here):**
- PATH export line is byte-identical: `export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"` (Apple-silicon + Intel brew prefixes + user-local).
- provision + sync use `set -euo pipefail`; verify deliberately uses `set -uo pipefail` (no `-e`) because it is a check-runner that tracks failures in `FAILED` and must reach its summary line. This asymmetry is correct, not a bug.

**Known non-blocking landmine (pre-existing, not introduced by the Sourcery fixes):** sync-rs-agents-to-hermes.sh line ~87 `hermes skills list | grep -c "rs-agents" | xargs …` under `set -euo pipefail` — if hermes ever reports ZERO rs-agents skills, `grep -c` exits 1, pipefail+`set -e` abort the script AFTER a successful sync, so the hourly launchd run logs a failure and skips the "✔ Sync complete" line. Happy-path safe (post-sync hermes normally reports ≥1).

**Out-of-scope arch note:** the plist `ProgramArguments` hardcodes `/opt/homebrew/bin/ollama` (Apple-silicon only). The script PATH-export changes are cross-arch, but the plist itself is not — an Intel always-on mini would fail to launch the unit. Flag if plist portability ever comes into scope.
