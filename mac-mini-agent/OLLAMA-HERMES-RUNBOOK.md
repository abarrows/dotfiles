# Standing up Ollama + Hermes — Runbook

> Live log of the exact steps required to get Ollama serving local models **through** the
> Hermes Agent harness. Captured as we execute on `rss-mbp-5` so it can be folded into a
> dotfiles provisioning script (DRY-RUN-PLAN.md §4 / O4) and replayed on the mac-mini.
>
> **Machine:** `rss-mbp-5` (MacBook, Apple M4, 16 GB) · **Hermes:** v0.17.0 (pip, `~/.local/bin/hermes`) · **Ollama:** 0.30.11 (brew) · **Date:** 2026-06-29

---

## TL;DR of what we discovered

1. Hermes was **already configured** to use Ollama during the 2026-06-28 spike
   (`provider: custom`, `base_url: http://localhost:11434/v1`) — but the spike **never reached GO**.
2. **The blocker:** Hermes refuses any *primary* model whose context window is **< 64,000 tokens**.
   `qwen2.5-coder:7b` reports only **32K** → rejected. This is why the spike stalled
   (evidence: `~/.hermes/config.yaml.pre-spike-bak` + the empty `§3 results` block in DRY-RUN-PLAN.md).
3. **Second, hidden issue:** Ollama itself only *serves* 4096 tokens by default
   (`default_num_ctx=4096` in its log) unless `OLLAMA_CONTEXT_LENGTH` is raised.
4. **Fix / model choice:** use **`gemma3:4b` (Gemma 3 4B, 128K native context)** as the general
   default — it clears the 64K floor with **no override hack**. Keep `qwen2.5-coder:7b` as the
   explicit *coding* model (its 32K is handled separately when selected).

---

## The steps

### Step 0 — Ollama server up with performance flags  ✅ DONE
```bash
OLLAMA_FLASH_ATTENTION=1 OLLAMA_KV_CACHE_TYPE=q8_0 ollama serve
```
Verify (log should show `OLLAMA_FLASH_ATTENTION:true`, `OLLAMA_KV_CACHE_TYPE:q8_0`, `Listening on 127.0.0.1:11434`):
```bash
curl -s http://localhost:11434/api/tags >/dev/null && echo "ollama UP"
```
> ⚠️ `brew services start ollama` does **NOT** set these env vars — see Step 6 for the durable launchd unit.

### Step 1 — Pull the models  ✅ DONE
```bash
ollama pull gemma3:4b           # general default — 128K context, clears Hermes' 64K floor
# already present from the 06-28 spike:
#   qwen2.5-coder:7b  (coding model, 32K ctx)
#   llama3.2:3b       (128K ctx, fast/smoke)
ollama list
```
Confirmed: `gemma3:4b` (4.3B, **131072** ctx, 3.3 GB), `qwen2.5-coder:7b`, `llama3.2:3b` all present.

### Step 2 — Point Hermes at the chosen model  ✅ DONE (decision below)
**Decision (2026-06-29):** default = **`llama3.1:8b`** (tools + native 128K, real 64K+ headroom,
no override hacks); keep **`qwen2.5-coder:7b`** for coding (select with `hermes -m qwen2.5-coder:7b`).
gemma3:4b dropped from the agent role (no tools).

`~/.hermes/config.yaml` (backed up to `config.yaml.bak-gemma`):
```yaml
model:
  default: llama3.1:8b
  provider: custom
  base_url: http://localhost:11434/v1
  context_length: 65536        # cap displayed ctx → clears 64K floor; memory-safe on 16 GB
  ollama_num_ctx: 65536        # request 64K runtime ctx from Ollama (required for 32K-native qwen)
```

### Step 3 — Make Ollama actually *serve* enough context  ✅ DONE (manual; launchd still pending → Step 6)
Default is 4096; raised so long agent sessions aren't silently truncated. Serve restarted with:
```bash
OLLAMA_FLASH_ATTENTION=1 OLLAMA_KV_CACHE_TYPE=q8_0 OLLAMA_CONTEXT_LENGTH=65536 ollama serve
```
**Verified the Ollama side works end to end:** a direct call to the OpenAI-compat endpoint
returns correct output, and `ollama ps` shows `gemma3:4b` loaded at **65536 ctx, 100% GPU, ~2.9 GB**:
```bash
curl -s http://localhost:11434/v1/chat/completions -H 'Content-Type: application/json' \
  -d '{"model":"gemma3:4b","messages":[{"role":"user","content":"Reply with: DIRECT_OK"}],"max_tokens":20}'
# -> "DIRECT_OK"
```

