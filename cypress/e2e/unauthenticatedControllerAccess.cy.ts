/**
 * Security regression tests: unauthenticated access to protected controllers.
 *
 * These tests are RED until the authentication fixes are applied. Each test
 * describes the *desired* behavior (redirect to sign-in). Currently several
 * of these will fail because the controllers lack `before_action :ensure_signed_in`.
 *
 * Vulnerability report: vibes/fixes/maryland-sec-vuln-report/vuln-report.md
 * Story: vibes/features/controller-auth-fixes/story.md
 */

import user1 from "../fixtures/users/user1.json";

// In the test environment the OmniAuth developer provider is active.
// ensure_signed_in redirects to /shortener/signin, which immediately
// redirects the browser to /auth/developer (the provider's entry point).
// cy.visit() follows both redirects, so the final pathname is /auth/developer.
const SIGNIN_PATH = "/auth/developer";

// Visits a path with no active session and asserts it redirects to sign-in.
// failOnStatusCode: false prevents Cypress from throwing on 500s that some of
// these controllers currently produce instead of redirecting.
function assertSigninRedirect(path: string) {
  cy.visit(path, { failOnStatusCode: false });
  cy.location("pathname").should("eq", SIGNIN_PATH);
}

describe("Unauthenticated access to protected controllers", () => {
  beforeEach(() => {
    cy.app("clean");
  });

  // -------------------------------------------------------------------------
  // TransferRequestsController
  // Current behavior: NoMethodError crash (current_user is nil)
  // Desired behavior: redirect to sign-in
  // -------------------------------------------------------------------------
  context("TransferRequestsController", () => {
    it("redirects GET /transfer_requests to sign-in", () => {
      assertSigninRedirect("/shortener/transfer_requests");
    });

    it("redirects GET /transfer_requests/new to sign-in", () => {
      assertSigninRedirect("/shortener/transfer_requests/new");
    });
  });

  // -------------------------------------------------------------------------
  // GroupContextController
  // Current behavior: NoMethodError crash (current_user is nil)
  // Desired behavior: redirect to sign-in
  // A valid group id is required — without one, RecordNotFound fires first (404).
  // -------------------------------------------------------------------------
  context("GroupContextController", () => {
    it("redirects GET /group_context/:id to sign-in", () => {
      cy.createUser(user1.umndid).then((user) => {
        assertSigninRedirect(`/shortener/group_context/${user.context_group_id}`);
      });
    });
  });

  // -------------------------------------------------------------------------
  // UrlCsvsController
  // Current behavior: NoMethodError crash (current_user is nil)
  // Desired behavior: redirect to sign-in
  // -------------------------------------------------------------------------
  context("UrlCsvsController", () => {
    it("redirects GET /urls/csv/:duration/:time_unit to sign-in (collection route)", () => {
      assertSigninRedirect("/shortener/urls/csv/7/days");
    });

    // The member route (/urls/:id/csv/click_data) is a separate code path from
    // the collection route above — both need to be guarded.
    it("redirects GET /urls/:id/csv/click_data to sign-in (member route)", () => {
      cy.createUser(user1.umndid).then((user) => {
        cy.createUrl({
          keyword: "auth-test-url",
          url: "https://example.com",
          group_id: user.context_group_id,
        }).then((url) => {
          assertSigninRedirect(`/shortener/urls/${url.id}/csv/click_data`);
        });
      });
    });
  });

  // -------------------------------------------------------------------------
  // BatchDeleteController — CRITICAL
  //
  // #new — current behavior: renders the form with no auth check
  // #create — current behavior: destroys matching URLs, no auth or ownership check
  //
  // Desired behavior: both redirect to sign-in; #create must not mutate data.
  // -------------------------------------------------------------------------
  context("BatchDeleteController (CRITICAL)", () => {
    it("redirects GET /batch_delete/new to sign-in", () => {
      assertSigninRedirect("/shortener/batch_delete/new");
    });

    it("does not delete URLs and redirects to sign-in when POSTing without a session", () => {
      // Set up a URL owned by a real user
      cy.createUser(user1.umndid).then((user) => {
        cy.createUrl({
          keyword: "precious-url",
          url: "https://example.com",
          group_id: user.context_group_id,
        });
      });

      cy.appEval("Url.where(keyword: 'precious-url').count").then((count) => {
        expect(count).to.eq(1);
      });

      // POST without a session — Rails test environment does not enforce CSRF
      // for requests without an established session, so no token is needed.
      cy.request({
        method: "POST",
        url: "/shortener/batch_delete",
        headers: { Accept: "text/javascript" },
        form: true,
        body: { "keywords[]": "precious-url" },
        failOnStatusCode: false,
        followRedirect: false,
      }).then((response) => {
        // After fix: 302 redirect to sign-in
        expect(response.headers["location"]).to.include("signin");
      });

      // The URL must still exist — destruction must not have run
      cy.appEval("Url.where(keyword: 'precious-url').count").then((count) => {
        expect(count).to.eq(1);
      });
    });
  });

  // -------------------------------------------------------------------------
  // Admin::UrlCsvsController
  // Current behavior: Pundit raises NotAuthorizedError → redirects to root (not signin)
  // Desired behavior: explicit redirect to sign-in before Pundit is ever reached
  // -------------------------------------------------------------------------
  context("Admin::UrlCsvsController", () => {
    it("redirects GET /admin/urls/csv/:duration/:time_unit to sign-in", () => {
      assertSigninRedirect("/shortener/admin/urls/csv/7/days");
    });
  });

  // -------------------------------------------------------------------------
  // Admin::TransferRequestsController
  // Current behavior: Pundit raises NotAuthorizedError → redirects to root (not signin)
  // Desired behavior: explicit redirect to sign-in before Pundit is ever reached
  // -------------------------------------------------------------------------
  context("Admin::TransferRequestsController", () => {
    // Note: /admin/transfer_requests (index) is intentionally not tested here.
    // The route exists but Admin::TransferRequestsController has no index action,
    // so AbstractController::ActionNotFound fires before ensure_signed_in can
    // redirect. That is a pre-existing unrelated gap; the security fix covers
    // the actions that actually exist (new and create).
    it("redirects GET /admin/transfer_requests/new to sign-in", () => {
      assertSigninRedirect("/shortener/admin/transfer_requests/new");
    });
  });
});
