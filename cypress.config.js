const { defineConfig } = require("cypress");
const {
  cypressBrowserPermissionsPlugin,
} = require("cypress-browser-permissions");

module.exports = defineConfig({
  e2e: {
    baseUrl: "http://localhost:3000",
    defaultCommandTimeout: 10000,
    supportFile: "cypress/support/index.ts",
    excludeSpecPattern: "**/examples/**",
    setupNodeEvents(on, config) {
      cypressBrowserPermissionsPlugin(on, config);
    },
    experimentalRunAllSpecs: true,
  },
  env: {
    browserPermissions: {
      "clipboard-read": "allow",
      "clipboard-write": "allow",
    },
  },
  // we hardly use video, so we can disable it to speed up the tests
  video: false,
  retries: {
    // `cypress run` retries
    runMode: 2,
  },
});
