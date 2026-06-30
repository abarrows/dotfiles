# Local AI Coding Harness — Provisioning Plan

**Author:** Claude (Opus 4.8) for @andyb · **Date:** 2026‑06‑28 (rev 2)
**Stand‑up target:** `rss-mbp-5` (your MacBook) first → **promote to the mac‑mini** (24/7 box)
**Status:** PLAN — nothing executed. The only thing I'd run before you approve is the ~10‑min GO/NO‑GO spike in §3, and only if you say go.

> **What you actually want (clarified 06‑28):** *"Stand up the Hermes agent harness, connect Ollama to it,
> then talk to Hermes via Microsoft Teams and/or a dashboard that can be hit externally."* Provisioned by
> the **dotfiles**, so it's repeatable on the mini. And — **critically** — **rs‑agents must be accessible to
> whatever model is selected, at all times.** "Dry run" = a real first working stand‑up (not throwaway).
>
> **The good news:** Hermes Agent (Nous Research) has native machinery for almost all of this — a web
> `dashboard`, `model` selection against any OpenAI‑compatible provider (Ollama fits), `skills tap`/`install`
> + `bundles` to load skills under a `/slash` command for **any** model, a launchd `gateway` for always‑on,
> and `webhook` for event‑driven activation. The **one non‑native piece is MS Teams** (bridge required).
>
> **The one risk that governs everything:** I've confirmed these commands *exist* (via `--help`), not that
> the integration *works end‑to‑end on a small local model*. So §3 is a single GO/NO‑GO test, and the rest
> of the plan is explicitly conditional on it.

---

## 1. Objectives (recovered from repeated mentions + 06‑28 clarification)

Marked **[R]** = recovered from repeated mentions across sessions; **[C]** = explicit 06‑28 clarification;
**[rec]** = my recommendation filling a gap you didn't specify.

| # | Objective | Source |
|---|-----------|--------|
| **O1** | mac‑mini as a **24/7 always‑on agent box** running your full AI tooling. | **[R]** 06‑23 (repeated), 06‑28 |
| **O2** | **Stand up the Hermes harness + connect Ollama** (local models) as the coding harness. | **[C]** 06‑28; **[R]** Brewfile `hermes-agent`/`ollama` |
| **O3** | Talk to Hermes via **MS Teams** and/or an **externally‑hittable dashboard**. | **[C]** 06‑28 |
| **O4** | **The dotfiles repo provisions the whole coding harness** (hermes, ollama, local models, a way to reach /rs‑agents) — "so I don't have to think about it." | **[C]** 06‑28; **[R]** O2 hardening |
| **O5** | **rs‑agents accessible to whatever model is selected, at all times** — *"our company's core tailored AI tooling."* | **[C]** 06‑28 (flagged *very important*) |
| **O6** | Bake the **Ollama service start** (with perf env vars) into provisioning. | **[C]** 06‑28 (brew caveat) |
| **O7** | **Fold learnings back into rs‑agents** skills (`local-development-setup` + `developer-onboarding`). | **[R]** 06‑28 |
| **O8** | Idempotent / re‑runnable provisioning. | **[R]** onboarding hardening |

Resolved earlier‑session unknown: **"hermes" = Hermes Agent by Nous Research** — a self‑improving agent that
selects any model/provider, runs skills, exposes a dashboard, and can run always‑on.

---

## 2. Architecture

```
  MS Teams ──(webhook bridge + bot — NON-NATIVE, phase 2)──┐
                                                            ▼
  External  ──(tunnel + auth)──>  Hermes dashboard ──>  ┌─────────────────────────┐
                                  (hermes dashboard)    │   HERMES AGENT HARNESS   │
                                                         │  model picker + fallback │
  You (CLI/Teams/dashboard) ─────────────────────────>  │  skills + /rs-agents     │
                                                         └───────┬──────────┬───────┘
                                          local inference ◀──────┘          └──────▶ rs-agents skills
                                   ┌────────────────────┐                    (hermes skills tap → on-demand)
                                   │  Ollama (service)  │
                                   │  FLASH_ATTENTION=1 │   models: llama3.2:3b (smoke),
                                   │  KV_CACHE_TYPE=q8_0│            qwen2.5-coder:7b (coding)
                                   └────────────────────┘
   ── all installed + configured by dotfiles: Brewfile + provision-coding-harness.sh ──
```

