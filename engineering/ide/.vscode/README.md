# Software Engineering IDE Information

## Keybindings

Migrating from TextMate to Atom to now VS Code, I tried to conform to as many
defaults as I could. The bindings listed in keybindings.json have a benign key
of "description" and then a value describing when the keybinding is useful.

In the keybindings.json file, you will notice a number of arbitrary key/value
pairs. These will not impact your VS Code operation. Below are examples with
descriptions of the information:

```json
  {
    "key": "The keyboard command to invoke the shortcut",
    "command": "This is the VS Code function that is called under the hood",
    "when": "These are the conditions that have to met for the shortcut to fire.  If these are not met, pressing the shortcut will not invoke.",
    "frequency": "Options are - Frequent, Ocassional, and Infrequent  Based on common experience, this is how often the respective keybinding is used during normal coding experiences.",
    "description": "A description of what the keybinding actually does.",
    "example": "A general example of when and/or how you would use the shortcut.",
    "default": "Boolean: If true then this is the VS Code keyboard shortcut that comes out of the box.  If default is false, it is a custom binding setup by the Front-end Engineering Manager."
  },
```

## Debugging

### Rails

1. Within [/ide/.vscode/launch.json](/ide/.vscode/launch.json), look for the
   launch task called: **Rails:Start - Development**. In vscode navigate to
   your debugger icon on the far left (It has a little bug on it) and activate
   the pane. Click the cogwheel at the top to configure your launch.json tasks.
   Paste in the launch task previously mentioned and then run it. This can be
   used in any rails project. (More
   Information)[https://rahul-arora.medium.com/debugging-ruby-on-rails-server-in-vs-code-819b45113e78]

## Extensions

*Needs to be cross checked with extensions_base.txt and updated for 2023*

Our team builds, maintains, and tests software using [VS
Code](https://code.visualstudio.com/download) The following items are brought
over during our dotfiles onboarding script:

1. Snippets - Helpful *gist-like* executable scripts for the tech stacks we use.
2. Extensions - By using one of the dotbot plugins called *dotbot-vscode*, it
   automatically will install the ide, install our default extensions. You will
   be prompted several times to allow access back to JIRA, github, and a couple
   other cross platform integrations. During
   this process, the script first Below are a number of helpful VS
   Code extensions, if he decides to try it:

Helpful VS Code Extensions for General Workflow

Name: Auto Import
Id: steoates.autoimport
Description: Automatically finds, parses and provides code actions and code completion for all available imports. Works with Typescript and TSX
Version: 1.5.3
Publisher: steoates
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=steoates.autoimport>
Name: Code Spell Checker
Id: streetsidesoftware.code-spell-checker
Description: Spelling checker for source code
Version: 1.9.2
Publisher: Street Side Software
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker>
Name: DotENV
Id: mikestead.dotenv
Description: Support for dotenv file syntax
Version: 1.0.1
Publisher: mikestead
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=mikestead.dotenv>
Name: ESLint
Id: dbaeumer.vscode-eslint
Description: Integrates ESLint JavaScript into VS Code.
Version: 2.1.13
Publisher: Dirk Baeumer
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint>
Name: GitLens — Git supercharged
Id: eamodio.gitlens
Description: Supercharge the Git capabilities built into Visual Studio Code — Visualize code authorship at a glance via Git blame annotations and code lens, seamlessly navigate and explore Git repositories, gain valuable insights via powerful comparison commands, and so much more
Version: 10.2.3
Publisher: Eric Amodio
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens>
Name: HTMLHint
Id: mkaufman.htmlhint
Description: VS Code integration for HTMLHint - A Static Code Analysis Tool for HTML
Version: 0.10.0
Publisher: Mike Kaufman
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=mkaufman.HTMLHint>
Name: Jira and Bitbucket (Official)
Id: atlassian.atlascode
Description: Bringing the power of Jira and Bitbucket to VS Code - With Atlassian for VS Code you can create and view issues, start work on issues, create pull requests, do code reviews, start builds, get build statuses and more!
Version: 2.8.3
Publisher: Atlassian
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=Atlassian.atlascode>
Name: Live Server
Id: ritwickdey.liveserver
Description: Launch a development local Server with live reload feature for static & dynamic pages
Version: 5.6.1
Publisher: Ritwick Dey
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer>
Name: Live Share
Id: ms-vsliveshare.vsliveshare
Description: Real-time collaborative development from the comfort of your favorite tools.
Version: 1.0.3121
Publisher: Microsoft
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=MS-vsliveshare.vsliveshare>
Name: markdownlint
Id: davidanson.vscode-markdownlint
Description: Markdown linting and style checking for Visual Studio Code
Version: 0.37.2
Publisher: David Anson
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint>
Name: npm Intellisense
Id: christian-kohler.npm-intellisense
Description: Visual Studio Code plugin that autocompletes npm modules in import statements
Version: 1.3.1
Publisher: Christian Kohler
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=christian-kohler.npm-intellisense>
Name: Path Intellisense
Id: christian-kohler.path-intellisense
Description: Visual Studio Code plugin that autocompletes filenames
Version: 2.3.0
Publisher: Christian Kohler
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense>
Name: Prettier - Code formatter
Id: esbenp.prettier-vscode
Description: Code formatter using prettier
Version: 5.7.1
Publisher: Prettier
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode>
Name: Sort JSON objects
Id: richie5um2.vscode-sort-json
Description: Sorts the keys within JSON objects
Version: 1.18.1
Publisher: richie5um2
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=richie5um2.vscode-sort-json>
Name: Sort lines
Id: tyriar.sort-lines
Description: Sorts lines of text
Version: 1.9.0
Publisher: Daniel Imms
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=Tyriar.sort-lines>
Name: stylelint
Id: stylelint.vscode-stylelint
Description: Modern CSS/SCSS/Less linter
Version: 0.85.0
Publisher: stylelint
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=stylelint.vscode-stylelint>
Name: Visual Studio IntelliCode
Id: visualstudioexptteam.vscodeintellicode
Description: AI-assisted development
Version: 1.2.10
Publisher: Microsoft
VS Marketplace Link: <https://marketplace.visualstudio.com/items?itemName=VisualStudioExptTeam.vscodeintellicode>
