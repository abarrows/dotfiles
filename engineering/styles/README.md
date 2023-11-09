# Stylelint

[Stylelint](https://stylelint.io/) is a CSS/SCSS static code analyzer that is customizable and compatible with most code editors. We're particular about our stylesheets, so read on for how to get Stylelint working for you.

## Prerequisites

_NOTE: All Prerequisites are included with the amu-onboarding ./install script._

1. [NVM](https://github.com/nvm-sh/nvm)(Node Version Management)
2. [Yarn](https://yarnpkg.com/) (The project should have a package.json file.)
3. [VS Code](https://code.visualstudio.com/download)
4. [VS Code Stylelint Extension](https://marketplace.visualstudio.com/items?itemName=stylelint.vscode-stylelint)
5. [VS Code Prettier Extension](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)

## Installation for a Project

_*Note: Installing stylelint globally is discouraged. It should be configured
project by project.*_
To install Stylelint navigate into your project and open a terminal and enter these commands:

```bash
yarn add stylelint --dev
yarn add stylelint-config-prettier --dev
yarn add stylelint-config-recommended-scss --dev
yarn add stylelint-no-unsupported-browser-features --dev
yarn add stylelint-scss --dev
```

After the packages have installed, navigate to the root directory of your
project and look in the package.json file. You should notice these dependencies
(and their current versions) displayed at the bottom of the "devDependencies"
object.

## VS Code Settings

Within VS Code, navigate to your User Settings (CMD + Shift + P -> Type "_Preferences:
Open Settings JSON_") and either verify these settings are in here or add/update
them to the follow configuration.

_NOTE: All VS Code Settings are included with the amu-onboarding ./install script._

```json
"[scss]": {
  "editor.codeActionsOnSave": {
    "source.fixAll.stylelint": true
  },
  "editor.defaultFormatter": "esbenp.prettier-vscode"
},
"[less]": {
  "editor.codeActionsOnSave": {
    "source.fixAll.stylelint": true
  },
  "editor.defaultFormatter": "esbenp.prettier-vscode"
},
"[css]": {
  "editor.codeActionsOnSave": {
    "source.fixAll.stylelint": true
  },
  "editor.defaultFormatter": "esbenp.prettier-vscode"
},
"css.validate": false,
"emmet.includeLanguages": {
  ...
  "sass": "css",
  "scss": "css"
},
"scss.validate": false,
```

## Configuration for a Project

Copy the following three files and paste
them into the root directory of your project. The files below are our team's
default configuration and rule set:

- `[stylelint.config.js](stylelint.config.js)`
- `[.stylelintrcignore](.stylelintrcignore)`
- `[../formatters/.prettierrc.json](../formatters/.prettierrc.json)`
- `[../formatters/.prettierrcignore.json](../formatters/.prettierrcignore.json)`
- `[../.browserslistrc](../.browserslistrc)`

## Using Stylelint on a project

### Linting and Formatting on Save

After stylelint is configured and setup, when navigating to any .css/.scss/.less
file, you will now notice linting errors and warnings within the Problems pane
of VS Code. Upon saving your stylesheet document, it will attempt to lint any
issues and then format the styling code automatically. If it cannot correct
something, you can always view outstanding errors/warnings in that problem pane.

### Pre-Commit Hooks and Scripts

In some projects, you'll notice two other methods to use stylelint and prettier
on styling code:

1. _Yarn Scripts within the package.json_ - Below are examples of common scripts
   that can be ran at the command line to lint stylesheet code:

    ```json
    "lint:styles": "stylelint **/*.scss --fix",
    "format-all": "prettier --write .",
    ```

2. _Pre-Commit Hooks_ - Some projects, automatically run scripts like the above
   example immediately before committing and pushing code changes. This keeps
   styling code uniform and allows the engineer to fix code before pushing it
   into our CI/CDs.

### Browserslist

One of the initial dependencies for stylelint is the .browserslistrc file. This
file is required to incorporate the [Unsupported Browsers
Plugin](https://github.com/ismay/stylelint-no-unsupported-browser-features).
This plugin assists in development to highlight disallowed stylefeatures which
are not supported by our team's agreed upon compatible browsers for the browser.
