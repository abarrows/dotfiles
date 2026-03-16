#!/bin/bash
# Apply git template settings to an existing repository
 
if [ ! -d .git ]; then
    echo "Error: Not in a git repository"
    exit 1
fi
 
echo "Applying Git template settings to $(git rev-parse --show-toplevel)..."
 
git config --local pull.rebase true
git config --local pull.autoStash true
git config --local rebase.autoStash true
git config --local rebase.autoSquash true
git config --local push.default current
git config --local push.followTags true
git config --local push.autoSetupRemote true
git config --local diff.algorithm histogram
git config --local diff.colorMoved default
git config --local diff.submodule log
git config --local merge.conflictStyle zdiff3
git config --local fetch.prune true
git config --local fetch.pruneTags true
git config --local branch.sort -committerdate
git config --local tag.sort -version:refname
git config --local rerere.enabled true
git config --local rerere.autoUpdate true
git config --local submodule.recurse true
git config --local status.submoduleSummary true
git config --local blame.ignoreRevsFile .git-blame-ignore-revs
git config --local maintenance.auto true
git config --local maintenance.strategy incremental
git config --local gc.autoDetach true
git config --local worktree.guessRemote true
git config --local extensions.worktreeConfig true
 
echo "✅ Git template settings applied to local repository!"
