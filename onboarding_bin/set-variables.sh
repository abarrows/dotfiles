#!/usr/bin/env bash
set -euo pipefail

# Repo/Env
REPO="template-nextjs-ui"   # leave as-is when run from repo root; or set to "owner/template-nextjs-ui"
ENV_NAME="development"

# Values you provided
USER_NAME="abarrows"
USER_EMAIL="" # Your Github email
JIRA_TOKEN_VALUE="" # Your JIRA API Token

# If running outside the repo directory, set REPO to "owner/template-nextjs-ui"
R_FLAG=()
if [[ "$REPO" == *"/"* ]]; then
  R_FLAG=(-R "$REPO")
else
  # Use current repo context
  REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
  R_FLAG=(-R "$REPO")
fi

# Ensure gh is ready
command -v gh >/dev/null 2>&1 || { echo "ERROR: gh CLI not installed."; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "ERROR: gh not authenticated. Run: gh auth login"; exit 1; }

echo "Ensuring environment '${ENV_NAME}' exists..."
gh api -X PUT -H "Accept: application/vnd.github+json" \
  "/repos/${REPO}/environments/${ENV_NAME}" \
  -F wait_timer=0 >/dev/null

echo "Creating environment secrets..."
gh secret set JIRA_TOKEN -e "${ENV_NAME}" "${R_FLAG[@]}" --body "${JIRA_TOKEN_VALUE}"

echo "Creating environment variables..."
gh variable set USER_NAME  -e "${ENV_NAME}" "${R_FLAG[@]}" --body "${USER_NAME}"
gh variable set USER_EMAIL -e "${ENV_NAME}" "${R_FLAG[@]}" --body "${USER_EMAIL}"

echo "Done. Configured env '${ENV_NAME}' for ${REPO}."
