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

    // listen for requests to the people search endpoint
    cy.intercept("/shortener/lookup_users*").as("peopleSearch");

    // create user1 and a url that belongs to user1
    cy.createUser(user1.umndid, { internet_id_loaded: user1.internet_id }).then(
      (user) => {
        cy.createUrl({
          keyword: "user1",
          url: "https://user1url.com",
          group_id: user.context_group_id,
        });

        cy.createUrl({
          keyword: "another-user1-url",
          url: "https://user1.com/b",
          group_id: user.context_group_id,
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
        group_id: admin.context_group_id,
      });
      cy.createUrl({
        keyword: "another-admin-url",
        url: "https://admin.com/b",
        group_id: admin.context_group_id,
      });
    });
    cy.login(admin.umndid);
    cy.visit("/shortener/admin/urls");
  });

  it("choices within bulk actions are disabled if nothing is checked", () => {
    cy.get("#bulk-actions").each(($el) => {
      cy.wrap($el).get("button,a").should("be.disabled");
    });
  });

  it("can transfer a url from user1 to user2 using bulk actions", () => {
    // verify that the owner is user1
    cy.get("table")
      .contains("https://user1url.com")
      .closest("tr")
      .as("user1Row");

    cy.get("@user1Row")
      .get("td:nth-child(4)") // owner column
      .should("contain", "user1");

    // select the url
    cy.get("@user1Row").find(":nth-child(1) > .select-checkbox").check();

    // choose bulk actions and give to
    cy.contains("Bulk Actions").click();
    cy.contains("Transfer to").click();

    // select user2
    cy.get("#person-search").type("user2");

    cy.wait("@peopleSearch");

    // choose user2 from the dropdown
    cy.get('[data-cy="person-search-list"]').contains("Test User 2").click();

    // submit the form
    cy.get('[data-cy="submit-transfer"]').contains("Transfer").click();

    // check the confirm message

    // verify that the owner is now user2
    cy.get("@user1Row").should("contain", "user2");

    // login as user2 and verify that user2 now
    // has the user1 url
    cy.login(user2.umndid);
    cy.visit("/shortener/urls");
    cy.get('[data-cy="short-url-table-cell"]').should("contain", "user1");
  });

  it("does not transfer the url with invalid user selected", () => {
    cy.get("table")
      .contains("https://user1url.com")
      .closest("tr")
      .as("user1Row");

    // select the url
    cy.get("@user1Row").find(":nth-child(1) > .select-checkbox").check();

    // choose bulk actions and give to
    cy.contains("Bulk Actions").click();
    cy.contains("Transfer to").click();

    cy.get("#person-search").type("notauser");

    cy.wait("@peopleSearch");

    // check that the submit button is disabled
    cy.get('[data-cy="submit-transfer"]')
      .contains("Transfer")
      .should("be.disabled");
  });

  it("can transfer to users that show up in lookup, but not have a Z account yet, provisioning the account", () => {
    // select the url
    cy.get("table")
      .contains("https://user1url.com")
      .closest("tr")
      .as("user1Row");

    // select the url
    cy.get("@user1Row").find(":nth-child(1) > .select-checkbox").check();

    // choose bulk actions and give to
    cy.contains("Bulk Actions").click();
    cy.contains("Transfer to").click();

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
    cy.get("#person-search").type("user3");

    cy.wait("@peopleSearch");
    cy.contains("Test User 3").click();

    // submit the form
    cy.get('[data-cy="submit-transfer"]').contains("Transfer").click();

    // verify that the owner is now user3
    cy.get("@user1Row").should("contain", "user3");
    cy.appEval(`User.find_by(uid: "${user3.umndid}")`).then(
      (user) => expect(user).to.not.be.null
    );
  });
});
