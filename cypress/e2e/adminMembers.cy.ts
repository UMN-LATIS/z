// fixtures
import user from "../fixtures/users/user1.json";
import admin from "../fixtures/users/admin.json";
import { validateFlashMessage } from "../support/validateFlashMessage";

describe("admin members index page", () => {
  beforeEach(() => {
    cy.app("clean");
  });

  context("as a non-admin", () => {
    beforeEach(() => {
      // create a test user without admin privileges
      cy.createAndLoginUser(user.umndid);
    });

    it("should not be able to access admin members page", () => {
      cy.visit("/shortener/admin/members");

      // it should redirect to the urls page
      cy.location("pathname").should("eq", "/shortener/urls");

      validateFlashMessage("not authorized");
    });
  });

  context("as an admin", () => {
    beforeEach(() => {
      cy.createAndLoginUser(admin.umndid, { admin: true });
      cy.visit("/shortener/admin/members");
    });

    it("displays the admin member internet_id", function () {
      cy.contains(admin.internet_id).should("be.visible");
    });

    it("displays the admin member display name", function () {
      cy.contains(admin.display_name).should("be.visible");
    });

    it("adds/remove a new admin", () => {
      cy.get("#people_search").type(user.internet_id);

      // select the user from the dropdown
      cy.get(".tt-dataset-people_search").contains(user.internet_id).click();

      // add them as an admin
      cy.contains("Add Admin").click();

      // confirm the add
      cy.contains("Confirm").click();

      // make sure the new admin is displayed
      cy.get("#user-2 > :nth-child(2)").should("have.text", user.internet_id);

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

    it("when removing oneself from the admins, one should not view the admin pages", function () {
      // remove the admin
      cy.get("#user-1").contains("Remove").click();

      // confirm the remove
      cy.get(".modal-body > p").should("contain.text", "Are you sure");
      cy.contains("Confirm").click();

      // check the db: admin is no longer an admin
      cy.appEval(`User.find_by(uid: "${admin.umndid}").admin`).should(
        "eq",
        false
      );

      // it should redirect to the urls page
      cy.location("pathname").should("equal", "/shortener");

      // try to visit the admin members page
      cy.visit("/shortener/admin/members");

      // TODO: this redirects to `shortener/urls` instead of `shortener`. Maybe fix to make it consistent?
      cy.location("pathname").should("eq", "/shortener/urls");
    });
  });
});
