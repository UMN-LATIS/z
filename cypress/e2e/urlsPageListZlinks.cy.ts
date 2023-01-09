import user from "../fixtures/users/user1.json";
import { validateQRResponse } from "../support/validateQRResponse";

describe("/shortener/urls - list zlinks", () => {
  beforeEach(() => {
    cy.app("clean");
    // create a test user without admin privileges
    cy.createUser(user.umndid)
      .then((u) => {
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

    it.only("can create a new collection from the dropdown and add a url", () => {
      // click the dropdown
      cy.get("#urls-table").contains("cla").closest("tr").as("claRow");
      // open the collection dropdown
      cy.get("@claRow").find("> :nth-child(3) > .dropdown > .btn").click();

      // choose the Create New Collection option
      cy.get("@claRow")
        .find(".dropdown-menu")
        .contains("Create New Collection")
        .click();

      // enter a name and description for the new collection
      cy.get("#group_name").type("testcollection");
      cy.get("#group_description").type("test description");

      // submit
      cy.get("#new_group").submit();

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
      cy.createGroupAndAddUser("testcollection", user);
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

    describe("filter and search the list of z-links", () => {
      beforeEach(() => {
        // create a test collection and add the cla url to it
        cy.createGroupAndAddUser("testcollection", user).then((group) => {
          // add the cla url to the test collection
          cy.addURLToGroup("cla", group);
        });

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

      it("downloads a QR code when clicking on the share > QR Code item", () => {
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
          .contains("Share")
          .realHover()
          .then(() => {
            // click on the QR Code item
            cy.get("@claDropdown").contains("QR Code").click();
          });

        // wait for the download to complete and then validate
        // the response
        cy.wait("@qrDownload").then(() => {
          validateQRResponse(qrResponse, "z-cla.png");
        });
      });
    });
  });
});
