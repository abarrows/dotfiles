# Contributing

New branches should always be associated with a Jira ticket. The branch should be prefixed with the issue key and a short description, like so: `jiraIssueType/AMUPRODUCT-1234/hyphenated-issue-summary`.

## Jira Smart Commits

In scenarios where creating a separate branch for each Jira ticket is not exactly feasible, you can still trigger our automation by using what are called [smart commits](https://confluence.atlassian.com/fisheye/using-smart-commits-960155400.html).

To use Jira smart commits, you would include the Jira issue key for each commit like so: `[AMUPRODUCT-1234], [AMUPRODUCT-1235] Knocked out the 4 copy edits needed`

## Creating Pull Requests

Once you have committed your effort in a separate branch, you will need to raise a pull request in Github. While filling out the Pull Request, **Please** follow the pull request template format and write a brief description of any technical details and Jira tickets that are related to the PR.

The recommended title for the pull request is typically just the branch name. Again, if a single issue per branch is not feasible, including a brief title of the effort is acceptable.

You do not need to fill in the reviewers or assignees. Our CODEOWNERS automation takes care of who will need to review it. As long as a AMU software engineer reviews it and the other checks pass, they will take care of merging the pull request into staging and production.

> NOTE: On every PR, we do run tests and automatically format the code with Prettier.

> NOTE: A PR will not be able to be merged until at least 1 reviewer with write access has approved it and all tests are passing. If a PR is updated with a new commit, stale reviews will be dismissed.
