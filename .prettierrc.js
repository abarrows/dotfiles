module.exports = {
  singleQuote: true,
  importOrder: [
    '^react$',
    '<THIRD_PARTY_MODULES>',
    '^src/pages/api/(.*)$',
    '^src/helpers/(.*)$',
    '^src/(constants|data)(.*)$',
    '^src/(contexts|store)/(.*)$',
    '^src/(components|page-templates)/(.*)$',
    '^src/(.*)$',
    '^(?!.*\\.module\\.scss)./(.*)$',
    '^../(.*)$',
    '^./(.*)module.scss$',
  ],
  importOrderSeparation: true,
  importOrderCaseInsensitive: true,
};
