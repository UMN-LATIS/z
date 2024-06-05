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

    cy.get("[data-cy='note-form']").within(() => {
      cy.get("[data-cy='note-input']").type("This is a note");
      cy.contains("Save").click();
    });

    cy.contains("Note saved").should("be.visible");

    // reload the page
    cy.visit("/shortener/urls/cla");
    // check that the note is there
    cy.get("[data-cy='note-input']").should("contain", "This is a note");
  });

  it('limits the note contents to 1000 characters', () => {
    cy.visit("/shortener/urls/cla");

    cy.get("[data-cy='note-form']").within(() => {
      cy.get("[data-cy='note-input']").type("a".repeat(1001), { delay: 0});
      cy.contains("Save").click();
    });

    cy.contains("Note is too long").should("be.visible");
  })
});
