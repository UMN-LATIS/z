require 'rails_helper'

describe 'as a non-admin user' do
  before do
    @user = FactoryGirl.create(:user)
    sign_in(@user)
    visit admin_urls_path
  end

  # Permissions not yet implemented
  it 'should display an access violation'
end

describe 'as a valid admin user' do
  before do
    @admin = FactoryGirl.create(:admin)
    sign_in(@admin)
  end

  describe 'visiting admin url index' do
    before { visit admin_urls_path }
    it 'display the URL title' do
      expect(page).to have_content 'Urls'
    end

    it 'should have the Owner field' do
      expect(page).to have_content 'Owner'
    end

    describe 'with an existing URL', js: true do
      before do
        @url = FactoryGirl.create(:url)
        visit admin_urls_path
      end

      it 'should display an edit button' do
        expect(page).to have_content 'Edit'
      end
      it 'should display a delete button' do
        expect(page).to have_content 'Delete'
      end

      describe 'acting on an existing URL' do
        let(:new_url) { 'http://www.facebook.com' }
        let(:new_keyword) { 'face' }

        describe 'when editing', js: true do
          before { find('.edit-url').click }

          describe 'with new valid content' do
            it 'should update the url in the db' do
              find('#url_url').set new_url
              find('.js-url-submit').click
              wait_for_ajax
              expect(@url.reload.url).to eq(new_url)
            end
            it 'should update the keyword in the db' do
              find('#url_keyword').set new_keyword
              find('.js-url-submit').click
              wait_for_ajax
              expect(@url.reload.keyword).to eq(new_keyword)
            end
          end
          describe 'with invalid content' do
            describe '[keyword]' do
              describe 'already taken' do
                before do
                  @other_url = FactoryGirl.create(:url)
                  find('#url_keyword').set @other_url.keyword
                end
                it 'should not save upon clicking Create' do
                  expect do
                    find('.js-url-submit').click
                    wait_for_ajax
                  end.to change(Url, :count).by(0)
                end
                it 'should display an error' do
                  find('.js-url-submit').click
                  wait_for_ajax
                  expect(page).to have_content('taken')
                end
              end
            end
          end
        end

        describe 'when deleting existing url', js: true do
          describe 'clicking delete' do
            it 'should delete the url' do
              expect do
                find('.delete-url').click
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
