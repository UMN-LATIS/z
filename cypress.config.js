const { defineConfig } = require("cypress");
const {
  cypressBrowserPermissionsPlugin,
} = require("cypress-browser-permissions");

module.exports = defineConfig({
  e2e: {
    baseUrl: "http://localhost:3000",
    defaultCommandTimeout: 10000,
    supportFile: "cypress/support/index.js",
    excludeSpecPattern: "**/examples/**",
    setupNodeEvents(on, config) {
      cypressBrowserPermissionsPlugin(on, config);
    },
    experimentalRunAllSpecs: true,
  },
  env: {
    browserPermissions: {
      clipboard: "allow",
    },
  },
});
