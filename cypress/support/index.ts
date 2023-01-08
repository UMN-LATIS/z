// ***********************************************************
// This example support/index.js is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

type RailsAppFactoriesCommand = [string, string, Record<string, unknown>];

// cypress/support/index.ts
declare global {
  namespace Cypress {
    interface Chainable {
      /**
       * Custom command to select DOM element by data-cy attribute.
       * @example cy.dataCy('greeting')
       */
      // dataCy(value: string): Chainable<JQuery<HTMLElement>>,
      appFactories<Model>(
        commands: RailsAppFactoriesCommand[]
      ): Chainable<Model[]>;
    }
  }
}
import "cypress-real-events";
import "./commands";
import "./on-rails";
