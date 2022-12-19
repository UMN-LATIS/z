/// <reference types="cypress" />

describe("z happy path", () => {
  beforeEach(() => {
    // have a look at cypress/app_commands/clean.rb
    cy.app("clean");

    // create a non-admin test user using factory_bot
    cy.appFactories([["create", "user", { uid: "testuser" }]]);
    cy.visit("/");
  });

  it("z happy path", () => {
    cy.get('[data-cy="hero-title"]').should("contain.text", "What will you Z?");
    cy.contains("Sign In to Z").click();

    // login (developer auth)
    cy.get("#email").type("testuser");
    cy.contains("Sign In").click();

    // check that we are at /shortener/urls
    cy.url().should("include", "/shortener/urls");

    // create a new short url
    cy.get("#url_url").type("https://cla.umn.edu");
    cy.get("#url_keyword").type("cla");
    cy.contains("Z-Link It").click();

    // check that the url is on our list
    cy.get('[data-cy="long-url-table-cell"] > a').should(
      "contain.text",
      "https://cla.umn.edu"
    );

    cy.get('[data-cy="short-url-table-cell"] > a')
      .should("contain.text", "/cla")
      // remove the target="_blank" attribute so that the link opens in
      // the same window
      .invoke("removeAttr", "target")
      .click();

    // check that we were redirected to the long url after click
    // cy.origin lets us test code that runs on a different origin (cla.umn.edu)
    // than our app
    cy.origin("https://cla.umn.edu", () => {
      // ignore any uncaught exceptions that happen on cla.umn.edu
      cy.on("uncaught:exception", (e) => false);
      // check that we were redirected to the long url
      cy.url().should("include", "https://cla.umn.edu");
    });
  });
});
