import admin from "../fixtures/users/admin.json";
import user1 from "../fixtures/users/user1.json";
import user2 from "../fixtures/users/user2.json";

// don't create this user in beforeEach.
// We'll use it to test that that it's automatically created
// when we transfer a url to it.
import user3 from "../fixtures/users/user3.json";

describe("admin url details (stats) page", () => {
  beforeEach(() => {
    cy.app("clean");

    // create user1 and a url that belongs to user1
    cy.createUser(user1.umndid, { internet_id_loaded: user1.internet_id }).then(
      (user) => {
        cy.createUrl({
          keyword: "user1",
          url: "https://user1url.com",
          user,
        });

        cy.createUrl({
          keyword: "another-user1-url",
          url: "https://user1.com/b",
          user,
        });
      }
    );

    cy.createUser(user2.umndid, { internet_id_loaded: user2.internet_id });
    cy.createUser(admin.umndid, {
      admin: true,
      internet_id_loaded: admin.internet_id,
    }).then((admin) => {
      cy.createUrl({
        keyword: "admin-url",
        url: "https://admin.com",
        user: admin,
      });
      cy.createUrl({
        keyword: "another-admin-url",
        url: "https://admin.com/b",
        user: admin,
      });
    });
    cy.login(admin.umndid);
    cy.visit("/shortener/admin/urls");
  });

  it("has bulk actions disabled if nothing is checked", () => {
    cy.get(".dt-buttons .btn")
      .first()
      .should("contain", "Bulk Actions")
      .should("have.class", "disabled");
  });

  it("can transfer a url from user1 to user2 using bulk actions", () => {
    // verify that the owner is user1
    cy.get("#url-1").should("contain", "user1");

    // select the url
    // TODO: the checkbox isn't really a checkbox,
    // it's just a table cell. I'm sure there are accessibility
    // issues with this.
    cy.get("#url-1").find("td.select-checkbox").click();

    // choose bulk actions and give to
    cy.contains("Bulk Actions").click();
    cy.contains("Give to").click();

    // select user2
    // this is a little hacky because twitter typeahead
    // doesn't seem to pick up on the input, so we force
    // the typing, and then click the input again to
    // trigger typeahead to show the dropdown
    cy.get("#people_search").click().type("user2", { force: true });
    cy.get("#people_search").click();

    // choose user2 from the dropdown
    cy.contains("Test User 2").click();

    // submit the form
    cy.contains("Send URLs").click();

    // check the confirm message
    cy.get(".modal-body").should("contain", "Are you sure");

    cy.contains("Confirm").click();

    // verify that the owner is now user2
    cy.get("#url-1").should("contain", "user2");

    // login as user2 and verify that user2 now
    // has the user1 url
    cy.login(user2.umndid);
    cy.visit("/shortener/urls");
    cy.get('[data-cy="short-url-table-cell"]').should("contain", "user1");
  });

  it("does not transfer the url with invalid user selected", () => {
    // select the url
    // TODO: the checkbox isn't really a checkbox,
    // it's just a table cell. I'm sure there are accessibility
    // issues with this.
    cy.get("#url-1").find("td.select-checkbox").click();

    // choose bulk actions and give to
    cy.contains("Bulk Actions").click();
    cy.contains("Give to").click();

    // select user2
    // this is a little hacky because twitter typeahead
    // doesn't seem to pick up on the input, so we force
    // the typing, and then click the input again to
    // trigger typeahead to show the dropdown
    cy.get("#people_search").click().type("notauser", { force: true });
    cy.get("#people_search").click();

    // submit the form
    cy.contains("Send URLs").click();

    cy.contains("Confirm").click();

    // check that an error is displayed
    cy.get(".modal-body").should("contain", "user must exist");
    // check that the url is still owned by user1
    cy.reload();
    cy.get("#url-1 > :nth-child(3)").should("contain", "user1");

    // login as user2 and verify that user2 does not
    // have the user1 url
    cy.login(user2.umndid);
    cy.visit("/shortener/urls");
    cy.get("table").should("not.contain", "user1");

    // check that there's no transfer request created
    cy.appEval(`TransferRequest.count`).should("eq", 0);
  });

  it("does not automatically transfer a url that is owned by an admin", () => {
    // get a table row with an admin url
    cy.get("table")
      .contains("admin")
      .closest("tr")
      // and now click the checkbox
      .find("td.select-checkbox")
      .click();

    // choose bulk actions and give to
    cy.contains("Bulk Actions").click();
    cy.contains("Give to").click();

    // select user2
    cy.get("#people_search").click().type("user2", { force: true });
    cy.get("#people_search").click();
    cy.contains("Test User 2").click();

    // submit the form
    cy.contains("Send URLs").click();
    cy.contains("Confirm").click();

    // is this a race?
    cy.wait(1000);

    // check that the url is pending approval
    // (and not immediately transferred)
    cy.appEval(`TransferRequest.where("status = 'pending'").count`).should(
      "eq",
      1
    );

    // go to the urls page (not the /admin/urls page)
    cy.visit("/shortener/urls");

    // check that the url is pending approval
    cy.contains("pending approval").should("exist");
    cy.get(".transfer-request-item")
      .should("have.length", 1)
      .should("contain", "user2")
      .should("contain", "https://admin.com");
  });

  it("can transfer to users that show up in lookup, but not have a Z account yet, provisioning the account", () => {
    // select the url
    cy.get("#url-1").find("td.select-checkbox").click();

    // choose bulk actions and give to
    cy.contains("Bulk Actions").click();
    cy.contains("Give to").click();

    // we haven't created an account for user3 yet
    // so let's transfer it to them, and make sure
    // that the account is created

    // verify that user3's account doesn't exist yet
    cy.appEval(`User.find_by(uid: "${user3.umndid}")`).then(
      (user) => expect(user).to.be.null
    );

    // despite not having an account, user3 will show up in
    // our user lookup since User_Lookup_Skeleton.rb will load
    // users from `fixtures/users`. This is similar to how
    // the real UserLookup will load users from LDAP

    // select user3
    cy.get("#people_search").click().type("user3", { force: true });
    cy.get("#people_search").click();
    cy.contains("Test User 3").click();

    // submit the form
    cy.contains("Send URLs").click();
    cy.contains("Confirm").click();

    // check that user3 is now the owner of the url
    cy.contains("user3");

    // check that user3 is now in the database
    cy.appEval(`User.find_by(uid: "${user3.umndid}")`).then(
      (user) => expect(user).to.not.be.null
    );
  });
});
