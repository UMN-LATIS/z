describe("Home Page", () => {
  beforeEach(() => {
    cy.createUser("testuser");
  });

  context("not logged in", () => {
    it("shows the home page", () => {
      cy.visit("/");

      // welcome message
      cy.get('[data-cy="hero-title"]').should("contain", "What will you Z?");

      // sign in button
      cy.contains("Sign In to Z").should("exist");
    });
  });
});
