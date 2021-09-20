# dotfiles-and-tooling

This repository is all my personal machine and software engineering
configurations, settings, tooling, and preferences. My ultimate goal with this
repo is:

1. To maintain and recreate my personal machine environment with in a single command
2. Lay ground work for maturing a team dotfiles across software engineering teams.

## Table of Contents

- [dotfiles-and-tooling](#dotfiles-and-tooling)
  - [Table of Contents](#table-of-contents)
  - [What IS included?](#what-is-included)
    - [Machine Level Provisioning](#machine-level-provisioning)
      - [Mac Preferences and Setup](#mac-preferences-and-setup)
      - [Homebrew - Package Manager for Macs](#homebrew---package-manager-for-macs)
    - [Software Engineering - General](#software-engineering---general)
      - [Git - Team configured version control](#git---team-configured-version-control)
      - [Shell - Extended and fine-tuned command line tools](#shell---extended-and-fine-tuned-command-line-tools)
      - [NVM - Node Package Manager](#nvm---node-package-manager)
      - [XCode Command Line Tools - Required for many of the programming languages](#xcode-command-line-tools---required-for-many-of-the-programming-languages)
      - [VSCode - Team recommended text editor with settings and tooling](#vscode---team-recommended-text-editor-with-settings-and-tooling)
    - [Software Engineering - Specialized Stacks](#software-engineering---specialized-stacks)
      - [Node](#node)
      - [React](#react)
      - [Ruby on Rails](#ruby-on-rails)
      - [Python](#python)
      - [Wordpress](#wordpress)
  - [What IS NOT included?](#what-is-not-included)
  - [Detailed List of Toolsets](#detailed-list-of-toolsets)
  - [Ruby on Rails](#ruby-on-rails-1)
  - [Linting and Code Analysis](#linting-and-code-analysis)
    - [Caveats](#caveats)
  - [TODOS](#todos)
  - [WORKFLOW INFORMATION](#workflow-information)
  - [DOTFILES TECHNOLOGY INDEX](#dotfiles-technology-index)

## What IS included?

Unsurprisingly, the order of execution is intentional, as many of the
dependencies build upon each other. Upon installation, there are three main
levels of configuration and tooling:

### Machine Level Provisioning

#### Mac Preferences and Setup

#### Homebrew - Package Manager for Macs

### Software Engineering - General

#### Git - Team configured version control

#### Shell - Extended and fine-tuned command line tools

1. Oh-My-ZSH

#### NVM - Node Package Manager

#### XCode Command Line Tools - Required for many of the programming languages

#### VSCode - Team recommended text editor with settings and tooling

### Software Engineering - Specialized Stacks

#### Node

#### React

#### Ruby on Rails

#### Python

#### Wordpress

## What IS NOT included?

- All private professional applications checked out in version control
- All private professional applications running locally
- An easy button for your machine's environment. If this repo is cloned, it is
  highly advised to review and tailor the contents to . The point of this utility is to get an engineer "80% there." The other 20% at their descretion. It is highly recommended to
  challenge and propose better approaches for any of these given toolsets. If
  there is a better toolsets, configurations, libraries, etc. let's talk about
  it as a group, weigh the pros and cons, and possibly try i## Installation Instructions

Accept invitation from github to join our organization, using your personal
account is fine.

Setup Git and save in 1password
`https://github.com/settings/keys`

Download and install Homebrew (alternative article explaining it)
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

Install “git“ using the command line:
`brew install git`

Checkout [Onboarding Engineering
Dotfiles](https://github.com/Andrews-McMeel-Universal/amu-onboarding) locally:
`git clone git@github.com:Andrews-McMeel-Universal/amu-onboarding.git`

Navigate to the root folder of the above project and using the command line run:
`git submodule add https://github.com/anishathalye/dotbot`
`sudo chmod -R 755 /usr/local/share/zsh`
`./install`

## Detailed List of Toolsets

After the script runs, what exactly did it do and why does it matter?

1. Dotenv
   - Machine level sensitive variables - All application potentially has
     sensitive values
2. iTerm 2
   - .zshrc
     - Agnoster Theme (Starship is Optional. See shell/.theme.sh for details.)
     - Plugins
     - Aliases
     - Custom Bash Functions
3. Git configuration and defaults
   - General Settings and Configurations
     - Repo Templates
     - Workflow Templates
     - Issue Templates
4. Homebrew

- Default recipes
- Default casks (iOS apps)

5. Node
   - NVM Version Manager
6. Yarn
   - Global NPM Packages
7. VS Code (Machine Level)
   - .devcontainer. and .vscode - Development Environment IDE General Settings and project agnostic
     configuration/linting/tooling. IE: Things like:
   - Settings.json
     - Theme
     - Keybindings
   - Extensions
     - Code Quality Tools
     - Linting
     - Productivity
     - Formatters
     - Workload integrations (JIRA/Github/Etc.)
8. VS Code - General Code Quality Tools
   - .editorconfig
   - package.json (Everything I work on has js and related dependencies)
   - Eslint
   - Stylelint
   - Prettier
   - Shell Checker
   - YAML Lint
   - JSON Lint/Sorting
9. VS Code - Project/Technology Specific
   - workspace environment - Workspace Environment for the specific tech stack.
   - IE: RoR, Python, Next.js, etc. This will contain any overrides/modifications to:

## Ruby on Rails

## Linting and Code Analysis

The following tools can be used for improving the confidence of this apps logic and code.

1. Fasterer gem - DESCRIPTION: Performance analyzer for ruby | DEPENDENCIES:
   `gem install fasterer` | COMMAND: fasterer
2. Flay gem - DESCRIPTION: This is the "DRY machine" for our code |
   DEPENDENCIES: `gem install flay` | COMMAND: flay -v --diff
3. Reek gem - DESCRIPTION: Code Quality Analyzer. This looks for bad code smells
   and informs you of them. | DEPENDENCIES: `gem install reek` |
   OUTPUT: /coverage/reek/ COMMAND: rake reek
4. Rails Best Practices - DESCRIPTION: Looks at the best practices and can
   advise on how to fix them | DEPENDENCIES: `gem install rails_best_practices` | COMMAND: `rails_best_practices -f html --output-file ./coverage/rails_best_practices.html`
   | OUTPUT: /coverage/rails_best_practices.html
5. YAML Lint gem - DESCRIPTION: This gem essentially is ESLint for YAML files.
   DEPENDENCIES: `brew install yamllint` and adding to \$PATH. | DEPENDENCIES:
   `gem install yamllint` | COMMAND: `yamllint ./path/yaml-file-you-want-to-lint.yml` | CONFIG: ./yamllint.yml
6. Better HTML - DESCRIPTION: This gem allows for greater control over
   html/erb formatting and enforcement of team's standards. It is more
   self-aware than erb in that your erb code will more correctly be compared
   against pure html rules and standards. It's highly customizable and can be
   configured to enforce custom team rules: IE: Do not use 'js-' prefixed
   classes. DEPENDENCIES: `gem install better_html` | CONFIGURATION:
   `./config/initializers/.better-html.yml` | USAGE:
   - 1. Include this line below the class declaration in your
        application_helper.rb: `include BetterHtml::Helpers`
7. ERB Lint - DESCRIPTION: This linter bridges the gap between html
   beautifier formatters and rubocop linting capabilities/auto-correct features.
   | DEPENDENCIES: `gem install erb_lint`, VS Code Extension:
   ERB Formatter/Beautify | CONFIG: `./erb-lint.yml` | USAGE:

   - 1. COMMAND: (This will scan the app and display linting errors in console)
        erblint --lint-all --enable-all-linters
   - 2. COMMAND: (This will auto-fix all errors that can be fixed) erblint --lint-all --enable-all-linters --autocorrect

8. Solargraph gem - (VS CODE ONLY) DESCRIPTION: This is an extension that
   enforces rubocop, rails best practices, fasterer, reek, erb-linting, etc. and
   will display the errors/warnings in real time under problems. It also offers
   Intellisense to Ruby, autocomplete, and much more |
   DEPENDENCIES: `gem install solargraph`, VS Code Extension:
   <https://marketplace.visualstudio.com/items?itemName=castwide.solargraph> |
   USAGE:
   - 1. `bundle exec yard gems && solargraph download-core && solargraph config .`
   - 2. Navigate to the VS Code Command Palette (CMD + Shift + P) Run command:
        `Restart Solargraph`
   - 3. Open a .rb file and you should begin seeing rubocop and many of the other linters listed
        above) errors within the VS Code _problems_ pane.

### Caveats

1. I discovered some strange caching and pathing issues in RVM and determined it
   was the bundler zsh plugin: <https://rvm.io/support/troubleshooting>. Updated
   on 2020.07.29 2. I have added a debugger file in my gists that outline how to troubleshoot
   uglifier gem woes.

## TODOS

1. Check the following dotfiles for ingestion or discarding:

- .phpls
- .profile
- .rnd
- .rvmrc
- .solargraph
- .vagrant.d
- .viminfo
- .vs-liveshare-keychain
- .vs-liveshare-settings.json

2. Address the following to codespaces/dotfile init:

- [cd ~/ && sh -c "$(curl -fsSL <https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh>)"]
- Linking failed /usr/local/bin/pathChecker.sh ->
  /home/codespace/.codespaces/.persistedshare/dotfiles/onboarding_bin/pathChecker.sh
- ~/.gitconfig already exists but is a regular file or directory

3. Add global precommit hook.

.gnupg failed to sign commit data when adding .gitconfig. I suspect this has
to do with having two entities in git or homebrew managing the GPG functionality.

1. Create multi-stage build for the second level above. IE: Provisioning of 1,
   2a (global ide settings, linting of js, css, etc.) then 2b.This will inherit from
   2a and will setup all the ruby on rails related IDE settings, linting, etc.
2. Decide if the workspace level should be language/tech stack specific or
   application specific.
3. Add the corresponding cloud machine vs code settings for each linter/tool and
   double check to ensure there are no other variables that need to accounted
   for so that a team could reliably use it EXACTLY the same.
4. Document the rest of the linters/tooling
   - Bullet
   - Brakeman
   - Simplecov
   - Rack-mini-profiler
   - Rubocop-performance
   - Rubocop-rails
   - Rubocop-rspec
   - Traceroute
5. Automate adding iterm profile, keymaps
6. Automate RVM installation
7. Drop zsh plugins from the initial ./install command.

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
  1. stylelint-config-prettier - This allows prettier and stylelint to "play nice"
     so formatting and linting do not override eachother.
  2. eslint-config-prettier - This allows prettier and stylelint to "play nice"
     so formatting and linting do not override eachother.
- To verify that both are the linting and formatting of a language is setup
  correctly, I look in the bottom status bar and click on the following 3 things
  to ensure it's respective config file is found and that there are no errors:
  1. Eslint
  2. Prettier (Checkmark icon showing means it's good)
  3. Formatting (Checkmark icon showing means it's good)

## DOTFILES TECHNOLOGY INDEX

1.
