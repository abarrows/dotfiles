#!/usr/bin/env bash

# Evaluation if this machine is an M1 Mac done in the .m1-mysql-fixes.sh file
if [ -r "/opt/homebrew/bin/brew" ]; then
  eval $(/opt/homebrew/bin/brew shellenv)
fi

# Ensure a writable temp dir. Headless / launchd-launched contexts inherit the
# root-owned macOS fallback (TMPDIR=/var/folders/zz/.../T, mode 0700), which is
# unwritable by the user and breaks vitest/npm/esbuild with EACCES. Only override
# when TMPDIR is unset or not writable, so interactive machines keep system temp.
if [ -z "$TMPDIR" ] || [ ! -w "${TMPDIR%/}" ]; then
  export TMPDIR="$HOME/.claude/tmp"
  export TMP="$TMPDIR"
  export TEMP="$TMPDIR"
  mkdir -p "$TMPDIR"
fi

if [[ $- == *i* ]] && [ -t 0 ]; then
  echo "This is an interactive shell"
else
  echo "This is not an interactive shell"
fi

# Setup for ruby and rbenv
if command -v rbenv >/dev/null 2>&1; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# Add .NET Core SDK tools
# export PATH="$PATH:$HOME/.dotnet/tools"

# Created by `pipx` on 2024-09-29 16:51:26
# export PATH="$PATH:/Users/acbarrows/.local/bin"

# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"
