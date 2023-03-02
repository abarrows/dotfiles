/* eslint-disable global-require */
/* eslint-disable object-shorthand */
/* eslint-disable func-names */
/* eslint-disable no-param-reassign */

const path = require("path");

// Use the hidden-source-map option when you don't want the source maps to be
// publicly available on the servers, only to the error reporting
const withSourceMaps = require("@zeit/next-source-maps")();

// Use the SentryWebpack plugin to upload the source maps during build step
const SentryWebpackPlugin = require("@sentry/webpack-plugin");

const getRedirects = require("./redirects/getRedirects");

const {
  SENTRY_DSN,
  SENTRY_ORG,
  SENTRY_PROJECT,
  APP_VERSION,
  NODE_ENV,
  SENTRY_AUTH_TOKEN,
} = process.env;

module.exports = withSourceMaps({
  async redirects() {
    return getRedirects();
  },
  webpack: (config, options) => {
    // In `pages/_app.js`, Sentry is imported from @sentry/node. While
    // @sentry/browser will run in a Node.js environment, @sentry/node will use
    // Node.js-only APIs to catch even more unhandled exceptions.
    //
    // This works well when Next.js is SSRing your page on a server with
    // Node.js, but it is not what we want when your client-side bundle is being
    // executed by a browser.
    //
    // Luckily, Next.js will call this webpack function twice, once for the
    // server and once for the client. Read more:
    // https://nextjs.org/docs#customizing-webpack-config
    //
    // So ask Webpack to replace @sentry/node imports with @sentry/browser when
    // building the browser's bundle
    if (!options.isServer) {
      config.resolve.alias["@sentry/node"] = "@sentry/browser";
    }

    /// When all the Sentry configuration env variables are available/configured
    // The Sentry webpack plugin gets pushed to the webpack plugins to build
    // and upload the source maps to sentry.
    // This is an alternative to manually uploading the source maps
    // Note: This is disabled in development mode.
    if (
      SENTRY_DSN &&
      SENTRY_ORG &&
      SENTRY_PROJECT &&
      SENTRY_AUTH_TOKEN &&
      APP_VERSION &&
      NODE_ENV === "production"
    ) {
      config.plugins.push(
        new SentryWebpackPlugin({
          include: ".next",
          ignore: ["node_modules"],
          urlPrefix: "~/_next",
          stripPrefix: ["webpack://_N_E/"],
          release: `${APP_VERSION}`,
        })
      );
    }

    // Polyfills
    const originalEntry = config.entry;
    config.entry = async () => {
      const entries = await originalEntry();
      if (
        entries["main.js"] &&
        !entries["main.js"].includes("./client/polyfills.js")
      ) {
        entries["main.js"].unshift("./client/polyfills.js");
      }
      return entries;
    };

    // Prebid
    config.module.rules.push({
      test: /.js$/,
      include: new RegExp(`\\${path.sep}prebid\\.js`),
      use: {
        loader: "babel-loader",
        options: require("prebid.js/.babelrc.js"),
      },
    });

    return config;
  },
});
