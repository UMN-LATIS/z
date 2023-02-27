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
    let collections = [];
    beforeEach(() => {
      collections = [];
      cy.createAndLoginUser(admin.umndid, { admin: true });
      // create some additional users
      cy.createUser("test1");
      cy.createUser("test2");

      // create a collection and add the current user to it
      cy.createGroup("collection0").then((group) => {
        collections.push(group);
        // no members, no urls
      });

      cy.createGroup("collection1").then((group) => {
        collections.push(group);
        // 1 member, 1 url
        cy.addUserToGroup("test1", group);
        cy.createUrl({
          keyword: "test1",
          url: "https://example.com",
          group_id: group.id,
        });
      });

      cy.createGroup("collection2").then((group) => {
        collections.push(group);

        // add 2 members and 2 urls
        cy.addUserToGroup("test1", group);
        cy.addUserToGroup("test2", group);
        cy.createUrl({
          keyword: "test2a",
          url: "https://example.com",
          group_id: group.id,
        });

        cy.createUrl({
          keyword: "test2b",
          url: "https://example.com",
          group_id: group.id,
        });
      });

      // visit the groups page
      cy.visit("/shortener/admin/groups");
    });

    it("shows a list of collections", () => {
      cy.get("[data-cy='groups-table'] tbody > tr")
        .should("have.length", 3)
        .each(($el, index) => {
          cy.wrap($el).within(() => {
            const collection = collections[index];

            // id
            cy.get("td").eq(0).should("contain", collection.id);

            // collection name
            cy.get("td")
              .eq(1)
              .should("contain", collection.name)
              .should("contain", collection.description);

            // number of urls
            // group 0 has no urls, group 1 has 1 url, ...
            cy.get("td").eq(2).should("contain", `${index} url`);

            // number of members
            // group 0 has no members, group 1 has 1 member, ...
            cy.get("td").eq(3).should("contain", `${index} member`);
          });
        });
    });

    it("can edit a collection name or description", () => {
      cy.get("[data-cy='groups-table'] tbody > tr")
        .eq(0)
        .within(() => {
          cy.get("td").eq(1).should("contain", collections[0].name);
          cy.contains("Edit").click();
        });

      cy.get('[data-cy="update-group"] [data-cy="group-name"]')
        .clear()
        .type("new name");

      cy.get('[data-cy="update-group"] [data-cy="group-description"]')
        .clear()
        .type("new description");

      cy.contains("Save").click();

      cy.get("[data-cy='groups-table'] tbody > tr")
        .eq(0)
        .within(() => {
          cy.get("td")
            .eq(1)
            .should("contain", "new name")
            .should("contain", "new description");
        });
    });

    it.only("removes a collection", () => {
      cy.get("[data-cy='groups-table'] tbody > tr")
        .eq(0)
        .within(() => {
          cy.get("td").eq(1).should("contain", collections[0].name);
          cy.contains("Delete").click();
        });

      cy.contains("Confirm").click();

      cy.get("[data-cy='groups-table'] tbody > tr")
        .should("have.length", 2)
        .should("not.contain", collections[0].name);
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
