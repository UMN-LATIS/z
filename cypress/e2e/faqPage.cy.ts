describe("FAQ Page", () => {
  beforeEach(() => {
    cy.app("clean");

    // create a FAQ
    cy.appFactories([
      [
        "create",
        "frequently_asked_question",
        {
          header: "General",
          question: "What is Z?",
          answer: "This site is used to shorten URLs.",
        },
      ],
      [
        "create",
        "frequently_asked_question",
        {
          header: "General",
          question: "Should I use it?",
          answer: "Indubitably.",
        },
      ],
    ]);
    cy.visit("/shortener/faq");
  });

  it("should render correctly", () => {
    cy.get("h1").should("contain", "Frequently Asked Questions");

    // two questions
    cy.get(".panel-heading")
      .should("have.length", 2)
      .should("contain", "What is Z?")
      .should("contain", "Should I use it?");

    // answers should be collapsed
    cy.get(".panel-body").should("have.length", 2).should("not.be.visible");

    // click on the first question
    cy.contains("What is Z?").click();

    // answer should be visible
    cy.contains("This site is used to shorten URLs.").should("be.visible");
  });
});
