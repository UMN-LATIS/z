/**
 * Ownership scoping tests for bulk action controllers.
 *
 * These tests prove that authenticated users can only preview and operate on
 * URLs belonging to their own groups. Both BatchDeleteController and
 * MoveToGroupController accept `keywords[]` params and query the database
 * directly — without ownership scoping, any authenticated user can target
 * any URL in the system.
 *
 * Tests are RED until ownership scoping is added to these controllers.
 *
 * Story: vibes/features/controller-auth-fixes/story.md
 */

import user1 from "../fixtures/users/user1.json";
import user2 from "../fixtures/users/user2.json";

describe("Ownership scoping on bulk action controllers", () => {
  beforeEach(() => {
    cy.app("clean");

    // user1 owns "victim-url" — user2 should not be able to see or affect it
    cy.createUser(user1.umndid).then((user) => {
      cy.createUrl({
        keyword: "victim-url",
        url: "https://victim.example.com",
        group_id: user.context_group_id,
      });
    });

    // user2 is the attacker — authenticated but does not own "victim-url"
    cy.createAndLoginUser(user2.umndid);
  });

  // ---------------------------------------------------------------------------
  // BatchDeleteController
  // ---------------------------------------------------------------------------
  context("BatchDeleteController", () => {
    context("#new — URL preview", () => {
      it("does not include URLs belonging to other users in the preview", () => {
        // Use "keywords[]" as the key so Rails receives a proper array
        // (Rails expects keywords[]=value, not keywords[0]=value).
        cy.request({
          url: "/shortener/batch_delete/new",
          qs: { "keywords[]": "victim-url" },
          headers: {
            Accept: "text/javascript",
            // Rails blocks JS GET responses without this header to prevent
            // cross-origin script embedding attacks. jQuery/UJS sets it
            // automatically; cy.request does not.
            "X-Requested-With": "XMLHttpRequest",
          },
          failOnStatusCode: false,
        }).then((response) => {
          // Before fix: response body contains "victim-url" (other user's URL shown)
          // After fix: response body does not contain "victim-url"
          expect(response.body).not.to.include("victim-url");
        });
      });
    });

    context("#create — deletion", () => {
      it("does not delete URLs belonging to other users", () => {
        cy.appEval("Url.where(keyword: 'victim-url').count").then((count) => {
          expect(count).to.eq(1);
        });

        // Attempt to delete a URL the attacker does not own.
        // The form is submitted as JS (data-remote: true), so we match that format.
        // Use "keywords[]" so Rails receives a proper array param.
        cy.request({
          method: "POST",
          url: "/shortener/batch_delete",
          headers: { Accept: "text/javascript" },
          form: true,
          body: { "keywords[]": "victim-url" },
          failOnStatusCode: false,
          followRedirect: false,
        });

        // Before fix: victim-url is deleted (destroy_all runs on unscoped query)
        // After fix: victim-url still exists (query scoped to attacker's groups)
        cy.appEval("Url.where(keyword: 'victim-url').count").then((count) => {
          expect(count).to.eq(1);
        });
      });
    });
  });

  // ---------------------------------------------------------------------------
  // MoveToGroupController
  // ---------------------------------------------------------------------------
  context("MoveToGroupController", () => {
    context("#new — URL preview", () => {
      it("does not include URLs belonging to other users in the preview", () => {
        cy.request({
          url: "/shortener/move_to_group/new",
          qs: { "keywords[]": "victim-url" },
          headers: {
            Accept: "text/javascript",
            // Same as above — required to pass Rails' cross-origin JS protection.
            "X-Requested-With": "XMLHttpRequest",
          },
          failOnStatusCode: false,
        }).then((response) => {
          // Before fix: response body contains "victim-url"
          // After fix: response body does not contain "victim-url"
          expect(response.body).not.to.include("victim-url");
        });
      });
    });

    context("#create — reassignment", () => {
      it("does not reassign URLs belonging to other users", () => {
        // Capture the original group before the attack attempt
        cy.appEval("Url.find_by(keyword: 'victim-url').group_id").then(
          (originalGroupId) => {
            // user2 attempts to move victim-url into their own group.
            // We need user2's group id to send as the target.
            cy.appEval(
              `User.find_by(uid: '${user2.umndid}').context_group_id`
            ).then((attackerGroupId) => {
              cy.request({
                method: "POST",
                url: "/shortener/move_to_group",
                headers: { Accept: "text/javascript" },
                form: true,
                body: {
                  "keywords[]": "victim-url",
                  Group: attackerGroupId,
                },
                failOnStatusCode: false,
                followRedirect: false,
              });

              // Before fix: victim-url's group_id is changed (stolen)
              // After fix: victim-url's group_id is unchanged
              cy.appEval("Url.find_by(keyword: 'victim-url').group_id").then(
                (groupIdAfter) => {
                  expect(groupIdAfter).to.eq(originalGroupId);
                }
              );
            });
          }
        );
      });
    });
  });
});
