import { RailsModel } from "../types";
import user1 from "../fixtures/users/user1.json";
import user2 from "../fixtures/users/user2.json";

describe("Members Page", () => {
  let group: RailsModel.Group | null = null;

  beforeEach(() => {
    group = null;
    cy.app("clean");
    cy.createAndLoginUser(user1.umndid);
    // create a collection and add the current user to it
    cy.createGroup("testcollection")
      .then((g) => {
        group = g;
        cy.addUserToGroup(user1.umndid, g);
      })
      .then(() => {
        // visit the group member's page
        cy.visit(`/shortener/groups/${group.id}/members`);
      });
  });

  it("should show the current user as a member", () => {
    cy.get("#members-table tbody tr").should("have.length", 1);

    // check the user 1 row for correct values
    cy.contains(user1.display_name)
      .parent("tr")
      .within(() => {
        cy.get("td").eq(0).should("contain", user1.display_name);
        cy.get("td").eq(1).should("contain", `${user1.internet_id}@umn.edu`);
        cy.get("td").eq(2).should("contain", "Remove");
      });
  });
});
