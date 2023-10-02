module.exports = {
  root: true,
  plugins: [
    'babel',
    'chai-friendly',
    'react',
    'jsx-a11y',
    '@typescript-eslint',
  ],
  extends: [
    'airbnb',
    'airbnb/hooks',
    'next/core-web-vitals',
    'plugin:react/recommended',
    'prettier',
    'plugin:storybook/csf',
    'plugin:storybook/recommended',
    'plugin:storybook/csf-strict',
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    requireConfigFile: false,
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 2021,
    sourceType: 'module',
    babelOptions: {
      presets: ['@babel/preset-react'],
    },
  },
  ignorePatterns: ['src/design-system-package/dist/**', '**/_design_tokens.js'],
  env: {
    jest: true,
    browser: true,
    es6: true,
    node: true,
    jquery: false,
  },
  rules: {
    '@next/next/no-img-element': 1,
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
          '{jest,.storybook,src/stories}/**/*',
          '**/*.{spec,stories,test}.js*',
          'jest.*.js',
          'webpack.config.js',
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
      // default to 'createReactClass'
      pragma: 'React',
      // Pragma to use, default to 'React'
      version: 'detect', // React version. 'detect' automatically picks the version you have installed.
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
