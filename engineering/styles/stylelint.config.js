module.exports = {
  extends: ['stylelint-config-standard-scss', 'stylelint-config-prettier-scss'],
  ignoreFiles: ['**/*.js', '**/*_design-tokens.scss'],
  plugins: [
    'stylelint-no-unsupported-browser-features',
    'stylelint-a11y',
    'stylelint-color-format',
  ],
  // https://github.com/stylelint-scss/stylelint-scss/tree/master/src/rules
  rules: {
    'declaration-no-important': [
      true,
      {
        message: 'Avoid usage of !important',
        severity: 'warning',
      },
    ],
    'at-rule-disallowed-list': [
      'extend',
      {
        severity: 'error',
        message: 'No @extend',
      },
    ],
    'color-format/format': {
      format: 'rgb',
    },
    'plugin/no-unsupported-browser-features': [
      true,
      {
        browsers: ['> 1%', 'Last 2 versions'],
        ignore: ['flexbox', 'viewport-units', 'multicolumn'],
        severity: 'warning',
      },
    ],

    'property-no-unknown': [true],
    'property-no-vendor-prefix': true,
    'selector-class-pattern': [
      '^([a-z][a-z0-9]*)((_|__|[A-Z])[a-z0-9]+)*$',
      {
        resolveNestedSelectors: true,
        severity: 'error',
        message:
          'USE AMU variant of BEM naming for class selectors. Remember: Only underscores.  IE: .blockName_modifierName and .blockName__elementName',
      },
    ],
    'selector-pseudo-element-colon-notation': 'single',
    'selector-max-id': 0,
    'selector-pseudo-class-no-unknown': [
      true,
      {
        ignorePseudoClasses: ['export', 'global', 'local', 'root'],
      },
    ],
    'shorthand-property-no-redundant-values': true,
    'value-no-vendor-prefix': true,
    'scss/at-import-partial-extension-whitelist': ['module'],

    // Front-end Consensus Agreed Rules
    // they were introduced during version upgrades and affect many files
    'comment-empty-line-before': 'always',
    'custom-property-no-missing-var-function': true,
    'custom-property-pattern': '^([a-z][a-z0-9]*)(-[a-z0-9]+)*$',
    'declaration-block-no-redundant-longhand-properties': true,
    'declaration-empty-line-before': 'never', // conflicts with prettier
    'rule-empty-line-before': 'never', // conflicts with prettier
    'scss/at-import-partial-extension': 'never', // 'DISCUSS'
    'scss/at-mixin-argumentless-call-parentheses': 'always',
    'scss/at-mixin-pattern': '^([a-z][a-z0-9]*)(-[a-z0-9]+)*$',
    'scss/dollar-variable-empty-line-before': 'always',
    'scss/dollar-variable-pattern': '^([a-z][a-z0-9]*)(-[a-z0-9]+)*$',
    'scss/double-slash-comment-empty-line-before': 'never', // conflicts with prettier
    'scss/no-global-function-names': true,
  },
};
