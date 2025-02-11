#!/bin/bash

# Check if repository path was provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <repository-path> [execute-deletions]"
  echo "Example: $0 /path/to/your/repo false"
  echo "Parameters:"
  echo "  repository-path: Path to git repository"
  echo "  execute-deletions: (Optional) true to actually delete branches, false for dry-run (default: false)"
  exit 1
fi

# Set parameters
REPO_PATH=$(cd "$(dirname "$1")" 2>/dev/null && pwd -P)/$(basename "$1")
EXECUTE_DELETIONS=${2:-false}

# Check if repository path exists and is a git repository
if [ ! -d "$REPO_PATH/.git" ]; then
  echo "Error: $REPO_PATH is not a git repository"
  exit 1 || exit
fi

# Change to repository directory
cd "$REPO_PATH"
echo "Running in repository: $(pwd)"
echo "----------------------------"

# Fetch and prune remote branches
git fetch -p

# Function to handle branch deletion
delete_branch() {
  local branch=$1
  local reason=$2
  local details=${3:-""}

  if [ "$EXECUTE_DELETIONS" = "true" ]; then
    echo "DELETING ($reason): $branch $details"
    git branch -D "$branch"
  else
    echo "WOULD DELETE ($reason): $branch $details"
  fi
}

# Find and log branches where "remote "is gone
git for-each-ref --format '%(refname:short) %(upstream:track)' |
  awk '$2 == "[gone]" {print $1}' |
  while read branch; do
    delete_branch "$branch" "remote gone"
  done

# Get all local branches except develop, main, and master
local_branches=$(git branch | grep -v -E "develop|main|master" | sed 's/^\*\?\s*//')

# Get develop branch SHA
develop_sha=$(git rev-parse develop)

for branch in $local_branches; do
  # Check if branch is merged into develop
  if git branch --merged develop | grep -q "^[* ]*$branch$"; then
    # Get local SHA
    local_sha=$(git rev-parse $branch)

    # Check if remote branch ever existed
    if git ls-remote --heads origin $branch | grep -q .; then
      # Remote exists or existed - get its SHA
      remote_sha=$(git rev-parse origin/$branch 2>/dev/null)

      if [ "$?" -eq 0 ] && [ "$local_sha" = "$remote_sha" ]; then
        delete_branch "$branch" "merged & synced" "(local: ${local_sha:0:8}, remote: ${remote_sha:0:8})"
      fi
    else
      # No remote branch ever existed
      echo "WARNING: Local branch '$branch' has no remote tracking history"
    fi
  fi
done
