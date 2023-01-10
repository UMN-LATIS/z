import { RailsModel } from "../types";
import user1 from "../fixtures/users/user1.json";
import user2 from "../fixtures/users/user2.json";
import { validateFlashMessage } from "../support/validateFlashMessage";

describe("groups: /shortener/groups", () => {
  beforeEach(() => {
    cy.app("clean");
    cy.createAndLoginUser(user1.umndid);
    cy.visit("/shortener/groups");
  });

  it("creates a new group", () => {
    cy.contains("Add New Collection").click();
    cy.get("#group_name").type("Test Group");
    cy.get("#group_description").type("Test Group Description");
    cy.contains("Create Collection").click();

    // verify the group was created
    cy.get("#groups-table tbody tr").should("have.length", 1);
    // check that the first column contains the group name and description
    cy.get("#groups-table tbody tr td:nth-child(1)")
      .should("contain", "Test Group")
      .should("contain", "Test Group Description");

    //check that the second column shows 1 member
    cy.get("#groups-table tbody tr td:nth-child(2)").should("contain", "1");

    // check that the third column shows 0 links
    cy.get("#groups-table tbody tr td:nth-child(3)").should("contain", "0");

    // check that the fourth column shows some date
    cy.get("#groups-table tbody tr td:nth-child(4)")
      .invoke("text")
      .should("match", /\d{2}\/\d{2}\/\d{4}/);
  });

  it("does not create a group with blank name", () => {
    cy.contains("Add New Collection").click();
    cy.get("#group_description").type("Test Group Description");
    cy.contains("Create Collection").click();

    // verify that it shows an error
    cy.get(".error-space").should("contain", "Name can't be blank");

    // verify the group was not created
    cy.reload();
    cy.get("#groups-table tbody tr")
      .should("contain", "Please click the New button to add a collection")
      .should("have.length", 1);
  });

  it("shows the correct members in the collection", () => {
    // create some additional users
    cy.createUser("test1");
    cy.createUser("test2");
    cy.createUser("test3");

    // create a collection and add the current user to it
    cy.createGroup("testcollection").then((group) => {
      cy.addUserToGroup(user1.umndid, group);
      cy.addUserToGroup("test1", group);
      cy.addUserToGroup("test2", group);
      cy.addUserToGroup("test3", group);
    });

    // visit the groups page
    cy.visit("/shortener/groups");

    // check that the second column shows the correct members
    cy.get("#groups-table tbody tr td:nth-child(2)").should("contain", "4");
  });

  it("shows the collections urls when the group name is clicked", () => {
    let group: RailsModel.Group | null = null;
    // create a collection and add the current user to it
    cy.createGroup("testcollection")
      .then((grp) => {
        group = grp;
        cy.addUserToGroup(user1.umndid, grp);
      })
      .then(() => {
        // visit the groups page
        cy.visit("/shortener/groups");

        // click the group name
        cy.get("#groups-table tbody").contains("testcollection").click();

        // // verify that we are on the group urls page
        cy.location("pathname").should("eq", `/shortener/urls?`);
        // check the query string for the group id
        cy.location("search").then((queryString) => {
          const params = new URLSearchParams(queryString);
          expect(params.get("collection")).to.eq(group.id.toString());
        });
      });
  });

  describe("group actions dropdown", () => {
    let group: RailsModel.Group | null = null;

    beforeEach(() => {
      group = null;
      // create a collection and add the current user to it
      cy.createGroup("testcollection").then((g) => {
        group = g;
        cy.addUserToGroup(user1.umndid, g);
      });

      // visit the groups page
      cy.visit("/shortener/groups");
      // open actions dropdown
      cy.get("#groups-table tbody")
        .contains("testcollection")
        .closest("tr")
        .as("testCollectionRow");
      cy.get("@testCollectionRow").find(".actions-dropdown-button").click();
      cy.get("@testCollectionRow").find(".dropdown").as("actionsDropdown");
    });

    it("Members option goes to the members page", () => {
      cy.get("@actionsDropdown").contains("Members").click();

      // we should be on the group members page
      cy.location("pathname").should(
        "eq",
        `/shortener/groups/${group.id}/members`
      );
    });

    it("Edit option lets the user edit the name and description", () => {
      // click the edit option
      cy.get("@actionsDropdown").contains("Edit").click();

      // edit the collection name and description
      cy.get("#group_name").clear().type("New Group Name");
      cy.get("#group_description").clear().type("New Group Description");

      // save the changes
      cy.contains("Edit Collection").click();

      // verify the group was updated
      cy.get("#groups-table tbody tr").should("have.length", 1);
      // check that the first column contains the group name and description
      cy.contains("New Group Name")
        .closest("tr")
        .within(() => {
          cy.get("td").eq(0).should("contain", "New Group Name");
          cy.get("td").eq(0).should("contain", "New Group Description");
        });
    });

    it("Edit does not allow the user to leave the group name blank", () => {
      // click the edit option
      cy.get("@actionsDropdown").contains("Edit").click();

      // edit the collection name and description
      cy.get("#group_name").clear();
      cy.get("#group_description").clear().type("New Group Description");

      // save the changes
      cy.contains("Edit Collection").click();

      // verify that it shows an error
      cy.get(".error-space").should("contain", "Name can't be blank");

      // verify the group was not updated
      cy.reload();
      cy.contains("testcollection").should("exist");
      cy.contains("New Group Name").should("not.exist");
    });

    it("Delete option deletes the group if there are no urls", () => {
      // click the delete option
      cy.get("@actionsDropdown").contains("Delete").click();

      // check the confirm message
      cy.get(".modal-body").contains("Are you sure you want to delete");
      cy.contains("Confirm").click();

      // verify the group was deleted
      cy.get("#groups-table tbody").should("not.contain", "testcollection");
    });

    it("Delete does NOT delete the group if it contains urls", () => {
      // add a url to the group
      cy.createUrl({
        keyword: "thisshouldnotbedeleted",
        url: "https://www.google.com",
        group_id: group.id,
      });

      cy.reload();

      // click the delete option
      cy.get("#groups-table tbody")
        .contains("testcollection")
        .closest("tr")
        .find(".actions-dropdown-button")
        .click();

      // the delete option should be disabled
      cy.get("#groups-table tbody")
        .find(".dropdown")
        .contains("Delete")
        .closest(".btn")
        .should("have.attr", "disabled", "disabled");

      // and even if it wasn't disabled, clicking it should not delete the group

      // enable the delete option and click it
      cy.get("#groups-table tbody")
        .find(".dropdown")
        .contains("Delete")
        .closest(".btn")
        .then(($btn) => {
          $btn.removeAttr("disabled");
        })
        .click();

      cy.contains("Confirm").click();

      // verify the group was not deleted
      cy.reload();
      cy.get("#groups-table tbody").should("contain", "testcollection");
    });
  });

  context("when logged in as another user", () => {
    let group: RailsModel.Group | null = null;

    beforeEach(() => {
      group = null;
      // create a collection and add the current user to it
      cy.createGroup("testcollection").then((g) => {
        group = g;
        cy.addUserToGroup(user1.umndid, g);
      });
    });

    it("does not allow editing of another's group", () => {
      // verify that user1 can see their group
      cy.login(user1.umndid);
      cy.visit("/shortener/groups");
      cy.get("#groups-table tbody").should("contain", "testcollection");

      // verify that user2 cannot see the group
      cy.createAndLoginUser(user2.umndid);
      cy.visit("/shortener/groups");
      cy.get("#groups-table tbody").should("not.contain", "testcollection");

      // even if they access the show page directly
      cy.visit(`/shortener/groups/${group.id}`);

      validateFlashMessage("You are not authorized to perform this action.");

      // verify that they are redirected to the urls home page
      cy.location("pathname").should("eq", "/shortener/urls");
    });
  });
});
