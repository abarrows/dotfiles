# dotfiles-and-tooling

This repository is all my personal machine and software engineering
configurations, settings, tooling, and preferences. My ultimate goal with this
repo is:

1. To maintain and recreate my personal machine environment with in a single command
2. Lay ground work for maturing a team dotfiles across software engineering teams.
3. Mature the onboarding process to be flexible enough to handle a base
   onboarding with different tech stacks as additional onboarding processes.

## Table of Contents

- [dotfiles-and-tooling](#dotfiles-and-tooling)
  - [Table of Contents](#table-of-contents)
  - [What IS included?](#what-is-included)
    - [Homebrew - Package Manager for Macs](#homebrew---package-manager-for-macs)
      - [RVM - Ruby Version Manager](#rvm---ruby-version-manager)
  - [Linting and Code Analysis](#linting-and-code-analysis)
    - [Caveats](#caveats)
  - [TODOS](#todos)

## What IS included?

Unsurprisingly, the order of execution is intentional, as many of the
dependencies build upon each other. Upon installation, there are three main
levels of configuration and tooling:

### Homebrew - Package Manager for Macs

The packages listed in [./Brewfile.ruby](./Brewfile.ruby) are intended to be
installed after the [./Brewfile.base](./Brewfile.base). The packages within
that specialized profile are specific to a Ruby on Rails technical stack. Some
examples of those packages are:

1. Imagemagick
2. Memcache
3. Mysql
4. PID
5. Sphinx

#### RVM - Ruby Version Manager

This standalone configuration sets up a default .rvm version to be used with the
RVM package. To install this use the instructions found in [./onboarding_bin/install-rvm.sh](./onboarding_bin/install-rvm.sh)

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

## TODOS

1. Document the rest of the linters/tooling
   - Bullet
   - Brakeman
   - Simplecov
   - Rack-mini-profiler
   - Rubocop-performance
   - Rubocop-rails
   - Rubocop-rspec
   - Traceroute
