// fixtures
import linkOwner from "../fixtures/users/user1.json";
import admin from "../fixtures/users/admin.json";
import nonOwner from "../fixtures/users/user2.json";
import { validateFlashMessage } from "../support/validateFlashMessage";

const claZlinkStatsPage = `/shortener/urls/cla`;

function validateCSV(csv) {
  cy.location("pathname")
    .should("be.equal", claZlinkStatsPage)
    // validate the csv contents
    .then(() => {
      // using a CSV parser would be better, but this is fine for now
      const rows = csv.trim().split("\n");
      expect(rows, "records + column headers").to.have.length(4);
      expect(rows[0], "column labels").to.equal(
        "url,keyword,country_code,url_created_on"
      );
      expect(rows[1], "first record").to.equal(
        "https://cla.umn.edu,cla,US,01/01/2020"
      );
    });
}

describe("csv of clicks for urls", () => {
  // this will hold our downloaded csv content
  let csv;

  beforeEach(() => {
    csv = null;
    cy.app("clean");
    cy.createUser(linkOwner.umndid)
      .then((user) => {
        // create some user-owned urls
        cy.createUrl({
          keyword: "cla",
          url: "https://cla.umn.edu",
          group_id: user.context_group_id,
        });
      })
      .then(() => {
        cy.clickUrl("cla", 3, { country_code: "US", created_at: "2020-01-01" });
      });

    // set up an intercept to catch the csv download request
    // and then redirect the browser back to the original page
    cy.intercept("GET", "*.csv", (req) => {
      req.reply((res) => {
        csv = res.body;
        // redirect the browser back to the original page
        // it seems to hang if we don't redirect since the focus
        // of cypress is on the download file, not the page
        res.headers.location = claZlinkStatsPage;
        res.send(302);
      });
    }).as("csvDownload");
  });

  context("not an admin or link owner", () => {
    beforeEach(() => {
      cy.createAndLoginUser(nonOwner.umndid);
    });

    it("doesnt allow a user to download a csv of clicks for a url", () => {
      cy.visit(claZlinkStatsPage);

      // it should redirect to the urls page
      cy.location("pathname").should("eq", "/shortener/urls");

      validateFlashMessage("not authorized");
    });
  });

  context("as a link owner", () => {
    beforeEach(() => {
      // login as the link owner
      cy.login(linkOwner.umndid);
    });
    it("downloads a csv of all clicks for a url", () => {
      // visit the stats page for cla
      cy.visit(claZlinkStatsPage);

      // click the export to csv button and the open the file,
      // then assert that the file contains the correct data
      cy.contains("Export to CSV").click();

      // wait for the csv download to complete, then validate
      cy.wait("@csvDownload").then(() => validateCSV(csv));
    });
  });

  context("as an admin user", () => {
    beforeEach(function () {
      cy.createAndLoginUser(admin.umndid, { admin: true });
    });
    it("should download a csv of all clicks", () => {
      // visit the stats page for cla
      cy.visit(claZlinkStatsPage);

      // click the export to csv button and the open the file,
      // then assert that the file contains the correct data
      cy.contains("Export to CSV").click();

      // wait for the csv download to complete
      cy.wait("@csvDownload").then(() => validateCSV(csv));
    });
  });
});
