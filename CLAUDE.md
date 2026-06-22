# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Team onboarding **dotfiles** for Retail Success engineers — provisions a fresh Mac (primarily; Windows via `windows-setup.ps1` + `Wingetfile.base`) for front-end / Ruby / DevOps work in roughly one sitting. Managed by [dotbot](https://github.com/anishathalye/dotbot). There is no application to build or test here — the "code" is shell scripts, YAML config, and dotfiles that get symlinked into `$HOME`.

## How provisioning works (the dotbot indirection chain)

Read this before editing anything — the flow spans several files:

1. **Entry points** (run from repo root):
   - `./install-profile <profile> [extra-configs...]` — the normal path. Runs `meta/base.yml`, then every config listed in `meta/profiles/<profile>`, then any extra config names passed as args. Loads the `dotbot-brew` plugin dir so `brew bundle` configs work.
   - `./install-standalone <config...>` — runs `meta/base.yml` then the named configs only. No brew plugin dir.
   - ⚠️ The README references `./install`; **that script does not exist**. Use the two above.

2. **Profiles** — `meta/profiles/<name>` is a plain newline-delimited list of config names (no extension). Existing: `base`, `devops`, `react`, `ruby`. A profile = the ordered set of configs for a stack.

3. **Configs** — `meta/configs/<name>.yml` are dotbot directive files (`link`, `shell`, `clean`, and brew bundles). `meta/base.yml` always runs first (sets link defaults, inits submodules, cleans `~` / `~/.config`).

4. **`link` directives** map a source file in a **content directory** → a `~/` destination (usually `force: true`, overwriting). So:
   - To change **what gets installed/run**, edit a config in `meta/configs/`.
   - To change the **content linked into `$HOME`**, edit the source file in its content directory.

`meta/dotbot/` and `meta/dotbot-brew/` are git submodules (the engine + Homebrew plugin); `install-*` runs `git submodule update --init --recursive` first.

### Content directories (where edits actually land)

- `shell/` — zsh dotfiles: `.zshrc`, `.aliases.zsh`, `.functions.zsh`, `.plugins.zsh`, `.theme.zsh`, `starship.toml`, Warp/iTerm profiles. (Oh My Zsh + Starship; Warp is the default terminal — the iTerm config in `command_line.yml` is commented out.)
- `engineering/` — `formatters/` (`.editorconfig`, prettier, htmlhint), `javascripts/` (`.nvmrc`, `.npmrc`), `ruby/` (erb-lint, better-html, fasterer, devcontainer, Dockerfile), `ide/.vscode/` (settings, keybindings, launch), `security/.ssh/`.
- `version-control/` — git template directory (`hooks/`, `CODEOWNERS`, `commit-template.txt`, `.gitignore`, `.git-blame-ignore-revs`), plus `WORKTREE-GUIDE.md` and PR/README templates. Note: the global `~/.gitconfig` is **not** linked — it is built imperatively by a `shell:` block in `meta/configs/version_control.yml`.
- `onboarding_bin/` — standalone, ad-hoc setup & maintenance shell scripts (Homebrew/rbenv/nvm/oh-my-zsh installers, ssh/gpg setup, branch/worktree pruning, VS Code extension management). Several configs invoke these via `shell:`.
- `operating_system/` — macOS preferences (`meta/configs/macosx.yml`).
- `Brewfile.base` / `Brewfile.ruby` / `Brewfile.devops` — Homebrew bundles consumed by the `homebrew_*` configs.
- `devops/`, `sandbox/` — DevOps notes and linter test fixtures.

## Machine configuration & secrets

`.envrc` (direnv) holds machine-level variables **including live secrets** (`JIRA_API_TOKEN`, `CURRENT_USER_GPG_KEY`, emails). It is generated from `.envrc.example` by `onboarding_bin/set-variables.sh` and is git-ignored — **never commit `.envrc`**.

## Git & commits

- **Main branch is `production`** — PRs and commits target it. (Git config sets `init.defaultBranch=main`, but that only affects newly *created* repos, not this one.)
- Follow conventional commits with verbose, JIRA-aligned types — `story` / `bugfix` / `hotfix` / `maintenance` — plus an optional scope. This repo's own history uses e.g. `maintenance(dotfiles): …` and **omits** JIRA issue keys; keys (`[XYZ-1234]`) are for downstream application work, not required here. See `.github/copilot-instructions-commit-message.md`.

## Tooling & linting

- No build, no test suite, no `package.json` scripts (the root `package-lock.json` is vestigial).
- Linting is **local, not CI** (there is no `.github/workflows/`): MegaLinter (`.mega-linter.yml`, tuned for shell/yaml/json/markdown/css), Prettier (`.prettierrc.js`), yamllint (`.yamllint.yml`). `sandbox/` holds throwaway files for exercising linters.

## Scope note

`.github/copilot-instructions.md` describes the **downstream React/TypeScript/MUI UI application** these dotfiles support — not this repo. Do **not** apply its React/TS/MUI/SWR rules when editing dotfiles (bash, yaml, zsh).
