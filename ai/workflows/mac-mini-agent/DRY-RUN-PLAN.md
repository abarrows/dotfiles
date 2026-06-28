# Local‑AI Agent Host — Dry‑Run Plan

**Author:** Claude (Opus 4.8) for @andyb · **Date:** 2026‑06‑28
**Dry‑run target:** `rss-mbp-5` (your MacBook — daily driver) · **Promotion target:** the mac‑mini (24/7 box)
**Status:** PLAN — nothing executed yet. Uncommitted.

> **Thesis.** Across your 06‑19 → 06‑28 sessions you've been building toward one thing from
> several angles: **a mac‑mini that runs your full AI tooling as an always‑on agent.** The pieces
> already exist but were assembled in separate conversations and never wired together:
> the dotfiles `onboard.sh` *installs* everything, `mac-mini-mcp-bootstrap.sh` *wires the tools (MCP)*,
> the `wayroo-demo` work *proved the always‑on pattern (init‑check → launchd → health probe)*, and
> Ollama + Hermes are *installed but unconfigured*. **"Next level" = unify those fragments into one
> coherent, reversible flow.** **"Dry run" = rehearse that whole flow ephemerally on `rss-mbp-5`
> (stand up → validate → tear down) before it touches the mini or production `onboard.sh`.**

---

## 1. Objectives — recovered from repeated mentions (with evidence)

Each objective below is something you said **more than once, across more than one session**. Frequency
and a representative quote are cited so you can audit the recovery. Where the transcripts left a gap,
the choice is explicitly marked **[my recommendation, not your stated requirement]**.

| # | Objective | Evidence (sessions) |
|---|-----------|---------------------|
| **O1** | **Provision the mac‑mini as a 24/7 always‑on agent box** running your full AI tooling + plugins. *(most‑repeated)* | `"We have a macmini that we are provisioning to be an always on bot that can leverage our full AI tooling, integrations, and those plugins."` — 06‑23 (repeated); 06‑28 `"the mac-mini that will be used for 24/7 agent use"` |
| **O2** | **A clean, idempotent, reversible one‑liner dotfiles onboarding** (`onboard.sh`). Hardened every session: `.env` prompts must run **before** dir creation; alias/`.envrc` pathing; VS Code symlinks; brew recipes. | 06‑19, 06‑22, 06‑26, 06‑28 (branch `feature/WR-18897-onboarding-dotfiles-hardening`) |
| **O3** | **Add Ollama + local models** to the stack. | 06‑28 `/compact`: `"add in using ollama and being able to use local models"` — installed via `Brewfile.base` line 19, never configured |
| **O4** | **Hermes Agent** as the self‑improving coding agent, routing between **local (Ollama)** and **cloud** models. | `Brewfile.base` line 14 `hermes-agent` "Coding harness and agent that self learns"; 06‑27 commit `4b88178`; raised on the mini 06‑28 |
| **O5** | **rs‑agents plugin as the brain** of the box — `init-check` gate → launchd always‑on → health/registry probe. | 06‑23 `wayroo-demo`: registry, `init-check`, launchd units (`RunAtLoad`/`KeepAlive`), health probe on :8765 |
| **O6** | **Fold learnings back into rs‑agents** skills/knowledge (`local-development-setup`, `developer-onboarding`) + maybe a new skill/workflow. | 06‑28 (verbatim): `"Use the /rs-agents:rs-agents and the /skill-creator to update /local-development-setup and/or the /developer-onboarding skill. From our learnings today, extract any wisdom we've gained..."` |
| **O7** | **Safety throughout** — idempotent, re‑runnable, reversible, dry‑run‑able. | `onboard.sh` "Re‑running is safe"; `ONBOARDING-PLAN.md` "Treat the Mini as the test bed" |

**Resolved open question:** "hermes" — unclarified in the 06‑28 Luci session — is **Hermes Agent by Nous
Research** (`hermes-agent.nousresearch.com`): *"a self‑improving AI agent that creates skills from
experience."* Its CLI (`model` / `moa` / `fallback` / `proxy` / `mcp` / `skills`) is what makes O3+O4 one
architecture, not two.

