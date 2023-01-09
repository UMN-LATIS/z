describe("Home Page", () => {
  beforeEach(() => {
    cy.app("clean");
    cy.createUser("testuser");
  });

  it("shows the home page if you're not logged in", () => {
    cy.visit("/");

    // welcome message
    cy.get('[data-cy="hero-title"]').should("contain", "What will you Z?");

    // sign in button
    cy.contains("Sign In to Z").should("exist");
  });

  it("redirects to urls page if signed in", () => {
    cy.login("testuser");
    cy.visit("/");
    cy.location("pathname").should("equal", "/shortener/urls");
  });
});
