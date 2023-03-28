//fixtures
import admin from "../fixtures/users/admin.json";
import { validateFlashMessage } from "../support/validateFlashMessage";

describe("admin audits page", () => {
  beforeEach(() => {
    cy.app("clean");
  });

  context("as a non-admin user", () => {
    beforeEach(() => {
      // create a test user without admin privileges
      cy.createAndLoginUser("testuser");
    });

    it("should not be able to access admin audits page", () => {
      cy.visit("/shortener/admin/audits");

      // it should redirect to the urls page
      cy.location("pathname").should("eq", "/shortener/urls");

      validateFlashMessage("not authorized");
    });
  });

  context("as an admin", () => {
    beforeEach(() => {
      cy.createAndLoginUser(admin.umndid, { admin: true });
      cy.visit("/shortener/admin/audits");
    });

    it("shows the audit page title and col headers", () => {
      cy.get("[data-cy='page-name']").should("contain", "Audit Logs");

      // check the column headers
      ["Item", "Event", "Whodunnit", "Change History", "As Of"].forEach(
        (text, i) => {
          cy.get(`.datatable thead th:nth-child(${i + 1})`).should(
            "contain",
            text
          );
        }
      );
    });

    it("renders the change history correctly", () => {
      // test that no tags are rendered in the change history
      cy.get("#audit-1 > :nth-child(4)").should("not.contain", "<br/>");
    });
  });
});
