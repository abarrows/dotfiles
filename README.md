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

## RVM

1. I discovered some strange caching and pathing issues in RVM and determined it
   was the bundler zsh plugin: https://rvm.io/support/troubleshooting. Updated
   on 2020.07.29
   2. I have added a debugger file in my gists that outline how to troubleshoot
      uglifier gem woes.

## TODOS

1. Create multi-stage build for the second level above. IE: Provisioning of 1,
   2a (global ide settings, linting of js, css, etc.) then 2b.This will inherit from
   2a and will setup all the ruby on rails related IDE settings, linting, etc.
2. Decide if the workspace level should be language/tech stack specific or
   application specific.

## WORKFLOW INFORMATION

During active development there are three major steps to standardizing efforts.
In the following order, my code is:

1. Linted and auto-fixed (Es-lint/Stylelint/YAML Lint/Etc.)
2. Formatted (Editor Config then Prettier)
3. Any remaining linting errors or manually fixed or formatting that I have not
   yet automated. IE: (Command Palette -> Sort JSON)

Some general caveats here are listed below:

- In order to prevent syntax and code breakage, I have turned off the following:
  - Format on Type (Since formatting should be done before linting)
  - Format on Paste (Since formatting should be done before linting)
- I am using yarn to install the following NPM packages so that linting only
  lints code quality problems and doesn't bleed into the formatting of code.
  (Vica versa)
  1.  stylelint-config-prettier - This allows prettier and stylelint to "play nice"
      so formatting and linting do not override eachother.
  2.  eslint-config-prettier - This allows prettier and stylelint to "play nice"
      so formatting and linting do not override eachother.
- To verify that both are the linting and formatting of a language is setup
  correctly, I look in the bottom status bar and click on the following 3 things
  to ensure it's respective config file is found and that there are no errors:
  1. Eslint
  2. Prettier (Checkmark icon showing means it's good)
  3. Formatting (Checkmark icon showing means it's good)
