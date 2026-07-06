# Hermes ⇄ Docker MCP Toolkit — Connect & Stay-in-Sync Plan

**Author:** Claude (Fable / Opus 4.8) for @andyb · **Date:** 2026-07-02
**Ticket:** WR-18897 (local AI coding harness)
**Status:** EXECUTED (same-machine spine, 2026-07-03) — see the Execution log below.
Refines the earlier draft of this file and the Hermes onboarding shipped in
`559303f` / `dcf059b` / `355e83f`.

---

## Execution log (2026-07-03)

The §1–§4 same-machine spine is built, run, and verified on this machine:

- **`onboarding_bin/connect-hermes-mcp.sh`** — new; idempotent, `--soft`/`--dry-run`,
  full-docker-path entry, verify gate, OAuth manual-gate listing, rollback hint.
- **`onboarding_bin/install-hermes-agent.sh`** — chained as best-effort step 3
  (after the rs-agents skills sync), same `--soft`-non-fatal pattern.
- **Live result:** `MCP_DOCKER` inserted into `~/.hermes/config.yaml`
  (diff vs backup = exactly the 9-line `mcp_servers` block; comments intact);
  `hermes mcp test MCP_DOCKER` connected in 21 s and discovered **289 tools**
  across the 18 servers of the `default` profile; re-run → `UNCHANGED` no-op;
  shellcheck clean.
- **One deliberate deviation from §4:** the upsert uses **Hermes' own config API**
  (`hermes_cli.mcp_config._save_mcp_server` via the venv Python Hermes ships) instead
  of `yq` — the plan's own named alternative. Rationale: `yq` is not installed and not
  in `Brewfile.base`, while the Hermes API is guaranteed present whenever Hermes is
  (zero new dependency), and it runs the same security validation, config lock,
  default-stripping, and atomic write as `hermes mcp add`. The `yq` preflight in §4 is
  therefore superseded.
- **Open items resolved:**
  - **§5.2 — resolved.** `cmd_mcp_add` writes only `command`/`args`/`env`; there is no
    per-server tool-filter key (filtering is agent-level `enabled_toolsets`/
    `disabled_toolsets`). A bare entry registered all 289 gateway tools, as designed.
  - **O1 — half-resolved (the Hermes half).** Hermes *does* implement dynamic tool
    discovery for `notifications/tools/list_changed`
    (`tools/mcp_tool.py:1511–1584`, `tools/registry.py:368`). Unverified half: whether
    the docker gateway *propagates* the notification when `--watch` reconfigures it.
    Until tested (add a Toolkit server while a Hermes session is open), the posture
    stays reconnect-on-demand; the mini-only launchd timer (Layer B.2) remains
    **not built** per the plan's own gate.
  - **O3 — moot for automation** (the script never uses `hermes mcp add`); left as a
    doc caveat for the manual convenience path only.
  - **D1 = same-machine shipped now; §7 deferred** to a follow-up ticket.
    **D2 = `default` profile** (env-overridable via `MCP_PROFILE=<id>`).
    **D3 = Docker stays a documented prerequisite** (no change to `meta/profiles/ai`).
- **Code review (rs-agents code-reviewer): approved with warnings — both fixed.**
  (1) daemon-down path no longer prints a false "connected" success (message is now
  conditioned on the daemon being up); (2) the live verify is capped by
  `run_with_timeout` (`timeout`/`gtimeout`/perl-alarm fallback, 180 s default,
  `HERMES_TEST_TIMEOUT` override) so a wedged gateway can never stall a piped
  `./install-profile ai`; (3) the private-API coupling to
  `hermes_cli.mcp_config._save_mcp_server` is now called out in a comment for
  post-`hermes update` diagnosability. Re-verified after the fixes: shellcheck clean,
  re-run `UNCHANGED`, live connect 20.8 s / 289 tools.
- **Not done here:** §5.6 (fold into the `local-development-setup` skill) — that skill
  lives in Wayroo.tools and ships via its own Jira → PR → `reload plugins` flow.