### Step 4 — Smoke test: prove Hermes routes to the LOCAL model  ✅ GO (plumbing proven)
`hermes -z "What is 17 + 25? Reply with just the number."` → **`42`**, exit 0, with
`qwen2.5-coder:7b` loaded 100% on GPU. Hermes ↔ Ollama agent path works end to end.

---

## 🔑 Root-cause writeup: why `hermes -z` "hung"/failed (RESOLVED)

It wasn't a hang. `hermes_cli/oneshot.py:148` does `logging.disable(logging.CRITICAL)` and wraps the
whole run in `redirect_stdout/stderr(devnull)` — so **all errors are silenced** in one-shot mode.
oneshot returns **exit 2** when the agent turn comes back `failed`/`partial` with empty text
(`oneshot.py:223`). The real error was only visible by calling `_run_agent()` directly with logging
on. It was:

```
HTTP 400: registry.ollama.ai/library/gemma3:4b does not support tools
```

**Two hard requirements for ANY local model used as a Hermes _primary_:**
1. **Tool-calling support** — Hermes sends tool definitions every request. Models without `tools`
   capability get a 400 and the turn fails.
2. **≥64K context** — Hermes' floor for reliable tool use, checked twice: the *displayed* context
   (static gate) AND the *runtime* context Ollama actually loads.

### Capability matrix (from `ollama show`)
| Model | tools | context (native) | Verdict as Hermes default |
|---|---|---|---|
| `gemma3:4b` | ❌ (vision only) | 128K | ❌ unusable — no tools (this was the blocker) |
| `llama3.2:3b` | ✅ | 128K | ⚠️ works, but 3B is too weak — emitted a bogus tool call, ~94 s |
| `qwen2.5-coder:7b` | ✅ | 32K | ✅ works with both context knobs; strong; effective ctx ~32K |

### The two context knobs (needed for 32K-native models like qwen)
```yaml
model:
  context_length: 65536     # overrides the DISPLAYED context → clears the static 64K gate
  ollama_num_ctx: 65536     # makes Hermes REQUEST 64K runtime ctx from Ollama
```
⚠️ Ollama still clamps qwen2.5-coder:7b to its trained **32K** at load (`ollama ps` shows
CONTEXT 32768). The knobs satisfy Hermes' gate; true 64K+ requires a natively-large model
(e.g. `llama3.1:8b`, 128K + tools) or a yarn-rope Modelfile.

### ⚠️ Latency / tuning (open)
First one-shot call: **94–148 s**. Dominated by (a) cold model load, (b) evaluating a large system
prompt — **44 enabled tools + a 71 KB `AGENTS.md` (truncated to 20K)**. Levers: trim/disable unused
tools (`-t`/plugin disable), shrink `AGENTS.md`, keep the model warm (`OLLAMA_KEEP_ALIVE`).

### Step 5 — Wire rs-agents skills to whatever model is selected (O5)  ⬜ PENDING

### Step 6 — Durable services (launchd) + fold into dotfiles (O4/O6)  ⬜ PENDING

---

## How to test it works (layered)

| Layer | What it proves | How |
|---|---|---|
| **A. Ollama alone** | local inference works | `ollama run gemma3:4b "say hi"` |
| **B. Hermes → Ollama** | the harness routes to the local model | `hermes -z "Reply with exactly: LOCAL_OK"` **while** tailing `~/.ollama` / serve log for a `chat/completions` hit |
| **C. Model identity** | the *right* model answered | `ollama ps` shows `gemma3:4b` loaded during the call |
| **D. Skill-following (O5)** | a local model uses an rs-agents skill | `hermes -z "Using the commit-conventions skill, write a commit message for: fix .env ordering bug (WR-18897)"` → output must be *shaped by the skill* |
| **E. Dashboard / tunnel** | external surface works | open the dev-tunnel URL, chat, confirm reply |

**GO** = layers A–D pass. **NO-GO branch** = if a local model can't follow the skill (D),
keep rs-agents on Claude and use Ollama for cheap/offline tasks only (DRY-RUN-PLAN §3 / §9).
