describe("create zlink in collection", () => {
  let url;
  beforeEach(() => {
    cy.app("clean");
    cy.createUser("testuser").then((user) => {
      url = cy.createUrl({
        keyword: "cla",
        url: "https://cla.umn.edu",
        group_id: user.context_group_id,
      });
    });

    cy.login("testuser");
  });

  it("adds a note to a url", () => {
    cy.visit("/shortener/urls/cla");

    cy.get("#note_note").type("This is a note");
    cy.contains("Save Note").click();

    cy.contains("This is a note").should("exist");
  });
});
