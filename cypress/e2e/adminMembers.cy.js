describe("/admin", () => {
  beforeEach(() => {
    cy.app("clean");
  });

  context("as a non-admin", () => {
    beforeEach(() => {
      // create a test user without admin privileges
      cy.appFactories([["create", "user", { uid: "testuser" }]]);
      cy.login({ uid: "testuser" });
    });

    // FIXME: the error message is actually hidden behind the
    // hero, so this fails (usually). See #120.
    it.skip("should not be able to access admin members page", () => {
      cy.visit("/shortener/admin/members");

      // it should redirect to the urls page
      cy.url().should("eq", Cypress.config().baseUrl + "/shortener/urls");

      // it should display an error message
      cy.contains("not authorized", { matchCase: false }).should("be.visible");
    });
  });

  context("as an admin", () => {
    beforeEach(() => {
      cy.fixture("users/admin.json")
        .as("admin")
        .then((admin) => {
          cy.appFactories([
            ["create", "user", { uid: admin.umndid, admin: true }],
          ]);
          cy.login({ uid: admin.umndid });
        });

      cy.visit("/shortener/admin/members");
    });

    it("displays the admin member internet_id", function () {
      // this.admin is from the admin fixture with .as('admin') above
      cy.contains(this.admin.internet_id).should("be.visible");
    });

    it("displays the admin member display name", function () {
      cy.contains(this.admin.display_name).should("be.visible");
    });

    it("adds/remove a new admin", () => {
      cy.fixture("users/user.json")
        .as("user")
        .then((user) => {
          // search for a user
          cy.get("#people_search").type(user.internet_id);

          // select the user from the dropdown
          cy.get(".tt-dataset-people_search")
            .contains(user.internet_id)
            .click();

          // add them as an admin
          cy.contains("Add Admin").click();

          // confirm the add
          cy.contains("Confirm").click();

          // make sure the new admin is displayed
          cy.get("#user-2 > :nth-child(2)").should(
            "have.text",
            user.internet_id
          );

          // remove the new admin
          cy.get("#user-2 > :nth-child(3)").contains("Remove").click();

          // confirm the remove
          cy.get(".modal-body > p").should("contain.text", "Are you sure");
          cy.contains("Confirm").click();

          // the new admin should no longer appear
          cy.get("#user-2").should("not.exist");

          // check the db: user is no longer an admin
          cy.appEval(`User.find_by(uid: "${user.umndid}").admin`).should(
            "eq",
            false
          );
        });
    });

    it("when removing oneself from the admins, one should not view the admin pages", function () {
      // remove the admin
      cy.get("#user-1").contains("Remove").click();

      // confirm the remove
      cy.get(".modal-body > p").should("contain.text", "Are you sure");
      cy.contains("Confirm").click();

      // check the db: admin is no longer an admin
      cy.appEval(`User.find_by(uid: "${this.admin.umndid}").admin`).should(
        "eq",
        false
      );

      // it should redirect to the urls page
      cy.url().should("equal", Cypress.config().baseUrl + "/shortener");

      // try to visit the admin members page
      cy.visit("/shortener/admin/members");

      // TODO: this redirects to `shortener/urls` instead of `shortener`. Maybe fix to make it consistent?
      cy.url().should("eq", Cypress.config().baseUrl + "/shortener/urls");
    });
  });
});
