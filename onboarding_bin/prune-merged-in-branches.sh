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
    # echo "Skipping excluded branch: $branch"
    continue
  fi

  # echo "Processing branch: $branch"
  merged=false

  for base in "${excluded_branches[@]}"; do
    # echo "Checking base: $base"
    # Get the merge base commit of the branch with the base branch
    merge_base=$(git merge-base "$base" "$branch" 2>/dev/null)

    if ! merge_base=$(git merge-base "$base" "$branch" 2>/dev/null); then
      # echo "Error: Could not find a common ancestor between $base and $branch"
      continue
    fi

    # echo "Merge base with \$base: \$merge_base"
    # Check if the branch has been merged into the base branch and if there have been any commits after the merge
    if git branch --contains "$merge_base" | grep -q "$branch"; then
      commits_after_merge=$(git log --pretty=oneline "$merge_base".."$branch" | wc -l | tr -d ' ')

      if [[ $commits_after_merge -eq 0 ]]; then
        # Delete the branch if it has been merged and there are no commits after the merge
        echo "Deleting branch $branch as it is merged and has no commits after the merge"
        git branch -d "$branch"
        merged=true

        # Break the loop if the branch was deleted
        break
      else
        echo "Skipping branch: $branch with $commits_after_merge commits after the initial merge"
      fi
    else
      echo "Skipping branch $branch as it was not merged into $base"
    fi
  done
  if [[ $merged == false ]]; then
    if git branch --merged | grep -q "$branch"; then
      echo "NOTICE: Branch $branch was merged into an unlisted branch"
    fi
  fi
done
