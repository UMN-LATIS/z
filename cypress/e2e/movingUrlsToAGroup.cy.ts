import user1 from "../fixtures/users/user1.json";

describe("moving urls to a group", () => {
  beforeEach(() => {
    cy.app("clean");
    cy.createUser(user1.umndid).then((user) => {
      return cy.createGroupAndAddUser("group1", user.uid);
    });
    cy.login(user1.umndid);
  });

  it("sends direct visits to move_to_group/new to 404 page", () => {
    cy.visit("/shortener/move_to_group/new", { failOnStatusCode: false });
    cy.contains("404").should("exist");
  });
});
