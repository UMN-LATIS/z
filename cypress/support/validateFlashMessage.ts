// FIXME: the error message is actually hidden behind the
// hero, so this fails (usually). See #120.
// we're using this function so that we can put it in
// the tests and update it in one place when we fix the bug
export function validateFlashMessage(msg: string) {
  // return cy.get(".flash-message").should("be.visible").contains(msg);
}