---

## 2. How the pieces fit (the architecture you're actually building)

```
                         ┌─────────────────────────────────────────────┐
                         │  rs-agents plugin  (the "team"/brain)          │
                         │  orchestrator → specialist sub-agents          │
                         │  gate: init-check  ·  always-on: launchd       │
                         └───────────────┬─────────────────────────────┘
                                         │ uses
            ┌────────────────────────────┼────────────────────────────┐
            │ MODEL/AGENT RUNTIME PLANE   │            TOOL PLANE        │
            ▼                             ▼                             ▼
   ┌──────────────┐            ┌────────────────────┐        ┌────────────────────┐
   │   Ollama     │◀──/v1──────│   Hermes Agent     │        │ Docker MCP Toolkit │
   │ local models │  OpenAI-   │ routes local+cloud │        │  17 MCP servers    │
   │ :11434       │  compat    │ fallback · moa     │        │  gateway (stdio)   │
   └──────────────┘            └────────────────────┘        └────────────────────┘
            ▲                             ▲                             ▲
            └─────────────── installed by ── dotfiles onboard.sh / Brewfile ──┘
```

- **Ollama** = local model **server** (OpenAI‑compatible at `:11434/v1`). Already installed.
- **Hermes** = agent **runtime** that points at Ollama for local inference, with a **fallback chain** to
  cloud when local can't cope, and self‑improving **skills**. Already installed (note: brew `hermes` is
  PATH‑shadowed by `~/.local/bin/hermes` — the pip build wins; that's the featureful one).
- **Docker MCP Toolkit** = the **tool plane** — already wired by `mac-mini-mcp-bootstrap.sh`.
- **rs‑agents** = the Claude‑Code **agent team**; `init-check` + launchd + health probe = the always‑on
  pattern from `wayroo-demo`.
- **dotfiles `onboard.sh`** = installs all of the above on a fresh Mac.

The **only missing wire** is the model/agent runtime plane (Ollama ↔ Hermes) and its always‑on form.
This plan stands that wire up — safely, on the laptop, first.

---

## 3. THE DRY RUN on `rss-mbp-5` (ephemeral · reversible · the core deliverable)

**Golden rule (daily‑driver safety):** the dry run installs **nothing persistent** — **no launchd units,
no `brew services`, no auto‑login, no sleep changes**. Everything runs in the foreground or in a sandbox
dir and is torn down by one command block. The persistence belongs to the mini (§6).

Run inside a sandbox so nothing leaks into your real config:

```bash
export DRY=~/.local/state/local-ai-dryrun         # sandbox for logs/config
mkdir -p "$DRY" && cd "$DRY"
```

Each step is **COMMAND → OBSERVABLE PASS CRITERION**. If a step's criterion isn't visibly met, stop.

### Step 0 — Preflight snapshot *(read‑only)*
```bash
for t in ollama hermes docker brew; do printf "%-8s %s\n" "$t" "$(command -v $t)"; done
ollama --version; hermes --version; docker --version
sysctl -n hw.memsize | awk '{print "RAM:", $1/1073741824 "GB"}'
```
**PASS:** all four resolve; you note your RAM (drives model choice below).

### Step 1 — Bring up Ollama ephemerally + pull one small model
```bash
ollama serve >"$DRY/ollama.log" 2>&1 &   echo $! > "$DRY/ollama.pid"   # foreground daemon, captured PID
sleep 2
ollama pull llama3.2:3b                    # ~2GB smoke model — fast, proves the path
curl -s http://localhost:11434/api/tags | jq '.models[].name'
curl -s http://localhost:11434/api/generate -d '{"model":"llama3.2:3b","prompt":"reply with the single word: ready","stream":false}' | jq -r .response
```
**PASS:** `/api/tags` lists the model **and** `/api/generate` returns text (≈ "ready").
**Model choice [my recommendation, not your stated requirement — no model was named in any transcript]:**
`llama3.2:3b` for the smoke test (small/fast); `qwen2.5-coder:7b` (~4.7GB) as the real coding model once
the path works. Rule of thumb: keep the model ≤ ~60% of RAM.

