import user from "../fixtures/users/user1.json";
import { validateQRResponse } from "../support/validateQRResponse";

describe("urlsPageListZlinks - /shortener/urls", () => {
  let testUser;
  beforeEach(() => {
    cy.app("clean");
    // create a test user without admin privileges
    cy.createUser(user.umndid)
      .then((u) => {
        testUser = u;

        // create 2 urls owned by the user
        cy.createUrl({
          keyword: "cla",
          url: "https://cla.umn.edu",
          group_id: u.context_group_id,
          created_at: "2022-03-14",
        });
        cy.createUrl({
          keyword: "morris",
          url: "https://morris.umn.edu",
          group_id: u.context_group_id,
          created_at: "2022-03-15",
        });
      })
      .then(() => {
        // add some clicks to the cla url
        cy.clickUrl("cla", 10, {
          // include country code to silence
          // `google.load is not a function` errors
          country_code: "US",
        });
      });

    // create one url owned by someone else
    // so that we can verify the user only sees their
    // urls
    cy.createUser("testuser").then((u) => {
      cy.createUrl({
        keyword: "anotherusers",
        url: "https://somewhere.com",
        group_id: u.context_group_id,
      });
    });
  });

  context("as a guest (not logged-in)", () => {
    it("redirect to the login page", () => {
      cy.visit("/shortener/urls");
      cy.location("pathname").should("eq", "/auth/developer");
    });
  });

  context("as a user (logged-in)", () => {
    beforeEach(() => {
      cy.login(user.umndid);
      cy.visit("/shortener/urls");
    });
    it("shows a table of user zlinks", () => {
      // check the column headers
      cy.get("#urls-table > thead")
        .should("contain", "Z-Links")
        .should("contain", "Collections")
        .should("contain", "Clicks")
        .should("contain", "Created")
        .should("contain", "Actions");

      // should only have 2 entries
      cy.get("#urls-table > tbody > tr").should("have.length", 2);

      // check the cla row
      cy.get("#urls-table").contains("cla").closest("tr").as("claRow");
      cy.get("@claRow")
        .should("contain", "cla")
        .should("contain", "https://cla.umn.edu")
        .should("contain", "No Collection")
        .should("contain", "03/14/2022");

      // check clicks
      cy.get("@claRow").find("> :nth-child(4)").should("contain", "10");

      // check that the other user's zlink doesn't appear
      cy.get("#urls-table > tbody > tr")
        .contains("anotherusers")
        .should("not.exist");
    });

    it("can create a new collection from the dropdown and add a url", () => {
      // click the dropdown
      cy.get("#urls-table").contains("cla").closest("tr").as("claRow");
      // open the collection dropdown
      cy.get("@claRow").find("> :nth-child(3) > .dropdown > .btn").click();

      // choose the Create New Collection option
      cy.get("@claRow")
        .find(".dropdown-menu")
        .contains("Create New Collection")
        .click();

      // Sometimes cypress doesn't complete typing the full string
      // into the input field. Using `force: true` and manually triggering
      // `input` event to work around this issue.
      cy.get("#group_name")
        .type("testcollection", { force: true })
        .trigger("input");

      cy.get("#group_description")
        .type("test description", { force: true })
        .trigger("input");

      // submit
      cy.contains("Submit").click();
      cy.contains("Confirm").click();

      // verify that the url was added to the collection
      cy.get("@claRow")
        .find("> :nth-child(3)")
        .should("contain", "testcollection");

      // double check the DB for the update
      cy.appEval(`Url.find_by_keyword("cla").group.name`).should(
        "eq",
        "testcollection"
      );
    });

    it("can add a url to an existing collection", () => {
      cy.createGroupAndAddUser("testcollection", user.umndid);
      cy.reload();

      // add the cla url to the test collection
      cy.get("#urls-table").contains("cla").closest("tr").as("claRow");
      // open the collection dropdown
      cy.get("@claRow").find("> :nth-child(3) > .dropdown > .btn").click();

      // choose the test collection
      cy.get("@claRow")
        .find(".dropdown-menu")
        .contains("testcollection")
        .click();

      // verify that the url is now in the collection
      cy.get("@claRow")
        .find("> :nth-child(3)")
        .should("contain", "testcollection");

      // double check the DB for the update
      cy.appEval(`Url.find_by_keyword("cla").group.name`).should(
        "eq",
        "testcollection"
      );
    });

    it("redirects to the user's main urls page if params include a collection that the user does not own", () => {
      cy.createGroup("testcollection").then((group) => {
        cy.visit(`/shortener/urls?collection=${group.id}`, {
          failOnStatusCode: false,
        });

        // should be redirected to the main urls page without
        // the collection param
        cy.location("pathname").should("eq", "/shortener/urls");
        cy.location("search").should("eq", "");

        // expect a flash message
        cy.contains("You do not have permission to access this collection");
      });
    });

    describe("filter and search the list of z-links", () => {
      beforeEach(() => {
        // create a test collection and add the cla url to it
        cy.createGroupAndAddUser("testcollection", user.umndid).then(
          (group) => {
            // add the cla url to the test collection
            cy.addURLToGroup("cla", group);
          }
        );

        // reload the page
        cy.reload();
      });

      it("can filter results by collection dropdown", () => {
        // now try filtering by the test collection
        cy.get("#urls-table_filter > .dropdown > .btn").click();
        cy.get("#urls-table_filter .open > .dropdown-menu")
          .contains("testcollection")
          .click();

        // verify that only the cla url is visible
        cy.get("#urls-table > tbody > tr").should("have.length", 1);
        cy.get("#urls-table").contains("cla");

        // and that morris is not visible since it's not in the collection
        cy.get("#urls-table").contains("morris").should("not.exist");
      });

      it("can filter by entering the url keyword or long url", () => {
        // try filtering by the keyword
        cy.get("#urls-table_filter input").as("filterInput").type("cla");
        cy.get("#urls-table > tbody > tr").should("have.length", 1);
        cy.get("#urls-table").should("contain", "cla");

        // and that morris is not visible
        cy.get("#urls-table").contains("morris").should("not.exist");

        cy.get("@filterInput").clear();

        // both urls should be visible again
        cy.get("#urls-table > tbody > tr").should("have.length", 2);

        // try filtering by the long url
        cy.get("@filterInput").type("cla.umn.edu");
        cy.get("#urls-table > tbody > tr").should("have.length", 1);
        cy.get("#urls-table").should("contain", "cla.umn.edu");

        // and that morris is not visible
        cy.get("#urls-table").contains("morris").should("not.exist");
      });
    });

    describe("url actions dropdown menu", () => {
      beforeEach(() => {
        cy.get("#urls-table").contains("cla").closest("tr").as("claRow");
        cy.get("@claRow").find(".dropdown").as("claDropdown");
        cy.get("@claDropdown").find(".actions-dropdown-button").click();
      });

      it("deletes a zlink", () => {
        // check the dropdown menu contents
        cy.get("@claDropdown").contains("Delete").click();

        //check the confirmation
        cy.get(".modal-body").should("contain", "delete the short URL cla");
        cy.get(".modal-footer").contains("Confirm").click();

        // confirm that url is no longer visible
        cy.get("#urls-table").should("not.contain", "cla");

        // and deleted from the DB
        cy.appEval('Url.find_by_keyword("cla")').should("be.null");
      });

      it("edits a zlink's keyword", () => {
        cy.get("@claDropdown").contains("Edit").click();

        // verify that the keyword is in the edit form
        cy.get("#edit_url_1 #url_keyword")
          .should("have.value", "cla")
          // clear the field and type a new keyword
          .clear()
          .type("newkeyword");

        // submit the form
        cy.contains("Submit").click();

        // confirm that the keyword has changed
        cy.get("@claRow").should("contain", "newkeyword");
      });

      it("goes to the show (stats) page by clicking on the Stats item", () => {
        cy.get("@claDropdown").contains("Stats").click();
        cy.location("pathname").should("eq", "/shortener/urls/cla");
      });

      it("downloads a PNG QR code when clicking on the QR Code > PNG item", () => {
        // set up an intercept for the QR download
        const claStatsPage = "/shortener/urls/cla";
        let qrResponse;

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

        // hover over the share item to open the share submenu
        cy.get("@claDropdown")
          .contains("QR Code")
          .realHover()
          .then(() => {
            // click on the QR Code item
            cy.get("@claDropdown").contains("PNG").click();
          });

        // wait for the download to complete and then validate
        // the response
        cy.wait("@qrDownload").then((interception) => {
          const { body, headers } = qrResponse;

          // check that the server response is not null
          expect(body.byteLength).to.be.greaterThan(100);

          // and that it's a png image
          expect(headers["content-type"]).to.equal("image/png");

          // and that the filename will be z-cla.png
          expect(headers["content-disposition"]).to.match(
            new RegExp(`filename=\"z-cla.png\"`)
          );
        });
      });

      it("downloads an SVG QR code when clicking on the QR Code > SVG item", () => {
        // set up an intercept for the QR download
        const claStatsPage = "/shortener/urls/cla";
        let qrResponse;

        //intercept the download request
        cy.intercept("GET", `${claStatsPage}/download_qrcode.svg`, (req) => {
          req.continue((res) => {
            qrResponse = res;

            // set location to the stats page so that
            // so that the test doesn't timeout
            res.headers.location = claStatsPage;
            res.send(302);
          });
        }).as("qrDownload");

        // hover over the share item to open the share submenu
        cy.get("@claDropdown")
          .contains("QR Code")
          .realHover()
          .then(() => {
            // click on the QR Code item
            cy.get("@claDropdown").contains("SVG").click();
          });

        // wait for the download to complete and then validate
        // the response
        cy.wait("@qrDownload").then(() => {
          const { body, headers } = qrResponse;

          expect(body).to.include("<svg");
          expect(headers["content-type"]).to.equal("image/svg+xml");
          expect(headers["content-disposition"]).to.match(
            new RegExp(`filename=\"z-cla.svg"`)
          );
        });
      });
    });

    describe("pagination", () => {
      it("keeps a user on the same page after saving an edited link", () => {
        // create new urls
        const urls = [];
        for (let i = 1; i <= 40; i++) {
          urls.push([
            "create",
            "url",
            {
              url: `https://example.com/${i}`,
              group_id: testUser.context_group_id,
            },
          ]);
        }
        cy.appFactories(urls);

        // reload the page to see the new urls
        cy.reload();

        // go to the next page
        cy.get(".pagination").contains("Next").click();

        // edit keyword
        cy.get("#urls-table tbody tr:first-child").as("row");
        cy.get("@row").find(".dropdown").as("rowDropdown");
        cy.get("@rowDropdown").find(".actions-dropdown-button").click();
        cy.get("@row").contains("Edit").click();

        // enter
        cy.get('#urls-table [data-cy="inline-edit-form"] #url_keyword')
          .clear()
          .type("updatedkeyword");
        cy.contains("Submit").click();

        // keyword should still be on the page
        // and we haven't navigated back to the first page
        cy.get("#urls-table").contains("updatedkeyword");
      });
    });
  });
});
