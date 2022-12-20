/// <reference types="cypress" />

describe("copy short url", () => {
  beforeEach(() => {
    cy.app("clean");

    // create a test user
    cy.appFactories([["create", "user", { uid: "testuser" }]]).then(
      (results) => {
        const user = results[0];

        // create a url for the test user
        cy.appFactories([
          [
            "create",
            "url",
            {
              url: "https://cla.umn.edu",
              group_id: user.context_group_id,
              keyword: "cla",
            },
          ],
        ]);
      }
    );

    // login as testuser
    cy.login({ uid: "testuser" });
  });

  context("on /shortener/urls", () => {
    beforeEach(() => {
      // visit the urls page
      cy.visit("/shortener/urls");
    });

    it("should copy short url using the url button", () => {
      cy.get('[data-cy="short-url-table-cell"] > .btn')
        .should("be.visible")
        .as("copyButton");

      // use a real click to trigger the copy event
      // rather than the default simulated click
      // which is a JS event
      cy.get("@copyButton").realClick();

      // check that the short url was copied to the clipboard
      cy.window()
        .then(({ navigator }) => navigator.clipboard.readText())
        .then((text) => {
          console.log(text);
          expect(text).to.contain("/cla");
        });
    });
  });
});

// require 'rails_helper'

// describe 'copy url button ' do
//   before do
//     @user = FactoryBot.create(:user)
//     sign_in(@user)
//   end

//   describe 'on the urls', js: true do
//     before do
//       @new_url = FactoryBot.create(:url, group: @user.context_group)
//     end

//     describe 'index page', js: true do
//       before do
//         visit urls_path
//       end

//       describe 'the copy button' do
//         it 'is present' do
//           expect(page).to have_selector('.clipboard-btn')
//         end
//       end
//     end

//     describe 'details page', js: true do
//       before do
//         @new_url = FactoryBot.create(:url, group: @user.context_group)
//         visit url_path(@new_url.keyword)
//       end

//       describe 'the copy button' do
//         it 'is present' do
//           expect(page).to have_selector('.clipboard-btn')
//         end
//       end
//     end
//   end
// end
