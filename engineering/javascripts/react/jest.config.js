module.exports = {
  testRegex: '(/__tests__/.*|(\\.|/)(test))\\.[j]sx?$',
  collectCoverageFrom: [
    '**/*.{js,jsx,ts,tsx}',
    '!**/*.d.ts',
    '!**/node_modules/**',
  ],
  setupFiles: ['<rootDir>/jest/support/setupEnvironmentVariables.js'],
  setupFilesAfterEnv: ['<rootDir>/jest/support/setupTests.js'],
  testPathIgnorePatterns: ['/node_modules/', '/.next/'],
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': '<rootDir>/node_modules/babel-jest',
    '^.+\\.css$': '<rootDir>/jest/support/cssTransform.js',
  },
  transformIgnorePatterns: [
    '/node_modules/',
    '^.+\\.module\\.(css|sass|scss)$',
  ],
  moduleDirectories: ['node_modules', '.'],
  moduleNameMapper: {
    '^.+\\.module\\.(css|sass|scss)$': 'identity-obj-proxy',
    '\\.(css|less|scss)$': 'identity-obj-proxy',
  },
  // Automatically clear mock calls and instances between every test
  clearMocks: true,
};
