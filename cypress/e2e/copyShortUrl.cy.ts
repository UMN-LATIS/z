describe("copy short url", () => {
  beforeEach(() => {
    cy.app("clean");
    cy.createUser("testuser").then((user) => {
      cy.createUrl({
        user,
        keyword: "cla",
        url: "https://cla.umn.edu",
      });
    });

    cy.login("testuser");

    // use the Chrome debugger protocol to grant the current browser window
    // access to the clipboard from the current origin
    // https://chromedevtools.github.io/devtools-protocol/tot/Browser/#method-grantPermissions
    // We are using cy.wrap to wait for the promise returned
    // from the Cypress.automation call, so the test continues
    // after the clipboard permission has been granted
    cy.wrap(
      Cypress.automation("remote:debugger:protocol", {
        command: "Browser.grantPermissions",
        params: {
          permissions: ["clipboardReadWrite", "clipboardSanitizedWrite"],
          // make the permission tighter by allowing the current origin only
          // like "http://localhost:56978"
          origin: window.location.origin,
        },
      })
    );
  });

  context("on /shortener/urls", () => {
    beforeEach(() => {
      // visit the urls page
      cy.visit("/shortener/urls");
    });

    it("should copy short url using the url button", () => {
      cy.get('[data-cy="short-url-table-cell"] > .btn')
        .should("be.visible")
        .as("copyButton");

      // use a real click to trigger the copy event
      // rather than the default simulated click
      // which is a JS event
      cy.get("@copyButton").realClick();

      // check that the short url was copied to the clipboard
      cy.window()
        .then(({ navigator }) => navigator.clipboard.readText())
        .then((text) => expect(text).to.contain("/cla"));
    });
  });

  context("on /shortener/urls/:keyword", () => {
    beforeEach(() => {
      // visit the urls page
      cy.visit("/shortener/urls/cla");
    });

    it("should copy short url using the url button", () => {
      cy.get('[data-cy="copy-button"]').should("be.visible").as("copyButton");

      // use a real click to trigger the copy event
      // rather than the default simulated click
      // which is a JS event
      cy.get("@copyButton").realClick();

      // check that the short url was copied to the clipboard
      cy.window()
        .then(({ navigator }) => navigator.clipboard.readText())
        .then((text) => expect(text).to.contain("/cla"));
    });
  });
});
