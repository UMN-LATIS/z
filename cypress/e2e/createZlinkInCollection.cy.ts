import user1 from "../fixtures/users/user1.json";
import { RailsModel } from "../types";

describe("create zlink in collection", () => {
  let group: RailsModel.Group | null = null;

  beforeEach(() => {
    cy.app("clean");
    cy.createAndLoginUser(user1.umndid);
    cy.createGroup("testcollection").then((grp) => {
      group = grp;
      cy.addUserToGroup(user1.umndid, grp);
    });
  });
  it("creates a zlink within the collection when on a collection page", () => {
    cy.visit(`/shortener/urls?collection=${group.id}`);

    // create a zlink on this collection page
    cy.get("#url_url").type("https://example.com");
    cy.contains("Z-Link It").click();

    // expect to see the zlink within the collection
    cy.get("#urls-table tbody tr:first-child").within(() => {
      cy.contains("https://example.com").should("exist");
    });
  });
});
