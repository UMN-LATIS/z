import user1 from "../fixtures/users/user1.json";
import user2 from "../fixtures/users/user2.json";
import { RailsModel } from "../types";

describe("create zlink in collection", () => {
  let user1Collection: RailsModel.Group | null = null;
  let user2Collection: RailsModel.Group | null = null;

  beforeEach(() => {
    cy.app("clean");
    cy.createUser(user1.umndid, { internet_id_loaded: user1.internet_id });
    cy.createUser(user2.umndid, { internet_id_loaded: user2.internet_id });

    cy.login(user1.umndid);

    cy.createGroup("user1collection")
      .then((grp) => {
        user1Collection = grp;
        cy.addUserToGroup(user1.umndid, grp);
      })
      .then(() => cy.createGroup("user2collection"))
      .then((grp) => {
        user2Collection = grp;
        cy.addUserToGroup(user2.umndid, grp);
      });
  });
  it("creates a zlink within the collection when on a collection page", () => {
    cy.visit(`/shortener/urls?collection=${user1Collection.id}`);

    // create a zlink on this collection page
    cy.get("#url_url").type("https://example.com");
    cy.contains("Z-Link It").click();

    // expect to see the zlink within the collection
    cy.get("#urls-table tbody tr:first-child").within(() => {
      cy.contains("https://example.com").should("exist");
    });
  });

  it("does not permit creating a zlink in a collection you do not have access to", () => {
    cy.visit(`/shortener/urls?collection=${user2Collection.id}`);
    cy.get("#url_url").type("https://madeByUser1.com");
    cy.contains("Z-Link It").click();

    // expect to see the url in User 1's default collection
    cy.visit("/shortener/urls");
    cy.contains("https://madeByUser1.com").should("exist");

    // then check the user 2 collection to verify the url is not there
    cy.login(user2.umndid);
    cy.visit(`/shortener/urls?collection=${user2Collection.id}`);
    cy.contains("https://madeByUser1.com").should("not.exist");
  });
});
