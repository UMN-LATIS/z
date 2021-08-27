require 'rails_helper'

describe 'as a non-admin user' do
  before do
    @user = FactoryBot.create(:user)
    sign_in(@user)
    visit admin_urls_path
  end

  it 'displays an access violation' do
    expect(page).to have_content 'You are not authorized to perform this action.'
  end
end

describe 'as a valid admin user' do
  before do
    @admin = FactoryBot.create(:admin)
    sign_in(@admin)
  end

  describe 'visiting admin url index' do
    before { visit admin_urls_path }

    it 'display the URL title' do
      expect(page).to have_content 'URLs'
    end

    it 'has the Owner field' do
      expect(page).to have_content 'Owner'
    end

    describe 'with an existing URL', js: true do
      before do
        @url = FactoryBot.create(:url)
        visit admin_urls_path
      end

      it 'displays the actions dropdown button' do
        expect(page).to have_selector('.dropdown .actions-dropdown-button')
      end

      describe 'acting on an existing URL' do
        let(:new_url) { 'http://www.facebook.com' }
        let(:new_keyword) { 'face' }

        describe 'when editing', js: true do
          before do
            find('.dropdown .actions-dropdown-button').click
            find('.dropdown-menu .edit-url').click
          end

          describe 'with new valid content' do
            it 'updates the url in the db' do
              expect(page).to have_css('#url_url')
              find('#url_url').set new_url
              find('.js-url-submit').click
              wait_for_ajax
              expect(@url.reload.url).to eq(new_url)
            end

            it 'updates the keyword in the db' do
              find('#url_keyword').set new_keyword
              find('.js-url-submit').click
              wait_for_ajax
              expect(@url.reload.keyword).to eq(new_keyword)
            end
          end

          describe 'with invalid content' do
            it 'displays an error and does not save upon clicking Create if keyword is already taken', retry: 3 do
              @other_url = FactoryBot.create(:url)
              expect(page).to have_selector('#url_keyword')
              find('#url_keyword').set @other_url.keyword

              expect do
                find('.js-url-submit').click
                expect(page).to have_content('taken')
              end.to change(Url, :count).by(0)
            end
          end
        end

        describe 'when deleting existing url', js: true do
          describe 'clicking delete' do
            it 'deletes the url' do
              expect do
                find('.dropdown .actions-dropdown-button').click
                find('.dropdown-menu .delete-url').click
                click_button "Confirm"
                wait_for_ajax
              end.to change(Url, :count).by(-1)
            end
          end
        end
      end
    end
  end
end
