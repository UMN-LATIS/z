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

      createUrl(partialUrl: Partial<RailsModel.Url>): Chainable<RailsModel.Url>;

      clickUrl(
        keyword: string,
        times?: number,
        clickOptions?: Partial<RailsModel.Click>
      ): Chainable<RailsModel.Click[]>;

      createGroup(name: string): Chainable<RailsModel.Group>;

      addUserToGroup(
        uid: string /* user uid or umndid */,
        group: Pick<RailsModel.Group, "name">
      ): Chainable<RailsModel.Group>;

      addURLToGroup(
        urlKeyword: string,
        group: Pick<RailsModel.Group, "name">
      ): Chainable<RailsModel.Group>;

      createGroupAndAddUser(
        groupName: string,
        uid: string /* user uid or umndid */
      ): Chainable<RailsModel.Group>;
    }
  }
}
