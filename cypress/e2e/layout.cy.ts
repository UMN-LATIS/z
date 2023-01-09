import user1 from "../fixtures/users/user1.json";

describe("default application layout", () => {
  beforeEach(() => {
    cy.app("clean");
  });

  context("when not signed in", () => {
    beforeEach(() => {
      cy.visit("/");
    });

    it("has Sign In link and nothing that requires a login", () => {
      cy.contains("Sign In").should("exist");
      cy.contains("Sign Out").should("not.exist");
      cy.contains("My URLs").should("not.exist");
    });
  });

  context("when signed in", () => {
    beforeEach(() => {
      cy.createAndLoginUser(user1.umndid);
      cy.visit("/");
    });

    it("has links for sign out, collection, urls, etc", () => {
      cy.contains("Sign In").should("not.exist");
      cy.contains("Sign Out").should("exist");
      cy.contains("My Z-Links").should("exist");
      cy.contains("My Collections").should("exist");
      cy.contains("Help").should("exist");
    });
  });
});
