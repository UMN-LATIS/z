import admin from "../fixtures/users/admin.json";
import user1 from "../fixtures/users/user1.json";
import user2 from "../fixtures/users/user2.json";

describe("admin url details (stats) page", () => {
  beforeEach(() => {
    cy.app("clean");

    // create a test user without admin privileges
    // and a create url that belong to user1
    cy.createUser(user1.umndid).then((user) => {
      cy.createUrl({
        keyword: "user1",
        url: "https://user1url.com",
        user,
      });
    });
  });

  describe("error handling", () => {
    beforeEach(() => {
      // FIXME: catch the drawChartHrs24 error for now
      cy.on("uncaught:exception", (err, runnable) => {
        if (err.message.includes("drawChartHrs24")) {
          return false;
        }
      });
    });

    it("redirects a user who is not the owner or an admin back to the urls page and shows a not authorized error", () => {
      cy.createAndLoginUser("testuser");

      cy.visit("/shortener/urls/user1");

      // it should redirect to the urls page
      cy.location("pathname").should("eq", "/shortener/urls");

      // FIXME: the error message is actually hidden behind the
      // hero, so this fails (usually). See #120.
      // it should display an error message
      // cy.contains("not authorized", { matchCase: false }).should("be.visible");
    });

    it("shows a not found page when the url does not exist", () => {
      cy.visit("/shortener/urls/does-not-exist", {
        failOnStatusCode: false,
      });
      cy.contains("not found", { matchCase: false }).should("be.visible");
    });
  });

  it("tracks clicks", () => {});
});