**Goal (SO THAT):** wire the Hermes AI harness to the machine's Docker Desktop
**MCP Toolkit** profile — and keep that connection correct as MCP servers are added,
updated, or removed in the Toolkit — **SO THAT** any local model driven by Hermes gets
the same live tool plane Claude Code already has, on every engineer's machine, with
zero hand-copying and no secrets in git.

**Scope note.** The primary target is the *same-machine* case the request describes:
Hermes talks to the Toolkit on whatever box runs it. §7 generalizes the same mechanism
to provisioning a *fresh* machine (mac-mini / teammate), which is a strictly larger
problem (secrets, OAuth) and is kept separate on purpose.

---

## 0. What we verified on this machine (2026-07-02)

These are the load-bearing facts the design rests on — all confirmed, not assumed.

### Hermes DOES consume MCP servers (this unblocks the whole plan)
- `hermes mcp` is a full CLI subcommand: `add` / `remove` / `list` / `test` /
  `configure` / `login` / `reauth` / `install` / `serve`.
  (`~/.hermes/hermes-agent/hermes_cli/subcommands/mcp.py`)
- MCP servers are stored in **`~/.hermes/config.yaml` under a top-level `mcp_servers:`
  dict** — one entry per server. CRUD writes go there via `_save_mcp_server()`
  (`hermes_cli/mcp_config.py`). There is **no** separate `mcp.json` or DB table.
  *(Note: the live `config.yaml` on this box has no `mcp_servers:` key yet — Hermes is
  installed but has never had an MCP server added. That is exactly the gap this plan
  closes.)*
- Transports supported: **stdio** (`command` + `args` + `env`), **HTTP/streamable**
  (`url` + `headers`), and **SSE** (`url` + `transport: sse`). A `url` key routes to
  HTTP; otherwise stdio (`tools/mcp_tool.py:_is_http()`).
- Each stdio server is spawned as its **own long-lived background subprocess** at
  session start, and its tool list is registered **at connect** (`_connect_server()`,
  `tools/mcp_tool.py`). → **A change to the Toolkit's server set is not guaranteed to
  appear in a running Hermes session** without a reconnect/restart. See §3.

**Consequence:** `docker mcp gateway run` slots into Hermes as a single **stdio**
`mcp_servers` entry — exactly the shape Claude Code uses for `MCP_DOCKER`. One entry,
all Toolkit tools multiplexed behind it. No gateway-awareness code needed in Hermes.

### The `docker mcp` CLI (verified via `--help` + live `profile show`)
1. **`docker mcp gateway run`** is local **stdio** — no url, no auth token to configure
   (that is confirmed already in `mac-mini-mcp-bootstrap.sh`). This is what Hermes spawns.
2. **`docker mcp gateway run --profile <id>`** pins the gateway to a specific profile
   (`--profile` is mutually exclusive with `--servers`/`--enable-all-servers`). Pinning
   makes Hermes' toolset explicit and versioned instead of "whatever `default` is."
3. **`docker mcp gateway run --watch`** is **on by default** — the gateway "watches for
   changes and reconfigures" itself. So when you add/remove a server in the Toolkit UI
   or CLI, the *gateway* picks it up live. (What a *client* sees is the §3 nuance.)
4. **`docker mcp gateway run --secrets docker-desktop`** (default) — the gateway reads
   secrets from **Docker Desktop's Keychain**. The client (Hermes/Claude Code) never
   handles secret values. A `.env` path is an escape hatch (plaintext at rest — avoid).
5. **`docker mcp profile export/import`** — export is YAML with the server list, pinned
   image digests, per-server config, and secret **names only (never values)** →
   git-safe. **`profile push/pull`** move a profile via an OCI registry (e.g. GHCR).
6. **`docker mcp secret`** has only `set` / `ls` / `rm` — **no get/export.** Secret
   *values* cannot be read back out. (Only matters for §7 fresh-machine provisioning;
   irrelevant to the same-machine case, where the values are already in the Keychain.)
