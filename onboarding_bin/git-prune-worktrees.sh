#!/bin/bash

git-prune-worktrees() {
  local main_path
  main_path=$(git rev-parse --show-toplevel)

  git worktree list --porcelain \
    | grep "^worktree " \
    | awk '{print $2}' \
    | grep -v "^${main_path}$" \
    | while read -r wt_path; do
        if [ -n "$(git -C "$wt_path" status --porcelain 2>/dev/null)" ]; then
          echo "⚠️  SKIPPED (has changes): $wt_path"
        else
          git worktree remove --force "$wt_path" && echo "✅ Removed: $wt_path"
        fi
      done

  git worktree prune
  echo "--- Remaining worktrees ---"
  git worktree list
}
