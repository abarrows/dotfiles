#!/bin/bash

# Get the total number of stashes
total_stashes=$(git stash list | wc -l)
branch_name="all-stashes"

# Check if there are any stashes
if [ "$total_stashes" -eq "0" ]; then
  echo "No stashes found."
  exit 0
fi

# Create a new branch to store the patches
git branch $branch_name && git checkout $branch_name

# Iterate over each stash
for ((n = 0; n < "$total_stashes"; n++)); do
  # Create a patch for the current stash
  git stash show -p "stash@{${n}}" >"stash-$n.patch"

  echo "Created the patch $branch_name"

  # Note: The stash is applied to the branch and dropped from the stash list when creating a branch from it
done

# Push the branch to the remote
git add . -u && git commit -m"Committing the $total_stashes to the branch." && git push origin "$branch_name"

echo "All stashes have been processed."
