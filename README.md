# dotfiles-and-tooling

This repository is all my personal IDE configuration, settings, tooling, and
preferences. My ultimate goal here is to recreate my entire Macbook Pro machine
in the cloud as it relates to development. Something that can be reproduced at
will and torn down with no repercussions. After some careful thought, this
process will involve three main levels of configuration and tooling:

1. setup.sh - Machine level installs, C compiled libraries, and other machine level
   settings.
   - iterm
   - .zshrc
   - Git configuration and defaults
   - Homebrew
   - Node
   - Yarn
2. .devcontainer. and .vscode - Development Environment IDE General Settings and project agnostic
   configuration/linting/tooling. IE: Things like:
   - .editorconfig
   - package.json (Everything I work on has js and related dependencies)
3. workspace environment - Workspace Environment for the specific tech stack.
   IE: RoR, Python, Next.js, etc. This will contain any overrides/modifications to:
   - settings.json
   - vs code extensions
   - new linting configurations, etc.
4. Application environment - This will bring in the actual application being
   worked on which inherits the levels of configuration and respective
   environment above.

## PACKAGES

1. stylelint-config-prettier - This allows prettier and stylelint to "play nice"
   so formatting and linting do not override eachother.
2. eslint-config-prettier - This allows prettier and stylelint to "play nice"
   so formatting and linting do not override eachother.

## TODOS

1. Create multi-stage build for the second level above. IE: Provisioning of 1,
   2a (global ide settings, linting of js, css, etc.) then 2b.This will inherit from
   2a and will setup all the ruby on rails related IDE settings, linting, etc.
2. Decide if the workspace level should be language/tech stack specific or
   application specific.
