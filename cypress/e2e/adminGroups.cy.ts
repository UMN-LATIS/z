import { validateFlashMessage } from "../support/validateFlashMessage";

describe("admin groups index page", () => {
  beforeEach(() => {
    cy.app("clean");
  });

  context("as a non-admin user", () => {
    beforeEach(() => {
      cy.createAndLoginUser("testuser");
    });
    it("should not be able to access admin groups page", () => {
      cy.visit("/shortener/admin/groups");

      cy.location("pathname").should("eq", "/shortener/urls");

      validateFlashMessage("not authorized");
    });
  });

});
