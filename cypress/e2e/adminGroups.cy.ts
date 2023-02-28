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

    it("edits a collection name and description", () => {
      cy.get("[data-cy='groups-table']")
        .contains(collections[0].id)
        .closest("tr")
        .as("row0");

      // edit the first collection
      cy.get("@row0").contains("Edit").click();

      // change the name and description
      cy.get('[data-cy="update-group"] [data-cy="group-name"]')
        .clear()
        .type("updated name");

      cy.get('[data-cy="update-group"] [data-cy="group-description"]')
        .clear()
        .type("updated description");

      // save the changes
      cy.get('[data-cy="update-group"]').contains("Save").click();

      // check that the changes were saved
      cy.get("[data-cy='groups-table'] tbody > tr")
        .should("have.length", 3)
        .contains("updated name")
        .closest("tr")
        .within(() => {
          // verify that the id is still the same
          cy.get("td").eq(0).should("contain", collections[0].id);

          // and that the name and description were updated
          cy.get("td").eq(1).should("contain", "updated name");
          cy.get("td").eq(1).should("contain", "updated description");
        });
    });

    it("removes a collection", () => {
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

    it("allows collections to be sorted by name", () => {
      // check that it's in acending order by default
      cy.get("[data-cy='groups-table'] tbody > tr").each(($el, index) => {
        cy.wrap($el).within(() => {
          const collection = collections[index];

          // collection name
          cy.get("td")
            .eq(1)
            .should("contain", collection.name)
            .should("contain", collection.description);
        });
      });

      //   // click the name header to sort by name
      cy.get("[data-cy='groups-table'] thead > tr")
        .contains("Name")
        .click() // hack: need to click twice to sort in test for some reason?
        .click();

      // check that it's in descending order
      cy.get("[data-cy='groups-table'] tbody > tr").each(($el, index) => {
        cy.wrap($el).within(() => {
          const collection = collections[collections.length - 1 - index];

          // collection name
          cy.get("td")
            .eq(1)
            .should("contain", collection.name)
            .should("contain", collection.description);
        });
      });
    });

    it("links a group name, url, and members", () => {
      const collection = collections[0];
      cy.get("[data-cy='groups-table'] tbody > tr:first-child").within(() => {
        cy.contains(collection.name).should(
          "have.attr",
          "href",
          `/shortener/urls?collection=${collection.id}`
        );

        cy.contains("0 urls").should(
          "have.attr",
          "href",
          `/shortener/urls?collection=${collection.id}`
        );

        cy.contains("0 members").should(
          "have.attr",
          "href",
          `/shortener/groups/${collection.id}/members`
        );
      });
    });

    it("searches collections by name", () => {
      cy.get("[data-cy='groups-table']").within(() => {
        cy.contains("Search").type("collection2");

        cy.get("tbody > tr")
          .should("have.length", 1)
          .should("contain", "collection2");
      });
    });

    it("creates a new collection", () => {
      cy.contains("New Collection").click();

      cy.get('[data-cy="create-group"] [data-cy="group-name"]').type(
        "new collection"
      );
      cy.get('[data-cy="create-group"] [data-cy="group-description"]').type(
        "new description"
      );

      // save the changes
      cy.get('[data-cy="create-group"]').contains("Save").click();

      // check that the changes were saved
      cy.get("[data-cy='groups-table'] tbody > tr")
        .should("have.length", 4)
        .contains("new collection")
        .closest("tr")
        .within(() => {
          cy.get("td").eq(1).should("contain", "new description");
        });
    });
  });
});
