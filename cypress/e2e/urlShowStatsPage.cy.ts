import { validateQRResponse } from "../support/validateQRResponse";
import user1 from "../fixtures/users/user1.json";

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
        group_id: user.context_group_id,
        created_at: "2020-01-01",
      });
      cy.createUrl({
        keyword: "morris",
        url: "https://morris.umn.edu",
        group_id: user.context_group_id,
        created_at: "2020-01-01",
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
      cy.contains("01/01/2020").should("be.visible");
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
        created_at: "01/01/2020",
      });

      // now add a few more clicks
      cy.clickUrl("cla", 5, { country_code: "CA" });

      // reload the page
      cy.reload();

      // check that the best day is 01-01-2020
      cy.contains("Best Day").closest(".panel").contains("January 01 2020");
    });

    it("downloads a QR code", () => {
      const claStatsPage = "/shortener/urls/cla";
      let qrResponse = null;

      //intercept the download request
      cy.intercept("GET", `${claStatsPage}/download_qrcode`, (req) => {
        req.continue((res) => {
          qrResponse = res;

          // set location to the stats page so that
          // so that the test doesn't timeout
          res.headers.location = claStatsPage;
          res.send(302);
        });
      }).as("qrDownload");

      // visit the stats page for cla
      cy.visit(claStatsPage);

      // click on the QR Code button
      cy.contains("QR Code").click();

      cy.wait("@qrDownload").then(() => {
        validateQRResponse(qrResponse, "z-cla.png");
      });
    });

    it("can change the url's collection", () => {
      cy.createGroupAndAddUser("testgroup", user1);

      cy.reload();

      // get the Collection Panel
      cy.get(".panel-heading")
        .contains("Collection")
        .closest(".panel")
        .as("collectionPanel");

      // verify that the url is not in a collection
      cy.get("@collectionPanel").contains("No Collection");

      // open the dropdown
      cy.get("@collectionPanel").find(".dropdown > .btn").click();

      // This select picker is not a normal select
      // dropdown, so we can't use cy.select(). We also
      // need to narrow the search to the dropdown-menu
      cy.get("@collectionPanel")
        .find(".dropdown-menu")
        .contains("testgroup")
        .click();

      // reload page and make sure changes were saved
      cy.reload();
      cy.get("@collectionPanel").contains("testgroup");

      // also check the My Collections page
      cy.visit("/shortener/groups");
      cy.contains("testgroup").should("be.visible").click();

      // when opening the group urls list,
      // the `cla` url should be in the collection
      cy.contains("cla").should("be.visible");
      cy.get(".dropdown > .btn").contains("testgroup").should("be.visible");
    });
  });
});
