import user1 from "../fixtures/users/user1.json";

describe("moving urls to a group", () => {
  beforeEach(() => {
    cy.app("clean");
    cy.createUser(user1.umndid).then((user) => {
      cy.createUrl({
        keyword: "cla",
        url: "https://cla.umn.edu",
        group_id: user.context_group_id,
      });

      cy.createUrl({
        keyword: "morris",
        url: "https://morris.umn.edu",
        group_id: user.context_group_id,
      });

      cy.createUrl({
        keyword: "duluth",
        url: "https://duluth.umn.edu",
        group_id: user.context_group_id,
      });
    });
    cy.login(user1.umndid);

    // create a new group. This is required for the "move" option to
    // show up under bulk actions
    cy.createGroupAndAddUser("group1", user1.umndid);
  });

  it("sends direct visits to move_to_group/new to 404 page", () => {
    cy.visit("/shortener/move_to_group/new", { failOnStatusCode: false });
    cy.contains("404").should("exist");
  });

  it("bulk moves urls to a given collection", () => {
    cy.visit("/shortener/urls");
    cy.get("#urls-table").contains("morris").closest("tr").as("morrisRow");
    cy.get("#urls-table").contains("duluth").closest("tr").as("duluthRow");

    // select morris and duluth rows
    cy.get("@morrisRow").find("td.select-checkbox").click();
    cy.get("@duluthRow").find("td.select-checkbox").click();

    // click bulk actions button
    cy.contains("Bulk Actions").click();
    cy.contains("Move to a different collection").click();

    // open the dropdown of collections
    cy.get(".modal-body .dropdown .btn").contains("No Collection").click();

    // select the group1 collection
    cy.get(".modal-body .dropdown .dropdown-menu").contains("group1").click();

    // click the Move button
    cy.get(".modal-footer").contains("Move URLs").click();

    // verify that a confirmation modal appears
    cy.contains("Are you sure you want to move these URLs?").should(
      "be.visible"
    );
    cy.contains("Confirm").click();

    // verify that Morris and Duluth are now in the group1 collection
    cy.get("@morrisRow").contains("group1");
    cy.get("@duluthRow").contains("group1");

    // check the database to verify that the group_id was updated
    cy.appEval(
      `
      Url.find_by_keyword("morris").group.name == "group1" &&
      Url.find_by_keyword("duluth").group.name == "group1"
    `
    ).then((areGroupsCorrect) => {
      expect(areGroupsCorrect).to.be.true;
    });
  });
});
