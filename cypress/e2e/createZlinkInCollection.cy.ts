import user1 from "../fixtures/users/user1.json";
import { RailsModel } from "../types";

describe("create zlink in collection", () => {
  let myGroup: RailsModel.Group | null = null;
  let notMyGroup: RailsModel.Group | null = null;

  beforeEach(() => {
    cy.app("clean");
    cy.createAndLoginUser(user1.umndid);
    cy.createGroup("testcollection")
      .then((grp) => {
        myGroup = grp;
        cy.addUserToGroup(user1.umndid, grp);
      })
      .then(() => {
        cy.createGroup("othercollection");
      })
      .then((grp) => {
        notMyGroup = grp;
      });
  });
  it("creates a zlink within the collection when on a collection page", () => {
    cy.visit(`/shortener/urls?collection=${myGroup.id}`);

    // create a zlink on this collection page
    cy.get("#url_url").type("https://example.com");
    cy.contains("Z-Link It").click();

    // expect to see the zlink within the collection
    cy.get("#urls-table tbody tr:first-child").within(() => {
      cy.contains("https://example.com").should("exist");
    });
  });

  it("does not permit creating a zlink in a collection you do not have access to", () => {
    cy.visit(`/shortener/urls?collection=${notMyGroup.id}`);
    cy.get("#url_url").type("https://thisshouldntwork.com");
    cy.contains("Z-Link It").click();

    // verify that the url was not created in the database
    cy.appEval(`Url.where(url: "https://thisshouldntwork.com").count`).should(
      "eq",
      0
    );

    // cy.contains(
    //   "You do not have permission to access this collection"
    // ).should("exist");
  });
});
