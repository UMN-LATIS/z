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

  it("adds/removes a group member", () => {
    // search for user 2
    cy.get("#people_search").type(user2.umndid);

    // select user 2 from the dropdown
    cy.get("#search-form .tt-menu").contains(user2.display_name).click();

    // click the add member button
    cy.contains("Add member").click();

    // check that a confirmation message is shown
    cy.get(".modal-body").should("contain", "Are you sure");

    // click the confirm button
    cy.contains("Confirm").click();

    // now there should be two users listed
    cy.get("#members-table tbody tr").should("have.length", 2);

    // and one of them should be user 2
    cy.contains(user2.display_name);

    // now remove user 2
    cy.contains(user2.display_name).closest("tr").contains("Remove").click();

    // verify the confirmation message
    cy.get(".modal-body").should("contain", "Are you sure");

    // click the confirm button
    cy.contains("Confirm").click();

    // now there should be only one user listed
    cy.get("#members-table tbody tr").should("have.length", 1);

    // and it should be user 1
    cy.get("#members-table tbody").should("contain", user1.display_name);
    cy.get("#members-table tbody").should("not.contain", user2.display_name);
  });

  it("prevents empty members from being added", () => {
    cy.contains("Add member").closest("button").should("be.disabled");
  });
});
