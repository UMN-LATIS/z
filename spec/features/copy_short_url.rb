require 'rails_helper'

describe 'copy url button ' do
  before do
    @user = FactoryBot.create(:user)
    sign_in(@user)
  end

  describe 'on the urls', js: true do
    before do
      @new_url = FactoryBot.create(:url, group: @user.context_group)
    end

    describe 'index page', js: true do
      before do
        visit urls_path
      end

      describe 'the copy button' do
        it 'is present' do
          expect(page).to have_selector('.clipboard-btn')
        end
      end
    end

    describe 'details page', js: true do
      before do
        @new_url = FactoryBot.create(:url, group: @user.context_group)
        visit url_path(@new_url.keyword)
      end

      describe 'the copy button' do
        it 'is present' do
          expect(page).to have_selector('.clipboard-btn')
        end
      end
    end
  end
end