7. Profiles present on this box: `default` (18 servers), `dev_workflow`,
   `terminal_control`. Per-server config in `~/.docker/mcp/config.yaml` carries identity
   (`andyb@retailsuccess.com`, `filesystem.paths`) — must be templated for §7 reuse.

---

## 1. Design — the same-machine spine (this is the whole answer for the request)

```
  ~/.docker/mcp/  ── profile "rs-agent" (or default) ──┐
   registry.yaml (servers)   config.yaml (identity)    │
   Keychain (secret VALUES)                            │
                                                       ▼
            docker mcp gateway run --profile rs-agent   (stdio, --watch, --secrets docker-desktop)
                                                       │
                     ┌─────────────────────────────────┴───────────────────────────┐
                     ▼                                                               ▼
   Claude Code  ~/.claude.json  MCP_DOCKER                        Hermes  ~/.hermes/config.yaml
     "docker mcp gateway run …"                                     mcp_servers.MCP_DOCKER:
     (already wired)                                                  command: docker
                                                                      args: [mcp, gateway, run, --profile, rs-agent]
```

**Principle:** Hermes points at the **gateway**, not at individual servers. The Toolkit
(registry + Keychain) is the single source of truth for *what tools exist* and *their
secrets*. `--watch` keeps the gateway current. The engineer's own Docker Desktop supplies
servers; the engineer's own Keychain supplies secrets. This is **per-machine-correct by
construction** — identical wiring on every box, nothing machine-specific committed.

**The exact Hermes entry** (idempotently written by the onboarding script — see §4):

```yaml
# ~/.hermes/config.yaml   (top-level mcp_servers dict)
mcp_servers:
  MCP_DOCKER:
    command: docker                                    # or full path — see §4 launchd note
    args: [mcp, gateway, run, --profile, default]      # profile: D2 (lead with `default`)
    env: {}                                             # no secrets here — gateway owns them
    # NB: deliberately NO tool-filter key → all gateway tools enabled (the gateway already
    # gates the server set; we don't want Hermes second-guessing it). Confirm in §5.2.
```

**Do NOT provision this with `hermes mcp add`.** Per the verified `add` flow, that command
is **interactive** — it runs a security probe and then presents a *tool-selection
checklist* on the tty. Under `./install-profile ai` (dotbot, piped, no tty, `--soft`),
an interactive `add` would hang, fail, or silently default the tool set — breaking the
zero-touch / idempotent invariant we inherit from WR-18897. So:
- **Primary path (automation): a structure-safe YAML upsert** of the block above into
  `~/.hermes/config.yaml`. This also matches the existing pattern — `sync-rs-agents-to-
  hermes.sh` writes Hermes state directly and never invokes an interactive `hermes`
  command. `config.yaml` is a large structured file (`_config_version: 31`, many
  sections), so a naive append corrupts it: use `yq` (or Hermes' config API) for an
  idempotent, structure-preserving `mcp_servers.MCP_DOCKER` set. §4 details this.
- **Manual convenience only:** `hermes mcp add MCP_DOCKER --command docker --args …`
  when a human is at a terminal and wants the interactive tool picker.

**Why name it `MCP_DOCKER`:** matches the Claude Code entry name, so the two harnesses
present the same server identity and the mental model is one-to-one.

**Profile choice (decision D2, §8):** for the literal ask — connect to *"my profile"* —
lead with the machine's existing **`default`** profile (the 18-server set already in use;
zero extra setup; it *is* "my profile"). Offer a pinned dedicated **`rs-agent`** profile
as a versioning enhancement (explicit, reproducible, reviewable) — not the default choice.

---

## 2. Secrets — nothing to build for the same-machine case

Because Hermes talks to the gateway and the gateway reads `--secrets docker-desktop`:
- **Secret values never touch Hermes, never touch this repo, never touch git.** They stay
  in the macOS Keychain where `docker mcp secret set` already put them.
- Adding the Hermes entry grants Hermes exactly the tools the Keychain already unlocks —
  no token plumbing, no vault, no `.env`.
- **OAuth servers** (`atlassian-remote`, `sentry-remote`, GitHub OAuth) are already
  authorized on this machine for Claude Code's use of the same gateway; Hermes inherits
  that through the shared gateway. Nothing to re-authorize for the same-machine case.

