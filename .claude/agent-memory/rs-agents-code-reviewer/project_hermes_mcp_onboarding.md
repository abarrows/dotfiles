---
name: hermes-mcp-onboarding
description: Review observations for onboarding_bin Hermes/MCP wiring scripts — conventions, a verified false-success edge case, and real docker mcp output shapes
metadata:
  type: project
---

Onboarding bash scripts in `onboarding_bin/` that wire Hermes Agent to the Docker MCP Toolkit gateway (WR-18897 branch).

**Convention baseline** (all onboarding_bin scripts follow this): `set -euo pipefail`, `export PATH="$HOME/.local/bin:/opt/homebrew/bin:..."` for launchd, `bold()/step()/warn()` printf helpers, `--soft` semantics = missing prereq warns + exit 0 so the install never fails. Modeled on `mac-mini-agent/sync-rs-agents-to-hermes.sh`.

**Verified bug pattern — daemon-down false success** (connect-hermes-mcp.sh): when `docker info` fails, `DAEMON_UP=0` and the live-verify block is skipped, but `VERIFY_OK` stays initialized to 1, so the script prints "✔ Hermes is connected" even though it earlier warned "Live verification is skipped." **Why:** `VERIFY_OK` is only ever set to 0 inside checks that are gated behind `DAEMON_UP=1`. **How to apply:** when reviewing verify-gate scripts, check that the summary/success message is gated on the same condition as the checks that would justify it.

**docker mcp CLI output shapes (verified live 2026-07):**
- `docker mcp oauth ls` → `name | authorized|not authorized` table; awk `-F'|' /not authorized/` is a safe filter (no false-positive from "authorized" rows).
- `docker mcp profile show <p>` → server count = `grep -c '^    - type:'` (4-space indent); nested `snapshot.server.type:` lines are more deeply indented so they do NOT inflate the count. Cross-checks against `docker mcp profile server ls`.
- `docker mcp profile server ls` → `PROFILE | TYPE | IDENTIFIER` table, all profiles at once.

**Non-findings to NOT re-raise:** quoted heredoc `<<'PYEOF'` means MCP_PROFILE reaches Python as pure argv data (no injection); `|| true` after `grep -c` neutralizes pipefail-on-zero-match; `if not _save_mcp_server(...)` relies on a truthy return from a private Hermes API (nit at most).
