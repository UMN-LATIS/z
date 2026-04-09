import admin from "../fixtures/users/admin.json";
import user1 from "../fixtures/users/user1.json";

describe("admin urls exact search", () => {
  beforeEach(() => {
    cy.app("clean");
    cy.createAndLoginUser(admin.umndid, { admin: true });
    cy.createUser(user1.umndid, {
      internet_id_loaded: user1.internet_id,
    }).then((user) => {
      // Create URLs where short keyword is a substring of longer ones
      cy.createUrl({
        keyword: "go",
        url: "https://go.umn.edu",
        group_id: user.context_group_id,
      });
      cy.createUrl({
        keyword: "google",
        url: "https://google.com",
        group_id: user.context_group_id,
      });
      cy.createUrl({
        keyword: "gopher",
        url: "https://gopher.umn.edu",
        group_id: user.context_group_id,
      });
      cy.createUrl({
        keyword: "golang",
        url: "https://golang.org",
        group_id: user.context_group_id,
      });
    });
    cy.visit("/shortener/admin/urls");
  });

  it("returns only the exact match when keyword is quoted", () => {
    // Type a quoted search term into the Z-link (keyword) column filter
    // The keyword column filter is the first filter input
    cy.get('[data-cy="admin-urls-table"] thead input[type="text"]')
      .first()
      .type('"go"');

    // Wait for the server-side search to complete
    cy.get('[data-cy="admin-urls-table"] tbody').should("not.contain", "Loading");

    // Should show only the exact match "go", not "google", "gopher", "golang"
    cy.get("[data-cy='admin-urls-table'] tbody > tr").should("have.length", 1);
    cy.get("[data-cy='admin-urls-table'] tbody").should("contain", "go");
    cy.get("[data-cy='admin-urls-table'] tbody").should("not.contain", "google");
    cy.get("[data-cy='admin-urls-table'] tbody").should(
      "not.contain",
      "gopher"
    );
    cy.get("[data-cy='admin-urls-table'] tbody").should(
      "not.contain",
      "golang"
    );
  });

  it("still returns substring matches when keyword is not quoted", () => {
    // Type an unquoted search term — should behave as before (LIKE %go%)
    cy.get('[data-cy="admin-urls-table"] thead input[type="text"]')
      .first()
      .type("go");

    cy.get('[data-cy="admin-urls-table"] tbody').should("not.contain", "Loading");

    // Should show all URLs containing "go"
    cy.get("[data-cy='admin-urls-table'] tbody > tr").should(
      "have.length.at.least",
      4
    );
    cy.get("[data-cy='admin-urls-table'] tbody").should("contain", "go");
    cy.get("[data-cy='admin-urls-table'] tbody").should("contain", "google");
    cy.get("[data-cy='admin-urls-table'] tbody").should("contain", "gopher");
    cy.get("[data-cy='admin-urls-table'] tbody").should("contain", "golang");
  });
});
