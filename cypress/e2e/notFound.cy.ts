describe("not found", () => {
  it("shows 404 page for url that does not exist", {}, () => {
    cy.visit("/not-a-real-url", { failOnStatusCode: false });
    cy.contains("404").should("exist");
  });

  it("shows 404 page if url has bad encoding in path", () => {
    cy.visit("/%E0%A4%A", { failOnStatusCode: false });
    cy.contains("404").should("exist");
  });
});
