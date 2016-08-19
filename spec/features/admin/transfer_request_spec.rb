require 'rails_helper'

describe 'admin urls index page' do
  before do
    @admin = FactoryGirl.create(:admin)
    sign_in(@admin)
  end

  describe 'creating a transfer request', js: true do
    before do
      visit admin_urls_path
    end

    describe 'with no urls' do
      describe 'the trasnfer button' do
        it 'should be disabled' do
          expect(page.find_link('Transfer to user')[:class]).to(
            have_content('disabled')
          )
        end
      end
    end
    describe 'with urls' do
      before do
        @user = FactoryGirl.create(:user)
        @users_url = FactoryGirl.create(:url, group: @user.context_group)
        @admins_url = FactoryGirl.create(:url, group: @admin.context_group)
        FactoryGirl.create(:url, group: @user.context_group)
        FactoryGirl.create(:url, group: @user.context_group)
        visit admin_urls_path
      end

      describe 'with no urls selected' do
        describe 'the trasnfer button' do
          it 'should be disabled' do
            expect(page.find_link('Transfer to user')[:class]).to(
              have_content('disabled')
            )
          end
        end
      end

      describe 'with urls selected' do
        before do
          find("#url-#{@users_url.id} > .select-checkbox").click
          find("#url-#{@admins_url.id} > .select-checkbox").click
        end
        describe 'the transfer button' do
          it 'should be enabled' do
            expect(page.find_link('Transfer to user')[:class]).to_not(
              have_content('disabled')
            )
          end
        end

        describe 'clicking the tranfser button' do
          before { click_link 'Transfer to user' }

          it 'should display the modal' do
            expect(page).to have_selector('#index-modal', visible: true)
          end

          describe 'filling out the form' do
            describe 'with valid information' do
              before do
                @other_user = FactoryGirl.create(:user)
                find('.js-new-transfer-to-group').set @other_user.uid
              end
              it 'should not create a transfer request' do
                expect do
                  find('#new_transfer_request  input[type="submit"]').click
                  wait_for_ajax
                end.to change(TransferRequest, :count).by(0)
              end
              it 'should transfer admins url immediately' do
                expect do
                  find('#new_transfer_request  input[type="submit"]').click
                  wait_for_ajax
                  @users_url.reload
                end.to change(@users_url, :group_id).to(@other_user.context_group_id)
              end

              it 'should transfer users url immediately' do
                expect do
                  find('#new_transfer_request  input[type="submit"]').click
                  wait_for_ajax
                  @admins_url.reload
                end.to change(@admins_url, :group_id).to(@other_user.context_group_id)
              end
            end

            describe 'with invalid information' do
              describe 'user does not exist' do
                before do
                  find('.js-new-transfer-to-group').set 'notauser123456'
                end
                it 'should display an error' do
                  find('#new_transfer_request  input[type="submit"]').click
                  wait_for_ajax
                  expect(page).to have_content 'To group must exist'
                end
                it 'should not create a transfer request' do
                  expect do
                    find('#new_transfer_request  input[type="submit"]').click
                    wait_for_ajax
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
