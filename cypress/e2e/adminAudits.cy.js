describe("admin audits page", () => {
  beforeEach(() => {
    cy.app("clean");
  });

  context("as a non-admin user", () => {
    beforeEach(() => {
      // create a test user without admin privileges
      cy.appFactories([["create", "user", { uid: "testuser" }]]);
      cy.login({ uid: "testuser" });
    });

    it("should not be able to access admin audits page", () => {
      cy.visit("/shortener/admin/audits");

      // it should redirect to the urls page
      cy.location("pathname").should("eq", "/shortener/urls");

      // FIXME: the error message is actually hidden behind the
      // hero, so this fails (usually). See #120.
      // it should display an error message
      // cy.contains("not authorized", { matchCase: false }).should("be.visible");
    });
  });

  context("as an admin", () => {
    beforeEach(() => {
      cy.fixture("users/admin.json")
        .as("admin")
        .then((admin) => {
          cy.appFactories([
            ["create", "user", { uid: admin.umndid, admin: true }],
          ]);
          cy.login({ uid: admin.umndid });
        });

      cy.visit("/shortener/admin/audits");
    });

    it("shows the audit page title and col headers", () => {
      cy.get(".page-header > h1").should("contain", "Audit Log");

      // check the column headers
      ["Item", "Last Action", "Whodunnit", "Change History", "As Of"].forEach(
        (text) => {
          cy.get("#audits-table").should("contain", text);
        }
      );
    });
  });
});
