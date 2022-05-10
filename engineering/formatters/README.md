# Tools

- [EditorConfig Setup](https://editorconfig.org/)
- [Prettier](https://prettier.io/)
- [HTML Tidy](https://www.html-tidy.org/)
- [HTML Hint](https://marketplace.visualstudio.com/items?itemName=mkaufman.HTMLHint)

## Code Formatting

There are many benefits to having the entire team using the same tools, but
perhaps the biggest is consistency in code formatting. Consistent formatting
increases legibility, reduces editing time (auto formatting to the rescue!),
makes manually addressing merge conflicts easier, and can even reveal code
structure problems before testing.

During active development there are three major steps that occur upon saving a
file. In the following order, our code (in any language) will do the following
in this order:

1. Automatically Linted and auto-fixed if possible (Es-lint/Stylelint/YAML Lint/Etc.)
2. The file's code is then formatted (Prettier, htmltidy, htmlhint)
3. MANUAL: Check the "Problems" tab in the terminal info panel and fix any remaining
   linting errors or any extra formatting IE: (Command Palette -> Sort JSON)

*Note: If formatting is not desired, you can skip this by opening the command
palette Cmd + Shift + P and typing:*Save File without Formatting*

### Caveats

- In order to prevent syntax and code breakage, I have turned off the following:
  - Format on Type (Since formatting should be done before linting)
  - Format on Paste (Since formatting should be done before linting)
- I am using yarn to install the following NPM packages so that linting only
  lints code quality problems and doesn't bleed into the formatting of code.
  (Vica versa)
