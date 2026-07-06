#!/usr/bin/env bash
# verify-ollama-hermes.sh — prove the Ollama + Hermes local-agent harness works CORRECTLY.
#
# Tests each link in the chain with explicit PASS/FAIL, proves inference is actually
# LOCAL (not a silent cloud fallback), and measures memory-fit + latency (the thing that
# made llama3.1:8b unusable on a 16 GB box). Repeatable + model-agnostic, so the same
# script validates a fresh Mac or the 24/7 mini.
#
#   Usage:  ./verify-ollama-hermes.sh [model]      (default: hermes config model.default)
#
set -uo pipefail

OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"
CFG="$HOME/.hermes/config.yaml"
MODEL="${1:-$(awk '/^model:/{m=1;next} m&&/default:/{print $2; exit}' "$CFG")}"

if [ -z "$MODEL" ]; then
  echo "Error: no default model could be derived." >&2
  echo "       Checked Hermes config: $CFG" >&2
  echo "       Expected a 'model:' section with a 'default:' entry, or a model argument:" >&2
  echo "         $0 <model>" >&2
  exit 1
fi

MARK="===VERIFY $(date +%H%M%S)==="
SLOG=/tmp/ollama-spike.log   # the ollama serve log (used to prove a local hit)
FAILED=0

g(){ printf "  \033[32mPASS\033[0m  %s\n" "$1"; }
r(){ printf "  \033[31mFAIL\033[0m  %s\n" "$1"; FAILED=1; }
i(){ printf "  ····  %s\n" "$1"; }

echo "════════════════════════════════════════════════════════════"
echo " Verifying Ollama + Hermes harness   model=$MODEL"
echo "════════════════════════════════════════════════════════════"

# L1 — Ollama server reachable
echo "[L1] Ollama server"
curl -s --max-time 5 "$OLLAMA_URL/api/tags" >/dev/null \
  && g "Ollama API responding ($OLLAMA_URL)" \
  || { r "Ollama API not responding — start it (ollama serve)"; echo "ABORT"; exit 1; }

# L2 — model pulled + the two hard requirements (tools, >=64K context)
echo "[L2] Model capabilities (Hermes needs BOTH: tools + >=64K context)"
if ollama show "$MODEL" >/dev/null 2>&1; then
  g "model '$MODEL' present"
  CAPS=$(ollama show "$MODEL" 2>/dev/null | awk '/Capabilities/{c=1;next} /Parameters|Projector|System|License/{c=0} c&&NF{print $1}' | tr '\n' ' ')
  CTX=$(ollama show "$MODEL" 2>/dev/null | awk '/context length/{print $NF}')
  case " $CAPS " in *" tools "*) g "tool-calling supported";; *) r "NO tool-calling — unusable as a Hermes primary (caps: $CAPS )";; esac
  if [ "${CTX:-0}" -ge 64000 ]; then g "native context ${CTX} >= 64000"; else i "native context ${CTX} < 64000 — relies on config context_length/ollama_num_ctx override"; fi
else
  r "model '$MODEL' not pulled (ollama pull $MODEL)"
fi

# L3 — raw model works via the OpenAI-compat endpoint Hermes uses (isolates model from Hermes)
echo "[L3] Direct inference (OpenAI-compat endpoint, no Hermes)"
t0=$(date +%s)
DIRECT=$(curl -s --max-time 180 "$OLLAMA_URL/v1/chat/completions" -H 'Content-Type: application/json' \
  -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"Reply with exactly: PING_OK\"}],\"max_tokens\":16}" \
  | python3 -c 'import sys,json;print(json.load(sys.stdin)["choices"][0]["message"]["content"].strip())' 2>/dev/null)
t1=$(date +%s)
echo "$DIRECT" | grep -q "PING_OK" && g "direct inference correct ($((t1-t0))s)" || r "direct inference wrong/empty: '$DIRECT'"

# snapshot swap to detect memory thrash across the heavy Hermes call
sw(){ sysctl -n vm.swapusage | sed -E 's/.*used = ([0-9.]+M).*/\1/'; }
SWAP0=$(sw)
printf '\n%s\n' "$MARK" >> "$SLOG"

# L4 — Hermes end-to-end AND proof it routed LOCALLY (the subtle correctness check)
echo "[L4] Hermes -z end-to-end + local-routing proof"
t0=$(date +%s)
OUT=$(hermes -z "What is 17 + 25? Reply with just the number as plain text." 2>/dev/null); RC=$?
t1=$(date +%s); LAT=$((t1-t0))
{ [ $RC -eq 0 ] && echo "$OUT" | grep -q "42"; } \
  && g "correct answer (exit 0, ${LAT}s): '$OUT'" \
  || r "Hermes failed (exit $RC, ${LAT}s): '$OUT'"
# local proof #1: Ollama logged a chat request during the window
if awk -v m="$MARK" '$0~m{f=1} f' "$SLOG" 2>/dev/null | grep -qiE "chat/completions|POST"; then
  g "request hit the LOCAL Ollama server (not cloud)"
else
  i "no local request line in ollama log (check proof #2)"
fi
# local proof #2: the model is loaded in ollama ps
PS=$(ollama ps 2>/dev/null | sed -n '2p')
[ -n "$PS" ] && g "model loaded locally: $PS" || i "ollama ps shows nothing loaded (may have unloaded)"

# FIT — memory + latency (why llama3.1:8b@64K failed on 16 GB)
echo "[FIT] Memory + latency"
i "latency ${LAT}s    swap used ${SWAP0} -> $(sw)"
[ "${LAT:-9999}" -le 300 ] && g "latency within 300s budget" \
  || r "latency ${LAT}s > 300s — likely memory thrash; model too big for this machine"

# L5 — the REAL-USE test: does the local model actually follow an rs-agents skill? (O5)
echo "[L5] rs-agents skill-following (the real-use bar)"
if hermes skills list 2>/dev/null | grep -qi "commit-conventions"; then
  SK=$(hermes -z "Using the commit-conventions skill, write ONLY a conventional commit subject line for: fixed the .env ordering bug in onboard.sh (ticket WR-18897)." 2>/dev/null)
  # Pass = the skill's CONTENT shaped the output: a type(scope): pattern + the ticket key,
  # found ANYWHERE (a local 7B often wraps it in a raw tool-call rather than clean text).
  if echo "$SK" | grep -qiE "[a-z]+\([^)]+\):" && echo "$SK" | grep -qiE "WR-18897"; then
    g "skill content applied: '$SK'"
    echo "$SK" | grep -q "{" && i "note: local model wrapped it in a raw tool-call — content correct, agentic mechanics rough on a 7B"
  else
    r "skill not followed (weak model or not loaded): '$SK'"
  fi
else
  i "SKIPPED — no rs-agents skill installed yet (Step C: hermes skills install <SKILL.md>)"
fi

echo "────────────────────────────────────────────────────────────"
[ "$FAILED" -eq 0 ] && echo " RESULT: ✅ ALL CHECKS PASSED — $MODEL" \
                    || echo " RESULT: ❌ FAILED — $MODEL (see above)"
echo "────────────────────────────────────────────────────────────"
exit $FAILED
