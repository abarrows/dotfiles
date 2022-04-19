module.exports = {
  root: true,
  plugins: ['babel', 'cypress', 'chai-friendly', 'react', 'jsx-a11y'],
  extends: [
    'airbnb',
    'airbnb/hooks',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'plugin:cypress/recommended',
    'prettier',
    'plugin:storybook/recommended',
    'plugin:storybook/csf',
    'plugin:storybook/csf-strict',
  ],
  parser: 'babel-eslint',
  parserOptions: {
    ecmaVersion: 6,
    ecmaFeatures: {
      jsx: true,
    },
  },
  env: {
    jest: true,
    browser: true,
    es6: true,
    node: true,
    jquery: false,
  },
  rules: {
    'max-len': [
      'error',
      {
        code: 120,
      },
    ],
    semi: 2,
    'jsx-a11y/anchor-is-valid': 'off',
    // https://nextjs.org/docs/api-reference/next/link
    'no-unused-expressions': 0,
    'chai-friendly/no-unused-expressions': 2,
    'react/jsx-sort-props': [
      1,
      {
        callbacksLast: true,
      },
    ],
    'react/sort-prop-types': [
      1,
      {
        callbacksLast: true,
        sortShapeProp: true,
      },
    ],
    // Require that any module used for application code is declared as a
    // `dependencies`
    // https://github.com/benmosher/eslint-plugin-import/blob/master/docs/rules/no-extraneous-dependencies.md
    // paths are treated both as absolute paths, and relative to process.cwd()
    'import/no-extraneous-dependencies': [
      'error',
      // globs allow using devDependencies in story and test files
      {
        devDependencies: [
          '**/*.{spec,stories,test}.js',
          'webpack.config.js',
          '{.jest,.storybook,cypress}/**/*',
        ],
      },
    ],
  },
  overrides: [
    {
      // Jest overrides
      files: ['./__tests__/**', '**.test.jsx'],
      rules: {
        'react/jsx-props-no-spreading': 'off',
      },
    },
    {
      // Storybook overrides
      files: ['./src/stories/**', '**.stories.jsx', '**.stories_skip.jsx'],
      rules: {
        'max-len': 'off',
        'react/forbid-prop-types': 'off',
        'react/no-unescaped-entities': 'off',
        'react/require-default-props': 'off',
        'react/jsx-props-no-spreading': 'off',
      },
    },
  ],
  settings: {
    'import/resolver': {
      node: {
        moduleDirectory: ['node_modules', '.'],
      },
    },
    react: {
      createClass: 'createReactClass',
      // Regex for Component Factory to use,
      // default to "createReactClass"
      pragma: 'React',
      // Pragma to use, default to "React"
      version: 'detect', // React version. "detect" automatically picks the version you have installed.
    },
    propWrapperFunctions: [
      // The names of any function used to wrap propTypes,
      // e.g. `forbidExtraProps`.If this isn't set, any propTypes
      // wrapped in a function will be skipped.
      'forbidExtraProps',
      {
        property: 'freeze',
        object: 'Object',
      },
      {
        property: 'myFavoriteWrapper',
      },
    ],
    linkComponents: [
      // Components used as alternatives to <a> for linking, eg. <Link to={ url } />
      'Hyperlink',
      {
        name: 'Link',
        linkAttribute: 'to',
      },
    ],
  },
};