- **Hermes = the harness / front door.** Picks the model (`hermes model`), holds the skills, serves the
  dashboard, runs always‑on via its launchd `gateway`.
- **Ollama = local model server** (OpenAI‑compatible `http://localhost:11434/v1`). Hermes points at it.
- **rs‑agents = skills made available to Hermes** so they ride with whatever model is selected (§5).
- **dotfiles = provisioning** — `Brewfile.base` already *installs* everything; a new
  `provision-coding-harness.sh` *configures* it (§4).

---

## 3. ⭐ STEP 1 — GO/NO‑GO smoke test (the spine; ~10 min; the only thing I'd run pre‑approval)

**The single question that validates the whole architecture:**
*Can I talk to Hermes, have it route to a **local** Ollama model, and have that model invoke **one** rs‑agents skill — end to end?*

```bash
# a) Ollama up with the perf flags you were told to use, + the model you'll actually code with
OLLAMA_FLASH_ATTENTION=1 OLLAMA_KV_CACHE_TYPE=q8_0 /opt/homebrew/opt/ollama/bin/ollama serve &>/tmp/ollama.log &
ollama pull qwen2.5-coder:7b           # the real coding model (test the weak link, not just a toy)
ollama pull llama3.2:3b                # fast fallback for the sanity ping

# b) Point Hermes at Ollama (interactive picker; choose a custom OpenAI-compatible provider)
hermes model                            # provider → OpenAI-compatible, base url http://localhost:11434/v1, model qwen2.5-coder:7b

# c) Make ONE rs-agents skill available to Hermes.
#    PRIMARY: add the repo as a skill tap
hermes skills tap add Retail-Success/Wayroo.tools     # ⚠️ may not discover ai/skills/<name>/SKILL.md (layout, see note)
#    FALLBACK if the tap finds nothing: install a single skill straight from its raw SKILL.md URL
hermes skills install https://raw.githubusercontent.com/Retail-Success/Wayroo.tools/<branch>/ai/skills/commit-conventions/SKILL.md --name commit-conventions
hermes skills list                      # confirm the skill is present

# d) End-to-end: local model + must use the skill
: > /tmp/ollama.log
hermes -z "Using our commit-conventions skill, write a conventional commit message for: fixed the .env ordering bug in onboard.sh (ticket WR-18897)."
grep -iE "chat/completions|qwen2.5-coder" /tmp/ollama.log   # proof inference was LOCAL
```

**✅ GO** if: the reply is correct *and shaped by the skill* (e.g. a `fix(...)` line with the WR‑18897 prefix),
**and** `/tmp/ollama.log` shows the request hit the local model. → proceed to §4.

**🛑 NO‑GO branches (decide here, cheaply):**
- *Local model ignores/garbles the skill* → small‑model tool/skill‑following is the limiter. Options: use a
  bigger local model, gate `/rs-agents` behind an explicit slash invocation, or keep rs‑agents on Claude
  Code and use Ollama only for cheap/offline tasks. **This finding reshapes §5 — better to learn it now.**
- *`hermes skills tap` doesn't discover the skills* → confirms the **layout mismatch** below; the real work
  becomes a thin export (next bullet), not the harness.

> **Layout note (the likely real friction):** `hermes skills install` uses an `<owner>/skills/<name>`
> identifier — i.e. skills at a repo's **top‑level `skills/`**. rs‑agents skills live at **`ai/skills/<name>/`**.
> So a naive tap of the repo may find nothing. Fallbacks, cheapest first: (1) install individual skills by
> raw URL (works regardless of layout); (2) a thin **export** that mirrors `ai/skills/**` → a top‑level
> `skills/**` on a branch/dedicated repo the tap understands; (3) `hermes mcp` against an rs‑agents MCP
> server (Tier 2). The spike tells us which we need.

