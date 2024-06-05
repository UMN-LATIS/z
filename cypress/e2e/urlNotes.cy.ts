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

  context("url show page (aka stats page)", () => {
    beforeEach(() => {
      cy.visit("/shortener/urls/cla");
    });

    it("adds a note to a url", () => {
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

    it("limits the note contents to 1000 characters", () => {
      cy.get("[data-cy='note-form']").within(() => {
        cy.get("[data-cy='note-input']").type("a".repeat(1001), { delay: 0 });
        cy.contains("Save").click();
      });

      cy.contains("Note is too long").should("be.visible");
    });
  });

  context("url index page", () => {
    beforeEach(() => {
      cy.visit("/shortener/urls");
    });

    it("edits a note", () => {
      cy.get("#urls-table").contains("cla").closest("tr").as("claRow");
      cy.get("@claRow").find(".dropdown").as("claDropdown");
      cy.get("@claDropdown").find(".actions-dropdown-button").click();
      cy.get("@claDropdown").contains("Edit").click();

      cy.get("[data-cy='note-input']").type("edited note");

      cy.contains("Submit").click();

      // reload the page
      cy.visit("/shortener/urls");

      // check that the note is there
      cy.get("#urls-table").contains("cla").closest("tr").as("claRow");
      cy.get("@claRow").find(".dropdown").as("claDropdown");
      cy.get("@claDropdown").find(".actions-dropdown-button").click();
      cy.get("@claDropdown").contains("Edit").click();
      cy.get("[data-cy='note-input']").should("contain", "edited note");
    });
  });
});
