import path from "path";

const claZlink = {
  keyword: "cla",
  url: "https://cla.umn.edu",
};

const morrisZlink = {
  keyword: "morris",
  url: "https://morris.umn.edu",
};

describe("admin csv of clicks for urls", () => {
  const downloadsFolder = Cypress.config("downloadsFolder");

  beforeEach(() => {
    cy.app("clean")
      .then(() => {
        // load the user and admin fixtures
        cy.fixture("users/user.json").as("user");
        cy.fixture("users/admin.json").as("admin");
      })
      .then(function () {
        // create user and admin user
        // using `this` to get the aliased user and admin
        // objects from the fixtures
        return cy.appFactories([
          ["create", "user", { uid: this.user.umndid }],
          ["create", "user", { uid: this.admin.umndid, admin: true }],
        ]);
      })
      .then(function ([user, admin]) {
        //create some user-owned urls
        return cy.appFactories([
          [
            "create",
            "url",
            {
              ...claZlink,
              group_id: user.context_group_id,
            },
          ],
          [
            "create",
            "url",
            {
              ...morrisZlink,
              group_id: user.context_group_id,
            },
          ],
        ]);
      })
      .then(() => {
        // duplicate the urls a few times so that
        // there's more than one click per url
        const urlsToClick = [
          // repeat the first url 10 times
          ...Array(3).fill(`/${claZlink.keyword}`),
          // repeat the second url 5 times
          ...Array(2).fill(`/${morrisZlink.keyword}`),
        ];

        // now generate a request for each url
        cy.wrap(urlsToClick).each((url) => cy.request(url));
      });
  });

  context("as an admin user", () => {
    beforeEach(function () {
      cy.login({ uid: this.admin.umndid });

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
      const claZlinkStatsPage = `/shortener/urls/${claZlink.keyword}`;

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
          const regex = new RegExp(
            `^${claZlink.url},${claZlink.keyword},"",.*$`
          );
          expect(rows[1], "first record").to.match(regex);
        });
    });
  });
});
