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

      // FIXME: the error message is actually hidden behind the
      // hero, so this fails (usually). See #120.
      // it should display an error message
      // cy.contains("not authorized", { matchCase: false }).should("be.visible");
    });
  });

  context("as an admin user", () => {
    beforeEach(() => {
      cy.createAndLoginUser(admin.umndid, { admin: true });
      cy.createUser(user1.umndid, {
        internet_id_loaded: user1.internet_id,
      }).then((user) => {
        cy.createUrl({
          keyword: "x1",
          url: "https://example1.com",
          user,
        });
        cy.createUrl({
          keyword: "x2",
          url: "https://example2.com",
          user,
        });
        cy.createUrl({
          keyword: "x3",
          url: "https://example3.com",
          user,
        });
      });
      cy.visit("/shortener/admin/urls");
    });

    it("shows the url info", () => {
      // check the column headers
      cy.get("#urls-table > thead")
        .should("contain", "Long URL")
        .should("contain", "Owner")
        .should("contain", "Clicks")
        .should("contain", "Created");

      // check the row data
      cy.get("#urls-table > tbody > tr").should("have.length", 3);
      cy.get("#urls-table").contains("x1").closest("tr").as("row1");

      cy.get("@row1")
        .should("contain", "x1")
        .should("contain", user1.internet_id);
    });

    it("updates the long url", () => {
      cy.get("#urls-table").contains("x1").closest("tr").as("row1");

      //open the first row's actions dropdown
      cy.get("@row1").find(".actions-dropdown-button").click();

      // click "Edit"
      cy.get("@row1").contains("Edit").click();

      cy.get("#url_url").clear().type("https://www.x1-updated.com");
      cy.contains("Submit").click();

      // check that the row was updated
      // currently there's a bug that doesn't close the form
      // and show the updated row, so we need to reload the
      // page to see the change. See #124.
      cy.reload();

      // the long url isn't shown anywhere in the current ui
      // so we need to click edit to see where it points
      cy.get("#urls-table").contains("x1").closest("tr").as("row1");
      cy.get("@row1").find(".actions-dropdown-button").click();
      cy.get("@row1").contains("Edit").click();
      cy.get("#url_url").should("have.value", "https://www.x1-updated.com");
    });

    it("updates the url keyword (the short url)", () => {
      cy.get("#urls-table").contains("x1").closest("tr").as("row1");

      //open the first row's actions dropdown
      cy.get("@row1").find(".actions-dropdown-button").click();

      // click "Edit"
      cy.get("@row1").contains("Edit").click();

      cy.get("#url_keyword").clear().type("x1-updated");
      cy.contains("Submit").click();

      // check that the row was updated
      // currently there's a bug that doesn't close the form
      // and show the updated row, so we need to reload the
      // page to see the change. See #124.
      cy.reload();

      cy.get("#urls-table").contains("x1").closest("tr").as("row1");
      cy.get("@row1").should("contain", "x1-updated");
    });

    it("shows an error and does not update if a keyword is already taken", () => {
      cy.get("#urls-table").contains("x1").closest("tr").as("row1");

      //open the first row's actions dropdown
      cy.get("@row1").find(".actions-dropdown-button").click();

      // click "Edit"
      cy.get("@row1").contains("Edit").click();

      // try changing the keyword to x2, which is already taken
      cy.get("#url_keyword").clear().type("x2");
      cy.contains("Submit").click();

      // check that an error is shown
      cy.contains("has already been taken").should("be.visible");

      // reload and verify that the keyword was not changed
      cy.reload();
      cy.get("#urls-table").contains("x1").closest("tr").as("row1");
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
