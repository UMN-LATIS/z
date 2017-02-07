require 'rails_helper'

describe 'copy url button ' do
  before do
    @user = FactoryGirl.create(:user)
    sign_in(@user)
  end

  describe 'on the urls', js: true do
    before do
      @new_url = FactoryGirl.create(:url, group: @user.context_group)
    end

    describe 'index page', js: true do
      before do
        visit urls_path
      end

      describe 'the copy button' do
        it 'should be present' do
          expect(page).to have_selector('.clipboard-btn', visible: true)
        end
      end
    end

    describe 'details page', js: true do
      before do
        @new_url = FactoryGirl.create(:url, group: @user.context_group)
        visit "urls/#{@new_url.keyword}"
      end

      describe 'the copy button' do
        it 'should be present' do
          expect(page).to have_selector('.clipboard-btn', visible: true)
        end
      end
    end
  end
end