### Step 2 — Confirm Hermes routes to the LOCAL model ⚠️ *(the step to verify, not assume)*
Hermes consumes OpenAI‑compatible `/v1` providers; Ollama serves `http://localhost:11434/v1`. Confirm
Hermes can be pointed there (via `hermes model` picker with a custom `--inference-url`, a config entry, or
`-m … --provider …`). Then run one prompt and confirm it hit the **local** server:
```bash
: > "$DRY/ollama.log"                       # clear log so the next hit is unambiguous
hermes -z "Say hello in 5 words." -m llama3.2:3b --provider <ollama-openai-compat>   # exact flag TBD in spike
grep -i "POST /v1/chat/completions\|/api/chat\|llama3.2" "$DRY/ollama.log"           # proof the local model served it
```
**PASS:** Hermes returns a completion **and** `ollama.log` shows the request — i.e. inference was local.
**FALLBACK if Hermes won't point at Ollama directly:** use **LM Studio** (also in your Brewfile, serves
OpenAI‑compat) or call Ollama's `/v1` endpoint directly; either still satisfies O3. Record what worked —
that becomes the documented recipe (§5).

### Step 3 — MCP tool plane sanity *(lightweight — skip secrets in the dry run)*
```bash
docker mcp --version && docker mcp server ls 2>/dev/null | head
```
**PASS:** `docker mcp` responds and lists servers. (Full secrets/keychain wiring is a mini concern, §6 —
don't load real PATs on the laptop for a dry run.)

### Step 4 — rs‑agents gate: does the plugin load and register?
Reuse the **`init-check`** you built in `wayroo-demo` (the "FIRST GATE — near‑free, no gateway"). Intent:
confirm the rs‑agents plugin loads and the agents/skills register.
```bash
# from wherever your init-check lives (wayroo-demo); confirm path during the spike
npm run init-check        # expect: AGENTS non-empty (~25 agents, ~59 skills)
```
**PASS:** registry reports the agent/skill roster non‑empty. If empty → the plugin didn't load; fix
`RS_AGENTS_PATH` before going further.

### Step 5 — Health/registry probe (foreground, NOT launchd)
Run the demo server/health probe in the foreground and hit it once:
```bash
# foreground only for the dry run — no launchd, no KeepAlive
curl -s localhost:8765/health | jq .     # adjust to your wayroo-demo probe
```
**PASS:** health returns `healthy` with `maxConcurrency`/`waiting` populated.

### Step 6 — TEARDOWN (single block — leaves the laptop exactly as found)
```bash
kill "$(cat "$DRY/ollama.pid")" 2>/dev/null      # stop the ephemeral Ollama daemon
ollama rm llama3.2:3b 2>/dev/null                # optional: reclaim ~2GB
# stop any foreground demo server (Ctrl-C in its terminal)
rm -rf "$DRY"                                    # remove sandbox logs/config
# NOTE: nothing was added to launchd / brew services / login items — nothing to undo there.
```
**PASS:** `pgrep ollama` empty, sandbox gone, no launchd/login changes exist.

**Dry‑run definition of done:** Steps 1, 2, 4, 5 each hit their PASS criterion, and Step 6 returns the
machine to its prior state. That's a complete, observable rehearsal of the always‑on stack — minus the
"always‑on."

---

## 4. Run the dry run *through* the rs‑agents plugin (O5/O6)

You asked to **leverage the company rs‑agents plugin** — so don't run §3 by hand, drive it through the
orchestrator (and let it use the right specialists):

```
/rs-agents  →  "Execute the Local-AI Agent Host dry run in mac-mini-agent/DRY-RUN-PLAN.md §3 on this
                MacBook, ephemerally. devops-engineer owns the bootstrap/teardown; verify each step's
                observable PASS criterion before proceeding; do NOT install launchd/brew-services/login
                items; report a per-step pass/fail table."
```
- **devops-engineer** — runs/edits the bootstrap + teardown, owns Step 1–3, 5–6.
- **debugger** — if Step 2 (Hermes↔Ollama) doesn't route locally.
- **tech-writer / skill author** — captures the result into rs‑agents (§5).

---

## 5. Capture learnings → rs‑agents (O6 — the "fold it back in" you asked for 06‑28)

**Decision (your call):** **extend the two existing skills** — do *not* add a new skill file.

After the dry run proves the recipe, encode it (author in native dirs, then
`node ai/scripts/generate-index.js`, then bump the plugin `version` — per `ai/CLAUDE.md`):

1. **Extend `local-development-setup`** (`ai/skills/local-development-setup/SKILL.md`) — generic today
   (zero mention of dotfiles/mac‑mini/Ollama/Hermes/MCP). Add: the dotfiles `onboard.sh` one‑liner as the
   Retail‑Success Mac‑provisioning path, and a "**Local AI agent host**" section = the proven §3
   Ollama + Hermes + MCP recipe (incl. the Hermes↔Ollama wiring that actually worked) and the §6
   promotion steps. Widen the `description:` frontmatter to mention Mac provisioning + local‑model setup.
2. **Extend `developer-onboarding`** (`ai/skills/developer-onboarding/SKILL.md`) — add a pointer to the
   dotfiles one‑liner and a short "your machine can run local models" note that links to (1).
3. **Optional workflow** `ai/workflows/mac-mini-agent-bootstrap.md` — the deterministic always‑on runbook.
4. **Bootstrap upgrades** (dotfiles): add a real **`--dry-run`/`DRY_RUN`** mode to
   `mac-mini-agent/mac-mini-mcp-bootstrap.sh` (it has none today), and **extend it with the Ollama+Hermes
   section** the `/compact` note promised — gated so the laptop run is ephemeral.
5. *(Optional)* a `project`/`reference` memory recording that hermes = Nous Hermes Agent and the
   Ollama↔Hermes wiring that actually worked.

---

## 6. Promote to the mac‑mini — DOCUMENTED, **not** part of the laptop dry run (O1)

These are the *persistent* pieces. They belong on the mini only, after §3 passes:
- **Ollama as a service:** `brew services start ollama` (or a launchd plist) + pre‑pull the chosen models.
- **Hermes** default model/provider set to local, cloud **fallback** configured.
- **Always‑on rs‑agents:** the `wayroo-demo` launchd units (`RunAtLoad`, `KeepAlive`), health probe on :8765.
- **Headless survival (from `mac-mini-mcp-bootstrap.sh`):** auto‑login, Docker Desktop autostart,
  `pmset`/`systemsetup` no‑sleep, Keychain auto‑unlock, MCP secrets in Keychain.
- **Remote access:** add the mini to `~/.ssh/config` (not present today); Tailscale optional (no CLI yet).

---

## 7. Risks & guardrails
- **Daily driver:** `rss-mbp-5` is your work machine — the dry run must stay ephemeral (§3 golden rule).
- **Disk:** ~179 GB free — fine for a few quantized models; `ollama rm` in teardown if tight.
- **Don't touch production `onboard.sh`** until the recipe is proven; keep bootstrap changes behind `--dry-run`.
- **Secrets:** no real PATs/tokens on the laptop dry run — that's a mini‑only step.
- **PATH shadowing:** `~/.local/bin/hermes` shadows brew `hermes-agent`; pick one deliberately and pin it.
- **Hermes↔Ollama routing is unverified** — §3 Step 2 is the spike that confirms it; LM Studio is the fallback.

---

## 8. Decisions (made 2026‑06‑28)
1. **Plan is the deliverable** — no changes to `rss-mbp-5` yet. Review/iterate this doc; execute §3 later.
2. **Models:** `llama3.2:3b` (smoke) + `qwen2.5-coder:7b` (coding). ✔ (already in §3 Step 1)
3. **rs‑agents capture:** extend `local-development-setup` + `developer-onboarding`; **no new skill.** ✔ (see §5)

### When you're ready to run it
Re‑open this file and either drive §3 through `/rs-agents` (§4) or run the steps directly. Sequence:
§3 (dry run) → §5 (fold back into the two skills + add `--dry-run` to the bootstrap) → §6 (promote to mini).