---

## 4. The provisioning script (dotfiles) — **conditional on §3 = GO**

New idempotent `mac-mini-agent/provision-coding-harness.sh`, callable standalone or from `onboard.sh`,
with a real `--dry-run` (print actions, change nothing — the bootstrap has none today). Stages:

1. **Ollama as a service with perf flags baked in (O6).** ⚠️ `brew services start ollama` does **not** set
   the env vars. Capture them properly via a launchd agent:
   `~/Library/LaunchAgents/com.retailsuccess.ollama.plist` with
   `EnvironmentVariables = { OLLAMA_FLASH_ATTENTION = "1"; OLLAMA_KV_CACHE_TYPE = "q8_0"; }`,
   `ProgramArguments = [/opt/homebrew/opt/ollama/bin/ollama, serve]`, `RunAtLoad`, `KeepAlive`.
   (Simple alternative, no perf flags: `brew services start ollama`.)
2. **Pre‑pull models:** `llama3.2:3b` (smoke) + `qwen2.5-coder:7b` (coding). **[rec]** — sized to RAM (≤ ~60%).
3. **Hermes config (scriptable):** `hermes setup --non-interactive`; default model/provider → Ollama; add a
   cloud **fallback** chain (`hermes fallback add`) so it degrades to cloud when local can't cope.
4. **rs‑agents available to Hermes (§5, Tier 1):** `hermes skills tap add …` (or the export from §3) so
   skills are discoverable on‑demand by any selected model.
5. **Dashboard:** `hermes dashboard` on `127.0.0.1:9119` (external exposure handled in §6, mini).
6. **Health check:** `hermes doctor` + `hermes status` as the post‑provision gate.

---

## 5. ⭐ rs‑agents → whatever model is selected (O5 — the critical requirement)

Hermes loads skills into the agent context independently of which model `hermes model` picks — so skills
made available to Hermes ride along with **every** model. Two tiers; **pick the tier explicitly** (this is a
real decision, not an implementation detail):

### Tier 1 — skills + knowledge on‑demand *(recommended start; verified by §3)*
- rs‑agents **skills** (59) and **knowledge** are standard `SKILL.md` / markdown → exposed to Hermes via
  **`hermes skills tap`** so any model can pull the relevant one **on demand**.
- **Do NOT force‑load all 59** into one `/rs-agents` bundle — that can blow a local model's context window.
  At most a **small curated bundle** (e.g. the always‑on engineering‑operating‑rules + a router skill that
  indexes the rest). Tap = discovery; bundle = a tiny core.
- **Live orchestration** (orchestrator → specialists, workflows) **stays on Claude Code**, which is just one
  selectable model in the harness. Non‑Claude models get the *content/standards*, not the sub‑agent spawning.
