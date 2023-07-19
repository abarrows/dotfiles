#!/bin/bash

# Simplified script to identify local branches which have already been merged in.
# git branch --merged | grep -i -v -E
# "master|main|development|staging|production" | xargs git branch -d

### This script does an initial check to:
# 1. identify branches that have already been merged in.
# 2. An additional one that will identify if commits have happened on it after the merge date.

# Set branch names to exclude from deletion
excluded_branches=(master main development staging production)

# Convert excluded branches to a space-separated string
excluded_branches_str="${excluded_branches[*]}"

# Loop over all local branches
for branch in $(git branch --format "%(refname:short)"); do
  # Skip excluded branches
  if [[ ${excluded_branches_str} =~ ${branch} ]]; then
    echo "Skipping excluded branch: $branch"
    continue
  fi

  echo "Processing branch: $branch"

  for base in "${excluded_branches[@]}"; do
    # Get the merge base commit of the branch with the base branch
    merge_base=$(git merge-base "\$base" "\$branch")
    echo "Merge base with \$base: \$merge_base"

    # Check if the branch has been merged into the base branch and if there have been any commits after the merge
    if git branch --contains "$merge_base" | grep -q "$branch"; then
      commits_after_merge=$(git log --pretty=oneline "$merge_base".."$branch" | wc -l)
      echo "Commits after merge: $commits_after_merge"

      if [[ $commits_after_merge -eq 0 ]]; then
        # Delete the branch if it has been merged and there are no commits after the merge
        echo "Deleting branch $branch as it is merged and has no commits after the merge"
        git branch -d "$branch"

        # Break the loop if the branch was deleted
        break
      else
        echo "Skipping branch $branch as it has commits after the merge"
      fi
    else
      echo "Skipping branch $branch as it was not merged into $base"
    fi
  done
done