The vault / token-injection problem the earlier draft treated as *blocking* only exists
when standing up a **fresh** machine — see §7. It does **not** block this request.

---

## 3. Staying in sync — detection + resync (the second half of the ask)

Two layers move independently. Be precise about which one `--watch` covers.

### Layer A — the gateway ↔ the Toolkit  ✅ automatic, nothing to build
`docker mcp gateway run --watch` (default on) reconfigures the running gateway when a
server is added / updated / removed in the Toolkit (via Docker Desktop UI or
`docker mcp profile server add|rm`). No script, no hook, no launchd unit — it is **free**.
Precision: `--watch` keeps the *gateway* current; it does **not** by itself refresh a
*running Hermes session's* view of the tools (that is Layer B / O1). What always picks up
a change on the Hermes side is a fresh connect — every new session gets the current set;
a live session needs the O1 answer.

### Layer B — a running Hermes session ↔ the gateway's current tool set  ⚠️ the one caveat
Hermes registers a stdio server's tools **at connect** (§0). Whether a *live* Hermes
session sees a mid-session tool change depends on whether Hermes honors the MCP
`tools/list_changed` notification or caches the list until reconnect. Evidence (long-
lived task, tools registered at connect) points to **cached-until-reconnect**, but this
was not confirmed by running the binary (blocked in this environment).

**Conservative, low-cost resync design (works regardless of which is true):**
1. **Default posture — reconnect on demand.** Adding/removing a Toolkit server is rare
   and deliberate. After such a change, the next new Hermes session already sees the new
   set (fresh connect). For a long-running session, `hermes mcp test MCP_DOCKER` (or
   remove+re-add, or restart the session) forces a reconnect. Document this one-liner;
   don't build machinery for a rare manual action.
2. **Always-on box only (mac-mini) — bounce on drift.** Reuse the *existing* proven
   launchd pattern (`com.retailsuccess.rs-agents-sync`, hourly, from `355e83f`). Add a
   sibling timer `com.retailsuccess.mcp-toolkit-watch` that:
   - hashes the Toolkit server set — **prefer a hash of `~/.docker/mcp/registry.yaml`
     over the `servers:` names from `docker mcp profile show`**: the registry hash also
     catches an *in-place* server update (same name, new pinned image digest / config),
     which a names-only hash would miss,
   - compares to the last-seen hash,
   - on change, forces the always-on Hermes session to reconnect so the new tool list is
     picked up. **Mechanism to confirm before building (O2):** the plan does *not* assume
     a `hermes gateway restart` command — that is not among the verified `hermes mcp`
     subcommands in §0 and was not confirmed (binary blocked here). The concrete,
     already-verified fallback is to **reload the always-on launchd unit**
     (`launchctl kickstart -k …`), which respawns Hermes and thus re-connects the gateway
     from scratch. Config-only; touches no secrets and no git.
   This is *optional* and *mini-only* — a 16 GB laptop does not need it (same call the
   team already made for the Ollama plist, which is intentionally not loaded on laptops).

**Verify `tools/list_changed` before building Layer B.2 — it's a two-link chain, test
both.** Live zero-touch sync requires: (a) the docker gateway **propagates** a
`tools/list_changed` notification downstream when `--watch` reconfigures it, AND (b)
Hermes **honors** that notification and re-lists mid-session. One cheap check on a box
where `hermes` runs: add a server to the Toolkit while a Hermes session is open and see
if the new tool appears without a restart. If *both* links hold, Layer B.2 collapses to
*nothing* and `--watch` alone covers everything. If *either* fails, the restart-on-change
default (B.1/B.2) covers it. Do not overclaim "Hermes honors list_changed" alone buys
live sync — the gateway must propagate it too. **Open item O1.**

### What is explicitly NOT built (avoid over-engineering)
- No per-server sync into Hermes. Hermes holds **one** entry (the gateway); the server
  *set* lives in the Toolkit, not duplicated in Hermes config.
