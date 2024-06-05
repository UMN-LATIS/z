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

    cy.get("[data-cy='notes-form']").within(() => {
      cy.get("[data-cy='notes-input']").type("This is a note");
      cy.contains("Save").click();
    });

    // // reload the page
    // cy.visit("/shortener/urls/cla");
    // // check that the note is there
    // cy.get("[data-cy='notes-input']").should("contain", "This is a note");
  });
});
