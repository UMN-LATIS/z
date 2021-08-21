require 'rails_helper'

def expect_urls_page_to_finish_loading
  expect(page).to have_content('Bulk Actions')
  expect(page).to have_no_content('Processing')
end

describe 'moving urls to a group', js: true do
  before do
    @user = FactoryBot.create(:user)
    sign_in(@user)
    @other_group = FactoryBot.create(:group)
    @user.groups << @other_group
  end

  describe 'accessing html endpoints directly' do
    it 'sends direct html visits to move_to_group/new to not found page' do
      # dont give a 500 error for a missing template
      visit new_move_to_group_path
      expect(page).to have_content('Not Found')
    end
  end

  describe 'page with no urls' do
    it 'has a disabled bulk action button' do
      visit urls_path
      expect_urls_page_to_finish_loading

      expect(page).to have_css('.table-options.disabled')
    end
  end

  describe 'page with urls' do
    before do
      @url = FactoryBot.create(:url, group: @user.context_group)
      visit urls_path
      expect_urls_page_to_finish_loading
    end

    it 'disables bulk action button when no urls are selected' do
      expect(page).to have_css('.table-options.disabled')
    end

    it 'enables bulk actions button when a url is selected' do
      find("#url-#{@url.id} .select-checkbox").click

      expect(page).to have_css('.table-options')
      expect(page).to have_no_css('.table-options.disabled')
    end

    it 'displays the modal clicking the "move group"' do
      find("#url-#{@url.id} .select-checkbox").click
      find('.table-options').click
      click_link 'Move to a different collection'

      expect(page).to have_selector('#index-modal')
    end

    it 'moves the url immediately upon confirming' do
      find("#url-#{@url.id} .select-checkbox").click
      find('.table-options').click
      click_link 'Move to a different collection'
      find('.js-move-group-group button').click
      find('.dropdown-menu.open li', text: @other_group.name).click

      expect do
        find('#move_group  input[type="submit"]').click
        click_button 'Confirm'
        wait_for_ajax
        @url.reload
      end.to change(@url, :group_id).to(@other_group.id)
    end
  end
end
