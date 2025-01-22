# instructions

## General Instructions

You must follow the conventional commit message format. The overarching goal is
to standardize how engineers describe the collective effort in a meaningful way that can later be used to inform SemVer auto-incrementing the release versions.

## Commit Type

Prefer verbose commit types
that match JIRA default
issue types like story, bugfix, hotfix, maintenance. Always try to add an
optional scope for the different aspects of the application like: storybook,
tests, api, devops, devex, ci, styling, dependencies, etc.

## JIRA Issue Key (smart commits) and Description

Examine the current branch name
and if a JIRA issue key is included, prepend the commit description with the
JIRA issue key. IE: maintenance(dependencies): [XYZ-1234] - Upgraded MUI and MSW
to their latest versions.

## Breaking Changes

When a breaking change is identified, Use the more verbose commit message with both ! and
BREAKING CHANGE footer. Here is an example of a conventional commit describing a new feature (minor update):

## Examples

```bash
story(collections): [YZ-1234] Introduced new collection feature.
```

```bash

bugfix(styling): [YZ-1234] Fixed the collection container from horizontally scrolling.

```

```bash

story(api): [YZ-1234] Switching from v98 to v99

```

```bash

! BREAKING CHANGE: Most of the collection endpoints have changed. All boolean attributes are now using datestamps."

```
