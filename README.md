# dotfiles-and-tooling TODO: THIS IS OUTDATED TBD

This repository is all my personal IDE configuration, settings, tooling, and
preferences. My ultimate goal here is to recreate my entire Macbook Pro machine
in the cloud as it relates to development. Something that can be reproduced at
will and torn down with no repercussions. After some careful thought, this
process will involve three main levels of configuration and tooling:

1. Dotenv
   - Machine level sensitive variables
2. iTerm 2
   - .zshrc
     - Agnoster
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
  IE: RoR, Python, Next.js, etc. This will contain any
  overrides/modifications to:

## Virtualized Dev Environment

With the emergence of cloud IDE's easing into our workflows, this was the
original catalyst and still remains my primary goal with organizing my dotfiles.
The day I can simply open a browser tab and share it to a colleague, environment
already setup, will the mission complete.

### Codespaces

I have been accepted into the beta program for Github's codespaces and have been
working to virtualize my own professional projects through this technology. A
starter codespace can be found here:
<https://github.com/microsoft/vscode-dev-containers.git>

### Microsoft Codespaces Online

Much of the earlier work in this repo was with the (now deprecated) microsoft
codespaces. The biggest challenge so far has been limited documentation on this
changeover between Microsoft and Github. Which settings override which? How
does it work in a docker container, etc. I digress. The old home for my
environments are here: <https://online.visualstudio.com/environments>

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
  /home/codespace/.codespaces/.persistedshare/dotfiles/acb_bin/pathChecker.sh
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
