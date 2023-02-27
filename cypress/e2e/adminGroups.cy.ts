import { validateFlashMessage } from "../support/validateFlashMessage";

//fixtures
import admin from "../fixtures/users/admin.json";
import user1 from "../fixtures/users/user1.json";

describe("admin groups index page", () => {
  beforeEach(() => {
    cy.app("clean");
  });

  context("as a non-admin user", () => {
    beforeEach(() => {
      cy.createAndLoginUser("testuser");
    });
    it("should not be able to access admin groups page", () => {
      cy.visit("/shortener/admin/groups");

      cy.location("pathname").should("eq", "/shortener/urls");

      validateFlashMessage("not authorized");
    });
    it("should not be able to use the admin groups api endpoint", () => {});
  });

  context("as an admin user", () => {
    beforeEach(() => {
      cy.createAndLoginUser(admin.umndid, { admin: true });
      // create some additional users
      cy.createUser("test1");
      cy.createUser("test2");
      cy.createUser("test3");

      // create a collection and add the current user to it
      cy.createGroup("collection1").then((group) => {
        cy.addUserToGroup("test1", group);
        cy.addUserToGroup("test2", group);
      });

      cy.createGroup("collection2").then((group) => {
        cy.addUserToGroup("test2", group);
        cy.addUserToGroup("test3", group);
      });

      cy.createGroup("collection3").then((group) => {
        cy.addUserToGroup("test3", group);
        cy.addUserToGroup("test1", group);
      });

      // visit the groups page
      cy.visit("/shortener/admin/groups");
    });

    it("shows a list of collections", () => {
      cy.get("[data-cy='groups-table'] > tbody > tr").should("have.length", 3);

      cy.get("[data-cy='groups-table'] > tbody > tr").each(($el, index) => {
        cy.wrap($el).within(() => {
          // collection name
          cy.get("td")
            .eq(0)
            .should("contain", `collection${index + 1}`);

          // collection description
          cy.get("td")
            .eq(1)
            .should("contain", `group_descr${index + 1}`);
        });
      });
    });

    it("can edit a collection name or description", () => {
      cy.get("[data-cy='groups-table'] > tbody > tr")
        .eq(0)
        .within(() => {
          cy.get("td").eq(0).should("contain", "collection1");

          cy.contains("Edit").click();

          cy.get("#group_name").clear().type("new name");
          cy.contains("Save").click();
        });
    });
    it("allows collections to be sorted by name");

    it("allows collections to be searched by name");

    it("can edit a collection name or description");

    it("can create a new collection");

    it("can delete a collection");

    it(
      "shows an error and does not update if a collection name is already taken"
    );
  });
});
