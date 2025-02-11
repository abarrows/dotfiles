# instructions

## defaultLanguage

This project uses TypeScript and strives to maintain a high level of code
quality. Please follow the guidelines below to ensure consistency and
readability across the codebase.

## generalGuidance

Follow modern software engineering typescript and React best practices. A high
focus should be on maintainability, clarity, scalability, and adherence to the
12-factor principles. When creating utility functions and component
capabilities, you must always deliver automated tests to cover the new code.
Write comprehensive tests using Jest and Testing Library to ensure code
reliability. On naming things, be verbose and descriptive. Avoid abbreviations.
This project always uses absolute imports from the base path. IE: from
'../../../types/etc. Do not use relative imports. IE: 'src/components/etc.'.

## Project History

This app was originally built with Create React App (CRA) and Material UI. If
at all possible, always initially try to leverage MUI's capabilities and
components before writing bespoke code for the same functionality. Our current
goal is to migrate the app to Next.js and Tailwind CSS. Any architecture or
structure that can assist a seamless shift to Nextjs and/or Vite would be ideal.

The project uses css modules for styling but prefer to use classes and props
within the component if at all possible.

## Frameworks

### SWR

Use SWR for data fetching and state management to ensure a clean and
scalable architecture. This library is already included in the project and
should be used for all data fetching and state management. Analyze the API
fetching patterns and ensure that it continues to use these patterns.

## preferences

### codingStyle

Airbnb
Material UI - You must use version 4's API and components. Do not use version 5
until the migration to Next.js is complete.
Jest
Testing Library
Next.js
Vite

### Dependencies

SWR
@mui/material
tailwindcss
jest
@testing-library/react
