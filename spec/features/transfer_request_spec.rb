require 'rails_helper'

describe 'creating a transfer request', js: true do
  before do
    @user = FactoryGirl.create(:user)
    sign_in(@user)
  end

  describe 'on the urls index page' do
    before do
      visit urls_path
    end

    describe 'with no urls' do
      describe 'the transfer button' do
        it 'should be disabled' do
          expect(page.find('.js-transfer-urls')[:class]).to(
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
        describe 'the transfer button', js: true do
          it 'should be disabled' do
            expect(page.find('.js-transfer-urls')[:class]).to(
              have_content('disabled')
            )
          end
        end
      end

      describe 'with multiple urls selected' do
        describe 'from different groups' do
          before do
            @new_group = FactoryGirl.create(:group)
            @new_group.users << @user
            @new_group_url = FactoryGirl.create(:url, group: @new_group)
            sign_in @user
            visit urls_path
            find("#url-#{@selected_url.id} > .select-checkbox").click
            find("#url-#{@new_group_url.id} > .select-checkbox").click
            find('.js-transfer-urls').click
            wait_for_ajax
          end

          it 'should display default group url' do
            expect(page).to have_selector(".new_transfer_request input[value='#{@selected_url.keyword}']", visible: false)
          end

          it 'should display new group url' do
            expect(page).to have_selector(".new_transfer_request input[value='#{@new_group_url.keyword}']", visible: false)
          end

          describe 'submitting a transfer request' do
            before do
              @other_user = FactoryGirl.create(:user)
              first('input#transfer_request_to_group', visible: false).set @other_user.uid
              find('#new_transfer_request  input[type="submit"]').click
              click_button 'Confirm'
              wait_for_ajax
            end
            it 'should have all of the urls in the request' do
              expect(TransferRequest.last.urls - [@selected_url, @new_group_url]).to be_empty
            end
          end
        end
      end


      describe 'with a single url selected' do
        before { find("#url-#{@selected_url.id} > .select-checkbox").click }
        describe 'the transfer button' do
          it 'should be enabled' do
            expect(page.find('.js-transfer-urls')[:class]).to_not(
              have_content('disabled')
            )
          end
        end

        describe 'clicking the tranfser button' do
          before do
            page.find('.js-transfer-urls').click
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
                  click_button "Confirm"
                  wait_for_ajax
                end.to change(TransferRequest, :count).by(1)
              end

              it 'should display the pending request on your screen' do
                find('#new_transfer_request  input[type="submit"]').click
                click_button "Confirm"
                wait_for_ajax
                expect(page).to have_content 'URLs you gave that are pending approval'
              end

              it 'should display the pending request on their screen' do
                find('#new_transfer_request  input[type="submit"]').click
                click_button "Confirm"
                sign_in(@other_user)
                visit urls_path
                expect(page).to have_content 'URLs you are being given'
              end

              describe 'user does not exist' do
                let(:new_uid) { 'notauser123456' }
                before do
                  first('input#transfer_request_to_group', visible: false).set new_uid
                end
                it 'should create a new user' do
                  expect do
                    find('#new_transfer_request input[type="submit"]').click
                    click_button "Confirm"
                    wait_for_ajax
                  end.to change(User, :count).by(1)
                end
                it 'should create a transfer request' do
                  expect do
                    find('#new_transfer_request  input[type="submit"]').click
                    click_button "Confirm"
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
                  click_button "Confirm"
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

  describe 'on the urls details', js: true do
    before do
      @url = FactoryGirl.create(:url, group: @user.context_group)
      visit url_path(@url.keyword)
    end

    describe 'the trasnfer button' do
      it 'should be present' do
        expect(page).to have_selector('.js-transfer-urls')
      end

      describe "when clicked" do
        before do
          page.find('.js-transfer-urls').click
          wait_for_ajax
        end

        it 'should display the modal' do
          expect(page).to have_selector('#index-modal', visible: true)
        end
      end
    end
  end

  describe 'intereacting with transfer request', js: true do
    before do
      @other_url = FactoryGirl.create(:url)
      @transfer = FactoryGirl.create(
        :transfer_request,
        to_group_id: @user.context_group_id,
        from_group_id: @other_url.group_id,
        from_user: @other_url.group.users.first,
        urls: [@other_url]
      )
      visit urls_path
    end

    describe 'accepting' do
      it 'should update the status of the transfer request' do
        expect do
          find('.js-approve-transfer').click
          wait_for_ajax
        end.to change(TransferRequest.pending, :count).by(-1)
      end
      it 'should change the status of the transfer to approved' do
        expect do
          find('.js-approve-transfer').click
          wait_for_ajax
          @transfer.reload
        end.to change(@transfer, :status).to('approved')
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
      it 'should change the status of the the transfer request' do
        expect do
          find('.js-reject-transfer').click
          click_button "Confirm"
          wait_for_ajax
        end.to change(TransferRequest.pending, :count).by(-1)
      end
      it 'should change the status of the transfer to rejected' do
        expect do
          find('.js-reject-transfer').click
          click_button "Confirm"
          wait_for_ajax
          @transfer.reload
        end.to change(@transfer, :status).to('rejected')
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
