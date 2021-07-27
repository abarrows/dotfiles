# Pull Requests

Before your branch can be merged into "staging", a code review is required as part of your [pull request](https://docs.github.com/en/free-pro-team@latest/github/collaborating-with-issues-and-pull-requests/about-pull-requests).

1. When initiating a pull request, make sure your branch name matches the parameters set forth in the [git-hooks](https://github.com/Andrews-McMeel-Universal/amu-code_standards/tree/production/general/github/git-hooks) section (if applicable).
2. In most cases, create your pull request against branch "staging" (in rare cases you may make pull requests to another engineer's branch or other environments).
3. Add a description of your changes and add relevant links. Repos should have a template to follow but if there isn't, please [add one from here](https://github.com/Andrews-McMeel-Universal/amu-code_standards/tree/production/general/github/git-hooks) and update the issue key to match the project's JIRA.
4. After initializing a pull request, you'll see a review page that shows a high-level overview of the changes between your branch and "staging". Here you can add explanation for your changes, especially if they're not explained in the associated JIRA task.
5. Make sure to add reviewers, this will ping the engineers you select for a review. In general, try to chose other engineers most familiar with the project you're working on.
6. After successful review, merge your branch into "staging". Make sure to delete your remote branch thereafter as to not clutter the number of branches on the repo.

## Peer Review Etiquette

1. Check your ego at the door. Peer reviews are an opportunity to learn and discuss code and should not be viewed in a personal manner. Stay professional!
2. Be mindful of other engineer's time. While you're not expected to immediately drop everything you're doing to handle a code review, there is an expectation to handle them as soon as possible as to not hold up progress. In general, if you've received no feedback on a PR after 20 minutes, ping the code reviewers.
3. Don't be afraid to include comments and provide explanations inside of your pull request!
4. In the event that another programmer leaves a comment, make sure to reply in a timely manner and let the other programmer resolve the comment before merging.
5. If another programmer approves the PR but a 2nd programmer makes a comment, be sure to address the comment before merging.

## Best Practices

1. Before opening a pull request, take the time to [review your changes](https://docs.github.com/en/free-pro-team@latest/github/collaborating-with-issues-and-pull-requests/about-comparing-branches-in-pull-requests). This will help you write a more meaningful description, catch errors and other things (like commented out code) that should be addressed first, and give a sense of scale of the pull request.
2. As you're coding and reviewing your changes, be mindful of scope creep. While we definitely encourage leaving code better than you found it, often times it may be better to split off changes that don't belong with the task at hand. The smaller your pull request, the easier the code review.
