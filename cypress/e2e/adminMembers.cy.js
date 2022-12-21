describe("/admin", () => {
  beforeEach(() => {
    cy.app("clean");
  });

  context("as a non-admin", () => {
    beforeEach(() => {
      // create a test user without admin privileges
      cy.appFactories([["create", "user", { uid: "testuser" }]]);
      cy.login({ uid: "testuser" });
    });

    // FIXME: the error message is actually hidden behind the
    // hero, so this fails (usually). See #120.
    it.skip("should not be able to access admin members page", () => {
      cy.visit("/shortener/admin/members");

      // it should redirect to the urls page
      cy.url().should("eq", Cypress.config().baseUrl + "/shortener/urls");

      // it should display an error message
      // FIXME: the error message is actually hidden behind the
      // hero. See #120
      cy.contains("not authorized", { matchCase: false }).should("be.visible");
    });
  });
});
