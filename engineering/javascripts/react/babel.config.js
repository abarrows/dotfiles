/* eslint-disable global-require */
// https://nextjs.org/docs/advanced-features/customizing-babel-config
// Configure these on 'next/babel' only:
//   preset-env
//   preset-react
//   preset-typescript
//   plugin-proposal-class-properties
//   plugin-proposal-object-rest-spread
//   plugin-transform-runtime
//   styled-jsx

module.exports = {
  presets: ['next/babel'],
  plugins: [
    require('@babel/plugin-syntax-dynamic-import').default,
    require('babel-plugin-dynamic-import-node'),
  ],
};
