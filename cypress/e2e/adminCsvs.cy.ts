// fixtures
import user from "../fixtures/users/user1.json";
import admin from "../fixtures/users/admin.json";

describe("admin csv of clicks for urls", () => {
  beforeEach(() => {
    cy.app("clean");
    cy.createUser(admin.umndid, { admin: true });
    cy.createUser(user.umndid)
      .then((user) => {
        // create some user-owned urls
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
      })
      .then(() => cy.clickUrl("cla", 3))
      .then(() => cy.clickUrl("morris", 1));
  });

  context("as an admin user", () => {
    beforeEach(function () {
      cy.login(admin.umndid);

      // since our DB is not populated with data that converts
      // ip addresses to locations, the country code for each click
      // will be null. This causes an error to be thrown when
      // the google chart is generated. So, we catch this error and ignore it.
      cy.on("uncaught:exception", (err, runnable) => {
        if (err.message.includes("google.load is not a function")) {
          return false;
        }
      });
    });

    it("should download a csv of all clicks", () => {
      const claZlinkStatsPage = `/shortener/urls/cla`;

      // this will hold our downloaded csv content
      let csv;

      // set up an intercept to catch the csv download request
      // and then redirect the browser back to the original page
      cy.intercept("GET", "*.csv", (req) => {
        req.reply((res) => {
          csv = res.body;
          // redirect the browser back to the original page
          res.headers.location = claZlinkStatsPage;
          res.send(302);
        });
      }).as("csvDownload");

      // visit the stats page for cla
      cy.visit(claZlinkStatsPage);

      // click the export to csv button and the open the file,
      // then assert that the file contains the correct data
      cy.contains("Export to CSV").click();

      cy.wait("@csvDownload");

      // we should stay on the original URL
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
          const regex = new RegExp(`^https://cla.umn.edu,cla,"",.*$`);
          expect(rows[1], "first record").to.match(regex);
        });
    });
  });
});