- **Sync:** rs‑agents repo stays the source of truth; `hermes skills update` (or Hermes' `curator`) refreshes.

### Tier 2 — port agents/workflows as personas *(large; defer until you decide it's needed)*
- Export each agent's system prompt + each workflow as a Hermes skill/persona so a **local** model can
  *replicate the team* (not just read the rules). This is a real build (export pipeline + sync + the
  small‑model reliability question from §3), and may not reproduce true delegation on a 7B model.
- **Recommendation:** start Tier 1; only commit to Tier 2 if the §3 spike shows local models follow skills
  well *and* you specifically need offline/non‑Claude orchestration. **Your call — flag it.**

---

## 6. Access surfaces (O3)

- **Dashboard (native, testable now):** `hermes dashboard`. Default bind `127.0.0.1` — local immediately.
  **External:** Hermes' June‑2026 hardening **requires an auth provider (password/OAuth) on any public bind**
  and recommends **bind localhost + a tunnel**. So external = `hermes dashboard` + **Tailscale Funnel /
  Cloudflare Tunnel** + auth — a **mini** concern (no tailscale CLI here yet).
- **MS Teams (the one non‑native piece — phase 2 / mini):** Hermes' gateway covers Telegram/Discord/
  WhatsApp/Weixin/Slack, **not Teams**. Bridge via **`hermes webhook subscribe`** (inbound, event‑driven
  activation) behind a small **Teams bot / Outgoing‑Webhook connector** (Azure Bot or a Teams incoming/
  outgoing webhook → POSTs to the Hermes webhook route; replies via `hermes send`). Don't let this block the
  local stand‑up.

---

## 7. Always‑on + promote to the mini (O1)

- **Hermes always‑on:** `hermes gateway install` (installs a launchd background service) — native, no custom
  units needed. `hermes gateway start/status`.
- **Ollama always‑on:** the launchd plist from §4.1 (`RunAtLoad`/`KeepAlive`).
- **Headless survival (from `mac-mini-mcp-bootstrap.sh`):** auto‑login, Docker Desktop autostart,
  `pmset`/`systemsetup` no‑sleep, Keychain auto‑unlock, MCP secrets in Keychain.
- **External access:** add the mini to `~/.ssh/config` (absent today); Tailscale for the tunnel + dashboard.
- **MCP tools:** the existing `mac-mini-mcp-bootstrap.sh` (17 servers) remains the tool plane; optionally
  `hermes mcp add MCP_DOCKER` so Hermes shares the same tools as Claude Code.

---

## 8. Fold learnings back into rs‑agents (O7 — decided: extend the two existing skills, no new skill)
Author in native dirs → `node ai/scripts/generate-index.js` → bump plugin `version` (per `ai/CLAUDE.md`).
- **`local-development-setup`** — add a "Local AI agent host" section: the proven §3/§4 recipe (Ollama
  service + env vars, Hermes→Ollama, the rs‑agents‑to‑Hermes mechanism that actually worked) + §7 promotion.
  Widen its `description:` to mention Mac provisioning + local‑model setup.
- **`developer-onboarding`** — pointer to the dotfiles one‑liner + "your machine can run local models" note
  linking to the above.
- **dotfiles:** add `--dry-run`/`DRY_RUN` to `mac-mini-mcp-bootstrap.sh` and ship `provision-coding-harness.sh`.

---

## 9. Risks & guardrails
- **Architecture rests on §3** — local model actually following an rs‑agents skill. Validate before building.
- **Small‑model reliability** — qwen2.5‑coder:7b may follow skills inconsistently; that's the real limiter on "any model."
- **Context window** — don't force‑load 59 skills into one bundle; tap on‑demand (§5).
- **Layout mismatch** — `hermes skills tap` likely won't see `ai/skills/**`; expect a thin export (§3 note).
- **External exposure** — dashboard public bind requires auth; use a tunnel, never a raw public bind. Secrets in Keychain, not the repo.
- **PATH shadowing** — `~/.local/bin/hermes` (pip) shadows brew `hermes-agent`; pin one in the dotfiles.
- **Daily driver** — this is a *real* stand‑up (not throwaway), but on the mini for always‑on; keep the laptop service stoppable (`hermes gateway stop`, `launchctl unload`).

---

## 10. Decisions & the one bounded ask
**Decided:** plan‑as‑deliverable (no full execution yet) · models `llama3.2:3b` + `qwen2.5-coder:7b` ·
capture by extending the two existing rs‑agents skills.

**Decided 06‑28 (rev 2):** run the §3 GO/NO‑GO spike now · **Teams bridge deferred to the mini phase**
(local harness + dashboard first).

**Still open (the spike informs these):**
- **rs‑agents tier:** Tier 1 (skills on‑demand, recommended) vs. commit to Tier 2 (persona export) — decide after §3.

### §3 spike results — _(appended below as the test runs)_
```
