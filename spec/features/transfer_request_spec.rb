require 'rails_helper'

describe 'urls index page' do
  before do
    @user = FactoryGirl.create(:user)
    sign_in(@user)
  end

  describe 'creating a transfer request', js: true do
    before do
      visit urls_path
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
        @selected_url = FactoryGirl.create(:url, group: @user.context_group)
        FactoryGirl.create(:url, group: @user.context_group)
        FactoryGirl.create(:url, group: @user.context_group)
        visit urls_path
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

      describe 'with a url selected' do
        before { find("#url-#{@selected_url.id} > .select-checkbox").click }
        describe 'the transfer button' do
          it 'should be enabled' do
            expect(page.find_link('Transfer to user')[:class]).to_not(
              have_content('disabled')
            )
          end
        end

        describe 'clicking the tranfser button' do
          before do
            click_link 'Transfer to user'
            wait_for_ajax
          end

          it 'should display the modal' do
            expect(page).to have_selector('#index-modal', visible: true)
          end

          describe 'filling out the form' do
            describe 'with valid information' do
              before do
                @other_user = FactoryGirl.create(:user)
                first('input#transfer_request_to_group', visible: false).set @other_user.uid
              end

              it 'should create a transfer request' do
                expect do
                  find('#new_transfer_request  input[type="submit"]').click
                  wait_for_ajax
                end.to change(TransferRequest, :count).by(1)
              end

              it 'should display the pending request on your screen' do
                find('#new_transfer_request  input[type="submit"]').click
                wait_for_ajax
                expect(page).to have_content 'Your transfer requests to others'
              end

              it 'should display the pending request on their screen' do
                find('#new_transfer_request  input[type="submit"]').click
                sign_in(@other_user)
                visit urls_path
                expect(page).to have_content 'You have pending transfer requests'
              end

              describe 'user does not exist' do
                let(:new_uid) { 'notauser123456' }
                before do
                  first('input#transfer_request_to_group', visible: false).set new_uid
                end
                it 'should create a new user' do
                  expect do
                    find('#new_transfer_request input[type="submit"]').click
                    wait_for_ajax
                  end.to change(User, :count).by(1)
                end
                it 'should create a transfer request' do
                  expect do
                    find('#new_transfer_request  input[type="submit"]').click
                    wait_for_ajax
                  end.to change(TransferRequest, :count).by(1)
                end
              end
            end

            describe 'with invalid information' do
              let(:new_uid) { '' }
              describe 'uid is blank' do
                before do
                  first('input#transfer_request_to_group', visible: false).set new_uid
                end
                it 'should display an error' do
                  find('#new_transfer_request input[type="submit"]').click
                  wait_for_ajax
                  expect(page).to have_content 'To group must exist'
                end
                it 'should not create a transfer request' do
                  expect do
                    find('#new_transfer_request input[type="submit"]').click
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

  describe 'intereacting with trasnfer request', js: true do
    before do
      @other_url = FactoryGirl.create(:url)
      @transfer = FactoryGirl.create(
        :transfer_request,
        to_group_id: @user.context_group_id,
        from_group_id: @other_url.group_id,
        urls: [@other_url]
      )
      visit urls_path
    end

    describe 'accepting' do
      it 'should delete the transfer request' do
        expect do
          find('.js-approve-transfer').click
          wait_for_ajax
        end.to change(TransferRequest, :count).by(-1)
      end
      it 'should change the owner of the url' do
        expect do
          find('.js-approve-transfer').click
          wait_for_ajax
          @other_url.reload
        end.to change(@other_url, :group_id).to(@user.context_group_id)
      end
      it 'should display the url in your list' do
        find('.js-approve-transfer').click
        wait_for_ajax
        expect(page).to have_selector("#url-#{@other_url.id}")
      end
    end

    describe 'rejecting' do
      it 'should delete the transfer request' do
        expect do
          find('.js-reject-transfer').click
          wait_for_ajax
        end.to change(TransferRequest, :count).by(-1)
      end
      it 'should not change the owner of the url' do
        expect do
          find('.js-reject-transfer').click
          wait_for_ajax
          @other_url.reload
        end.to_not change(@other_url, :group_id)
      end
      it 'should not display the url in your list' do
        find('.js-reject-transfer').click
        wait_for_ajax
        expect(page).to_not have_selector("#url-#{@other_url.id}")
      end
    end
  end
end
