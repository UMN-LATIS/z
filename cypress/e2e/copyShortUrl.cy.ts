describe("copy short url", () => {
  beforeEach(() => {
    cy.app("clean");
    cy.createUser("testuser").then((user) => {
      cy.createUrl({
        group_id: user.context_group_id,
        keyword: "cla",
        url: "https://cla.umn.edu",
      });
    });

    cy.login("testuser");
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
