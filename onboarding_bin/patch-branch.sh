#!/bin/bash

set -e

BRANCH_NAME="$1"

if [ -z "$BRANCH_NAME" ]; then
  echo "Usage: $0 <branchname>"
  exit 1
fi

# Detect clipboard tool
if command -v pbpaste &>/dev/null; then
  CLIP_CMD="pbpaste"
elif command -v xclip &>/dev/null; then
  CLIP_CMD="xclip -selection clipboard -o"
else
  echo "❌ Clipboard tool not found (requires pbpaste or xclip)"
  exit 1
fi

# Ensure WindSurf exists
if ! command -v windsurf &>/dev/null; then
  echo "❌ WindSurf not found in PATH"
  exit 1
fi

# Set worktree path predictably based on branch name
WORKTREE_DIR="$(git rev-parse --show-toplevel)/.git-worktrees/$BRANCH_NAME"

# Fetch latest from origin
echo "📦 Fetching origin/develop..."
git fetch origin develop

# Create worktree if it doesn't exist already
if [ -d "$WORKTREE_DIR" ]; then
  echo "♻️  Reusing existing worktree at $WORKTREE_DIR"
else
  echo "🧪 Creating worktree '$BRANCH_NAME' at $WORKTREE_DIR"
  git worktree add --detach "$WORKTREE_DIR" origin/develop
fi

# Move into the worktree
pushd "$WORKTREE_DIR" >/dev/null

echo "🌿 Checking for existing branch: $BRANCH_NAME"
if git show-ref --quiet "refs/heads/$BRANCH_NAME"; then
  if git worktree list | grep -q "$BRANCH_NAME"; then
    echo "🔁 Branch '$BRANCH_NAME' already checked out in a worktree"
    git checkout "$BRANCH_NAME" 2>/dev/null || true
  else
    echo "🔁 Branch exists but not in a worktree — checking out"
    git checkout "$BRANCH_NAME"
  fi
else
  echo "🌿 Creating new branch '$BRANCH_NAME'"
  git checkout -b "$BRANCH_NAME"
fi

echo "📋 Applying patch from clipboard..."
if ! $CLIP_CMD | git apply --check; then
  echo "❌ Patch does not apply cleanly. Aborting."
  popd >/dev/null
  exit 1
fi

$CLIP_CMD | git apply

echo "➕ Staging changes..."
git add .

echo "🧠 Opening WindSurf in $WORKTREE_DIR"
windsurf . &

popd >/dev/null

echo "✅ Patch applied and staged in branch '$BRANCH_NAME'."
echo "📂 Worktree: $WORKTREE_DIR"
echo "🧹 To remove later: git worktree remove \"$WORKTREE_DIR\""
