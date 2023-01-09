describe("not found", () => {
  it("shows 404 page for url that does not exist", {}, () => {
    cy.visit("/not-a-real-url", { failOnStatusCode: false });
    cy.contains("404").should("exist");
  });

  it("shows 404 page if url has bad encoding in path", () => {
    // cy.visit doesn't like bad encoding in the paths
    // so we have to use cy.request
    cy.request({
      method: "GET",
      url: "/%E0%A4%A",
      failOnStatusCode: false,
    }).then((response) => {
      // expect a 404 page
      expect(response.headers["content-type"]).to.contain("text/html");
      expect(response.status).to.eq(404);
      expect(response.body).to.contain("Not Found");
    });
  });

  it("shows Not Found page if query string is malformed", () => {
    cy.visit("/someplace?alsdkjflakjdf%$$$)$%=", { failOnStatusCode: false });
    cy.contains("404").should("exist");
  });
});