- No polling of individual servers, no secret re-injection loop on the same machine.
- No hiding of failures: do **not** use `hermes -z` (silences all errors,
  `oneshot.py:148`) or `docker mcp gateway run --secrets` to a plaintext `.env` to
  paper over a locked Keychain.

---

## 4. Integration with the onboarding flow (dotbot + WR-18897 zero-touch)

Mirror how rs-agents skills were wired into Hermes in `dcf059b`/`355e83f`: a best-effort,
idempotent step hung off the Hermes install, gated on the tools existing.

### New script — `onboarding_bin/connect-hermes-mcp.sh` (idempotent, `--dry-run`)
Modeled on `sync-rs-agents-to-hermes.sh` (same `set -euo pipefail`, `PATH` export for
launchd, `bold/step/warn` helpers, `--soft` mode that never fails the install):
1. **Preflight (soft):** need `docker`, `docker mcp`, `hermes` on PATH, **and `yq`**
   (the structure-safe upsert tool — step 3). Any missing → warn + exit 0 under `--soft`
   (Hermes install still succeeds; run later).
   - **Runtime dependency to name, not to block on:** the wiring is written even if Docker
     Desktop is *installed but not running* — but `docker mcp gateway run` (and therefore
     every live Hermes session and the §4.4 verify gate) only works once the **daemon is
     up**. This is a session-time dependency, not an install-time one. Mirror
     `mac-mini-mcp-bootstrap.sh` step 1: if `docker info` fails, warn "start Docker
     Desktop, wait for green, then the gateway connects" (and `open -a Docker` on the
     mini). The entry is still written; it simply activates when the daemon comes up.
     The verify gate surfaces a down daemon loudly (not silenced, per §6).
2. **Ensure the profile exists (only if using a pinned `rs-agent` profile, D2):**
   `docker mcp profile show rs-agent` or create/import from the committed profile YAML
   (§7). For the plain `default` case, skip.
