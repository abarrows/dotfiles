# Git Hooks

## Commit Message w/ Jira Key

To install the `commit-msg` Git Hook:

1. Download `commit-msg` and place in: `project-root/.git/hooks/`
2. Ensure the hook file is executable by running: `chmod u+x ~/project-root/.git/hooks/commit-msg`
3. Then copy the `commit-msg` hook to any other projects you want to use it with. You shouldn't need to update the permissions elsewhere, but if it doesn't run as expected, you may need to update them after all.

To use the `commit-msg` Git Hook:

1. Create your branch, prefixing it with the ticket's key, like `TICKET-123-name-of-branch`.
2. The hook looks for the issue key in the branch name so that it add the [Smart Commit](https://confluence.atlassian.com/bitbucket/use-smart-commits-298979931.html).
3. The hook will prepend the Jira issue key to the beginning of your commit hook automatically. You can still add additional Smart Commits to your commit message, the hook won't alter anything else in your commit.