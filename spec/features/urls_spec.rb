require 'rails_helper'

describe 'urls index page' do
  before { @user = FactoryGirl.create(:user) }

  describe 'creating new url', js: true do
    let(:url) { 'http://www.google.com' }
    let(:keyword) { 'goog' }
    before do
      visit urls_path
      find('.add-new-url').click
      wait_for_ajax
      find('#url_url').set url
      find('#url_keyword').set keyword
    end
    describe 'with valid information' do
      describe 'when both fields are filled in' do
        it 'should save upon clicking Create' do
          expect do
            find('.js-url-submit').click
            wait_for_ajax
          end.to change(Url, :count).by(1)
        end
      end
      describe 'when the keyword is blank' do
        before { find('#url_keyword').set '' }
        it 'should save upon clicking Create' do
          expect do
            find('.js-url-submit').click
            wait_for_ajax
          end.to change(Url, :count).by(1)
        end
      end
    end
    describe 'with invalid information' do
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
      describe '[url]' do
        describe 'missing http/https' do
          before { find('#url_url').set 'google.com' }
          it 'should not save upon clicking Create' do
            expect do
              find('.js-url-submit').click
              wait_for_ajax
            end.to change(Url, :count).by(0)
          end
          it 'should display an error' do
            find('.js-url-submit').click
            wait_for_ajax
            expect(page).to have_content('http')
          end
        end
      end
    end
  end

  describe 'with an existing url' do
    let(:new_url) { 'http://www.facebook.com' }
    let(:new_keyword) { 'face' }
    let(:invalid_url) { 'facebook.com' }
    before do
      @url = FactoryGirl.create(:url)
      visit urls_path
    end

    describe 'page content' do
      it 'should display the url\'s url' do
        expect(page).to have_content @url.url
      end
      it 'should display the url\'s keyword' do
        expect(page).to have_content @url.keyword
      end
      it 'should display the url\'s click count' do
        expect(page).to have_content @url.total_clicks
      end
      it 'should display an edit button' do
        expect(page).to have_content 'Edit'
      end
      it 'should display a delete button' do
        expect(page).to have_content 'Edit'
      end
    end

    describe 'when editing existing url', js: true do
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

      describe 'with new invalid content' do
        before { find('#url_url').set invalid_url }

        it 'should not update the url in the db' do
          find('.js-url-submit').click
          wait_for_ajax
          expect(@url.reload.url).to_not eq(invalid_url)
        end
        it 'should display an error' do
          find('.js-url-submit').click
          wait_for_ajax
          expect(page).to have_content('http')
        end
      end
    end

    describe 'when deleting existing url', js: true do
      describe 'clicking delete' do
        it 'should delete the url' do
          expect do
            find('.delete-url').click
            wait_for_ajax
          end.to change(Url, :count).by(-1)
        end
      end
    end
  end
end
