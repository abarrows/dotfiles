# dotfiles-and-tooling

## Summary

This repository is all my personal machine and software engineering
configurations, settings, tooling, and preferences. My ultimate goal with this
repo is:

1. To maintain and recreate my personal machine environment with in a single command
2. Lay ground work for maturing a team dotfiles across software engineering teams.

## Table of Contents

- [dotfiles-and-tooling](#dotfiles-and-tooling)
  - [Summary](#summary)
  - [Table of Contents](#table-of-contents)
  - [New Machine Setup Instructions](#new-machine-setup-instructions)
  - [What IS included?](#what-is-included)
    - [Profiles](#profiles)
    - [Configurations](#configurations)
      - [Initialize](#initialize)
      - [Mac Preferences and Setup](#mac-preferences-and-setup)
      - [Homebrew - Package Manager for Macs](#homebrew---package-manager-for-macs)
    - [Security](#security)
    - [Command Line](#command-line)
    - [Version Control](#version-control)
    - [NVM](#nvm)
    - [IDE](#ide)
  - [What IS NOT included?](#what-is-not-included)
  - [Pre-Installation Instructions](#pre-installation-instructions)
  - [Detailed List of Toolsets](#detailed-list-of-toolsets)
  - [Todos](#todos)
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

## New Machine Setup Instructions

1. Open terminal and begin downloading XCode tools. Execute the following
    command: `xcode-select --install`
2. Navigate to Github → Account Settings →
    [Emails](https://github.com/settings/emails) -> Add email address (Your
    corporate email: *flastname@amuniversal.com*) → Verify Email (In your inbox)
3. Navigate to the invitation (<https://www.github.com/Andrews-McMeel-Universal/Invitation>)
4. Github → Developer Settings → [PAT](https://github.com/settings/tokens) → Generate a new token with the following set:

        - Less than a year expiration.
        - All Repo rights
        - Gist rights
        - All User rights
        - All Codespaces rights
        - Generate and store safely for the next step. (_NOTE: You will not see this again after you navigate away from the page\_)

5. Copy your PAT
6. Verify XCode tools have downloaded successfully.
7. Open terminal and navigate to ~/
8. Replace the following *${YOUR_GITHUB_PAT}* in the script below and then
   execute it:

        ```
        cd ~/Documents && mkdir -p AMU/repos/amu-development-team && cd ~/Documents/AMU/repos/amu-development-team && git clone <https://${YOUR_GITHUB_PAT}:x-oauth-basic@github.com/Andrews-McMeel-Universal/amu-onboarding.git> && cd amu-onboarding && cp .envrc.example .envrc && open .envrc
        ```

9. Upon successfully running the script above, it should open up a new file
    called **envrc**. Please fill in the dotenv values as instructed. (This will
    provide your specific information for git, command line tools, VS Code, and a
    number of other aspects of the onboarding process.)

10. After saving your .envrc file, go back to your terminal (where you previously were) and execute the following:

          ```shell
          ./install-profile base
          ```

11. You will begin executing the dotfiles and will need to input your machine
    password, a few times so please keep an eye on it. \*NOTE: Due to
    overlapping processes with our DevOps team, there may be a handful of
    homebrew recipes and/or parts of the script that appear to error. This is
    likely due to some applications already installed on your machine. As long
    as the script finishes, you should be able to continue on to the final step.

12. Depending on the tech stack you will be working in at AMU, execute the following command(s):

        ```shell
        ./install-profile react
        ```

        ```shell
        ./install-profile ruby
        ```

        ```shell
        ./install-profile devops
        ```

## What IS included?

This dotfiles repo uses dotbot, a popular framework for organizing dotfiles. Within the [meta](/meta/) folder you will see two important directories:

### Profiles

**[profiles/](/meta/profiles)** - Each profile is a simple file listing out
   both the order and which "configs" need to be executed on the new machine.
   It was setup this way to offer easy flexibility.  Whether you (or a teammate)
   are wanting to work on react applications or you are mainly going to be
   working on Ruby on Rails, simply execute the corresponding profile **AFTER**
   running the base profile.  Below are the current profiles setup in this
   repository:
      1. [Base](/meta/profiles/base)
      2. [React](/meta/profiles/react)
      3. [Ruby](/meta/profiles/ruby)
      4. [DevOps](/meta/profiles/devops)

### Configurations

**[configurations/](/meta/configs)** - Each of these yml files
   executes a specific aspect of setting up a new or virtualized machine.
   *Example: ide.yml - Provisions the VS Code text editor, extensions,
   keybindings, etc.*  Below are the high level configurations available:

#### Initialize

- Creation of foundational directories that will be used in later operation.
- Github template directories
- Organized folders for different types of repositories

#### Mac Preferences and Setup

Sensible defaults and settings like:

- Showing hidden files in finder
- Autohiding the dock
- Showing the path in finder

#### Homebrew - Package Manager for Macs

**Filename: [Brewfile.base](/Brewfile.base**)
Using the dotbot plugin dotbot-brew, a homebrew bundle file called Brewfile.base
lists a collection of libraries and casks (applications) that will be used for
most technical stacks on a new machine. This is obviously something that could
be highly personalized.  I have gone to great lengths to ensure only the
necessary packages are included for whatever profile is calling the Brewfile.
The general base (Brewfile.base) is tailored for general software engineering.

**Filename: [Brewfile.react](/Brewfile.react**)
Using the dotbot plugin dotbot-brew, a homebrew bundle file called Brewfile.react
lists a collection of libraries and casks (applications) that will be used *on
top* of the base homebrew dependencies.

**Filename: [Brewfile.ruby](/Brewfile.ruby**)
Using the dotbot plugin dotbot-brew, a homebrew bundle file called Brewfile.ruby
lists a collection of libraries and casks (applications) that will be used *on
top* of the base homebrew dependencies.

**Filename: [Brewfile.ruby](/Brewfile.devops**)
Using the dotbot plugin dotbot-brew, a homebrew bundle file called Brewfile.devops
lists a collection of libraries and casks (applications) that will be used *on
top* of the base homebrew dependencies.

### Security

- Symlinks the [onboarding_bin](/onboarding_bin) to the home
directory of your new machine.
- Symlinks your .envrc file to your home directory.  This contains your
  sensitive information like git tokens, email address, etc.
- This also provisions your read/write permissions that are required for the onboarding process.

### Command Line

- This instantiates oh-my-zsh and supportive shell files.
- Sets up common team defaults within iTerm (our preferred command line tool).
- Also Adds a few recommended plugins, the starship theme, and a variety of aliases that are dynamically created based on your .envrc file.

### Version Control

- Fueled by your .envrc file, this sets up some .github defaults like a
  .gitignore template, some sensible default settings surrounding git
  configuration.
- Copies over some helpful github.com specific template and configurations like:
      - CODEOWNERS
      - pull_request_template.yml
      - pre-commit hook for use with JIRA

### NVM

- Symlink and copies over a current .nvmrc file for Node version management.

### IDE

Sets up VS Code and copies over some base settings of:

   1. Extensions recommended to use on any UI project
   2. Keybindings that are highly recommended. Each binding has some helpful
      information explaining it's use-case and how often it is used.
   3. Launch Actions and Tasks - Scaffolded tasks to start things like the
      debugger, server, or running other jobs related to an application.
   4. Cleanup - This outputs a final message and re-sources your .zshrc file.
   *NOTE: If errors occur, it may just be related to steps that you may have
   already taken before the onboarding script was executed. If these main steps
   did not at least start and end then please raise an issue with your
   onboarding guide.*

## What IS NOT included?

- Any private or sensitive information regarding your professional team's
  configuration and setup.
- Any private or sensitive applications running locally

## Pre-Installation Instructions

Accept invitation from github to join our organization, using your personal
account is fine. Just please be sure to navigate into your [email
settings](https://github.com/settings/emails) and add your corporate email
address. IE: *flastname@amuniversal.com*

Once you are apart of the organization and have your corporate email account
linked, head over to setup your [Personal Access
Tokens](https://github.com/settings/tokens). Set one up specifically for AMU.
IE: *AMU_ONBOARDING_PAT*. Copy this token and safely store it into a password
manager like [1Password](https://1password.com/).

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

## Todos

Check the following dotfiles for ingestion or discarding:

- .phpls
- .profile
- .rnd
- .vagrant.d
- .viminfo
- .vs-liveshare-keychain
- .vs-liveshare-settings.json
