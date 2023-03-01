import { validateFlashMessage } from "../support/validateFlashMessage";

//fixtures
import admin from "../fixtures/users/admin.json";
import user1 from "../fixtures/users/user1.json";

describe("admin urls page", () => {
  beforeEach(() => {
    cy.app("clean");
  });
  context("as a non-admin user", () => {
    beforeEach(() => {
      // create a test user without admin privileges
      cy.createAndLoginUser("testuser");
    });

    it("should not be able to access admin audits page", () => {
      cy.visit("/shortener/admin/urls");

      // it should redirect to the urls page
      cy.location("pathname").should("eq", "/shortener/urls");

      validateFlashMessage("not authorized");
    });
  });

  context("as an admin user", () => {
    let urls = [];
    beforeEach(() => {
      urls = [];
      cy.createAndLoginUser(admin.umndid, { admin: true });
      cy.createUser(user1.umndid, {
        internet_id_loaded: user1.internet_id,
      }).then((user) => {
        [1, 2, 3].forEach((i) => {
          cy.createUrl({
            keyword: `x${i}`,
            url: `https://example${i}.com`,
            group_id: user.context_group_id,
          }).then((url) => urls.push(url));
        });
      });
      cy.visit("/shortener/admin/urls");
    });

    it("shows the url info", () => {
      // check the column headers
      cy.get('[data-cy="admin-urls-table"] thead').within(() => {
        cy.contains("Z-link");
        // cy.contains("Long URL");
        cy.contains("Owner");
        cy.contains("Clicks");
        cy.contains("Created");
        cy.contains("Actions");
      });

      // check the row data
      cy.get("[data-cy='admin-urls-table'] tbody > tr").should(
        "have.length",
        3
      );
      cy.get("[data-cy='admin-urls-table'] tbody")
        .contains("x1")
        .closest("tr")
        .as("row1");

      cy.get("@row1")
        .should("contain", "x1")
        .should("contain", user1.internet_id);
    });

    it("updates the long url", () => {
      cy.get("[data-cy='admin-urls-table']")
        .contains("x1")
        .closest("tr")
        .as("row1");

      // click "Edit"
      cy.get("@row1").contains("Edit").click();
      cy.get("[data-cy='longurl-input']")
        .clear()
        .type("https://www.x1-updated.com");
      cy.contains("Save").click();

      // check that the row was updated
      cy.get("[data-cy='admin-urls-table']")
        .contains("x1")
        .closest("tr")
        .within(() => {
          cy.contains("https://www.x1-updated.com");
        });
    });

    it("updates the url keyword (the short url)", () => {
      cy.get("[data-cy='admin-urls-table']")
        .contains("x1")
        .closest("tr")
        .as("row1");

      // click "Edit"
      cy.get("@row1").contains("Edit").click();
      cy.get("[data-cy='keyword-input']").clear().type("updated-keyword");
      cy.contains("Save").click();

      // check that the row was updated
      cy.get("[data-cy='admin-urls-table']")
        .contains("https://example1.com")
        .closest("tr")
        .within(() => {
          cy.contains("updated-keyword");
        });
    });

    it.only("shows an error and does not update if a keyword is already taken", () => {
      cy.get("[data-cy='admin-urls-table']")
        .contains("x1")
        .closest("tr")
        .as("row1");

      // click "Edit"
      cy.get("@row1").contains("Edit").click();
      cy.get("[data-cy='keyword-input']").clear().type("x2");
      cy.contains("Save").click();

      // check that an error is shown
      cy.contains("has already been taken").should("be.visible");

      // reload and verify that the keyword was not changed
      cy.reload();
      cy.get("[data-cy='admin-urls-table']")
        .contains("x1")
        .closest("tr")
        .as("row1");
      cy.get("@row1").should("contain", "x1");
    });

    it("deletes a url", () => {
      cy.get("#urls-table").contains("x1").closest("tr").as("row1");

      //open the first row's actions dropdown
      cy.get("@row1").find(".actions-dropdown-button").click();

      // click "Edit"
      cy.get("@row1").contains("Delete").click();

      // check that a confirmation message is shown
      cy.get(".modal-body").contains("Are you sure you want to delete");

      // check that the correct short url is shown with the confirmation message
      cy.get(".modal-body").contains("x1");

      // confirm and check that the row was deleted
      cy.contains("Confirm").click();
      cy.get("#urls-table > tbody > tr").should("have.length", 2);

      // check that the url as also removed from the database
      cy.appEval('Url.where(keyword: "x1").count').then((count) => {
        expect(count).to.eq(0);
      });
    });
  });
});
