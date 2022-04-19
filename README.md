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
    - [Initialize](#initialize)
    - [Mac Preferences and Setup](#mac-preferences-and-setup)
    - [Homebrew_base - Package Manager for Macs](#homebrew_base---package-manager-for-macs)
    - [Software Engineering - General](#software-engineering---general)
      - [Shell - Extended and fine-tuned command line tools](#shell---extended-and-fine-tuned-command-line-tools)
      - [NVM - Node Package Manager](#nvm---node-package-manager)
      - [XCode Command Line Tools - Required for many of the programming languages](#xcode-command-line-tools---required-for-many-of-the-programming-languages)
      - [VSCode - Team recommended text editor with settings and tooling](#vscode---team-recommended-text-editor-with-settings-and-tooling)
    - [Software Engineering - Specialized Stacks](#software-engineering---specialized-stacks)
      - [Node](#node)
      - [React](#react)
      - [Ruby on Rails](#ruby-on-rails)
      - [Wordpress](#wordpress)
  - [What IS NOT included?](#what-is-not-included)
  - [Pre-Installation Instructions](#pre-installation-instructions)
  - [Detailed List of Toolsets](#detailed-list-of-toolsets)
  - [Ruby on Rails](#ruby-on-rails-1)
  - [Linting and Code Analysis](#linting-and-code-analysis)
  - [TODOS](#todos)
  - [How are Linters and Formatters Applied?](#how-are-linters-and-formatters-applied)
  - [WORKFLOW INFORMATION](#workflow-information)
    \*\*\*\*- [Git - Team configured version control](#git---team-configured-version-control)
    - [Shell - Extended and fine-tuned command line tools](#shell---extended-and-fine-tuned-command-line-tools)
    - [NVM - Node Package Manager](#nvm---node-package-manager)
    - [XCode Command Line Tools - Required for many of the programming languages](#xcode-command-line-tools---required-for-many-of-the-programming-languages)
    - [VSCode - Team recommended text editor with settings and tooling](#vscode---team-recommended-text-editor-with-settings-and-tooling)
    - [Software Engineering - Specialized Stacks](#software-engineering---specialized-stacks)
      - [Node](#node)
      - [React](#react)
      - [Ruby on Rails](#ruby-on-rails)
      - [Wordpress](#wordpress)
  - [What IS NOT included?](#what-is-not-included)
  - [Detailed List of Toolsets](#detailed-list-of-toolsets)
  - [Ruby on Rails](#ruby-on-rails-1)
  - [Linting and Code Analysis](#linting-and-code-analysis)
  - [TODOS](#todos)
  - [WORKFLOW INFORMATION](#workflow-information)
  - [DOTFILES TECHNOLOGY INDEX](#dotfiles-technology-index)

## What IS included?

This dotfiles repo uses dotbot, a popular framework for organizing dotfiles. Within the meta folder you will see two important directories:

1. **configurations/** - Each of these yml files executes a specific aspect of setting up a new or virtualized machine
2. **profiles/** - Each profile is a simply file that includes certain configurations, offering flexibility out of the box to create your own unique profile of dotfiles. Common use cases for this would be a personal and professional machine.

#### Initialize

Creation of foundational directories that will be used in later operation.

- Github template directories
- Organized folders for different types of repositories

#### Mac Preferences and Setup

Sensible defaults and settings like:

- Showing hidden files in finder
- Autohiding the dock
- Showing the path in finder

#### Homebrew_base - Package Manager for Macs

Using the dotbot plugin dotbot-brew, a homebrew bundle file called Brewfile.base lists a collection of libraries and casks (applications) that will be used for most technical stacks on a new machine. This is obviously something that should be highly personalized and is tailored for my React / Ruby on Rails environments.

### Software Engineering - General

1. Initialize - Sets up uniform folder structure for repos and tooling.
2. macosx - Sensible defaults settings for a new Mac OSX machine.
3. Homebrew - Installation of homebrew, the common packages we use for software
   engineering, and mac applications that we use within the front-end team.
4. Security - Copies your .envrc file with your sensitive information like git
   tokens. This also provisions your read/write permissions that are required
   for the onboarding process.
5. Command Line and Shell Configuration - Sets up common team defaults within
   iTerm (our preferred command line tool). Also adds oh-my-zsh, a few recommended
   plugins, the starship theme, and a variety of aliases that are dynamically
   created based on your .envrc file.
6. Version Control - Also fueled by your .envrc values, this sets up some
   .github defaults like a .gitignore template, some sensible default settings
   to how the team operates, and a copy of team related git files to be familiar
   with like CODEOWNERS, pull_request_template.yml, pre-commit hook for use with
   JIRA, etc.
7. NVM - Node version manager with our default version.
8. IDE - Sets up VS Code and copies over some base settings of:
   1. Extensions recommended to use on any UI project
   2. Keybindings that are highly recommended. Each binding has some helpful
      information explaining it's use-case and how often it is used.
   3. Launch Actions and Tasks - Scaffolded tasks to start things like the
      debugger, server, or running other jobs related to an application.
9. Cleanup - This outputs a final message and re-sources your .zshrc file.
   NOTE: If errors occur, it may just be related to steps that you may have
   already taken before the onboarding script was executed. If these main steps
   did not at least start and end then please raise an issue with your
   onboarding guide.

#### Shell - Extended and fine-tuned command line tools

1. Oh-My-ZSH

#### NVM - Node Package Manager

#### XCode Command Line Tools - Required for many of the programming languages

#### VSCode - Team recommended text editor with settings and tooling

### Software Engineering - Specialized Stacks

#### Node

#### React

#### Ruby on Rails

#### Wordpress

## What IS NOT included?

- All the company flagship repos checked out in version control
- Any company applications running locally

## Pre-Installation Instructions

Accept invitation from github to join our organization, using your personal
account is fine. Just please be sure to navigate into your [email
settings](https://github.com/settings/emails) and add your corporate email
address. IE: _flastname@amuniversal.com_

Once you are apart of the organization and have your corporate email account
linked, head over to setup your [Personal Access
Tokens](https://github.com/settings/tokens). Set one up specifically for AMU.
IE: _AMU_ONBOARDING_PAT_. Copy this token and safely store it into a password
manager like [1Password](https://1password.com/).

**NEEDS 2022 UPDATES FROM HERE DOWN**
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
   - IE: RoR, Next.js, etc. This will contain any overrides/modifications to:

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

## TODOS

1. Check the following dotfiles for ingestion or discarding:

- .phpls
- .profile
- .rnd
- .vagrant.d
- .viminfo
- .vs-liveshare-keychain
- .vs-liveshare-settings.json

  double check to ensure there are no other variables that need to accounted
  for so that a team could reliably use it EXACTLY the same.

  - Bullet
  - Brakeman
  - Simplecov
  - Rack-mini-profiler
  - Rubocop-performance
  - Rubocop-rails
  - Rubocop-rspec
  - Traceroute

## How are Linters and Formatters Applied?

During active development there are three major steps that occur upon saving a
file. In the following order, our code (in any language) will do the following
in this order:

1. Automatically Linted and auto-fixed if possible (Es-lint/Stylelint/YAML Lint/Etc.)
2. The file's code is then formatted (Prettier, htmltidy, htmlhint)
3. MANUAL: Check the "Problems" tab in the terminal info panel and fix any remaining
   linting errors or any extra formatting IE: (Command Palette -> Sort JSON)

_Note: If formatting is not desired, you can skip this by using the keyboard
shortcut Ctrl + Cmd + S. This will "Save File without Formatting"_

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
