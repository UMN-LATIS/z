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

import "cypress-real-events";
import "./commands";
import "./on-rails";

import { RailsModel } from "../types";
import { RailsAppFactoriesCommand } from "../types";

// add custom commands to Cypress interface
// for autocompletion and type checking
declare global {
  namespace Cypress {
    interface Chainable {
      // dataCy(value: string): Chainable<JQuery<HTMLElement>>,

      app(command: string, ...args: unknown[]): Chainable<unknown>;

      appEval(code: string): Chainable<unknown>;

      appFactories<T>(commands: RailsAppFactoriesCommand[]): Chainable<T[]>;

      login(uid: string, redirect_to?: string): Chainable<void>;

      createUser(
        uid: string,
        opts?: Record<string, unknown>
      ): Chainable<RailsModel.User>;

      createAndLoginUser(
        uid: string,
        opts?: Record<string, unknown>
      ): Chainable<RailsModel.User>;

      createAnnouncement(
        opts?: Record<string, unknown>
      ): Chainable<RailsModel.Announcement>;

      createUrl({
        keyword,
        url,
      }: {
        keyword: string;
        url: string;
        user: RailsModel.User;
      }): Chainable<RailsModel.Url>;

      clickUrl(url: string, times?: number): Chainable<void>;
    }
  }
}
