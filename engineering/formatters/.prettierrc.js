module.exports = {
  plugins: ['@ianvs/prettier-plugin-sort-imports'],
  singleQuote: true,
  tabWidth: 2,
  trailingComma: 'all',
  jsxSingleQuote: true,
  importOrder: [
    '<BUILTIN_MODULES>',
    '^react$',
    '',
    '<THIRD_PARTY_MODULES>',
    '^data/(.*)$',
    '^src/pages/api/(.*)$',
    '^src/app/api/(.*)$',
    '',
    '^(@|src)/constants(.*)$',
    '^(@|src)/helpers/(.*)$',
    '^(@|src)/contexts/(.*)$',
    '^@/(.*)$',
    '^(@|src)/components/(.*)$',
    '^src/(.*)$',
    '',
    '^(?!.*\\.module\\.scss)./(.*)$',
    '^../(.*)$',
    '^./(.*)module.scss$',
    '^./public/(.*)$',
  ],
};
