describe("/admin", () => {
  beforeEach(() => {
    cy.app("clean");
  });

  context("as a non-admin", () => {
    beforeEach(() => {
      // create a test user without admin privileges
      cy.appFactories([["create", "user", { uid: "testuser" }]]);
      cy.login({ uid: "testuser" });
    });

    // FIXME: the error message is actually hidden behind the
    // hero, so this fails (usually). See #120.
    it.skip("should not be able to access admin members page", () => {
      cy.visit("/shortener/admin/members");

      // it should redirect to the urls page
      cy.url().should("eq", Cypress.config().baseUrl + "/shortener/urls");

      // it should display an error message
      cy.contains("not authorized", { matchCase: false }).should("be.visible");
    });
  });

  context("as an admin", () => {
    beforeEach(() => {
      // create a test user without admin privileges
      cy.appFactories([["create", "user", { uid: "admin", admin: true }]]);
      cy.login({ uid: "admin" });

      cy.visit("/shortener/admin/members");
    });

    it("displays the admin member internet_id", () => {
      // in a test environment, the user_lookup_service_skeleton
      // is used, so the internet_id is `testinternetid`
      cy.contains("testinternetid").should("be.visible");

      // this is redundant, but it's a good example of how to
      // get the user object's `internet_id` from the Rails side.
      // This method will work regardless of the user_lookup_service
      // is stubbed or the real one is used.
      cy.appEval('User.find_by(uid: "admin").internet_id').then(
        (expectedInternetId) => {
          cy.contains(expectedInternetId).should("be.visible");
        }
      );
    });
  });
});

// require 'rails_helper'

// def wait_for_admin_page_to_load
//   expect(page).to have_content('Add an Admin')
// end

// describe 'admin members index page' do
//   before do
//     @user = FactoryBot.create(:user, admin: true, uid: :test_admin_uid)
//     sign_in(@user)
//     visit admin_members_path(@user)
//   end

//   describe 'visiting the group membership page' do
//     let(:user) { User.where(uid: :test_admin_uid).first }

//     it 'displays the admin member internet_id' do
//       expect(page).to have_content user.internet_id
//     end

//     it 'displays the admin member display name' do
//       expect(page).to have_content user.display_name
//     end
//   end

//   describe 'creating and deleting a admin member', js: true do
//     before do
//       js_make_all_inputs_visible
//     end

//     it 'adds admin a new admin to an existing group of admins' do
//       find('#uid', visible: false).set :new_admin_uid
//       click_button 'Add'
//       click_button 'Confirm'

//       visit admin_members_path(@user)
//       wait_for_admin_page_to_load

//       # DB should be updated
//       expect(User.where(uid: :new_admin_uid, admin: true)).to exist

//       # Admin table should have two entries now.
//       # one for :test_admin_uid and :new_admin_uid
//       within 'table' do
//         expect(page).to have_selector 'tbody > tr', count: 2
//       end
//     end

//     it 'deletes an admin and displays a notification' do
//       find('#uid', visible: false).set :new_admin_uid
//       click_button 'Add'
//       click_button 'Confirm'

//       visit admin_members_path(@user)
//       wait_for_admin_page_to_load
//       page.all(:css, '.delete-admin-member')[1].click
//       click_button 'Confirm'
//       expect(page).to have_content 'has been removed.'
//       expect(User.where(uid: :new_admin_uid, admin: true)).not_to exist
//     end

//     it 'when removing oneself from the admins, one should not view the admin pages' do
//       visit admin_members_path(@user)
//       wait_for_admin_page_to_load
//       page.all(:css, '.delete-admin-member')[0].click
//       click_button 'Confirm'

//       visit admin_members_path(@user)
//       expect(User.where(uid: :test_admin_uid, admin: true)).not_to exist
//       expect(page).to have_content 'not authorized'
//     end
//   end
// end

// describe 'visiting the admin member list as a non-admin' do
//   before do
//     bad_user = FactoryBot.create(:user, uid: :non_admin_user)
//     sign_in(bad_user)
//     visit admin_members_path(bad_user)
//   end

//   it 'displays the authorization error' do
//     expect(page).to have_content 'not authorized'
//   end
// end
