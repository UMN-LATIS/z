require 'rails_helper'


# Uses javascript to select an element and set the attribute.
# 
# An alternative to capybara's find and set methods.
# Only selects the first element that matches.
#
#   js_set_attr("#my-hidden-input", "type", "text")
def js_set_attr(selector, attr_name, attr_value)
  js = "document" \
    ".querySelector('#{selector}')" \
    ".setAttribute('#{attr_name}','#{attr_value}')"
  page.execute_script(js)
end

# uses JS to make a hidden input visible
def js_make_input_visible(input_selector)
  js_set_attr(input_selector, "type", "text")
end

describe 'admin urls index page' do
  before do
    @admin = FactoryBot.create(:admin)
    sign_in(@admin)
  end

  describe 'creating a transfer request', js: true do
    before do
      visit admin_urls_path
    end

    describe 'with no urls' do
      describe 'the transfer button' do
        it 'should be disabled' do
          expect(page.find('.table-options')[:class]).to(
              have_content('disabled')
          )
        end
      end
    end
    describe 'with urls' do
      before do
        @user = FactoryBot.create(:user)
        @users_url = FactoryBot.create(:url, group: @user.context_group)
        @admins_url = FactoryBot.create(:url, group: @admin.context_group)
        FactoryBot.create(:url, group: @user.context_group)
        FactoryBot.create(:url, group: @user.context_group)
        visit admin_urls_path
      end
      describe 'as an admin' do
        describe ' and not in the group of of the url' do
          before do
            find("#url-#{@users_url.id} > .select-checkbox").click
            page.find('.table-options').click
            page.find('.js-transfer-urls').click
            @to_user = FactoryBot.create(:user)
            
            # Use JS Make hidden input visible for testing
            # as a workaround for the option "visible: false"
            # which doesn't seem to work on this test
            js_make_input_visible("#transfer_request_to_group")
            first('#transfer_request_to_group').set @to_user.uid
            find('#new_transfer_request  input[type="submit"]').click
            click_button 'Confirm'
            wait_for_ajax
          end
          it 'should have transfered' do
            expect(TransferRequest.find_by(to_group: @to_user.context_group_id).status).to be == 'approved'
          end
        end
        describe 'and in the group of the url' do
          before do
            find("#url-#{@admins_url.id} > .select-checkbox").click
            page.find('.table-options').click
            page.find('.js-transfer-urls').click

            @to_user = FactoryBot.create(:user)
            js_make_input_visible("input#transfer_request_to_group")
            first('input#transfer_request_to_group').set @to_user.uid
            find('#new_transfer_request  input[type="submit"]').click
            click_button 'Confirm'

          end
          it 'should not have transferred' do
            expect(@admin.context_group.urls.count).to be == 1
          end
        end
      end
      describe 'with no urls selected' do
        describe 'the transfer button' do
          it 'should be disabled' do
            expect(page.find('.table-options')[:class]).to(
                have_content('disabled')
            )
          end
        end
      end

      describe 'with urls selected' do
        before do
          find("#url-#{@users_url.id} > .select-checkbox").click
        end
        describe 'the transfer button' do
          it 'should be enabled' do
            expect(page.find('.table-options')[:class]).to_not(
                have_content('disabled')
            )
          end
        end

        describe 'clicking the transfer button' do
          before do
            page.find('.table-options').click
            page.find('.js-transfer-urls').click
          end

          it 'should display the modal' do
            expect(page).to have_selector('#index-modal')
          end

          describe 'filling out the form' do
            describe 'with valid information' do
              before do
                @other_user = FactoryBot.create(:user)
                js_make_input_visible("input#transfer_request_to_group")
                first('input#transfer_request_to_group').set @other_user.uid
              end
              it 'should not create a transfer request' do
                expect do
                  find('#new_transfer_request  input[type="submit"]').click
                end.to change(TransferRequest, :count).by(0)
              end
              describe 'user does not exist' do
                let(:new_uid) { 'notauser123456' }
                before do
                  js_make_input_visible("input#transfer_request_to_group")
                  first('input#transfer_request_to_group').set new_uid
                end
                it 'should create a new user' do
                  expect do
                    find('#new_transfer_request input[type="submit"]').click
                    click_button 'Confirm'
                  end.to change(User, :count).by(1)
                end
                it 'should create an approved transfer request to the new user' do
                    find('#new_transfer_request input[type="submit"]').click
                    click_button 'Confirm'
                    user = User.find_by(uid: new_uid)
                    expect(TransferRequest.find_by(to_group: user.context_group_id).status).to be == 'approved'
                    expect(user.context_group.id).to be == TransferRequest.find_by(to_group: user.context_group_id).to_group_id
                end
              end
            end
            describe 'with invalid information' do
              let(:new_uid) { '' }
              describe 'uid is blank' do
                before do
                  js_make_input_visible("input#transfer_request_to_group")
                  first('input#transfer_request_to_group').set new_uid
                end
                it 'should display an error' do
                  find('#new_transfer_request input[type="submit"]').click
                  click_button "Confirm"
                  expect(page).to have_content 'To group must exist'
                end
                it 'should not create a transfer request' do
                  expect do
                    find('#new_transfer_request input[type="submit"]').click
                  end.to change(TransferRequest, :count).by(0)
                end
              end
            end
          end
        end
      end
    end
  end
end
