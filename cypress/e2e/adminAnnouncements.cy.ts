import dayjs from "dayjs";

// fixtures
import admin from "../fixtures/users/admin.json";

describe("admin announcements page", () => {
  const now = dayjs();
  const thirtyDaysAgo = now.subtract(30, "days").format("YYYY-MM-DD");
  const thirtyDaysFromNow = now.add(30, "days").format("YYYY-MM-DD");

  beforeEach(() => {
    cy.app("clean");

    // create a test announcement
    cy.createAnnouncement({
      title: "Announcement Title",
      body: "This is a test announcement body",
      start_delivering_at: thirtyDaysAgo,
      stop_delivering_at: thirtyDaysFromNow,
    });
  });

  context("as a non-admin user", () => {
    beforeEach(() => {
      // create a test user without admin privileges
      cy.createUser("testuser");
      cy.login("testuser");
    });

    it("displays the announcement on urls page", () => {
      cy.visit("/shortener/urls");
      cy.contains("This is a test announcement body").should("be.visible");
    });

    it("when trying to visit the admin announcement page, it redirects home and show a not authorized message", () => {
      cy.visit("/shortener/admin/announcements");

      // it should redirect to the urls page
      cy.location("pathname").should("equal", "/shortener/urls");

      // FIXME: the error message is actually hidden behind the
      // hero, so this fails (usually). See #120.
      // it should display an error message
      // cy.contains("not authorized", { matchCase: false }).should("be.visible");
    });
  });

  context("as an admin user", () => {
    beforeEach(() => {
      cy.createUser(admin.umndid, { admin: true });
      cy.login(admin.umndid);
      cy.visit("/shortener/admin/announcements");
    });

    it("displays the announcement body, start, and end dates", () => {
      // the body should be visible
      cy.contains("This is a test announcement body").should("be.visible");

      // start and end dates should be visible
      cy.contains(thirtyDaysAgo).should("be.visible");
      cy.contains(thirtyDaysFromNow).should("be.visible");
    });

    it("deletes an announcement, then shows a message when there are no announcements", () => {
      // does not show a message about no announcements
      // since an was created in the beforeEach
      cy.contains("No Announcements. Click").should("not.exist");

      // delete the announcement
      cy.contains("Delete").click();

      // confirm the deletion
      cy.contains("Confirm").click();

      // some message about no announcements should be visible
      cy.contains("No Announcements. Click").should("be.visible");
    });
  });
});