3. **Wire Hermes idempotently — via structure-safe YAML upsert, NOT `hermes mcp add`**
   (which is interactive; see §1). Use `yq` (or Hermes' config API) to set
   `mcp_servers.MCP_DOCKER` in `~/.hermes/config.yaml`: absent → insert; present and
   identical → no-op; present and stale (wrong args/profile) → update in place. Must
   preserve every other section of the large `config.yaml` (`_config_version`, etc.) and
   never clobber unrelated `mcp_servers` entries. Fail loudly if `yq` is unavailable
   rather than hand-editing YAML with `sed`/`echo`.
4. **Verify gate** (same philosophy as `verify-ollama-hermes.sh` layers):
   `hermes mcp list` shows `MCP_DOCKER` · `hermes mcp test MCP_DOCKER` connects · the
   gateway tool count matches `docker mcp profile show`. Under `--soft`, verify is
   best-effort.
5. **Print manual gates** (only what's genuinely interactive): first-run OAuth
   `docker mcp oauth authorize <name>` if any OAuth server isn't yet authorized on this
   box. (Same-machine: usually already done for Claude Code.)

### Hook it into the Hermes installer
In `onboarding_bin/install-hermes-agent.sh`, after the rs-agents skills sync block, add
a third best-effort step calling `connect-hermes-mcp.sh --soft` — same pattern, same
"non-fatal" guard. `./install-profile ai` then stands up the *whole* harness: Ollama →
Hermes → rs-agents skills → **Toolkit tool plane**.

### Profile / config file touch-list
- **`onboarding_bin/connect-hermes-mcp.sh`** — new.
- **`onboarding_bin/install-hermes-agent.sh`** — add the one best-effort call.
- **`meta/profiles/ai`** — currently just `hermes`. Optionally add a `docker` config so
  `./install-profile ai` also guarantees Docker Desktop is present (or keep Docker a
  documented prerequisite, matching `mac-mini-mcp-bootstrap.sh` step 0). Decision D3.
- **`meta/configs/hermes.yml`** — unchanged (it already invokes the installer, which now
  chains the MCP connect).
- **`mac-mini-agent/provision-coding-harness.sh`** — add the optional Layer B.2 launchd
  timer for the always-on box only (mirrors the `rs-agents-sync` timer it already
  installs). **Not** loaded on laptops.

### Rollback / unwiring (one-step revert, per repo release discipline)
The change is additive but must be reversible in one step:
- **Remove the Hermes wiring:** `hermes mcp remove MCP_DOCKER` (or delete the
  `mcp_servers.MCP_DOCKER` block from `~/.hermes/config.yaml` via `yq`). Hermes then runs
  exactly as before — this touches nothing else.
- **Stop chaining it on install:** revert the one best-effort call added to
  `install-hermes-agent.sh`.
- **Mini-only:** unload + remove the `com.retailsuccess.mcp-toolkit-watch` launchd unit
  (`launchctl bootout …` + delete the plist) — same teardown as the existing
  `rs-agents-sync` timer.
Since Claude Code's `MCP_DOCKER` wiring is entirely independent, reverting the Hermes side
never affects Claude Code's access to the same gateway.

### Failure mode to design for: the spawned `docker` subprocess environment
The entry's `env: {}` is correct for secrets (the gateway owns them). But when Hermes
runs **always-on under launchd on the mini**, the `docker mcp gateway run` subprocess
inherits launchd's **minimal environment** — `docker` may not be on PATH and the Docker
context/`DOCKER_HOST` may not resolve. This is the exact minimal-env problem that forced
the explicit `PATH` export in `sync-rs-agents-to-hermes.sh`. Mitigate at §1's entry:
either use a **full path** in `command` (e.g. `/usr/local/bin/docker` /
`/opt/homebrew/bin/docker`) or set a minimal `env` (`PATH`, and `DOCKER_HOST` if the
socket isn't default). The §4.4 verify gate (`hermes mcp test MCP_DOCKER`) surfaces this
loudly at connect — a broken connection fails visibly, it is not silenced. Same-machine
laptop (interactive login shell) is not affected; this is a mini/launchd concern.

### Idempotency & zero-touch invariants (match the WR-18897 bar)
- Re-runnable: every step checks-then-acts; second run is a no-op.
- `--soft` on the onboarding path: a missing Docker/Toolkit never fails a Hermes install.
- No secrets written anywhere by this flow (gateway owns them).
- Source of truth stays the Toolkit (same-machine) / the committed profile YAML (§7),
  never `~/.hermes/config.yaml` (which is a generated consumer, like `~/.hermes/skills`).

---

## 5. Sequencing

1. **Confirm O1** (both links: gateway propagates + live Hermes honors
   `tools/list_changed`?) on a box where `hermes` runs. Decides whether Layer B.2 is
   needed at all. *(cheap, 5 min)*
2. **§5.2 — Confirm the no-tool-filter default enables all gateway tools.** Write the
   bare `{command, args, env}` entry (no tool-filter key), start a session, and check
   `hermes mcp test MCP_DOCKER` / the tool count matches `docker mcp profile show`. If
   Hermes defaults a *bare* entry to zero/partial tools, the upsert must write the
   tool-enable field too. *(cheap, 5 min — do alongside step 1)*
3. Build `connect-hermes-mcp.sh` (+`--dry-run`); rehearse against the machine's `default`
   profile first, then a scratch `rs-agent-test` profile. *(the main build — small)*
4. Chain it into `install-hermes-agent.sh --soft`; dry-run `./install-profile ai`. *(small)*
5. **Only if O1 = not-live:** add the `mcp-toolkit-watch` launchd timer to
   `provision-coding-harness.sh` (mini-only). *(small, optional)*
6. Fold the working recipe into the `local-development-setup` skill (per DRY-RUN §8):
   "connect the local AI host to the Docker MCP tool plane."

---

## 6. Security guardrails
- Same-machine: **no secret ever leaves the Keychain**; nothing secret is written by this
  flow; `~/.hermes/config.yaml` holds only the gateway command, not tokens.
- Do **not** default the gateway to `--secrets <env-file>` (plaintext at rest). Only if a
  box is truly headless with a locked Keychain, and then the file is `chmod 600` outside
  the repo — an explicit decision, never a drift.
- Do **not** silence failures: no `hermes -z`, no swallowing gateway connect errors. The
  verify gate must surface a broken connection loudly.
- Per-machine OAuth is a feature: a copied profile YAML grants no access on its own.

---

## 7. Generalizing to a fresh machine (mac-mini / teammate) — SECONDARY, larger scope

The same-machine plan above needs none of this. It applies **only** when provisioning a
box that has *no* Toolkit servers/secrets yet — the earlier draft's abarrows→mac-mini
replication problem. Kept separate because it introduces the two hard parts the
same-machine case avoids: the server-set transport and the secret values.

- **Transport of the server set:** commit a **sanitized** `docker mcp profile export`
  (server list + config with identity templated from `.envrc`, secret *names* only, a
  grep gate proving zero secret *values*) to
  `mac-mini-agent/mcp/profile-rs-agent.yaml`; `docker mcp profile import` on the target.
  Fallback: `docker mcp profile push/pull` via GHCR if the YAML grows large.
- **Secret values:** the CLI can't export them (§0.6). A vault (1Password `op` or the
  company standard) is the only source of truth: `op read … | docker mcp secret set …`
  per required secret name. Missing vault item → fall back to the interactive
  `set_secret` prompt already in `mac-mini-mcp-bootstrap.sh` (never worse than today).
- **OAuth:** per-machine by design — the apply step ends by printing the exact
  `docker mcp oauth authorize <name>` commands to run interactively on the target.
- **24/7 survival:** keep `mac-mini-mcp-bootstrap.sh` §5 (auto-login, Docker autostart,
  `pmset` no-sleep, Keychain auto-unlock).
- **Housekeeping:** `ai/workflows/mac-mini-agent/` holds a stale rev-1 copy of
  DRY-RUN-PLAN.md + a duplicate bootstrap script — delete the copies (or symlink) so
  `mac-mini-agent/` is canonical. Retire the manual server-list/secret-prompt parts of
  `mac-mini-mcp-bootstrap.sh` once the export/apply flow covers them; keep its §5.

---

## 8. Open decisions & items

- **O1 (blocks only Layer B.2):** Two-link chain for live sync — does the docker gateway
  *propagate* `tools/list_changed` on `--watch` reconfigure, AND does a running Hermes
  session *honor* it (vs. caching tools until reconnect)? Test both empirically (§5.1).
  Only if both hold does `--watch` alone become the entire sync story with no launchd
  timer. Either failing → keep the restart-on-change default.
- **O2 (blocks only Layer B.2 mechanism):** Confirm how to force a live Hermes reconnect
  — is there a `hermes gateway restart` (unverified; not in the §0 subcommand list)?
  If not, the launchd-unit reload (`launchctl kickstart -k`) is the verified fallback.
- **O3 (blocks only the CLI convenience path):** Verify that
  `hermes mcp add MCP_DOCKER --command docker --args mcp gateway run --profile default`
  passes `--profile`/trailing args through to the gateway subprocess rather than having
  Hermes' own parser consume them (a `--` separator or quoting may be required). The
  automation path uses the unambiguous YAML upsert and is unaffected; this only gates the
  documented manual convenience command in §1.
- **D1:** Same-machine only (this request) vs. also build the §7 fresh-machine path now?
  Recommend: ship the same-machine spine first (small, complete answer), do §7 as its
  own follow-up ticket.
- **D2:** For the literal "connect to *my* profile" ask, lead with the machine's existing
  **`default`** profile (zero extra setup; it *is* "my profile"). A pinned dedicated
  **`rs-agent`** profile is the versioning enhancement (explicit/reproducible) — same
  choice as pinning `--profile` on the Claude Code side.
- **D3:** Make `docker`/Docker-Desktop a `meta/profiles/ai` dependency, or keep it a
  documented prerequisite (matches today's bootstrap step 0)?
- **D4 (only if §7 is taken):** vault choice (1Password `op` vs company standard);
  agent-box-scoped tokens vs reusing andyb's.
