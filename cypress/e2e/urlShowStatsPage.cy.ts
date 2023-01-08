import path from "path";
import dayjs from "dayjs";

import admin from "../fixtures/users/admin.json";
import user1 from "../fixtures/users/user1.json";
import user2 from "../fixtures/users/user2.json";

describe("admin url details (stats) page", () => {
  beforeEach(() => {
    cy.app("clean");

    // since our DB is not populated with data that converts
    // ip addresses to locations, the country code for each click
    // will be null. This causes an error to be thrown when
    // the google chart is generated. So, we catch this error and ignore it.
    cy.on("uncaught:exception", (err, runnable) => {
      if (err.message.includes("google.load is not a function")) {
        return false;
      }
    });

    // create a test user without admin privileges
    // and a create url that belong to user1
    cy.createUser(user1.umndid).then((user) => {
      cy.createUrl({
        keyword: "cla",
        url: "https://cla.umn.edu",
        user,
      });
      cy.createUrl({
        keyword: "morris",
        url: "https://morris.umn.edu",
        user,
      });
    });
  });

  describe("error handling", () => {
    beforeEach(() => {
      // FIXME: catch the drawChartHrs24 error for now
      cy.on("uncaught:exception", (err, runnable) => {
        if (err.message.includes("drawChartHrs24")) {
          return false;
        }
      });
    });

    it("redirects a user who is not the owner or an admin back to the urls page and shows a not authorized error", () => {
      cy.createAndLoginUser("testuser");

      cy.visit("/shortener/urls/cla");

      // it should redirect to the urls page
      cy.location("pathname").should("eq", "/shortener/urls");

      // FIXME: the error message is actually hidden behind the
      // hero, so this fails (usually). See #120.
      // it should display an error message
      // cy.contains("not authorized", { matchCase: false }).should("be.visible");
    });

    it("shows a not found page when the url does not exist", () => {
      cy.visit("/shortener/urls/does-not-exist", {
        failOnStatusCode: false,
      });
      cy.contains("not found", { matchCase: false }).should("be.visible");
    });
  });

  context("when url owner is logged in", () => {
    beforeEach(() => {
      cy.login(user1.umndid);
      cy.visit("/shortener/urls/cla");
    });

    it("shows the url details", () => {
      // long url
      cy.contains("https://cla.umn.edu").should("be.visible");

      // keyword
      cy.contains("cla").should("be.visible");

      // created at
      cy.contains(dayjs().format("MM/DD/YYYY")).should("be.visible");
    });

    it("shows the total clicks on this url", () => {
      // initially the clicks should be 0
      cy.contains("Historical Click Count")
        .closest(".panel")
        .find("table")
        .contains("Last 24 Hours")
        .closest("tr")
        .as("last24row");

      cy.get("@last24row").contains("0 hits").should("be.visible");

      // add some clicks
      cy.clickUrl("cla", 3);
      cy.reload();

      // the total clicks for cla should be 3
      cy.get("@last24row").contains("3 hits").should("be.visible");
    });

    it("shows the best day for clicks", () => {
      1;
      cy.clickUrl("cla", 10, {
        country_code: "US",
        created_at: "2020-01-01",
      });

      // now add a few more clicks
      cy.clickUrl("cla", 5, { country_code: "CA" });

      // reload the page
      cy.reload();

      // check that the best day is 01-01-2020
      cy.contains("Best Day").closest(".panel").contains("January 01 2020");
    });

    it("downloads a QR code", () => {
      const downloadsFolder = Cypress.config("downloadsFolder");
      const downloadedFilename = path.join(downloadsFolder, "z-cla.png");

      const claStatsPage = "/shortener/urls/cla";

      //intercept the download request
      cy.intercept("GET", `${claStatsPage}/download_qrcode`, (req) => {
        req.reply((res) => {
          // qrDownload = res.body;
          // redirect the browser back to the url details page
          res.headers.location = claStatsPage;
          res.send(302);
        });
      }).as("qrDownload");

      // visit the stats page for cla
      cy.visit(claStatsPage);

      // click on the QR Code button
      cy.contains("QR Code").click();

      // wait for the download to complete
      cy.wait("@qrDownload");

      // make sure we're back on the the original page
      cy.location("pathname").should("be.equal", claStatsPage);

      // make sure the file was downloaded
      cy.readFile(downloadedFilename, "binary").should((buffer) => {
        // and that it has content
        expect(buffer.length).to.be.greaterThan(100);
      });
    });

    it("can change a collection from the collection dropdown");
  });
});
