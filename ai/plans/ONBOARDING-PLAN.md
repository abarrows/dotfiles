# Onboarding Consolidation — Handoff Plan

**Goal:** take a bare Mac (the new Mac Mini) to a fully provisioned dev
environment with the **fewest possible manual steps** — ideally one command. A
literal "one shot" is impossible (a few gates are interactive *by design*), but
the README's ~10 scattered, partly-broken steps collapse into: **run one
command and answer a handful of identity prompts.**

> **⚠️ Validation status:** The orchestrator's logic is exercised only on a
> *fresh* machine. Every step here is guarded by an idempotency check, and this
> author machine is already provisioned — so on it, every step takes the *skip*
> path and the real provisioning logic never runs. **`shellcheck` + `bash -n`
> prove syntax, not behavior. "Done" = a clean run on the Mac Mini.** Treat the
> Mini as the test bed; the script is written to be safe to re-run while
> iterating.

---

## The decision that shaped this (identity setup)

Chosen posture: **Hybrid.**

- **SSH key** — generated non-interactively (passphraseless ed25519; standard
  for an auth/clone key).
- **GPG signing key** — generation stays **interactive** so the engineer sets a
  passphrase on their signing identity (no silently-minted passphraseless
  signing key).
- **Both public keys auto-upload to GitHub via `gh ssh-key add` /
  `gh gpg-key add`** — `gh` is already authenticated by that point, so the two
  "paste your key into github.com" steps are eliminated. If the token lacks the
  key-write scope, the script falls back to printing the key + opening the
  settings page (never worse than before).

Rejected: full passphraseless auto-gen of the GPG key (truly zero-touch but a
real security regression — anyone with disk access could sign commits as you).

---

## Gap analysis — what the old README got wrong

| # | README said | Reality | Fix |
|---|---|---|---|
| 1 | `./install` | No such file | `./install-profile base` |
| 2 | bootstrap via `set-variables.sh`, curled from a `github.com/.../blob/` URL | `set-variables.sh` configures **GitHub Actions secrets** for `template-nextjs-ui`, not `.envrc`; `/blob/` returns HTML, not a script | Bootstrap is `pre-onboarding-script.sh` / now `onboard.sh`, curled from `raw.githubusercontent.com` |
| 3 | `git submodule add https://github.com/anishathalye/dotbot` | dotbot is already in `.gitmodules`; `install-*` runs `submodule update --init` | Removed — re-adding errors |
| 4 | `sudo chmod -R 755 /usr/local/share/zsh` | Intel-only path; Apple Silicon uses `/opt/homebrew` | Use `normalize-permissions.sh` (`chown $(brew --prefix)/*`) |
| 5 | Xcode CLT only "pre-onboarding" prose | `meta/configs/xcode.yml` exists but is in **no profile** → never runs | Added `xcode` to `meta/profiles/base` |
| 6 | (silent) `install-homebrew.sh` runs `arch -x86_64 …` on arm64 | Installs **Rosetta x86 Homebrew at `/usr/local`** on Apple Silicon | Dropped `arch -x86_64`; native `/opt/homebrew` |
| 7 | SSH/GPG buried in "Detailed List" + TODOs, never sequenced | `base` profile sets `commit.gpgsign true` but **never sets `user.signingkey`** → every commit fails | `version_control.yml` now wires `user.signingkey` from `.envrc`; `onboard.sh` sets it directly |
| 8 | manual key paste into GitHub | `gh` is authed → `gh ssh-key add` / `gh gpg-key add` | Auto-upload, manual paste only as fallback |

---

## Target flow — `onboarding_bin/onboard.sh`

One idempotent orchestrator (thin sequencer over existing macro-steps), runnable
from a bare machine via `curl | bash` or in-repo:

```bash
# bare machine:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/abarrows/dotfiles/production/onboarding_bin/onboard.sh)" -- react
# already cloned:
./onboarding_bin/onboard.sh react        # stack ∈ {react|ruby|devops}; omit for base only
```

Steps: **1** Xcode CLT → **2** Homebrew (arch-aware, native prefix) → **3**
bootstrap pkgs (git, gh, direnv) → **4** `gh auth` → **5** locate-or-clone repo →
**6** `.envrc` (reuse / move `~/.envrc` / seed from `.envrc.example`) → **7**
`./install-profile base` + optional stack → **8** SSH key (gen + `gh ssh-key add`)
→ **9** GPG key (interactive gen + `gh gpg-key add`, wire `user.signingkey`,
persist key id to `.envrc`).

### Remaining manual gates (cannot be scripted)
1. **sudo password** (Homebrew install / chown).
2. **Xcode CLT GUI dialog** (click Install, accept license).
3. **`gh auth login`** (browser/device identity).
4. **GPG passphrase** (pinentry GUI — by the Hybrid choice).

Public-key pasting into GitHub is **removed** (auto-uploaded via `gh`), unless
the token lacks key-write scope (then it falls back to paste + opens the page).

---

## Files changed (working tree, on `production` — uncommitted)

- `onboarding_bin/onboard.sh` *(new)* — orchestrator (Hybrid identity, gh upload).
- `onboarding_bin/install-homebrew.sh` — drop `arch -x86_64` on arm64.
- `meta/profiles/base` — add `xcode`.
- `meta/configs/version_control.yml` — wire `user.signingkey` from `.envrc`.
- `README.md` — Quick Start section + repaired longhand commands.
- `onboarding_bin/setup_git.sh` — deprecation banner (gitconfig now owned by
  `version_control.yml` / `onboard.sh`; avoids the dual source of truth).

---

## Open follow-ups (out of scope for this pass)
- **`version_control.yml` vs `setup_git.sh` conflict:** editor `windsurf --wait`
  vs `code --wait`, and `pull.rebase true` vs `false`. This machine's live config
  is `code --wait` — i.e. it matches `setup_git.sh`, *not* the profile. Pick one
  canonical gitconfig. `onboard.sh` relies solely on `version_control.yml`.
- **`gh` token scopes:** for auto-upload, the auth needs `admin:public_key` +
  `write:gpg_key`. If absent, `onboard.sh` falls back to manual paste; consider
  requesting scopes during `gh auth login`.
- **direnv hook** is absent from `shell/.zshrc`, so `.envrc` won't auto-load in
  interactive shells (install scripts `source` it directly). Add
  `eval "$(direnv hook zsh)"` if live loading is wanted.
- **Node/Ruby:** `nvm` is installed via Brewfile but no Node version is; `rbenv`
  ruby + bundler remain post-steps (`install-rbenv.sh`, `install-bundler.sh`).
